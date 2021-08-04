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
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'grafon_expr.dart';
import 'grafon_widget.dart';
import 'grafon_word.dart';
import 'gram_infra.dart';
import 'gram_table.dart';
import 'phonetics.dart';
import 'speech_svc.dart';

/// Widget that display a GramTable
class GramTableView extends StatefulWidget {
  final Size? size;
  final GramTable table;

  GramTableView({Key? key, this.size})
      : table = GramTable(),
        super(key: key);

  @override
  _GramTableViewState createState() => _GramTableViewState();
}

class _GramTableViewState extends State<GramTableView> {
  static final log = Logger("_GramTableViewState");

  Unary? _unOp;
  Binary? _binOp;
  CodaForm? _codaForm;
  bool _compound = false;

  Unary? get unary => _unOp;

  Binary? get binary => _binOp;

  CodaForm? get codaForm => _codaForm;

  @override
  Widget build(BuildContext ctx) {
    final speechSvc = ctx.watch<SpeechService>();
    final scheme = Theme.of(ctx).colorScheme;
    final mediaSize = (widget.size ?? MediaQuery.of(ctx).size);
    final screenWidth = mediaSize.width;
    final screenHeight = mediaSize.height;
    final vPad = 5.0;
    final hPad = 20.0;
    final space = 5.0;
    final inset = 10.0;
    final dim = min(
      (screenWidth - 2 * hPad) / (widget.table.numCols + 2),
      (screenHeight - 2 * vPad) / (widget.table.numRows + 1),
    );

    final fontScale = screenWidth / 1000;
    final fontSizing = (base) => (fontScale * base).clamp(6, 60).toDouble();
    final textStyle =
        (fontSize, [lineHeight = 1.25, color = Colors.white]) => TextStyle(
              fontWeight: FontWeight.bold,
              height: lineHeight,
              color: color,
              fontSize: fontSizing(fontSize),
            );
    final headerStyle = textStyle(18);
    final rowHeadTextStyle = textStyle(30);
    final rowTailTextStyle = textStyle(20, 1.5);
    final unaryFooterStyle = textStyle(18, 1.4);
    final unarySelectedStyle = textStyle(18, 1.4); //, scheme.primary);
    final binaryFooterStyle = textStyle(18, 1.4);
    final binarySelectedStyle = textStyle(18, 1.4); //, scheme.primary);

    final headerRow = [
      for (var fTxt in [
        'Face vowel -\nbase, head\nconsonant',
        ...Face.values
            .map((f) => '${f.shortName}\n\n${f.vowel.shortName.toLowerCase()}'),
        'Symbol\nName'
      ])
        Container(
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
              onTap: () => speechSvc.pronounce(
                Pronunciation(
                  [
                    widget.table
                        .atMonoFace(m, f)
                        .syllable
                        .diffEndVowel(_unOp == null ? Vowel.NIL : _unOp!.ending)
                        .diffCoda(_compound
                            ? Coda.ng
                            : (_binOp == null
                                ? Coda.NIL
                                : _binOp!.coda[_codaForm!])),
                  ],
                ),
              ),
              onLongPress: () => speechSvc.pronounce(
                Pronunciation([
                  widget.table
                      .atMonoFace(m, f)
                      .syllable
                      .headForm
                      .diffEndVowel(_unOp == null ? Vowel.NIL : _unOp!.ending)
                      .diffCoda(_compound
                          ? Coda.ng
                          : (_binOp == null
                              ? Coda.NIL
                              : _binOp!.coda[_codaForm!]))
                ]),
              ),
              child: GrafonTile(
                widget.table.atMonoFace(m, f).renderPlan,
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

    final biBorderCol = _codaForm == CodaForm.base
        ? Colors.greenAccent
        : (_codaForm == CodaForm.tail ? Colors.yellow : Colors.pinkAccent);
    final biBorder = Border.all(color: biBorderCol, width: 4);
    final uniBorder = Border.all(color: Colors.purpleAccent, width: 4);
    final uniBorderDeco = BoxDecoration(
      border: uniBorder,
      color: scheme.primaryVariant,
    );
    final biBorderDeco = BoxDecoration(
      border: biBorder,
      color: scheme.primaryVariant,
    );
    final unaryOpRow = [
      Container(
        child: Center(
          child: Text(
            'Unary\nOperator',
            textAlign: TextAlign.center,
            style: rowTailTextStyle,
          ),
        ),
        color: scheme.primaryVariant,
      ),
      for (var u in Unary.values)
        GestureDetector(
          onTap: () => setState(() {
            _unOp = (_unOp == u ? null : u);
            log.info("Toggling Unary operator to $_unOp");
          }),
          child: Container(
            child: Center(
              child: Text(
                '${u.shortName}\n${u.symbol}\n…${u.ending.shortName.toLowerCase()}',
                textAlign: TextAlign.center,
                style: _unOp != u ? unaryFooterStyle : unarySelectedStyle,
              ),
            ),
            color: _unOp != u ? scheme.primaryVariant : null,
            decoration: _unOp == u ? uniBorderDeco : null,
          ),
        ),
      Container(
        child: Center(
          child: Text(
            'Ending\nVowel',
            textAlign: TextAlign.center,
            style: rowTailTextStyle,
          ),
        ),
        color: scheme.primaryVariant,
      ),
    ];

    final binaryOpRow = [
      Container(
        child: Center(
          child: Text(
            'Binary\nOperator, Compound',
            textAlign: TextAlign.center,
            style: rowTailTextStyle,
          ),
        ),
        color: scheme.primaryVariant,
      ),
      for (var b in Binary.values)
        GestureDetector(
          onTap: () => setState(() {
            if (_binOp != b) {
              _binOp = b;
              _codaForm = CodaForm.base;
            } else {
              // cycle thru the CodaForms
              if (_codaForm == CodaForm.alt) {
                _binOp = null;
                _codaForm = null;
              } else if (_codaForm == CodaForm.base) {
                _codaForm = CodaForm.tail;
              } else {
                _codaForm = CodaForm.alt;
              }
            }
            _compound = false;
            log.info("Toggling Binary operator to $_binOp");
          }),
          child: Container(
            child: Center(
              child: Text(
                '${b.shortName}\n${b.symbol}\n' +
                    (_binOp == b && _codaForm != null
                        ? '(${_codaForm!.shortName}) …${b.coda[_codaForm!].shortName}'
                        : [
                            b.coda.base.shortName,
                            b.coda.tail.shortName,
                            b.coda.alt.shortName
                          ].join(' ')),
                textAlign: TextAlign.center,
                style: _binOp == b ? binarySelectedStyle : binaryFooterStyle,
              ),
            ),
            color: _binOp != b ? scheme.primaryVariant : null,
            decoration: _binOp == b ? biBorderDeco : null,
          ),
        ),
      GestureDetector(
        onTap: () => setState(() {
          _compound = !_compound;
          _binOp = null;
          _codaForm = null;
          log.info("Toggling Compound operator to $_compound");
        }),
        child: Container(
          child: Center(
            child: Text(
              'Compound\n${CompoundWord.SEPARATOR_SYMBOL}\n…' +
                  CompoundWord.PRONUNCIATION_LINK.shortName,
              textAlign: TextAlign.center,
              style: _compound ? binarySelectedStyle : binaryFooterStyle,
            ),
          ),
          color: _compound ? null : scheme.primaryVariant,
          decoration: _compound ? uniBorderDeco : null,
        ),
      ),
      Container(
        child: Center(
          child: Text(
            'Ending\nConsonant',
            textAlign: TextAlign.center,
            style: rowTailTextStyle,
          ),
        ),
        color: scheme.primaryVariant,
      ),
    ];

    return Container(
      width: dim * (widget.table.numCols + 2) + 2 * hPad,
      height: dim * (widget.table.numRows + 1) + 2 * vPad,
      padding: EdgeInsets.symmetric(vertical: vPad, horizontal: hPad),
      child: Center(
        child: GridView.count(
          crossAxisCount: widget.table.numCols + 2,
          crossAxisSpacing: space,
          mainAxisSpacing: space,
          children: [
            ...headerRow,
            ...gramTable,
            ...unaryOpRow,
            ...binaryOpRow,
          ],
        ),
      ),
    );
  }
}
