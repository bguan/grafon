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

library speech_svc;

import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:googleapis/texttospeech/v1.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logging/logging.dart';

import 'buffer_audio_src.dart';
import 'phonetics.dart';

/// Speech Service to play either local or cloud API audio
class SpeechService {
  static final log = Logger("SpeechService");
  final AudioPlayer _player;
  final AssetBundle _bundle;
  TexttospeechApi? _cloudTTS;

  SpeechService(this._bundle, this._player, [this._cloudTTS]);

  set cloudTTS(TexttospeechApi? tts) {
    _cloudTTS = tts;
  }

  Future<void> pronounce(Pronunciation p, {multiStitch = true}) async {
    try {
      List<Syllable> syllables = List.from(p.syllables);
      late final audioSrc;
      if (_cloudTTS != null) {
        final request = SynthesizeSpeechRequest.fromJson({
          "input": {
            "ssml":
                "<speak><phoneme alphabet='ipa' ph='${Pronunciation(syllables)}'>?</phoneme></speak>",
          },
          "voice": {
            "languageCode": "en-US",
            "name": "en-US-Wavenet-H",
            "ssmlGender": "FEMALE"
          },
          "audioConfig": {"audioEncoding": "MP3"}
        });
        final response = await _cloudTTS!.text.synthesize(request);
        final mp3bytes = response.audioContentAsBytes;
        audioSrc = BufferAudioSource(mp3bytes);
      } else if (multiStitch) {
        final allBytes = <int>[];
        for (var i = 0; i < syllables.length; i++) {
          final bytes =
              await _bundle.load("assets/audios/${p.fragmentSequence[i]}.mp3");
          allBytes.addAll(
            trimMP3Frames(
              bytes.buffer.asUint8List(),
              0.0,
              i < syllables.length - 1 ? 0.1 : 0,
            ),
          );
        }
        audioSrc = BufferAudioSource(allBytes);
      } else if (syllables.length == 1) {
        audioSrc = AudioSource.uri(
          Uri.parse("asset:///assets/audios/${syllables.first}.mp3"),
          headers: {
            'Content-Type': 'audio/mpeg',
            'Content-Length': '${syllables.first.durationMillis}'
          },
        );
      } else {
        List<AudioSource> sources = [
          for (var i = 0; i < syllables.length; i++)
            AudioSource.uri(
              Uri.parse("asset:///assets/audios/${p.fragmentSequence[i]}.mp3"),
              headers: {
                'Content-Type': 'audio/mpeg',
                'Content-Length': '${syllables[i].durationMillis}'
              },
            ),
        ];
        audioSrc = ConcatenatingAudioSource(children: sources);
      }
      await _player.setAudioSource(audioSrc);
      await _player.play();
    } catch (e) {
      log.warning("Error playing audio: $e");
    }
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
      backBytePos = (len * (1.0 - backTrimRatio)).floor();
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
