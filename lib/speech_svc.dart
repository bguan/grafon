// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

/// Speech generation service
library speech_svc;


import 'package:flutter/services.dart';
import 'package:googleapis/texttospeech/v1.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logging/logging.dart';

import 'buffer_audio_src.dart';
import 'phonetics.dart';

/// Speech Service to play either local or cloud API audio
class SpeechService {
  static final log = Logger("SpeechService");
  static const SILENCE_FILE = "silence.mp3";
  static const TTS_CONFIG = {
    "languageCode": "en-GB", //"en-US", //
    "name": "en-GB-Wavenet-A", //"en-US-Wavenet-H", //
    "ssmlGender": "FEMALE"
  };
  static const PAUSE_DURATION = Duration(milliseconds: 200);
  final AudioPlayer _player;
  final AssetBundle _bundle;
  late final String locale;
  late final AudioSource _silenceAudioFileSrc;
  late final BufferAudioSource _silenceAudioBufferSrc;
  TexttospeechApi? _cloudTTS;

  SpeechService(this._bundle, this._player, [this._cloudTTS]) {
    final speechConfig = TTS_CONFIG;
    locale = speechConfig['languageCode']!;
    _loadSilenceAudio();
  }

  Future<void> _loadSilenceAudio() async {
    final bytes = await _bundle.load("assets/$locale-audios/$SILENCE_FILE");
    _silenceAudioBufferSrc = BufferAudioSource(bytes.buffer.asUint8List());
    _silenceAudioFileSrc = AudioSource.uri(
      Uri.parse("asset:///assets/$locale-audios/$SILENCE_FILE"),
      headers: {'Content-Type': 'audio/mpeg', 'Content-Length': '200'},
    );
  }

  set cloudTTS(TexttospeechApi? tts) {
    _cloudTTS = tts;
  }

  void pronounce(Iterable<Pronunciation> pronunciations, {multiStitch = true}) {
    try {
      if (_cloudTTS != null) {
        _pronounceViaTTS(pronunciations);
      } else {
        _pronounceAsFragments(pronunciations, multiStitch);
      }
    } catch (e) {
      log.warning("Error playing audio: $e");
    }
  }

  Future<void> _pronounceAsFragments(
      Iterable<Pronunciation> pronunciations, multiStitch) async {
    final audios = <AudioSource>[];
    for (var p in pronunciations) {
      List<Syllable> syllables = List.from(p.syllables);
      if (multiStitch) {
        final allBytes = <int>[];
        for (var i = 0; i < syllables.length; i++) {
          final s = syllables[i];
          if (!s.isSilence) {
            final bytes = await _bundle
                .load("assets/$locale-audios/${p.fragmentSequence[i]}.mp3");
            allBytes.addAll(
              trimMP3Frames(
                bytes.buffer.asUint8List(),
                0.0,
                i >= syllables.length - 1 || syllables[i].coda != Coda.NIL
                    ? 0.05
                    : 0.3,
              ),
            );
          }
        }
        audios.add(BufferAudioSource(allBytes));
        audios.add(_silenceAudioBufferSrc);
      } else if (syllables.length == 1 && !syllables.first.isSilence) {
        audios.add(
          AudioSource.uri(
            Uri.parse("asset:///assets/$locale-audios/${syllables.first}.mp3"),
            headers: {
              'Content-Type': 'audio/mpeg',
              'Content-Length': '${syllables.first.durationMillis}'
            },
          ),
        );
        audios.add(_silenceAudioFileSrc);
      } else {
        List<AudioSource> sources = [
          for (var i = 0; i < p.fragmentSequence.length; i++)
            if (!syllables[i].isSilence)
              AudioSource.uri(
                Uri.parse(
                    "asset:///assets/$locale-audios/${p.fragmentSequence[i]}.mp3"),
                headers: {
                  'Content-Type': 'audio/mpeg',
                  'Content-Length': '${syllables[i].durationMillis}'
                },
              ),
        ];
        audios.add(ConcatenatingAudioSource(children: sources));
        audios.add(_silenceAudioFileSrc);
      }
    }

    await _player.setAudioSource(
      audios.length < 2
          ? audios.first
          : ConcatenatingAudioSource(children: audios),
    );
    await _player.play();
  }

  Future<void> _pronounceViaTTS(Iterable<Pronunciation> pronunciations) async {
    String phonemeMarkup(String s) =>
        "<phoneme alphabet='ipa' ph='$s'>.</phoneme><break strength='weak'/>";

    final phonemeMarkups = <String>[];

    for (var p in pronunciations) {
      final phonemes = StringBuffer();
      for (var i = 0; i < p.phonemes.length; i++) {
        if (p.phonemes[i].isEmpty) {
          phonemeMarkups.add(phonemeMarkup(phonemes.toString()));
          phonemes.clear();
        } else {
          phonemes.write(p.phonemes[i]);
        }
      }
      final remainder = phonemes.toString();
      if (remainder.isNotEmpty) phonemeMarkups.add(phonemeMarkup(remainder));
    }
    final ssml = "<speak>\n${phonemeMarkups.join('\n')}</speak>";
    final request = SynthesizeSpeechRequest.fromJson({
      "input": {"ssml": ssml},
      "voice": TTS_CONFIG,
      "audioConfig": {"audioEncoding": "MP3"}
    });
    final response = await _cloudTTS!.text.synthesize(request);
    final mp3bytes = response.audioContentAsBytes;
    await _player.setAudioSource(BufferAudioSource(mp3bytes));
    await _player.play();
  }

  /// trim by ratio from beginning and end of a MP3 bytes along frame boundaries
  Uint8List trimMP3Frames(
    Uint8List input,
    double headTrimRatio,
    double backTrimRatio,
  ) {
    if (headTrimRatio + backTrimRatio >= 1.0) return Uint8List.fromList([]);
    if (headTrimRatio <= 0.0 && backTrimRatio <= 0.0) return input;

    final len = input.lengthInBytes;
    // scan for 12 consecutive bits of 1s as frame marker
    late int headBytePos;
    if (headTrimRatio <= 0.01) {
      headBytePos = 0;
    } else {
      headBytePos = (len * headTrimRatio).floor();
      while (headBytePos < len - 1) {
        if (input[headBytePos] == 0x00FF &&
            input[headBytePos + 1] & 0xFFF0 == 0x00F0) {
          break;
        }
        headBytePos++;
      }
    }
    late int backBytePos;
    if (backTrimRatio <= 0.01) {
      backBytePos = len;
    } else {
      backBytePos = (len * (1.0 - backTrimRatio)).ceil();
      while (backBytePos >= 0) {
        if (input[backBytePos] == 0x00FF &&
            input[backBytePos + 1] & 0xFFF0 == 0x00F0) {
          break;
        }
        backBytePos--;
      }
    }
    return headBytePos >= len || backBytePos <= 0
        ? input
        : Uint8List.sublistView(input, headBytePos, backBytePos);
  }
}
