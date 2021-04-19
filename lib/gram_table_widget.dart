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
import 'package:grafon/gram_expr_tile_widget.dart';
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
    final useSize = (size ?? MediaQuery.of(ctx).size);
    final width = useSize.width.clamp(500.0, 1000.0);
    final height = useSize.height.clamp(500.0, 1000.0);
    final widthHeightRatio = (width / height).clamp(.5, 2);
    final vpad = widthHeightRatio * 10.0;
    final hpad = widthHeightRatio * 10.0;
    final space = 5.0;
    final inset = widthHeightRatio * 12.0;
    final dim = min((width - 2 * hpad) / (GramTable.numCols + 2),
        (0.8 * height - 2 * vpad) / (GramTable.numRows + 3));
    final gridSize = Size(dim - 2 * inset - space, dim - 2 * inset - space);

    final headerRow = [
      for (var fTxt in [
        'Face vowel - \nConsonant\nbase, head',
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      color: Colors.white,
                      fontSize: widthHeightRatio * 18,
                    ),
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                      color: scheme.surface,
                      fontSize: widthHeightRatio * 18,
                    ),
                  ),
                ),
                color: scheme.primaryVariant,
              ),
    ];

    final binaryOpRow = [
      for (var bTxt in [
        'Binary\nOperator\ndecreasing precedence',
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                      color: scheme.surface,
                      fontSize: widthHeightRatio * 15,
                    ),
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: widthHeightRatio * 25,
              ),
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                height: 1.5,
                color: scheme.surface,
                fontSize: widthHeightRatio * 25,
              ),
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
