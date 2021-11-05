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

/// Library of widgets to display groups of related words
library word_groups_page;

import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:grafon/constants.dart';
import 'package:provider/provider.dart';

import 'grafon_widget.dart';
import 'grafon_word.dart';
import 'phonetics.dart';
import 'speech_svc.dart';

/// Widget to render multiple word groups on a page as expandable sections
class WordGroupsPage extends StatefulWidget {
  final String title;
  final List<WordGroup> groups;

  WordGroupsPage(this.title, this.groups, {Key? key}) : super(key: key);

  @override
  _WordGroupsPageState createState() =>
      _WordGroupsPageState(this.title, this.groups);

  static String genVoicingLabel(
    Iterable<Pronunciation> ps, [
    bool isLines = false,
  ]) {
    if (ps.isEmpty) return "";

    final fragStr = StringBuffer();
    final phonemeStr = StringBuffer();
    final approxStr = StringBuffer();
    fragStr.write(ps.first.fragmentSequence.join());
    phonemeStr.write(ps.first.phonemes);
    approxStr.write(ps.first.approxVoice);
    for (var p in ps.skip(1)) {
      fragStr
        ..write(' ')
        ..write(p.fragmentSequence.join());
      phonemeStr
        ..write(' ')
        ..write(p.phonemes);
      approxStr
        ..write(' ')
        ..write(p.approxVoice);
    }
    return [
      fragStr.toString(),
      '[$phonemeStr]',
      '"$approxStr"',
    ].join(isLines ? '\n' : ' ');
  }
}

class _WordGroupsPageState extends State<WordGroupsPage> {
  static const LOGO_HEIGHT_SCALE = .1;
  static const WORD_HEIGHT_SCALE = .09;
  static const MIN_CARD_WIDTH = 150.0;
  static const CARD_GAP_SCALE = .05;
  static const STD_PAD = 8.0;

  final String title;
  final List<WordGroup> groups;
  late final List<bool> _expandedFlag;

  _WordGroupsPageState(this.title, this.groups) {
    _expandedFlag = [
      for (var _ in groups) false,
    ];
  }

  @override
  Widget build(BuildContext ctx) {
    final speechSvc = ctx.watch<SpeechService>();
    final scheme = Theme.of(ctx).colorScheme;
    final mediaSize = MediaQuery.of(ctx).size;
    final pageWidth = mediaSize.width;
    final cardGap = CARD_GAP_SCALE * pageWidth;

    final sectionScale = pow(.35 * pageWidth / MIN_CARD_WIDTH, .5).toDouble();
    final numCols = pow(pageWidth / MIN_CARD_WIDTH, .7).floor();

    final cardWidth =
        (pageWidth - (numCols + 1) * cardGap - 2 * STD_PAD) / numCols;

    final cardScale = cardWidth / MIN_CARD_WIDTH;

    final titleStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.normal,
      height: 1.5,
      color: scheme.primaryVariant,
      fontSize: 18 * sectionScale,
    );
    final sectionStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.normal,
      height: 1.2,
      color: scheme.primaryVariant,
      fontSize: 16 * sectionScale,
    );
    final groupDescStyle = TextStyle(
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.2,
      color: scheme.primaryVariant,
      fontSize: 14 * sectionScale,
    );
    final voicingStyle = TextStyle(
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.italic,
      height: 1.2,
      color: scheme.primaryVariant,
      fontSize: 12 * sectionScale,
    );

    final logoHeight = sectionScale * LOGO_HEIGHT_SCALE * mediaSize.height;
    double maxLogoWidth = 0;
    for (var g in groups) {
      maxLogoWidth = max(maxLogoWidth, g.logo.widthAtHeight(logoHeight));
    }
    final sectionPad = STD_PAD * sectionScale;
    final sectionTextWidth = .85 * pageWidth - maxLogoWidth - 4 * sectionPad;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(sectionPad),
            child: Text(title, style: titleStyle),
          ),
          ExpansionPanelList(
            elevation: 0,
            expandedHeaderPadding: EdgeInsets.zero,
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                _expandedFlag[index] = !isExpanded;
              });
            },
            children: [
              for (int i = 0; i < groups.length; i++)
                ExpansionPanel(
                  canTapOnHeader: true,
                  headerBuilder: (ctx, _) => Container(
                    padding: EdgeInsets.all(sectionPad),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: sectionTextWidth,
                              padding: EdgeInsets.only(bottom: sectionPad),
                              child: Text(
                                groups[i].title,
                                style: sectionStyle,
                              ),
                            ),
                            Container(
                              width: sectionTextWidth,
                              padding: EdgeInsets.only(bottom: sectionPad),
                              child: Text(
                                WordGroupsPage.genVoicingLabel(
                                  groups[i].logo.pronunciations,
                                ),
                                style: voicingStyle,
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Container(
                              width: sectionTextWidth,
                              child: Text(
                                groups[i].description,
                                style: groupDescStyle,
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          padding:
                              EdgeInsets.all(sectionPad + 0.1 * logoHeight),
                          child: GestureDetector(
                            onTap: () => speechSvc.pronounce(
                              groups[i].logo.pronunciations,
                              multiStitch: kIsWeb || Platform.isIOS,
                            ),
                            child: GrafonTile(
                              groups[i].logo.renderPlan,
                              height: 0.8 * logoHeight,
                              width: groups[i]
                                  .logo
                                  .widthAtHeight(0.8 * logoHeight),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  body: MultiWordWidget(
                    groups[i].values,
                    cardWidth: cardWidth,
                    stdPad: STD_PAD * cardScale,
                    cardGap: cardGap * cardScale,
                    wordHeight:
                        WORD_HEIGHT_SCALE * mediaSize.height * cardScale,
                    scaleFactor: cardScale,
                  ),
                  isExpanded: _expandedFlag[i],
                )
            ],
          ),
          Container(height: FOOTER_HEIGHT + 2 * GRAM_GAP),
        ],
      ),
    );
  }
}

