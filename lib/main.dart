import 'dart:math';

import 'package:flutter/material.dart';
import 'package:grafon/atom_infra.dart';
import 'package:grafon/graview.dart';

import 'atom_table.dart';
import 'operators.dart';
import 'phonetics.dart';

void main() {
  runApp(GrafonApp());
}

class GrafonApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext ctx) {
    return MaterialApp(
      title: 'Grafon',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GrafonHome(title: 'Grafon Home'),
    );
  }
}

class GrafonHome extends StatelessWidget {
  GrafonHome({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext ctx) {
    final scheme = Theme.of(ctx).colorScheme;
    final width = MediaQuery.of(ctx).size.width.clamp(500.0, 1000.0);
    final height = MediaQuery.of(ctx).size.height.clamp(500.0, 1000.0);
    final widthHeightRatio = (width / height).clamp(.5, 2);
    final vpad = 20.0;
    final hpad = 20.0;
    final space = 5.0;
    final inset = widthHeightRatio * 10.0;
    final dim = min((width - 2 * hpad) / (GraTable.numCols + 2),
        (0.8 * height - 2 * vpad) / (GraTable.numRows + 3));
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
                      fontSize: widthHeightRatio * 12,
                    ),
                  ),
                ),
                color: scheme.secondaryVariant,
              ),
    ];

    final binaryOpRow = [
      for (var bTxt in [
        'Binary\nOperator',
        ...Binary.values.map((b) =>
            '${b.shortName}\n${b.symbol}\n' +
            '_${b.ending.base}${b.ending.tail.length > 0 ? '  _' + b.ending.tail : ''}'),
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
                      height: 1.5,
                      color: scheme.surface,
                      fontSize: widthHeightRatio * 12,
                    ),
                  ),
                ),
                color: scheme.primaryVariant,
              ),
    ];

    final unaryOpRow = [
      for (var uTxt in [
        'Unary\nOperator',
        ...Unary.values.map((u) =>
            '${u.shortName}\n${u.symbol}\n_${u.ending.shortName.toLowerCase()}'),
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
                      fontSize: widthHeightRatio * 12,
                    ),
                  ),
                ),
                color: scheme.primaryVariant,
              ),
    ];

    final graTable = [
      for (var m in Mono.values) ...[
        Container(
          child: Center(
            child: Text(
              '${m.gra.consPair.base.shortName}, ${m.gra.consPair.head.shortName}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: widthHeightRatio * 15,
              ),
            ),
          ),
          color: scheme.background,
        ),
        for (var f in Face.values)
          Container(
            padding: EdgeInsets.all(inset),
            child: GraView(GraTable.atMonoFace(m, f), gridSize),
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
                fontSize: widthHeightRatio * 15,
              ),
            ),
          ),
          color: scheme.background,
        ),
      ],
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: vpad, horizontal: hpad),
        child: Center(
          child: GridView.count(
            crossAxisCount: GraTable.numCols + 2,
            crossAxisSpacing: space,
            mainAxisSpacing: space,
            children: [
              ...headerRow,
              ...graTable,
              ...unaryOpRow,
              ...binaryOpRow
            ],
          ),
        ),
      ),
    );
  }
}
