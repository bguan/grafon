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

import 'package:flutter/material.dart';

import 'gram_expr_widget.dart';
import 'gram_table.dart';
import 'gram_table_widget.dart';

/// Main Starting Point of the App.
void main() {
  runApp(GrafonApp());
}

class GrafonApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext ctx) {
    final scheme = Theme.of(ctx).colorScheme;
    final controller = PageController(initialPage: 0);

    final gramSize = Size(150, 150);
    final expressions = {
      Mono.Sun.gram: "Sun, star.",
      Quads.Swirl.up: "Swirling upward, spinning upward.",
      Quads.Angle.up.merge(Quads.Gate.down): "House, dwelling, building.",
      Mono.Dot.gram.over(Quads.Line.up): "Human.",
      Quads.Arc.down.around(Mono.Sun.gram): "Day time, day.",
      Mono.Blob.up().before(Quads.Angle.up.merge(Quads.Arc.down)):
          "Life Drip, blood?",
      Quads.Flow.down.before(Quads.Flow.down): "Rain.",
      Quads.Gate.left.around(Quads.Flow.right): "Talk, speech.",
      Quads.Step.up: "Step up, count, number.",
      Mono.Circle.gram: "Zero, Moon, Circle.",
      Quads.Line.up: "One, ground, floor.",
      Quads.Corner.up: "Two, corner.",
      Quads.Gate.up: "Three, open gate.",
      Mono.Square.gram: "Four.",
      Quads.Line.right.merge(Mono.Square.gram): "Number Five.",
      Quads.Line.down.merge(Mono.X.gram): "Number Six.",
      Quads.Line.left.merge(Mono.Square.shrink()): "Number Seven.",
      Mono.X.gram.merge(Mono.Square.gram): "Eight.",
      Quads.Line.up.merge(Mono.Square.shrink()): "Nine.",
      Mono.Circle.gram.before(Quads.Line.up.up()):
          "Ten(s), ten to the power of 1.",
      Mono.Circle.gram.before(Quads.Corner.up.up()):
          "Hundred(s), ten to the power of 2.",
      Mono.Circle.gram.before(Quads.Gate.up.up()):
          "Thousand(s), ten to the power of 3.",
      Mono.Light.gram.around(Quads.Zap.down): "White, light from lightning.",
      Mono.Light.gram.around(Mono.Flower.gram): "Red, light from flower.",
      Mono.Light.gram.around(Quads.Arc.up.merge(Quads.Arc.down)):
          "Green, light from leaf.",
      Mono.Light.gram.around(Quads.Flow.right): "Blue, light from water.",
      Mono.Light.gram.around(Mono.X.gram): "Black, no light.",
      Mono.Sun.gram.compound(Mono.Dot.gram.over(Quads.Line.up)):
          "Star being, alien, god?",
      Quads.Arc.up
              .around(Mono.Dot.gram)
              .compound(Quads.Gate.left.around(Quads.Flow.right)):
          '"Eye Talk", the Grafon language in Grafon.',
    };

    final wordViews = [
      for (var expr in expressions.keys)
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(flex: 2),
            Container(
              alignment: Alignment.center,
              width: gramSize.width,
              height: gramSize.height,
              child: Center(child: GramExprTile(expr, size: gramSize)),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.all(5),
              child: Text(
                expr.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                  color: scheme.primaryVariant,
                  fontSize: 20,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5),
              child: Text(
                '"${expr.pronunciation}"',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                    color: scheme.primaryVariant,
                    fontSize: 30,
                    fontFamily: "Courier"),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5),
              child: Text(
                expressions[expr] ?? '?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  height: 1.5,
                  color: scheme.primaryVariant,
                  fontSize: 20,
                ),
              ),
            ),
            Spacer(flex: 2),
          ],
        ),
    ];

    return MaterialApp(
      title: 'Grafon',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(title: Text('Grafon Home')),
        body: PageView(
          scrollDirection: Axis.horizontal,
          controller: controller,
          children: [
            GramTableView(),
            ...wordViews,
          ],
        ),
      ),
    );
  }
}
