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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:grafon/gram_expr_widget.dart';
import 'package:grafon/gram_infra.dart';

import 'gram_table.dart';
import 'operators.dart';
import 'phonetics.dart';

/// Widget that display a GramTable
class GramTableView extends StatelessWidget {
  final Size? size;

  GramTableView({Key? key, this.size}) : super(key: key);

  @override
  Widget build(BuildContext ctx) {
    final scheme = Theme.of(ctx).colorScheme;
    final mediaSize = (size ?? MediaQuery.of(ctx).size);
    final width = mediaSize.width.clamp(500.0, 2000.0);
    final height = mediaSize.height.clamp(500.0, 2000.0) - 100;
    final widthHeightRatio = (width / height).clamp(.5, 2);
    final vpad = widthHeightRatio * 8.0;
    final hpad = widthHeightRatio * 40.0;
    final space = 4.0;
    final inset = widthHeightRatio * 15.0;
    final dim = min((width - 2 * hpad) / (GramTable.numCols + 2),
        (0.8 * height - 2 * vpad) / (GramTable.numRows + 3));
    final gridSize = Size(dim, dim);

    final fontScale = width / 1000;
    final fontSizing = (base) => (fontScale * base).clamp(6, 60).toDouble();
    final textStyle = (fontSize, [lineHeight = 1.25]) => TextStyle(
          fontWeight: FontWeight.bold,
          height: lineHeight,
          color: Colors.white,
          fontSize: fontSizing(fontSize),
        );
    final headerStyle = textStyle(17);
    final unaryFooterStyle = textStyle(18, 1.4);
    final binaryFooterStyle = textStyle(16);
    final rowHeadTextStyle = textStyle(30);
    final rowTailTextStyle = textStyle(25, 1.5);

    final headerRow = [
      for (var fTxt in [
        'Face vowel -\nConsonant\nbase, head',
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

    final binaryOpRow = [
      for (var bTxt in [
        'Binary\nOperator\ndecreasing\nprecedence',
        ...Binary.values.map((b) =>
            '${b.shortName}\n${b.symbol}\n' +
            '…${b.ending.base}${b.ending.tail.length > 0 ? ' …' + b.ending.tail : ''}'),
        'Ending\nConsonant\nbase, tail'
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
              '${m.gram.consPair.base.shortName}, ${m.gram.consPair.head.shortName}',
              textAlign: TextAlign.center,
              style: rowHeadTextStyle,
            ),
          ),
          color: scheme.background,
        ),
        for (var f in Face.values)
          Container(
            padding: EdgeInsets.all(inset),
            child: GramExprTile(GramTable.atMonoFace(m, f), size: gridSize),
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
      padding: EdgeInsets.symmetric(vertical: vpad, horizontal: hpad),
      child: Center(
        child: GridView.count(
          crossAxisCount: GramTable.numCols + 2,
          crossAxisSpacing: space,
          mainAxisSpacing: space,
          children: [...headerRow, ...gramTable, ...unaryOpRow, ...binaryOpRow],
        ),
      ),
    );
  }
}
