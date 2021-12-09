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
import 'generated/l10n.dart';
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
  static const MIN_CLUSTER_WIDE_WTH = 150;
  static const MIN_CLUSTER_TALL_WTH = 150;
  static const HDR_CLUSTER_HGT_RATIO = 0.35;
  static const HDR_CLUSTER_WTH_RATIO = 0.25;
  static const INSET = 3.0;
  static final log = Logger("_GramTableViewState");

  var _binary = Op.Next;

  @override
  Widget build(BuildContext ctx) {
    final l10n = S.of(ctx);
    final speechSvc = ctx.watch<SpeechService>();
    final table = ctx.watch<GramTable>();
    final scheme = Theme.of(ctx).colorScheme;
    final mediaSize = (widget.size ?? MediaQuery.of(ctx).size);
    final isPortrait = mediaSize.width < mediaSize.height;
    final pageWth = (kIsWeb ? .95 : (isPortrait ? 1 : .85)) * mediaSize.width;
    final pageHgt = (kIsWeb ? .95 : (isPortrait ? .9 : 1)) *
        (mediaSize.height - TOOL_BAR_HEIGHT - FOOTER_HEIGHT);
    final isTinyDev = pageWth < MIN_CLUSTER_WIDE_WTH;
    bool isWide =
        pageWth > 1.5 * (MIN_CLUSTER_TALL_WTH / MIN_CLUSTER_WIDE_WTH) * pageHgt;
    final minClusterWth = isWide ? MIN_CLUSTER_WIDE_WTH : MIN_CLUSTER_TALL_WTH;
    final numCols = isTinyDev
        ? 1
        : (pageWth > 4 * minClusterWth && pageWth > pageHgt ? 4 : 2);

    // if packing many columns per row, always use tall settings
    if (numCols >= 4) {
      isWide = false;
    }

    final numRows = (table.numRows / numCols).ceil() + 1; // extra bottom space
    final maxClusterWth = (pageWth - 2 * (numCols + 1) * INSET) / numCols;
    final maxClusterHgt = isTinyDev
        ? pageHgt / 2
        : (pageHgt - 2 * (numRows + 1) * INSET) / numRows;
    final cellWth = (isWide ? 1 - HDR_CLUSTER_WTH_RATIO : 1) *
        (maxClusterWth - 10 * INSET) /
        5;
    final cellHgt =
        (isWide ? 1 : 1 - HDR_CLUSTER_HGT_RATIO) * (maxClusterHgt - 2 * INSET);
    final cellDim = min(cellWth, cellHgt);
    final clusterWth = 5 *
        (cellDim + 2 * INSET) *
        (isWide ? 1 / (1 - HDR_CLUSTER_WTH_RATIO) : 1);
    final clusterHgt =
        (cellDim + 2 * INSET) * (isWide ? 1 : 1 / (1 - HDR_CLUSTER_HGT_RATIO));
    final hdrWth = clusterWth * HDR_CLUSTER_WTH_RATIO;
    final hdrHgt = clusterHgt * HDR_CLUSTER_HGT_RATIO;
    final btnWth = min(
        200.0,
        (clusterWth * numCols + 2 * numCols * INSET) /
            (2 + Op.values.length + Group.values.length));
    final btnHgt = min(50.0, cellDim * .8);
    final opHeaderStyle = TextStyle(
      fontWeight: FontWeight.normal,
      color: scheme.primary,
      fontStyle: FontStyle.italic,
      fontSize: btnHgt * (isWide ? .5 : .3),
      backgroundColor: Colors.transparent,
    );
    final opTxtStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontSize: btnHgt * (isWide ? .5 : .35),
      backgroundColor: Colors.transparent,
    );

    final onBinaryTap = (Op b) => () => setState(() {
          _binary = b;
          log.finest('Set binary operator to ${_binary.shortName}');
        });

    final onGroupingTap = (Group g) => () => speechSvc.pronounce([
          Pronunciation([g.syllable])
        ]);

    final codaTxt = (Op b) => b.coda.shortName.isEmpty ? '' : b.coda.shortName;

    final opLabel = (Op b) {
      final codas = codaTxt(b);
      return l10n.page_gram_table_op_label(
          l10n.common_op_name(b), b.symbol, codas);
    };

    final grpLabel = (Group grp) {
      return l10n.page_gram_table_grp_label(
          l10n.common_grp_name(grp), grp.symbol, grp.syllable.shortName);
    };

    final opRow = Wrap(
      spacing: 2 * INSET,
      runSpacing: 2 * INSET,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      children: [
        Text(
          l10n.page_gram_table_operators,
          textAlign: TextAlign.center,
          style: opHeaderStyle,
        ),
        for (var b in Op.values)
          GestureDetector(
            child: Container(
              padding: EdgeInsets.all(INSET / 2),
              height: btnHgt,
              width: btnWth,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _binary == b ? scheme.primary : scheme.background,
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: Text(
                opLabel(b),
                textAlign: TextAlign.center,
                style: opTxtStyle,
                maxLines: 2,
              ),
            ),
            onTap: onBinaryTap(b),
          ),
        Text(
          l10n.page_gram_table_grouping,
          textAlign: TextAlign.center,
          style: opHeaderStyle,
        ),
        for (var g in Group.values)
          GestureDetector(
            child: Container(
              padding: EdgeInsets.all(INSET / 2),
              height: btnHgt,
              width: btnWth,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border.all(color: scheme.primary),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: Text(
                grpLabel(g),
                textAlign: TextAlign.center,
                style: opTxtStyle.copyWith(color: scheme.primary),
                maxLines: 2,
              ),
            ),
            onTap: onGroupingTap(g),
          ),
      ],
    );

    final gramTable = Container(
      padding: EdgeInsets.all(INSET / 2),
      alignment: Alignment.center,
      child: Table(
        defaultColumnWidth: IntrinsicColumnWidth(),
        children: [
          for (int ri = 0; ri < numCols * table.numRows; ri++)
            TableRow(children: [
              for (int ci = 0; ci < numCols; ci++)
                if (ri * numCols + ci < table.numRows)
                  GramClusterWidget(
                    Mono.values[ri * numCols + ci],
                    (List<Gram> gs) async {
                      final coda = _binary.coda;
                      speechSvc.pronounce(
                        gs.map(
                            (g) => Pronunciation([g.syllable.diffCoda(coda)])),
                        multiStitch: kIsWeb || Platform.isIOS,
                      );
                    },
                    isWide: isWide,
                    gramDim: cellDim,
                    headerDim: isWide ? hdrWth : hdrHgt,
                    pad: INSET,
                  )
                else
                  Container(),
            ]),
        ],
      ),
    );

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          gramTable,
          Container(height: INSET),
          opRow,
        ],
      ),
    );
  }
}

