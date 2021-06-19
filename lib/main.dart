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

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'grafon_dictionary.dart';
import 'gram_table_widget.dart';
import 'word_group_widget.dart';

/// Main Starting Point of the App.
void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((r) {
    print('${r.loggerName} ${r.level.name} ${r.time}: ${r.message}');
  });
  runApp(GrafonApp());
}

/// This widget is the root of Grafon application.
class GrafonApp extends StatelessWidget {
  static final log = Logger("GrafonApp");
  static const GITHUB_LINK = 'https://github.com/bguan/grafon';

  Future<void> _initSpeechGen(FlutterTts flutterTts) async {
    final languages = await flutterTts.getLanguages;
    log.info("FlutterTts supported languages: $languages");
    await flutterTts.setLanguage("en-GB");
    await flutterTts.setSpeechRate(.5);
    await flutterTts.setPitch(1);
  }

  Future<void> _openBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext ctx) {
    final controller = PageController(initialPage: 0);
    final wordViews = [
      WordGroupPage(w),
      WordGroupPage(spiritual),
      WordGroupPage(testGroup),
      WordGroupPage(interpersonalGroup),
      WordGroupPage(numericGroup),
      WordGroupPage(demoGroup),
    ];

    return MaterialApp(
      title: 'Grafon',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MultiProvider(
        providers: [
          Provider<FlutterTts>(create: (_) {
            final speechGen = FlutterTts();
            _initSpeechGen(speechGen);
            return speechGen;
          })
        ],
        child: Scaffold(
          appBar: AppBar(
            title: Text('Grafon Home'),
            leading: IconButton(
              icon: Icon(Icons.help_outline_rounded),
              onPressed: () => _openBrowser(GITHUB_LINK),
            ),
          ),
          body: SafeArea(
            child: PageView(
              scrollDirection: Axis.horizontal,
              controller: controller,
              children: [
                GramTableView(),
                ...wordViews,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