/// Widget to render a word group
class MultiWordWidget extends StatelessWidget {
  final Iterable<GrafonWord> words;
  final double wordHeight;
  final double cardWidth;
  final double stdPad;
  final double cardGap;
  final double scaleFactor;

  MultiWordWidget(
    this.words, {
    this.cardWidth = 0,
    this.wordHeight = 50,
    this.cardGap = 20,
    this.stdPad = 10,
    this.scaleFactor = 1.0,
  });

  @override
  Widget build(BuildContext ctx) {
    final speechSvc = ctx.watch<SpeechService>();
    final scheme = Theme.of(ctx).colorScheme;

    final wordDescStyle = TextStyle(
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.2,
      color: scheme.primaryVariant,
      fontSize: 12 * scaleFactor,
    );
    final wordTitleStyle = wordDescStyle.copyWith(
      fontWeight: FontWeight.bold,
      height: 1.2,
      fontSize: 14 * scaleFactor,
    );
    final voicingStyle = TextStyle(
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.italic,
      height: 1.2,
      color: scheme.primaryVariant,
      fontSize: 10 * scaleFactor,
    );
    final tinyLineStyle = TextStyle(
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 0.1,
      fontSize: 1 * scaleFactor,
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: stdPad),
      child: Wrap(
        spacing: cardGap,
        runSpacing: cardGap,
        children: <Widget>[
          for (var w in words)
            Container(
              width: max(cardWidth, w.widthAtHeight(wordHeight)),
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
                        padding: EdgeInsets.all(stdPad + 0.1 * wordHeight),
                        height: wordHeight + stdPad,
                        width: w.widthAtHeight(wordHeight) + stdPad,
                        child: GestureDetector(
                          onTap: () => speechSvc.pronounce(
                            w.pronunciations,
                            multiStitch: kIsWeb || Platform.isIOS,
                          ),
                          child: GrafonTile(
                            w.renderPlan,
                            height: wordHeight,
                            width: w.widthAtHeight(wordHeight),
                          ),
                        ),
                      ),
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.top,
                      child: Container(
                        width: w.widthAtHeight(wordHeight) > cardWidth * .5
                            ? cardWidth
                            : cardWidth - stdPad - w.widthAtHeight(wordHeight),
                        padding: EdgeInsets.only(top: stdPad),
                        child: Text(
                          w.key +
                              '\n' +
                              WordGroupsPage.genVoicingLabel(w.pronunciations),
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
    );
  }
}
