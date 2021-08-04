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

import 'package:googleapis/texttospeech/v1.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logging/logging.dart';

import 'buffer_audio_src.dart';
import 'phonetics.dart';

/// Speech Service to play either local or cloud API audio
class SpeechService {
  static final log = Logger("SpeechService");
  final AudioPlayer _player;
  TexttospeechApi? _cloudTTS;

  SpeechService(this._player, [this._cloudTTS]);

  set cloudTTS(TexttospeechApi? tts) {
    _cloudTTS = tts;
  }

  Future<void> pronounce(Pronunciation p) async {
    try {
      List<Syllable> syllables = List.from(p.syllables);
      late final audioSrc;
      if (syllables.length == 1) {
        audioSrc = AudioSource.uri(
          Uri.parse("asset:///assets/audios/${syllables.first}.mp3"),
          headers: {
            'Content-Type': 'audio/mpeg',
            'Content-Length': '${syllables.first.durationMillis}'
          },
        );
      } else if (_cloudTTS != null) {
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
}
