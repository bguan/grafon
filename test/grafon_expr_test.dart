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
import 'package:grafon/expr_render.dart';
import 'package:grafon/grafon_expr.dart';
import 'package:grafon/gram_infra.dart';
import 'package:grafon/gram_table.dart';
import 'package:grafon/phonetics.dart';
import 'package:vector_math/vector_math.dart';

/// Unit Tests for Expressions
void main() {
  test('Unary symbol should all be unique', () {
    final symbolsFromUnary = Set.of([
      ...Unary.values.map((u) => u.symbol),
    ]);
    expect(symbolsFromUnary.length, Unary.values.length);
  });

  test('Binary symbol should all be unique', () {
    final symbolsFromBinary = Set.of([
      ...Binary.values.map((b) => b.symbol),
    ]);
    expect(symbolsFromBinary.length, Binary.values.length);
  });

  test('Unary ending should all be unique', () {
    final endingsFromUnary = Set.of([
      ...Unary.values.map((u) => u.ending),
    ]);
    expect(endingsFromUnary.length, Unary.values.length);
  });

  test('Binary ending should all be unique', () {
    final endingsFromBinary = Set.of([
      ...Binary.values.map((b) => b.coda),
    ]);
    expect(endingsFromBinary.length, Binary.values.length);
  });

  test('GramMetrics computation', () {
    final dot = PolyStraight.anchors([Anchor.O, Anchor.O]);
    expect(dot.vectors, [Vector2(0, 0), Vector2(0, 0)]);

    final metricsDot = RenderPlan([dot]);
    expect(metricsDot.width, RenderPlan.MIN_WIDTH);
    expect(metricsDot.center, Vector2(0, 0));
    expect(metricsDot.yMin, 0.0);
    expect(metricsDot.yMax, 0.0);
    expect(metricsDot.xMin, 0.0);
    expect(metricsDot.xMax, 0.0);

    final vLine = PolyStraight.anchors([Anchor.N, Anchor.S]);
    expect(vLine.vectors, [Vector2(0, 0.5), Vector2(0, -0.5)]);

    final metricsVL = RenderPlan([vLine]);
    expect(metricsVL.width, RenderPlan.MIN_WIDTH);
    expect(metricsVL.center, Vector2(0, 0));
    expect(metricsVL.xMin, 0.0);
    expect(metricsVL.xMax, 0.0);
    expect(metricsVL.yMin, -0.5);
    expect(metricsVL.yMax, 0.5);

    final hLine = PolyStraight.anchors([Anchor.W, Anchor.E]);
    expect(hLine.vectors, [Vector2(-0.5, 0), Vector2(0.5, 0)]);

    final metricsHL = RenderPlan([hLine]);
    expect(metricsHL.width, 1);
    expect(metricsHL.center, Vector2(0, 0));
    expect(metricsHL.yMin, 0.0);
    expect(metricsHL.yMax, 0.0);
    expect(metricsHL.xMin, -0.5);
    expect(metricsHL.xMax, 0.5);
  });

  test('SingleGram to String matches gram equivalent', () {
    for (final m in Mono.values) {
      final mg = GramTable().atMonoFace(m, Face.Center);
      expect(mg.toString(), m.shortName);
      for (final f in FaceHelper.directionals) {
        final qg = GramTable().atMonoFace(m, f);
        expect(qg.toString(), "${f.shortName}_${m.quadPeer.shortName}");
      }
    }
  });

  test('SingleGram pronunciation matches gram equivalent', () {
    for (final cp in ConsPair.values) {
      for (final v in Vowel.values.where((e) => e != Vowel.nil)) {
        final g = GramTable().atConsPairVowel(cp, v);
        expect(
          g.pronunciation.first,
          Syllable(cp.base, v, Vowel.nil, Coda.nil),
        );
      }
    }
  });

  test('UnaryExpr to String is correct', () {
    for (final m in Mono.values) {
      for (final f in Face.values) {
        final g = GramTable().atMonoFace(m, f);
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
        final g = GramTable().atMonoFace(m, f);
        expect(
          g.shrink().pronunciation.first,
          g.pronunciation.first.diffEndVowel(Unary.Shrink.ending),
        );
        expect(
          g.up().pronunciation.first,
          g.pronunciation.first.diffEndVowel(Unary.Up.ending),
        );
        expect(
          g.down().pronunciation.first,
          g.pronunciation.first.diffEndVowel(Unary.Down.ending),
        );
        expect(
          g.left().pronunciation.first,
          g.pronunciation.first.diffEndVowel(Unary.Left.ending),
        );
        expect(
          g.right().pronunciation.first,
          g.pronunciation.first.diffEndVowel(Unary.Right.ending),
        );
      }
    }
  });

  test('BinaryExpr toString and pronunciation is correct', () {
    final sun = Mono.Sun.gram; // or star
    expect(sun.toString(), "Sun");
    expect(sun.pronunciation.first, Syllable(Consonant.Sh, Vowel.A));

    final house = Quads.Angle.up.merge(Quads.Gate.down);
    expect(house.toString(), "Up_Angle * Down_Gate");
    expect(house.pronunciation.length, 2);
    expect(
        house.pronunciation.first, Syllable.cvc(Consonant.G, Vowel.I, Coda.K));
    expect(house.pronunciation.last, Syllable(Consonant.D, Vowel.U));

    final person = Mono.Dot.gram.over(Quads.Line.up);
    expect(person.toString(), "Dot / Up_Line");
    expect(person.pronunciation.length, 2); // "As-I"
    expect(person.pronunciation.first, Syllable.vc(Vowel.A, Coda.S));
    expect(person.pronunciation.last, Syllable.v(Vowel.I));

    final rain = Quads.Flow.down.next(Quads.Flow.down);
    expect(rain.toString(), "Down_Flow . Down_Flow");
    expect(rain.pronunciation.length, 2); // "Fu-Fu"
    expect(rain.pronunciation.first, Syllable(Consonant.F, Vowel.U));
    expect(rain.pronunciation.last, Syllable(Consonant.F, Vowel.U));

    final speech = Quads.Gate.left.wrap(Quads.Flow.right);
    expect(speech.toString(), "Left_Gate @ Right_Flow");
    expect(speech.pronunciation.length, 2); // "Don-Fe"
    expect(
        speech.pronunciation.first, Syllable.cvc(Consonant.D, Vowel.O, Coda.N));
    expect(speech.pronunciation.last, Syllable(Consonant.F, Vowel.E));

    // Red is the light from a Flower
    final red = Mono.Light.gram.wrap(Mono.Flower.gram);
    expect(red.toString(), "Light @ Flower");
    expect(red.pronunciation.length, 2);
    expect(red.pronunciation.first, Syllable.cvc(Consonant.S, Vowel.A, Coda.N));
    expect(red.pronunciation.last, Syllable(Consonant.F, Vowel.A));
  });

  test("GramMetrics has correct widthRatio", () {
    final sun = Mono.Sun.gram; // or star
    expect(sun.renderPlan.width, 1.0);
  });
}
