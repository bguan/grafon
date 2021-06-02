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
import 'package:url_launcher/url_launcher.dart';

import 'grafon_word.dart';
import 'gram_table_widget.dart';
import 'word_group_widget.dart';

/// Main Starting Point of the App.
void main() {
  runApp(GrafonApp());
}

/// This widget is the root of Grafon application.
class GrafonApp extends StatelessWidget {
  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext ctx) {
    final controller = PageController(initialPage: 0);
    final wordViews = [
      WordGroupPage(w),
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
      home: Scaffold(
        appBar: AppBar(
          title: Text('Grafon Home'),
          leading: IconButton(
            icon: Icon(Icons.help_outline_rounded),
            onPressed: () =>
                _launchInBrowser('https://github.com/bguan/grafon'),
          ),
        ),
        body: PageView(
          scrollDirection: Axis.horizontal,
          controller: controller,
          children: [
            GramTableView(),
            ...wordViews,
          ],
        ),
      ),
    );
  }
}
