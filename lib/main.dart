import 'dart:math';

import 'package:flutter/material.dart';
import 'package:grafon/atom_infra.dart';
import 'package:grafon/graview.dart';

import 'atom_table.dart';
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
    final width = MediaQuery.of(ctx).size.width;
    final height = MediaQuery.of(ctx).size.height;
    const vpad = 20.0;
    const hpad = 10.0;
    const space = 5.0;
    const inset = 5.0;
    final dim = min((width - 2 * hpad) / (GraTable.numCols + 2),
        0.8 * (height - 2 * vpad) / (GraTable.numRows + 1));
    final gridSize = Size(dim - 2 * inset - space, dim - 2 * inset - space);

    final allGras = [
      for (var chdr in [
        '',
        ...Vowel.values.map((Vowel v) => v.shortName.toLowerCase()),
        ''
      ])
        chdr.length <= 0
            ? SizedBox()
            : Container(
                padding: const EdgeInsets.all(inset),
                child: Center(
                  child: Text(
                    '$chdr',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                color: chdr.length <= 0 ? scheme.surface : scheme.background,
              ),
      for (var m in Mono.values) ...[
        Container(
          padding: const EdgeInsets.all(inset),
          child: Center(
            child: Text(
              '${m.gra.consPair.base.shortString}, ${m.gra.consPair.head.shortString}',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          color: scheme.background,
        ),
        for (var f in Face.values)
          Container(
            padding: const EdgeInsets.all(inset),
            child: GraView(GraTable.atMonoFace(m, f), gridSize),
            color: scheme.surface,
          ),
        Container(
          padding: const EdgeInsets.all(inset),
          child: Center(
            child: Text(
              '${m.quadPeer.shortName} ${m.shortName}',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                  fontSize: 9),
            ),
          ),
          color: scheme.surface,
        ),
      ],
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: vpad, horizontal: hpad),
        child: Center(
          child: GridView.count(
            crossAxisCount: GraTable.numCols + 2,
            crossAxisSpacing: space,
            mainAxisSpacing: space,
            children: allGras,
          ),
        ),
      ),
    );
  }
}
