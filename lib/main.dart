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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/texttospeech/v1.dart';
import 'package:grafon/gram_table.dart';
import 'package:grafon/speech_svc.dart';
// import 'package:intl/intl_browser.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'buffer_audio_src.dart';
import 'constants.dart';
import 'generated/l10n.dart';
import 'grafon_dictionary.dart';
import 'grafon_widget.dart';
import 'grafon_word.dart';
import 'gram_table_widget.dart';
import 'word_groups_page.dart';

/// Main Starting Point of the Grafon App.
void main() async {
  final debug = false;
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((r) {
    print('${r.loggerName} ${r.level.name} ${r.time}: ${r.message}');
  });
  // findSystemLocale(); if web
  runApp(
    MaterialApp(
      title: 'Grafon',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: DEF_FONT,
      ),
      home: debug ? TestApp() : GrafonApp(),
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
    ),
  );
}

class TestApp extends StatelessWidget {
  const TestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final test = CoreWord.def(Quads.Triangle.up.mix(Quads.Branch.down));
    return Center(
      child: GrafonTile(test.renderPlan, height: 100),
    );
  }
}

/// Root widget f Grafon application.
class GrafonApp extends StatefulWidget {
  /// google sign-in service as a shared singleton
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[TexttospeechApi.cloudPlatformScope],
  );

  GrafonApp({Key? key}) : super(key: key);

  @override
  State createState() => GrafonAppState();
}

/// The state of the main widget.
class GrafonAppState extends State<GrafonApp> {
  static final log = Logger("GrafonAppState");
  static const GITHUB_LINK = 'https://github.com/bguan/grafon';

  final _player = AudioPlayer();
  final _gramTable = GramTable();

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
    widget.googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) {
      setState(() {
        _googleAcct = account;
        if (_googleAcct != null) {
          _initTTS();
        }
      });
    });
    widget.googleSignIn.signInSilently();
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
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _initTTS() async {
    try {
      final locale = Localizations.localeOf(context);
      final localeTag = locale.toLanguageTag();
      final langTTS = LANG_TAG_TO_TTS_VOICE.containsKey(localeTag)
          ? localeTag
          : DEF_LANG_TAG;
      final voiceTTS = LANG_TAG_TO_TTS_VOICE[langTTS];
      final l10n = S.of(context);

      _cloudTTS =
          TexttospeechApi((await widget.googleSignIn.authenticatedClient())!);
      _speechSvc.cloudTTS = _cloudTTS;
      final request = SynthesizeSpeechRequest.fromJson({
        "input": {
          "ssml": "<speak>${l10n.app_TTS_enabled_msg}</speak>",
        },
        "voice": {
          "languageCode": langTTS,
          "name": voiceTTS,
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
      await widget.googleSignIn.signIn();
    } catch (error) {
      log.warning(error);
    }
  }

  Future<void> _signOut() async {
    try {
      await widget.googleSignIn.signOut();
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
    final l10n = S.of(ctx);
    final scheme = Theme.of(ctx).colorScheme;
    final theme = Theme.of(ctx).textTheme;
    final pages = [
      GramTableView(),
      WordGroupsPage(l10n.page_core_words_title, coreWords),
      WordGroupsPage(l10n.page_random_words_title, testWords),
    ];
    final inset = 5.0;
    final animDuration = Duration(milliseconds: 200);
    final scrollCurve = Curves.ease;

    final leftButton = IconButton(
      icon: Icon(Icons.arrow_left),
      iconSize: FOOTER_HEIGHT / 2,
      padding: EdgeInsets.all(0),
      color: Colors.white,
      disabledColor: Colors.grey,
      onPressed: () =>
          _controller.previousPage(duration: animDuration, curve: scrollCurve),
    );

    final rightButton = IconButton(
      icon: Icon(Icons.arrow_right),
      iconSize: FOOTER_HEIGHT / 2,
      padding: EdgeInsets.all(0),
      color: Colors.white,
      disabledColor: Colors.grey,
      onPressed: () =>
          _controller.nextPage(duration: animDuration, curve: scrollCurve),
    );

    final pageDots = Container(
      padding: EdgeInsets.only(top: inset),
      child: DotsIndicator(
        dotsCount: pages.length,
        position: _currentPage,
        decorator: DotsDecorator(
          activeColor: Colors.white,
          color: scheme.background,
        ),
      ),
    );

    return MultiProvider(
      providers: [
        Provider<AudioPlayer>(create: (_) => _player),
        Provider<GoogleSignInAccount?>(create: (_) => _googleAcct),
        Provider<TexttospeechApi?>(create: (_) => _cloudTTS),
        Provider<SpeechService>(create: (_) => _speechSvc),
        Provider<GramTable>(create: (_) => _gramTable),
      ],
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: TOOL_BAR_HEIGHT,
          title: Text(
            l10n.app_title,
            style: theme.titleLarge?.copyWith(
              color: scheme.surface,
              fontWeight: FontWeight.bold,
              fontSize: TOOL_BAR_HEIGHT / 1.6,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.help_outline_rounded),
            iconSize: TOOL_BAR_HEIGHT / 2,
            onPressed: () => _openBrowser(GITHUB_LINK),
          ),
          actions: <Widget>[
            if (_googleAcct == null)
              IconButton(
                icon: Icon(Icons.login),
                iconSize: TOOL_BAR_HEIGHT / 2,
                tooltip: l10n.app_login_tooltip,
                onPressed: () => _signIn(),
              )
            else
              IconButton(
                icon: Icon(Icons.logout),
                iconSize: TOOL_BAR_HEIGHT / 2,
                tooltip: l10n.app_logout_tooltip,
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
          height: FOOTER_HEIGHT,
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: inset),
          alignment: Alignment.topCenter,
          color: scheme.primary,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leftButton,
              pageDots,
              rightButton,
            ],
          ),
        ),
      ),
    );
  }
}
