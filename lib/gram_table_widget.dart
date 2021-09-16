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

/// Widget library to render GramTable
library gram_table_widget;

import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'constants.dart';
import 'grafon_expr.dart';
import 'grafon_widget.dart';
import 'gram_infra.dart';
import 'gram_table.dart';
import 'phonetics.dart';
import 'speech_svc.dart';

/// Widget that display the GramTable and calling speech service onTap
class GramTableView extends StatefulWidget {
  final Size? size;

  GramTableView({Key? key, this.size}) : super(key: key);

  @override
  _GramTableViewState createState() => _GramTableViewState();
}

class _GramTableViewState extends State<GramTableView> {
  static const MIN_GRAM_CLUSTER_WIDTH = 150;
  static const MIN_GRAM_CLUSTER_HEIGHT = 300;
  static const HEADER_CELL_RATIO = 0.8;
  static final log = Logger("_GramTableViewState");

  var _isAlt = false;
  var _binary = Binary.Next;

  @override
  Widget build(BuildContext ctx) {
    final speechSvc = ctx.watch<SpeechService>();
    final table = ctx.watch<GramTable>();
    final scheme = Theme.of(ctx).colorScheme;
    final mediaSize = (widget.size ?? MediaQuery.of(ctx).size);
    final inset = 4.0;
    final pageWidth = mediaSize.width - 9 * inset;
    final pageHeight = mediaSize.height - TOOL_BAR_HEIGHT - FOOTER_HEIGHT;
    final numCols = pageWidth < MIN_GRAM_CLUSTER_WIDTH ||
            pageHeight < MIN_GRAM_CLUSTER_HEIGHT
        ? 1
        : (pageWidth > pageHeight && pageWidth > 4 * MIN_GRAM_CLUSTER_WIDTH
            ? 4
            : 2);
    final rowWidth = pageWidth / numCols;
    final rowHeight = pageHeight / (2 + table.numRows / numCols);
    final cellWidth = (rowWidth - 12 * inset) / 5;
    final cellHeight = rowHeight / (1 + HEADER_CELL_RATIO) - 1.5 * inset;
    final cellDim = numCols == 1 ? cellWidth : min(cellWidth, cellHeight);
    final headerHeight = cellDim * HEADER_CELL_RATIO;
    final opButtonHeight = min(FOOTER_HEIGHT, headerHeight);

    final opHeaderStyle = TextStyle(
      fontWeight: FontWeight.normal,
      color: scheme.primary,
      fontStyle: FontStyle.italic,
      fontSize: (opButtonHeight / 3),
      backgroundColor: Colors.transparent,
    );
    final opTxtStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontSize: (opButtonHeight / 2.5),
      backgroundColor: Colors.transparent,
    );

    final gramTable = Container(
      padding: EdgeInsets.all(inset / 2),
      alignment: Alignment.center,
      child: Table(
        defaultColumnWidth: IntrinsicColumnWidth(),
        children: [
          for (int ri = 0; ri < table.numRows / numCols; ri++)
            TableRow(children: [
              for (int ci = 0; ci < numCols; ci++)
                GramRowWidget(
                  Mono.values[ri * numCols + ci],
                  (List<Gram> gs) async {
                    final coda = _isAlt ? _binary.coda.alt : _binary.coda;
                    speechSvc.pronounce(
                      gs.map((g) => Pronunciation([g.syllable.diffCoda(coda)])),
                      multiStitch: kIsWeb || Platform.isIOS,
                    );
                  },
                  headerHeight: headerHeight,
                  gramDim: cellDim,
                  pad: inset,
                ),
            ]),
        ],
      ),
    );

    final onBinaryTap = (Binary b) => () => setState(() {
          if (_binary == b) {
            if (_binary.coda.shortName.isEmpty || _isAlt) {
              _binary = Binary.Next;
              _isAlt = false;
            } else {
              _isAlt = true;
            }
          } else {
            _binary = b;
            _isAlt = false;
          }
          log.finest(
            'Set binary operator to ${_binary.shortName}'
            '${_isAlt ? ' (alt)' : ''}',
          );
        });

    final codaTxt = (Binary b) => b.coda.shortName.isEmpty
        ? ''
        : (_binary == b
            ? (_isAlt ? '…${b.coda.alt.shortName}' : '…${b.coda.shortName}')
            : '${b.coda.shortName}, ${b.coda.alt.shortName}');

    final binaryRow = Wrap(
      spacing: 2 * inset,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Operators',
          textAlign: TextAlign.center,
          style: opHeaderStyle,
        ),
        for (var b in Binary.values)
          GestureDetector(
            child: Container(
              padding: EdgeInsets.all(inset / 2),
              height: opButtonHeight,
              width: pageWidth / (1.5 + Binary.values.length),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _binary == b
                    ? (_isAlt ? scheme.primaryVariant : scheme.primary)
                    : scheme.background,
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: Text(
                "${b.shortName} ${b.symbol} ${codaTxt(b)}",
                textAlign: TextAlign.center,
                style: opTxtStyle,
              ),
            ),
            onTap: onBinaryTap(b),
          ),
      ],
    );

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          gramTable,
          Container(height: inset),
          binaryRow,
          Container(height: FOOTER_HEIGHT + inset),
        ],
      ),
    );
  }
}

typedef SpeechCallBack = void Function(List<Gram>);

/// A widget that renders a row of 5 grams in the same Mono row in Gram Table
class GramRowWidget extends StatelessWidget {
  final Mono mono;
  final SpeechCallBack onTap;
  final double gramDim;
  final double headerHeight;
  final double pad;

  const GramRowWidget(this.mono, this.onTap,
      {this.gramDim = 50, this.headerHeight = 20, this.pad = 5, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext ctx) {
    final scheme = Theme.of(ctx).colorScheme;
    final table = ctx.watch<GramTable>();
    final headerTxtStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontSize: (headerHeight / 3),
    );
    final cons = mono.gram.cons.shortName;
    final consTxt = cons.isEmpty ? '' : '($cons…)';
    return Padding(
      padding: EdgeInsets.all(pad),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: scheme.primary, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => onTap(table.monoRow(mono)),
              child: Container(
                height: headerHeight,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  border: Border.all(color: scheme.primary, width: 1),
                ),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(pad / 2),
                child: Text(
                  "${mono.shortName} & ${mono.quadPeer.shortName} $consTxt",
                  style: headerTxtStyle,
                  maxLines: 1,
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var f in Face.values)
                  Container(
                    padding: EdgeInsets.all(pad + 0.1 * gramDim),
                    child: GestureDetector(
                      onTap: () => onTap([table.atMonoFace(mono, f)]),
                      child: GrafonTile(
                        table.atMonoFace(mono, f).renderPlan,
                        height: 0.8 * gramDim,
                        width: 0.8 * gramDim,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
