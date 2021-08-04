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
  final httpClient = await clientViaApplicationDefaultCredentials(scopes: [
    TexttospeechApi.cloudPlatformScope,
  ]);

  final sndAssetDirPath = 'assets/ext'; // 'assets/audios';
  final sndAssetDir = Directory(sndAssetDirPath);
  if (!sndAssetDir.existsSync()) {
    sndAssetDir.createSync();
  }

  try {
    final tts = TexttospeechApi(httpClient);
    final voiceList = await tts.voices.list.call();
    final voiceNames = voiceList.voices!.map((v) => v.name);
    print('Received ${voiceNames.length} voices: ' + voiceNames.join(', '));

    var counts = 0;

    Future<SynthesizeSpeechResponse> Function(String ssml) synthesize = (ssml) {
      final request = SynthesizeSpeechRequest.fromJson({
        "input": {"ssml": "<speak>$ssml</speak>"},
        "voice": {
          "languageCode": "en-US",
          "name": "en-US-Wavenet-E",
          "ssmlGender": "FEMALE"
        },
        "audioConfig": {"audioEncoding": "MP3"}
      });
      return tts.text.synthesize(request);
    };

    for (var cc in [
      ...Cons.values.where((c) => c != Cons.NIL && c != Cons.h),
      Coda.th,
      Coda.ng,
    ]) {
      for (var v in Vowel.values.where((v) => v != Vowel.NIL)) {
        for (var e in Vowel.values) {
          for (var t in Coda.values) {
            counts++;
            late final String cn;
            late final String cp;
            if (cc is Cons) {
              cn = cc.shortName;
              cp = cc.phoneme;
            } else if (cc is Coda) {
              cn = cc.shortName;
              cp = cc.phoneme;
            } else {
              continue;
            }

            final vn = v.shortName;
            final en = e.shortName;
            final tn = t.shortName;
            final s = "$cn$vn$en$tn";
            final vp = v.phoneme;
            final ep = e.shortPhoneme;
            final tp = t.phoneme;
            final p = e == Vowel.NIL ? "$cp$vp$tp" : "$cp$vp $ep$tp";
            final ssml = "<phoneme alphabet='ipa' ph='$p'>?</phoneme>.";
            print(ssml);

            final mp3bytes = (await synthesize(ssml)).audioContentAsBytes;
            print("Voice response for '$s' is ${mp3bytes.length} bytes.");
            final sndFilePath = '$sndAssetDirPath/$s.mp3';
            print("About to write to $sndFilePath...");
            final sndFile = await File(sndFilePath).create();
            sndFile.writeAsBytesSync(mp3bytes, flush: true);
            sleep(Duration(milliseconds: 500));
          }
        }
      }
    }
    final msg = "$counts sound samples generated.";
    print(msg);

    final summaryFilePath = '$sndAssetDirPath/summary.txt';
    final summFile = await File(summaryFilePath).create();
    final summary = '$msg\nVoices:\n' + voiceNames.join('\n');
    summFile.writeAsStringSync(summary, flush: true);
  } finally {
    httpClient.close();
  }
}
