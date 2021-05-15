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
import 'package:url_launcher/url_launcher.dart';

import 'expression.dart';
import 'grafon_widget.dart';
import 'gram_table.dart';
import 'gram_table_widget.dart';

/// Main Starting Point of the App.
void main() {
  runApp(GrafonApp());
}

/// This widget is the root of Grafon application.
class GrafonApp extends StatelessWidget {
  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext ctx) {
    final scheme = Theme.of(ctx).colorScheme;
    final controller = PageController(initialPage: 0);

    final tileHeight = 100.0;
    Map<GramExpression, String> word2desc = {
      Quads.Angle.up.shrink(): "Test",
      Mono.Circle.next(Quads.Angle.up): "Test",
      Mono.Circle.over(Quads.Angle.up): "Test",
      Mono.Circle.wrap(Quads.Angle.up): "Test",
      Mono.Circle.merge(Quads.Angle.up): "Test",
      Mono.Circle.merge(Quads.Angle.up.shrink()): "Test",
      Mono.Circle.merge(Quads.Angle.up.up()): "Test",
      Mono.Circle.merge(Quads.Angle.up.down()): "Test",
      Mono.Circle.merge(Quads.Angle.up.left()): "Test",
      Mono.Circle.merge(Quads.Angle.up.right()): "Test",
      Mono.Circle.wrap(Quads.Angle.up.up()): "Test",
      Mono.Circle.wrap(Quads.Angle.up.down()): "Test",
      Mono.Circle.wrap(Quads.Angle.up.left()): "Test",
      Mono.Circle.wrap(Quads.Angle.up.right()): "Test",
      Mono.Circle.wrap(Quads.Angle.up.shrink()): "Test",
      Quads.Step.right.merge(Mono.Circle.up()): "I, first person pronoun.",
      Mono.Circle.left().over(Quads.Corner.up): "You, second person pronoun.",
      Mono.Circle.right().over(Quads.Corner.right):
          "He/She/It, third person pronoun.",
      Quads.Angle.up.over(Quads.Gate.down): "House, dwelling, building.",
      Mono.Circle.over(Quads.Line.up): "Human.",
      Mono.Sun.gram.over(Quads.Line.down): "Day time, day.",
      Quads.Flow.down: "Flow down.",
      Quads.Flow.down.next(Quads.Flow.down): "Rain.",
      Quads.Arc.left.next(Quads.Flow.right): "Talk, speech.",
      Quads.Arc.left.next(Quads.Arc.right): "Leaf",
      Quads.Step.up: "Step up, count, number.",
      Mono.Circle.gram: "Zero, Moon, Circle.",
      Quads.Line.up: "One, vertical line.",
      Quads.Corner.right: "Two, angle down.",
      Quads.Gate.right: "Three, lighting down.",
      Mono.Square.gram: "Four.",
      Mono.Square.gram.merge(Quads.Line.left): "Number Five.",
      Quads.Gate.right.merge(Quads.Angle.right): "Number Six.",
      Mono.Square.merge(Quads.Angle.right): "Number Seven.",
      Mono.Square.merge(Mono.X.gram): "Eight.",
      Mono.Square.merge(Quads.Zap.down): "Nine.",
      Mono.Circle.next(Quads.Line.up.up()): "Ten(s), ten to the power of 1.",
      Mono.Circle.next(Quads.Corner.right.up()):
          "Hundred(s), ten to the power of 2.",
      Mono.Circle.next(Quads.Gate.right.up()):
          "Thousand(s), ten to the power of 3.",
      Quads.Angle.up.over(Quads.Arc.down): "Drip.",
      Mono.Light.wrap(Quads.Zap.down): "White, light from lightning.",
      Mono.Light.wrap(Mono.Flower.gram): "Red, light from flower.",
      Mono.Light.wrapCluster(Quads.Arc.left.next(Quads.Arc.right)):
          "Green, light from leaf.",
      Mono.Light.wrap(Quads.Flow.right): "Blue, light from water.",
      Mono.Light.wrap(Mono.X.gram): "Black, no light.",
      ClusterExpression(Quads.Arc.up.next(Quads.Arc.up)).over(Quads.Angle.down):
          "Heart, Love.",
      CompoundWord([
        Mono.Circle.wrap(Mono.Dot.gram),
        Quads.Arc.left.next(Quads.Flow.right),
      ]): '"Eye Talk", the Grafon language in Grafon.',
      CompoundWord([Mono.Sun.gram, Mono.Circle.over(Quads.Line.up)]):
          "Star being, alien, god?",
    };

    final pad = tileHeight * .2;
    final wordViews = [
      for (GramExpression word in word2desc.keys)
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(flex: 2),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: scheme.background,
              ),
              alignment: Alignment.center,
              padding: EdgeInsets.all(pad),
              height: 2 * pad + tileHeight,
              width: 2 * pad + word.flexRenderWidth(tileHeight),
              child: GrafonTile(word, height: tileHeight, flexFit: true),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.all(5),
              child: Text(
                word.toString(),
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
                '"${word.pronunciation.join('-')}"',
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
                word2desc[word] ?? '?',
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
        appBar: AppBar(
          title: Text('Grafon Home'),
          leading: IconButton(
            icon: Icon(Icons.help_outline_rounded),
            onPressed: () =>
                _launchInBrowser('https://github.com/bguan/grafon'),
          ),
        ),
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
