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
  static const MIN_GRAM_CLUSTER_WIDTH = 110;
  static const HEADER_CELL_RATIO = .8;
  static final log = Logger("_GramTableViewState");

  Unary? _unary;
  Binary? _binary;

  @override
  Widget build(BuildContext ctx) {
    final speechSvc = ctx.watch<SpeechService>();
    final table = ctx.watch<GramTable>();
    final scheme = Theme.of(ctx).colorScheme;
    final mediaSize = (widget.size ?? MediaQuery.of(ctx).size);
    final inset = min(mediaSize.width, mediaSize.height) / 100;
    final pageWidth = mediaSize.width - 2 * inset;
    final pageHeight =
        mediaSize.height - TOOL_BAR_HEIGHT - FOOTER_HEIGHT - 12 * inset;
    final numCols = pageWidth < MIN_GRAM_CLUSTER_WIDTH
        ? 1
        : (pageWidth > pageHeight && pageWidth > 4 * MIN_GRAM_CLUSTER_WIDTH
            ? 4
            : 2);
    final cellWidth =
        ((pageWidth - 2 * (5 * numCols + 1) * inset) / (5 * numCols));
    final cellHeight =
        ((pageHeight - (2 * inset * (1 + table.numRows / numCols))) /
            ((1 + HEADER_CELL_RATIO) * (1 + table.numRows / numCols)));
    final cellDim = min(cellWidth, cellHeight);
    final allRowWidth =
        ((cellDim + 2 * inset) * 5 * numCols) + 2 * inset * numCols;
    final headerHeight = (cellDim * HEADER_CELL_RATIO).clamp(15.0, 50.0);
    final opHeaderStyle = TextStyle(
      fontWeight: FontWeight.normal,
      color: scheme.primary,
      fontStyle: FontStyle.italic,
      fontSize: (headerHeight / 3).clamp(5.0, 18.0),
      backgroundColor: Colors.transparent,
    );
    final opTxtStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontSize: (headerHeight / 2.75).clamp(5.0, 20.0),
      backgroundColor: Colors.transparent,
    );

    final gramTable = Container(
      padding: EdgeInsets.all(inset),
      alignment: Alignment.center,
      child: Table(
        defaultColumnWidth: IntrinsicColumnWidth(),
        children: [
          for (int ri = 0; ri < table.numRows ~/ numCols; ri++)
            TableRow(children: [
              for (int ci = 0; ci < numCols; ci++)
                GramRowWidget(
                  Mono.values[ri * numCols + ci],
                  (List<Gram> gs) async {
                    final coda = _binary == null ? Coda.NIL : _binary!.coda;
                    await speechSvc.pronounce(
                      gs.map((g) => Pronunciation([
                            _unary == null
                                ? g.syllable.diffCoda(coda)
                                : g.syllable
                                    .diffExtension(_unary!.extn)
                                    .diffCoda(coda)
                          ])),
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

    final onUnaryTap = (Unary u) => () => setState(() {
          _unary = _unary == u ? null : u;
          log.info("Toggling Unary operator to $_unary");
        });

    final unaryRow = Wrap(
      spacing: inset,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Unary Ops',
          textAlign: TextAlign.center,
          style: opHeaderStyle,
        ),
        for (var u in Unary.values)
          GestureDetector(
            child: Container(
              padding: EdgeInsets.all(inset / 2),
              height: headerHeight,
              width: allRowWidth / 6,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _unary == u ? scheme.primary : scheme.background,
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: Text(
                "${u.shortName} ${u.symbol} …${u.extn.shortName}…",
                textAlign: TextAlign.center,
                style: opTxtStyle,
              ),
            ),
            onTap: onUnaryTap(u),
          ),
      ],
    );

    final onBinaryTap = (Binary b) => () => setState(() {
          if (_binary == b) {
            _binary = null;
          } else {
            _binary = b;
          }
          log.info(_binary == null
              ? 'Switch Binary operator off.'
              : 'Toggling Binary operator to ${_binary!.shortName}.');
        });

    final codaTxt =
        (Binary b) => (b.coda.shortName.isEmpty ? '' : ' …${b.coda.shortName}');

    final binaryRow = Wrap(
      spacing: inset,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Binary Ops',
          textAlign: TextAlign.center,
          style: opHeaderStyle,
        ),
        for (var b in Binary.values)
          GestureDetector(
            child: Container(
              padding: EdgeInsets.all(inset / 2),
              height: headerHeight,
              width: allRowWidth / 5,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _binary == b ? scheme.primary : scheme.background,
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
          unaryRow,
          Container(height: inset),
          binaryRow,
          Container(height: TOOL_BAR_HEIGHT + FOOTER_HEIGHT),
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
      fontSize: (headerHeight / 2.5).clamp(5, 12),
    );
    final cons = mono.gram.cons.shortName;
    final consTxt = cons.isEmpty ? '' : '($cons…)';
    return Container(
      padding: EdgeInsets.all(pad / 2),
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => onTap(table.monoRow(mono)),
            child: Container(
              height: headerHeight,
              color: scheme.primaryVariant,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: pad, vertical: pad / 2),
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
                  padding: EdgeInsets.all(pad),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    border: Border.all(color: scheme.primaryVariant, width: .2),
                  ),
                  child: GestureDetector(
                    onTap: () => onTap([table.atMonoFace(mono, f)]),
                    child: GrafonTile(
                      table.atMonoFace(mono, f).renderPlan,
                      height: gramDim,
                      width: gramDim,
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
