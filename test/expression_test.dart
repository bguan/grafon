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

import 'package:flutter_test/flutter_test.dart';
import 'package:grafon/expression.dart';
import 'package:grafon/gram_infra.dart';
import 'package:grafon/gram_table.dart';
import 'package:grafon/operators.dart';
import 'package:grafon/phonetics.dart';
import 'package:grafon/render_plan.dart';
import 'package:vector_math/vector_math.dart';

/// Unit Tests for Expressions
void main() {
  test('GramMetrics computation', () {
    final dot = PolyStraight.anchors([Anchor.O, Anchor.O]);
    expect(dot.vectors, [Vector2(0, 0), Vector2(0, 0)]);

    final metricsDot = RenderPlan([dot]);
    expect(metricsDot.width, RenderPlan.MIN_WIDTH);
    expect(metricsDot.center, Vector2(0, 0));
    expect(metricsDot.yMin, -RenderPlan.MIN_HEIGHT / 2);
    expect(metricsDot.yMax, RenderPlan.MIN_HEIGHT / 2);
    expect(metricsDot.xMin, -RenderPlan.MIN_WIDTH / 2);
    expect(metricsDot.xMax, RenderPlan.MIN_WIDTH / 2);

    final vLine = PolyStraight.anchors([Anchor.N, Anchor.S]);
    expect(vLine.vectors, [Vector2(0, 0.5), Vector2(0, -0.5)]);

    final metricsVL = RenderPlan([vLine]);
    expect(metricsVL.width, RenderPlan.MIN_WIDTH);
    expect(metricsVL.center, Vector2(0, 0));
    expect(metricsVL.xMin, -RenderPlan.MIN_WIDTH / 2);
    expect(metricsVL.xMax, RenderPlan.MIN_WIDTH / 2);
    expect(metricsVL.yMin, -0.5);
    expect(metricsVL.yMax, 0.5);

    final hLine = PolyStraight.anchors([Anchor.W, Anchor.E]);
    expect(hLine.vectors, [Vector2(-0.5, 0), Vector2(0.5, 0)]);

    final metricsHL = RenderPlan([hLine]);
    expect(metricsHL.width, 1);
    expect(metricsHL.center, Vector2(0, 0));
    expect(metricsHL.yMin, -RenderPlan.MIN_HEIGHT / 2);
    expect(metricsHL.yMax, RenderPlan.MIN_HEIGHT / 2);
    expect(metricsHL.xMin, -0.5);
    expect(metricsHL.xMax, 0.5);
  });

  test('SingleGram to String matches gram equivalent', () {
    for (final m in Mono.values) {
      final mg = GramTable.atMonoFace(m, Face.Center);
      expect(mg.toString(), m.shortName);
      for (final f in FaceHelper.directionals) {
        final qg = GramTable.atMonoFace(m, f);
        expect(qg.toString(),
            "${m.quadPeer.shortName} ${f.shortName.toLowerCase()}");
      }
    }
  });

  test('SingleGram pronunciation matches gram equivalent', () {
    for (final cp in ConsPair.values) {
      for (final v in Vowel.values) {
        final g = GramTable.atConsPairVowel(cp, v);
        expect(
            g.pronunciation,
            (cp == ConsPair.aHa ? '' : cp.base.shortName) +
                (cp == ConsPair.aHa ? v.shortName : v.shortName.toLowerCase()));
      }
    }
  });

  test('UnaryExpr to String is correct', () {
    for (final m in Mono.values) {
      for (final f in Face.values) {
        final g = GramTable.atMonoFace(m, f);
        expect(g.shrink().toString(), Unary.Shrink.symbol + g.toString());
        expect(g.up().toString(), Unary.Up.symbol + g.toString());
        expect(g.down().toString(), Unary.Down.symbol + g.toString());
        expect(g.left().toString(), Unary.Left.symbol + g.toString());
        expect(g.right().toString(), Unary.Right.symbol + g.toString());
      }
    }
  });

  test('UnaryExpr pronunciation is correct', () {
    for (final m in Mono.values) {
      for (final f in Face.values) {
        final g = GramTable.atMonoFace(m, f);
        expect(g.shrink().pronunciation,
            g.pronunciation + Unary.Shrink.ending.shortName.toLowerCase());
        expect(
          g.up().pronunciation,
          g.pronunciation + Unary.Up.ending.shortName.toLowerCase(),
        );
        expect(
          g.down().pronunciation,
          g.pronunciation + Unary.Down.ending.shortName.toLowerCase(),
        );
        expect(
          g.left().pronunciation,
          g.pronunciation + Unary.Left.ending.shortName.toLowerCase(),
        );
        expect(
          g.right().pronunciation,
          g.pronunciation + Unary.Right.ending.shortName.toLowerCase(),
        );
      }
    }
  });

  test('BinaryExpr toString and pronunciation is correct', () {
    final sun = Mono.Sun.gram; // or star
    expect(sun.toString(), "Sun");
    expect(sun.pronunciation, "Sa");

    final house = Quads.Angle.up.merge(Quads.Gate.down);
    expect(house.toString(), "Angle up * Gate down");
    expect(house.pronunciation, "GirDu");

    final person = Mono.Dot.gram.over(Quads.Line.up);
    expect(person.toString(), "Dot / Line up");
    expect(person.pronunciation, "AsI");

    final rain = Quads.Flow.down.next(Quads.Flow.down);
    expect(rain.toString(), "Flow down | Flow down");
    expect(rain.pronunciation, "FuFu");

    final speech = Quads.Gate.left.wrap(Quads.Flow.right);
    expect(speech.toString(), "Gate left @ Flow right");
    expect(speech.pronunciation, "DomFe");

    // Red is the light from a Flower
    final red = Mono.Light.gram.wrap(Mono.Flower.gram);
    expect(red.toString(), "Light @ Flower");
    expect(red.pronunciation, "ChamFa");
  });

  test("CompoundWord pronunciation link is different from all BinaryEnding",
      () {
    final endings =
        BinaryEnding.values.map((ending) => ending.shortName.toLowerCase());
    expect(endings.contains(CompoundWord.PRONUNCIATION_LINK.toLowerCase()),
        isFalse);
  });

  test("CompoundWord symbol is different from all Binary operator symbols", () {
    final symbols = Binary.values.map((bin) => bin.symbol);
    expect(symbols.contains(CompoundWord.SEPARATOR_SYMBOL), isFalse);
  });

  test("CompoundWord pronunciation", () {
    final sun = Mono.Sun.gram; // or star
    final person = Mono.Dot.gram.over(Quads.Line.up);

    final starMan = CompoundWord([sun, person]); // God? Alien?
    expect(starMan.toString(), "Sun : Dot / Line up");
    expect(starMan.pronunciation, "Sa-AsI");
  });

  test("GramMetrics has correct widthRatio", () {
    final sun = Mono.Sun.gram; // or star
    expect(sun.renderPlan.width, 1.0);
  });
}
