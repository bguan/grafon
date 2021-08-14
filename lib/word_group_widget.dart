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
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'grafon_widget.dart';
import 'grafon_word.dart';
import 'phonetics.dart';
import 'speech_svc.dart';

/// Widget to render a word group
class WordGroupWidget extends StatelessWidget {
  static const LOGO_HEIGHT = 70.0;
  static const WORD_HEIGHT = 50.0;
  static const MIN_CARD_WIDTH = 190.0;
  static const CARD_GAP = 15.0;
  static const STD_PAD = 10.0;

  final WordGroup wordGroup;

  WordGroupWidget(this.wordGroup);

  @override
  Widget build(BuildContext ctx) {
    final speechSvc = ctx.watch<SpeechService>();
    final scheme = Theme.of(ctx).colorScheme;
    final mediaSize = MediaQuery.of(ctx).size;
    final pageWidth = mediaSize.width;
    final cardWidth =
        2 * MIN_CARD_WIDTH > pageWidth ? .6 * pageWidth : MIN_CARD_WIDTH;
    final groupDescStyle = TextStyle(
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.2,
      color: scheme.primaryVariant,
      fontSize: 13,
      fontFamily: "Noto",
    );
    final wordTitleStyle = groupDescStyle.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      height: 1.2,
    );
    final wordDescStyle = groupDescStyle.copyWith(
      fontSize: 12,
      height: 1.2,
    );
    final voicingStyle = TextStyle(
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.italic,
      height: 1.2,
      color: scheme.primaryVariant,
      fontSize: 10,
      fontFamily: "Noto",
    );
    final tinyLineStyle = TextStyle(
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 0.1,
      fontSize: 1,
      fontFamily: "Noto",
    );

    final genVoicing = (Pronunciation p, [bool isLines = false]) => [
          p.fragmentSequence.join(),
          '[$p]',
          '"${p.approxVoice}"',
        ].join(isLines ? '\n' : ' ');

    return Container(
      padding: EdgeInsets.only(left: CARD_GAP, top: STD_PAD),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: LOGO_HEIGHT,
                width: wordGroup.logo.widthAtHeight(LOGO_HEIGHT) + CARD_GAP,
                padding: EdgeInsets.only(right: CARD_GAP),
                child: GestureDetector(
                  onTap: () => speechSvc.pronounce(
                    [wordGroup.logo.pronunciation],
                    multiStitch: !kIsWeb && Platform.isIOS,
                  ),
                  child: GrafonTile(
                    wordGroup.logo.renderPlan,
                    height: LOGO_HEIGHT,
                    width: wordGroup.logo.widthAtHeight(LOGO_HEIGHT),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: pageWidth -
                        wordGroup.logo.widthAtHeight(LOGO_HEIGHT) -
                        2 * CARD_GAP,
                    padding: EdgeInsets.only(right: CARD_GAP),
                    child: Text(
                      genVoicing(wordGroup.logo.pronunciation),
                      style: voicingStyle,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Container(height: STD_PAD),
                  Container(
                    width: pageWidth -
                        wordGroup.logo.widthAtHeight(LOGO_HEIGHT) -
                        2 * CARD_GAP,
                    padding: EdgeInsets.only(right: CARD_GAP),
                    child: Text(
                      wordGroup.description,
                      style: groupDescStyle,
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(height: CARD_GAP),
          Divider(endIndent: CARD_GAP),
          Wrap(
            spacing: CARD_GAP,
            runSpacing: CARD_GAP,
            children: <Widget>[
              for (var w in wordGroup.values)
                Container(
                  width: cardWidth,
                  alignment: Alignment.topLeft,
                  child: RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                      text: "${w.title}${w.description.isEmpty ? '\n' : ''}",
                      style: w.title.isEmpty && w.description.isEmpty
                          ? tinyLineStyle
                          : wordTitleStyle,
                      children: <InlineSpan>[
                        TextSpan(
                          text: w.description.isNotEmpty
                              ? " - ${w.description}\n"
                              : "",
                          style: w.title.isEmpty && w.description.isEmpty
                              ? tinyLineStyle
                              : wordDescStyle,
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.top,
                          child: Container(
                            padding: EdgeInsets.only(
                              top: STD_PAD,
                              right: STD_PAD,
                              bottom: STD_PAD,
                            ),
                            height: WORD_HEIGHT + STD_PAD,
                            width: w.widthAtHeight(WORD_HEIGHT) + STD_PAD,
                            child: GestureDetector(
                              onTap: () => speechSvc.pronounce(
                                [w.pronunciation],
                                multiStitch: !kIsWeb && Platform.isIOS,
                              ),
                              child: GrafonTile(
                                w.renderPlan,
                                height: WORD_HEIGHT,
                                width: w.widthAtHeight(WORD_HEIGHT),
                              ),
                            ),
                          ),
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.top,
                          child: Container(
                            width: w.widthAtHeight(WORD_HEIGHT) > cardWidth / 2
                                ? cardWidth
                                : cardWidth -
                                    STD_PAD -
                                    w.widthAtHeight(WORD_HEIGHT),
                            padding: EdgeInsets.only(top: STD_PAD),
                            child: Text(
                              w.key + '\n\n' + genVoicing(w.pronunciation),
                              style: voicingStyle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
