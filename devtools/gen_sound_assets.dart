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

import 'dart:io';

import 'package:googleapis/texttospeech/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:grafon/phonetics.dart';

/// Main Starting Point of the gen_sound_assets cmdline devtool.
/// launch as command line app in IDE with env variable
/// GOOGLE_APPLICATION_CREDENTIALS=${path to tts-api-creds.json}

Future<void> main() async {
  const TTS_CONFIG = {
    "languageCode": "en-GB", //"en-US", //"en-AU", //
    "name": "en-GB-Wavenet-A", //"en-US-Wavenet-H", //"en-AU-Wavenet-A", //
    "ssmlGender": "FEMALE"
  };

  final httpClient = await clientViaApplicationDefaultCredentials(scopes: [
    TexttospeechApi.cloudPlatformScope,
  ]);
  final speechConfig = TTS_CONFIG;
  final locale = speechConfig['languageCode'];
  final sndArchiveDirPath = 'assets/$locale-audios';
  final sndAssetDirPath = 'assets/$locale-audios';
  final sndAssetDir = Directory(sndAssetDirPath);
  if (!sndAssetDir.existsSync()) {
    sndAssetDir.createSync();
  }

  try {
    final tts = TexttospeechApi(httpClient);
    final voiceList = await tts.voices.list.call();
    final voiceNames = voiceList.voices!.map((v) => v.name);
    print('Received ${voiceNames.length} voices: ' + voiceNames.join(', '));

    var copyCounts = 0;
    var genCounts = 0;

    Future<SynthesizeSpeechResponse> Function(String ssml) synthesize = (ssml) {
      final request = SynthesizeSpeechRequest.fromJson({
        "input": {"ssml": "<speak>$ssml</speak>"},
        "voice": speechConfig,
        "audioConfig": {"audioEncoding": "MP3"}
      });
      return tts.text.synthesize(request);
    };

    for (var cc in Cons.values) {
      for (var v in Vowel.values.where((v) => v != Vowel.NIL)) {
        for (var t in Coda.values) {
          final cn = cc.shortName;
          final vn = v.shortName;
          final tn = t.shortName;
          final s = "$cn$vn$tn";
          final cp = cc.phoneme;
          final vp = v.phoneme;
          final tp = t.phoneme;
          final p = "$cp$vp$tp";

          final archivePath = '$sndArchiveDirPath/$s.mp3';
          final sndFilePath = '$sndAssetDirPath/$s.mp3';
          final archiveFile = File(archivePath);
          if (archiveFile.existsSync()) {
            copyCounts++;
            print("Found $archivePath, copy to $sndFilePath...");
            archiveFile.copySync(sndFilePath);
          } else {
            genCounts++;
            final ssml = "<phoneme alphabet='ipa' ph='$p'>?</phoneme>.";
            print(ssml);
            final mp3bytes = (await synthesize(ssml)).audioContentAsBytes;
            print("Voice response for '$s' is ${mp3bytes.length} bytes.");
            print("About to write to $sndFilePath...");
            final sndFile = await File(sndFilePath).create();
            sndFile.writeAsBytesSync(mp3bytes, flush: true);
            sleep(Duration(milliseconds: 500));
          }
        }
      }
    }
    final msg = "$copyCounts copied, $genCounts sound samples generated.";
    print(msg);
  } finally {
    httpClient.close();
  }
}
