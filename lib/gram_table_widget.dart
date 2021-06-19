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
library gram_table_widget;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import 'grafon_expr.dart';
import 'grafon_widget.dart';
import 'grafon_word.dart';
import 'gram_infra.dart';
import 'gram_table.dart';
import 'phonetics.dart';

/// Widget that display a GramTable
class GramTableView extends StatelessWidget {
  final Size? size;
  final GramTable table;

  GramTableView({Key? key, this.size})
      : table = GramTable(),
        super(key: key);

  Future _speak(FlutterTts speechGen, String voiceText) async {
    if (voiceText.isNotEmpty) {
      await speechGen.awaitSpeakCompletion(true);
      await speechGen.speak(voiceText);
    }
  }

  @override
  Widget build(BuildContext ctx) {
    final speechGen = ctx.watch<FlutterTts>();
    final scheme = Theme.of(ctx).colorScheme;
    final mediaSize = (size ?? MediaQuery.of(ctx).size);
    final screenWidth = mediaSize.width.clamp(500.0, 2000.0);
    final screenHeight = mediaSize.height.clamp(500.0, 2000.0) - 100;
    final widthHeightRatio = (screenWidth / screenHeight).clamp(.5, 2);
    final vPad = widthHeightRatio * 8.0;
    final hPad = widthHeightRatio * 40.0;
    final space = 4.0;
    final inset = widthHeightRatio * 20.0;
    final dim = min((screenWidth - 2 * hPad) / (table.numCols + 2),
            (0.8 * screenHeight - 2 * vPad) / (table.numRows + 3)) -
        2 * inset;

    final fontScale = screenWidth / 1000;
    final fontSizing = (base) => (fontScale * base).clamp(6, 60).toDouble();
    final textStyle = (fontSize, [lineHeight = 1.25]) => TextStyle(
        fontWeight: FontWeight.bold,
        height: lineHeight,
        color: Colors.white,
        fontSize: fontSizing(fontSize));
    final headerStyle = textStyle(16);
    final unaryFooterStyle = textStyle(16, 1.4);
    final binaryFooterStyle = textStyle(16);
    final rowHeadTextStyle = textStyle(30);
    final rowTailTextStyle = textStyle(22, 1.5);

    final headerRow = [
      for (var fTxt in [
        'Face vowel -\nbase, head\nconsonant',
        ...Face.values
            .map((f) => '${f.shortName}\n\n${f.vowel.shortName.toLowerCase()}'),
        'Symbol\nName'
      ])
        fTxt.length <= 0
            ? SizedBox()
            : Container(
                child: Center(
                  child: Text(
                    '$fTxt',
                    textAlign: TextAlign.center,
                    style: headerStyle,
                  ),
                ),
                color: scheme.secondaryVariant,
              ),
    ];

    final unaryOpRow = [
      for (var uTxt in [
        'Unary\nOperator',
        ...Unary.values.map((u) =>
            '${u.shortName}\n${u.symbol}\n…${u.ending.shortName.toLowerCase()}'),
        'Ending\nVowel'
      ])
        uTxt.length <= 0
            ? SizedBox()
            : Container(
                child: Center(
                  child: Text(
                    '$uTxt',
                    textAlign: TextAlign.center,
                    style: unaryFooterStyle,
                  ),
                ),
                color: scheme.primaryVariant,
              ),
    ];

    final decoStr = (s) => (s == '' ? '' : '…' + s);
    final binaryOpRow = [
      for (var bTxt in [
        'Binary\nOperator & Compound',
        ...Binary.values.map((b) =>
        '${b.shortName}\n${b.symbol}\n' +
            decoStr(b.coda.base.phoneme) +
            ' ' +
            decoStr(b.coda.tail.phoneme) +
            ' ' +
            decoStr(b.coda.alt.phoneme)),
        'Compound\n${CompoundWord.SEPARATOR_SYMBOL}\n…' +
            CompoundWord.PRONUNCIATION_LINK.phoneme,
        'Ending\nConsonant\nbase/tail/alt & compound'
      ])
        bTxt.length <= 0
            ? SizedBox()
            : Container(
                child: Center(
                  child: Text(
                    '$bTxt',
                    textAlign: TextAlign.center,
                    style: binaryFooterStyle,
                  ),
                ),
                color: scheme.primaryVariant,
              ),
    ];

    final gramTable = [
      for (var m in Mono.values) ...[
        Container(
          child: Center(
            child: Text(
              '${m.gram.consPair.base.shortName} ${m.gram.consPair.head.shortName}',
              textAlign: TextAlign.center,
              style: rowHeadTextStyle,
            ),
          ),
          color: scheme.background,
        ),
        for (var f in Face.values)
          Container(
            padding: EdgeInsets.all(inset),
            child: GestureDetector(
              onTap: () => _speak(
                speechGen,
                "${table.atMonoFace(m, f).syllable}",
              ),
              onLongPress: () => _speak(
                speechGen,
                "${table.atMonoFace(m, f).syllable.headForm}",
              ),
              child: GrafonTile(
                table.atMonoFace(m, f).renderPlan,
                height: dim,
                width: dim,
              ),
            ),
            color: scheme.surface,
          ),
        Container(
          child: Center(
            child: Text(
              '${m.shortName}\n${m.quadPeer.shortName}',
              textAlign: TextAlign.center,
              style: rowTailTextStyle,
            ),
          ),
          color: scheme.background,
        ),
      ],
    ];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: vPad, horizontal: hPad),
      child: Center(
        child: GridView.count(
          crossAxisCount: table.numCols + 2,
          crossAxisSpacing: space,
          mainAxisSpacing: space,
          children: [...headerRow, ...gramTable, ...unaryOpRow, ...binaryOpRow],
        ),
      ),
    );
  }
}
