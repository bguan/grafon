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
import 'package:grafon/constants.dart';
import 'package:grafon/expr_render.dart';
import 'package:grafon/grafon_expr.dart';
import 'package:grafon/grafon_word.dart';
import 'package:grafon/gram_infra.dart';
import 'package:grafon/gram_table.dart';
import 'package:vector_math/vector_math.dart';

/// Unit Tests for RenderPlan
void main() {
  test("RenderPlan has correct widthRatio", () {
    final sun = Mono.Sun.gram; // or star
    expect(sun.renderPlan.width, 1.0);
  });

  test('RenderPlan metrics computation works', () {
    final dot = PolyStraight.anchors([Anchor.O, Anchor.O]);
    expect(dot.vectors, [Vector2(0, 0), Vector2(0, 0)]);

    final metricsDot = RenderPlan([dot]);
    expect(metricsDot.width, MIN_GRAM_WIDTH);
    expect(metricsDot.center, Vector2(0, 0));
    expect(metricsDot.yMin, 0.0);
    expect(metricsDot.yMax, 0.0);
    expect(metricsDot.xMin, 0.0);
    expect(metricsDot.xMax, 0.0);

    final vLine = PolyStraight.anchors([Anchor.N, Anchor.S]);
    expect(vLine.vectors, [Vector2(0, 0.5), Vector2(0, -0.5)]);

    final metricsVL = RenderPlan([vLine]);
    expect(metricsVL.width, MIN_GRAM_WIDTH);
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

  test('RenderPlan next operators leaves expected gap btw non-fixed expr', () {
    final r = Quads.Arc.left.next(Quads.Arc.right).renderPlan;
    final lines = r.lines.where((l) => l is! InvisiDot).toList();
    expect(lines.length, 2);
    // Previous height about same as Next
    expect(lines[0].metrics.height, moreOrLessEquals(lines[1].metrics.height));
    // Previous don't overlap with Next
    expect(lines[0].metrics.xMax, lessThan(lines[1].metrics.xMin));
    // Gap is not too big
    expect(lines[1].metrics.xMin - lines[0].metrics.xMax,
        lessThan(1.1 * GRAM_GAP));
  });

  test('RenderPlan compounding next operators does not lead to exploding width',
      () {
    final up = Quads.Angle.up;
    final upWth = up.renderPlan.width;
    final upHt = up.renderPlan.height;
    final expr = up.next(up).next(up).next(up).next(up);
    final r = expr.renderPlan;
    final exprWth = r.width;
    final exprHt = r.height;
    expect(exprHt, moreOrLessEquals(upHt));
    expect(exprWth, closeTo(5 * upWth + 4 * GRAM_GAP, 0.1));
    expect(r.widthRatio, moreOrLessEquals(exprWth / exprHt));
  });

  test('RenderPlan next operators leaves gap btw fixed aspect and non-fixed',
      () {
    final r = Mono.Diamond.next(Quads.Gate.left).renderPlan;
    final lines = r.lines.toList();
    expect(lines.length, 2);
    // Previous height about same as Next
    expect(lines[0].metrics.height, moreOrLessEquals(lines[1].metrics.height));
    // Previous don't overlap with Next
    expect(lines[0].metrics.xMax, lessThan(lines[1].metrics.xMin));
    // Gap is not too big
    expect(lines[1].metrics.xMin - lines[0].metrics.xMax, lessThan(.3));
  });

  test('RenderPlan over operators leaves gap btw fixed aspect and non-fixed',
      () {
    final r = Mono.Dot.over(Quads.Line.up).renderPlan;
    final lines = r.lines.where((e) => !(e is InvisiDot)).toList();
    expect(lines.length, 2);
    final m0 = lines[0].metrics;
    final m1 = lines[1].metrics;
    // Previous width about same as Next
    expect(m0.width, moreOrLessEquals(m1.width));
    // Previous don't overlap with Next
    expect(m1.yMax, lessThan(m0.yMin));
    // Gap is not too big
    expect(m0.yMin - m1.yMax, lessThan(.5));
  });

  test('RenderPlan equality, hashcode, toString works', () {
    final dot = Mono.Dot.gram.renderPlan;
    final dotPlan = RenderPlan([
      PolyDot.anchors([Anchor.O]),
      InvisiDot.anchors(
        [],
        minHeight: GRAM_GAP,
        minWidth: GRAM_GAP,
      ),
    ]);
    final circle = Mono.Circle.gram.renderPlan;

    expect(dot == dot, isTrue);
    expect(dot, dotPlan);
    expect(dot.hashCode, dotPlan.hashCode);
    expect(dot.toString(), dotPlan.toString());
    expect(dot == circle, isFalse);
  });

  test('RenderPlan metrics calculation for Circle is correct', () {
    final cp = RenderPlan([
      PolyCurve.anchors([
        Anchor.W,
        Anchor.N,
        Anchor.E,
        Anchor.S,
        Anchor.W,
        Anchor.N,
        Anchor.E,
      ], isFixedAspect: true)
    ]);

    expect(cp.xMin, -.5);
    expect(cp.xMax, .5);
    expect(cp.yMin, -.5);
    expect(cp.yMax, .5);
    expect(cp.xAvg, .0);
    expect(cp.yAvg, .0);
    expect(cp.width, 1.0);
    expect(cp.height, 1.0);
    expect(cp.center, Vector2(.0, .0));
    expect(cp.mass, 0.16);
    expect(cp.vMass, 0.1);
    expect(cp.hMass, 0.1);
    expect(cp.area, moreOrLessEquals(1.0));
  });

  test('RenderPlan toDevice works', () {
    final word = CoreWord(Quads.Arc.left.next(Quads.Arc.right));
    final devHt = 100.0;
    final devWth = word.widthAtHeight(devHt);
    final r = word.renderPlan.toDevice(devHt, devWth);
    final lines = r.lines.where((l) => l is! InvisiDot).toList();
    expect(lines.length, 2);
    // Previous height about same as Next
    expect(lines[0].metrics.height, moreOrLessEquals(lines[1].metrics.height));
    // Previous don't overlap with Next
    expect(lines[0].metrics.xMax, lessThan(lines[1].metrics.xMin));
    // Gap is not too big
    expect(lines[1].metrics.xMin - lines[0].metrics.xMax,
        lessThan(1.1 * GRAM_GAP * devHt));
  });

  test('RenderPlan metrics computation works', () {
    final cross = RenderPlan([
      PolyStraight.anchors([Anchor.N, Anchor.S], isFixedAspect: true),
      PolyStraight.anchors([Anchor.E, Anchor.W], isFixedAspect: true),
    ]);

    final foldFixed = (int numFixed, l) => numFixed + (l.isFixedAspect ? 1 : 0);
    final numFixed = cross.lines.fold(0, foldFixed);

    expect(numFixed, 2);

    final relaxed = cross.relaxFixedAspect();

    final numFixedRelaxed = relaxed.lines.fold(0, foldFixed);

    expect(numFixedRelaxed, 0);
  });

  test('RenderPlan padding check works', () {
    final dot = RenderPlan([
      PolyDot.anchors([Anchor.O]),
    ]);
    expect(dot.isHeightPadded, true);
    expect(dot.isWidthPadded, true);
    expect(dot.isPadded, true);

    final vLine = RenderPlan([
      PolyStraight.anchors([Anchor.N, Anchor.S]),
    ]);
    expect(vLine.isHeightPadded, false);
    expect(vLine.isWidthPadded, true);
    expect(vLine.isPadded, true);

    final hLine = RenderPlan([
      PolyStraight.anchors([Anchor.W, Anchor.E]),
    ]);
    expect(hLine.isHeightPadded, true);
    expect(hLine.isWidthPadded, false);
    expect(hLine.isPadded, true);

    final cross = RenderPlan([
      PolyStraight.anchors([Anchor.N, Anchor.S]),
      PolyStraight.anchors([Anchor.W, Anchor.E]),
    ]);
    expect(cross.isHeightPadded, false);
    expect(cross.isWidthPadded, false);
    expect(cross.isPadded, false);
  });

  test('Brute force many 1st levelgram combo RenderPlan', () {
    final table = GramTable();
    for (final m1 in Mono.values) {
      for (final f1 in [Face.Center, Face.Right]) {
        final expr1 = table.atMonoFace(m1, f1);
        for (final bop in [null, ...Binary.values]) {
          final exprs = <GrafonExpr>[];
          if (bop == null) {
            exprs.add(expr1);
          } else {
            for (final m2 in Mono.values) {
              for (final f2 in [Face.Center, Face.Down]) {
                final expr2 = table.atMonoFace(m2, f2);
                exprs.add(BinaryOpExpr(expr1, bop, expr2));
              }
            }
          }
          for (var e in exprs) {
            final render = e.renderPlan;
            expect(render.mass > 0, isTrue);
          }
        }
      }
    }
  });

  test('RenderPlan noInvisidot works', () {
    final lineNO = RenderPlan([
      PolyStraight.anchors([Anchor.N, Anchor.O]),
    ]);
    expect(lineNO.noInvisiDots(), lineNO);
    final lineNOIDotS = RenderPlan([
      PolyStraight.anchors([Anchor.N, Anchor.O]),
      InvisiDot.anchors([Anchor.S]),
    ]);

    expect(lineNOIDotS == lineNO, isFalse);
    expect(lineNOIDotS.noInvisiDots(), lineNO);
    expect(lineNOIDotS.height, 0.5);
    expect(lineNOIDotS.noInvisiDots().height, 0.5);
  });
}
