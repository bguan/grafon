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

library word_group_widget;

import 'dart:io';

import 'package:charcode/html_entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'grafon_widget.dart';
import 'grafon_word.dart';
import 'speech_svc.dart';

/// Widget to render a word group as a page
class WordGroupPage extends StatelessWidget {
  final WordGroup wordGroup;

  WordGroupPage(this.wordGroup);

  @override
  Widget build(BuildContext ctx) {
    final speechSvc = ctx.watch<SpeechService>();
    final scheme = Theme.of(ctx).colorScheme;
    final titleStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.normal,
      height: 1.5,
      color: scheme.primaryVariant,
      fontSize: 20,
      fontFamily: "Arial",
    );
    final groupDescStyle = TextStyle(
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.1,
      color: scheme.primaryVariant,
      fontSize: 14,
      fontFamily: "Times",
    );
    final wordDescStyle = groupDescStyle.copyWith(fontSize: 12);
    final voicingStyle = TextStyle(
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.italic,
      height: 1.2,
      color: scheme.primaryVariant,
      fontSize: 12,
      fontFamily: "Noto",
    );

    final genPronunciationText = (p, [isLines = false]) => [
          p.fragmentSequence.join("-"),
          '[$p]',
          '"${p.approxVoice}"',
        ].join(isLines ? '\n' : ' ');
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      alignment: Alignment.topLeft,
                      child: Text(wordGroup.title,
                          textAlign: TextAlign.left, style: titleStyle),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.topLeft,
                      child: Text(wordGroup.description,
                          textAlign: TextAlign.justify, style: groupDescStyle),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      height: 120,
                      width: wordGroup.logo.widthAtHeight(100),
                      child: GestureDetector(
                        onTap: () => speechSvc.pronounce(
                          wordGroup.logo.pronunciation,
                          multiStitch: !kIsWeb && Platform.isIOS,
                        ),
                        child: GrafonTile(
                          wordGroup.logo.renderPlan,
                          height: 60,
                          width: wordGroup.logo.widthAtHeight(60),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        genPronunciationText(
                            wordGroup.logo.pronunciation, false),
                        textAlign: TextAlign.right,
                        style: voicingStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10, width: 10),
          Table(
            border: TableBorder(),
            columnWidths: const <int, TableColumnWidth>{
              0: IntrinsicColumnWidth(),
              1: IntrinsicColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: <TableRow>[
              for (GrafonWord w in wordGroup.values)
                TableRow(
                  children: <Widget>[
                    Container(
                      height: 80,
                      width: w.widthAtHeight(50) + 30,
                      padding: EdgeInsets.all(15),
                      child: GestureDetector(
                        onTap: () => speechSvc.pronounce(
                          w.pronunciation,
                          multiStitch: !kIsWeb && Platform.isIOS,
                        ),
                        child: GrafonTile(
                          w.renderPlan,
                          height: 50,
                          width: w.widthAtHeight(50),
                        ),
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: genPronunciationText(w.pronunciation),
                        style: voicingStyle,
                        children: <TextSpan>[
                          TextSpan(
                              text: ' ${String.fromCharCode($mdash)} ',
                              style: wordDescStyle),
                          if (w.description.isEmpty)
                            TextSpan(text: '${w.key}.', style: wordDescStyle),
                          if (w.description.isNotEmpty)
                            TextSpan(
                                text: '${w.description}.',
                                style: wordDescStyle),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Container(height: 50),
        ],
      ),
    );
  }
}
