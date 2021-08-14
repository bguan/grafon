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

import 'package:audio_session/audio_session.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/texttospeech/v1.dart';
import 'package:grafon/speech_svc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'buffer_audio_src.dart';
import 'grafon_dictionary.dart';
import 'gram_table_widget.dart';
import 'wordgroups_page.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[TexttospeechApi.cloudPlatformScope],
);

/// Main Starting Point of the App.
void main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((r) {
    print('${r.loggerName} ${r.level.name} ${r.time}: ${r.message}');
  });

  runApp(
    MaterialApp(
      title: 'Grafon',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GrafonApp(),
    ),
  );
}

/// This widget is the root of Grafon application.
class GrafonApp extends StatefulWidget {
  GrafonApp({Key? key}) : super(key: key);

  @override
  State createState() => GrafonAppState();
}

/// The state of the main widget.
class GrafonAppState extends State<GrafonApp> {
  static final log = Logger("GrafonAppState");
  static const GITHUB_LINK = 'https://github.com/bguan/grafon';

  final AudioPlayer _player = AudioPlayer();

  TexttospeechApi? _cloudTTS;
  GoogleSignInAccount? _googleAcct;

  late final SpeechService _speechSvc =
      SpeechService(rootBundle, _player, _cloudTTS);

  final _controller = PageController(initialPage: 0);
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _currentPage = _controller.page ?? 0;
      });
    });
    _initAudio();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _googleAcct = account;
      });
      if (_googleAcct != null) {
        _initTTS();
      }
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _initAudio() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      log.warning('Audio error: $e');
    });
  }

  Future<void> _openBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _initTTS() async {
    try {
      _cloudTTS = TexttospeechApi((await _googleSignIn.authenticatedClient())!);
      _speechSvc.cloudTTS = _cloudTTS;
      final request = SynthesizeSpeechRequest.fromJson({
        "input": {
          "ssml": "<speak>Cloud Text to Speech initialized.</speak>",
        },
        "voice": {
          "languageCode": "en-US",
          "name": "en-US-Wavenet-E", //"en-US-Standard-C",
          "ssmlGender": "FEMALE"
        },
        "audioConfig": {"audioEncoding": "MP3"}
      });
      final response = await _cloudTTS!.text.synthesize(request);
      final mp3bytes = response.audioContentAsBytes;
      await _player.setAudioSource(BufferAudioSource(mp3bytes));
      await _player.play();
    } catch (e) {
      log.warning("Error initializing TTS: $e");
    }
  }

  Future<void> _signIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      log.warning(error);
    }
  }

  Future<void> _signOut() async {
    try {
      await _googleSignIn.signOut();
      _googleAcct = null;
      _speechSvc.cloudTTS = null;
    } catch (error) {
      log.warning(error);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    final scheme = Theme.of(ctx).colorScheme;
    final pages = [
      GramTableView(),
      WordGroupsPage(
        "Random Words for Testing...",
        testWords,
      ),
      WordGroupsPage(
        "Core Words",
        coreWords,
      ),
    ];

    return MultiProvider(
      providers: [
        Provider<AudioPlayer>(create: (_) {
          return _player;
        }),
        Provider<GoogleSignInAccount?>(create: (_) {
          return _googleAcct;
        }),
        Provider<TexttospeechApi?>(create: (_) {
          return _cloudTTS;
        }),
        Provider<SpeechService>(create: (_) {
          return _speechSvc;
        })
      ],
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 40,
          title: Text('Grafon Home'),
          leading: IconButton(
            icon: Icon(Icons.help_outline_rounded),
            onPressed: () => _openBrowser(GITHUB_LINK),
          ),
          actions: <Widget>[
            if (_googleAcct == null)
              IconButton(
                icon: const Icon(Icons.login),
                tooltip: 'Login',
                onPressed: () => _signIn(),
              )
            else
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: () => _signOut(),
              ),
          ],
        ),
        body: SafeArea(
          child: PageView(
            scrollDirection: Axis.horizontal,
            controller: _controller,
            children: pages,
          ),
        ),
        bottomSheet: Container(
          height: 38,
          padding: EdgeInsets.all(2),
          alignment: Alignment.topCenter,
          color: scheme.primary,
          child: DotsIndicator(
            dotsCount: pages.length,
            position: _currentPage,
            decorator: DotsDecorator(
              activeColor: Colors.yellowAccent,
              color: scheme.background,
            ),
          ),
        ),
      ),
    );
  }
}