typedef SpeechCallBack = void Function(List<Gram>);

/// A widget that renders a row of 5 grams in the same Mono row in Gram Table
class GramClusterWidget extends StatelessWidget {
  final Mono mono;
  final SpeechCallBack onTap;
  final double gramDim;
  final double headerDim;
  final bool isWide;
  final double pad;

  const GramClusterWidget(this.mono, this.onTap,
      {this.isWide = false,
      this.gramDim = 50,
      this.headerDim = 20,
      this.pad = 5,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext ctx) {
    final l10n = S.of(ctx);
    final scheme = Theme.of(ctx).colorScheme;
    final table = ctx.watch<GramTable>();
    final headerTxtStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontSize: gramDim * (isWide ? .28 : .3),
      height: isWide ? 1.2 : 1.0,
    );
    final cons = mono.gram.cons.shortName;
    final monoName = l10n.common_mono_name(mono.shortName);
    final quadName = l10n.common_quad_name(mono.quadPeer.shortName);
    final wideHdrPad = EdgeInsets.fromLTRB(pad / 2, pad / 4, 2 * pad, pad / 4);
    final tallHdrPad = EdgeInsets.all(pad / 2);
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: pad, vertical: isWide ? pad / 4 : pad),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: scheme.primary, width: 1),
        ),
        child: Flex(
          direction: isWide ? Axis.horizontal : Axis.vertical,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => onTap(table.monoRow(mono)),
              child: Container(
                height: isWide ? gramDim + 2 * pad : headerDim,
                width: isWide ? headerDim : 5 * (gramDim + 2 * pad),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  border: Border.all(color: scheme.primary, width: 1),
                ),
                alignment: Alignment.centerLeft,
                padding: isWide ? wideHdrPad : tallHdrPad,
                child: Text(
                  l10n.page_gram_table_row_header(monoName, quadName, cons),
                  style: headerTxtStyle,
                  maxLines: 3,
                  softWrap: true,
                  textAlign: isWide ? TextAlign.right : TextAlign.left,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
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
