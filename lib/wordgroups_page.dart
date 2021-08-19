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

library word_groups_page;

import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
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
}

final _genVoicing = (Pronunciation p, [bool isLines = false]) => [
      p.fragmentSequence.join(),
      '[$p]',
      '"${p.approxVoice}"',
    ].join(isLines ? '\n' : ' ');

class _WordGroupsPageState extends State<WordGroupsPage> {
  static const LOGO_HEIGHT = 50.0;
  static const WORD_HEIGHT = 50.0;
  static const MIN_CARD_WIDTH = 190.0;
  static const CARD_GAP = 15.0;
  static const STD_PAD = 10.0;

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

    final titleStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.normal,
      height: 1.5,
      color: scheme.primaryVariant,
      fontSize: 18,
    );
    final sectionStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.normal,
      height: 1.2,
      color: scheme.primaryVariant,
      fontSize: 14,
    );
    final groupDescStyle = TextStyle(
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.2,
      color: scheme.primaryVariant,
      fontSize: 12,
    );
    final voicingStyle = TextStyle(
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.italic,
      height: 1.2,
      color: scheme.primaryVariant,
      fontSize: 10,
    );

    double maxLogoWidth = 0;
    for (var g in groups) {
      maxLogoWidth = max(maxLogoWidth, g.logo.widthAtHeight(LOGO_HEIGHT));
    }
    final sectionTextWidth = .8 * pageWidth - maxLogoWidth - 3 * STD_PAD;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(STD_PAD),
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
                    padding: EdgeInsets.all(STD_PAD),
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
                              padding: EdgeInsets.only(bottom: STD_PAD),
                              child: Text(
                                groups[i].title,
                                style: sectionStyle,
                              ),
                            ),
                            Container(
                              width: sectionTextWidth,
                              padding: EdgeInsets.only(bottom: STD_PAD),
                              child: Text(
                                _genVoicing(groups[i].logo.pronunciation),
                                style: voicingStyle,
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Container(
                              width: sectionTextWidth,
                              child: Text(
                                groups[i].description,
                                style: groupDescStyle,
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(
                            horizontal: STD_PAD,
                            vertical: 0,
                          ),
                          child: GestureDetector(
                            onTap: () => speechSvc.pronounce(
                              [groups[i].logo.pronunciation],
                              multiStitch: kIsWeb || Platform.isIOS,
                            ),
                            child: GrafonTile(
                              groups[i].logo.renderPlan,
                              height: LOGO_HEIGHT,
                              width: groups[i].logo.widthAtHeight(LOGO_HEIGHT),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  body: MultiWordWidget(
                    groups[i].values,
                    minCardWidth: MIN_CARD_WIDTH,
                    stdPad: STD_PAD,
                    cardGap: CARD_GAP,
                    wordHeight: WORD_HEIGHT,
                  ),
                  isExpanded: _expandedFlag[i],
                )
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget to render a word group
class MultiWordWidget extends StatelessWidget {
  final Iterable<GrafonWord> words;
  final double wordHeight;
  final double minCardWidth;
  final double stdPad;
  final double cardGap;

  MultiWordWidget(
    this.words, {
    this.minCardWidth = 0,
    this.wordHeight = 50,
    this.cardGap = 20,
    this.stdPad = 10,
  });

  @override
  Widget build(BuildContext ctx) {
    final speechSvc = ctx.watch<SpeechService>();
    final scheme = Theme.of(ctx).colorScheme;
    final mediaSize = MediaQuery.of(ctx).size;
    final pageWidth = mediaSize.width;
    final cardWidth =
        2 * minCardWidth > pageWidth ? .6 * pageWidth : minCardWidth;

    final wordDescStyle = TextStyle(
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.2,
      color: scheme.primaryVariant,
      fontSize: 12,
    );
    final wordTitleStyle = wordDescStyle.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      height: 1.2,
    );
    final voicingStyle = TextStyle(
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.italic,
      height: 1.2,
      color: scheme.primaryVariant,
      fontSize: 10,
    );
    final tinyLineStyle = TextStyle(
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 0.1,
      fontSize: 1,
    );

    return Wrap(
      spacing: cardGap,
      runSpacing: cardGap,
      children: <Widget>[
        for (var w in words)
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
                    text:
                        w.description.isNotEmpty ? " - ${w.description}\n" : "",
                    style: w.title.isEmpty && w.description.isEmpty
                        ? tinyLineStyle
                        : wordDescStyle,
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.top,
                    child: Container(
                      padding: EdgeInsets.only(
                        top: stdPad,
                        right: stdPad,
                        bottom: stdPad,
                      ),
                      height: wordHeight + stdPad,
                      width: w.widthAtHeight(wordHeight) + stdPad,
                      child: GestureDetector(
                        onTap: () => speechSvc.pronounce(
                          [w.pronunciation],
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
                      width: w.widthAtHeight(wordHeight) > cardWidth / 2
                          ? cardWidth
                          : cardWidth - stdPad - w.widthAtHeight(wordHeight),
                      padding: EdgeInsets.only(top: stdPad),
                      child: Text(
                        w.key + '\n\n' + _genVoicing(w.pronunciation),
                        style: voicingStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
