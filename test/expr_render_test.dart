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

  test('RenderPlan next operators leaves expected gap btw non-fixed expr', () {
    final r = Quads.Arc.left.next(Quads.Arc.right).renderPlan;
    final lines = r.lines.where((l) => l is! InvisiDot).toList();
    expect(lines.length, 2);
    // Previous height about same as Next
    expect(lines[0].metrics.height, moreOrLessEquals(lines[1].metrics.height));
    // Previous don't overlap with Next
    expect(lines[0].metrics.xMax, lessThan(lines[1].metrics.xMin));
    // Gap is not too big
    expect(lines[1].metrics.xMin - lines[0].metrics.xMax, lessThan(0.2));
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
    expect(exprWth, closeTo(5 * upWth + 4 * RenderPlan.STD_GAP, 0.1));
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
    expect(lines[1].metrics.xMin - lines[0].metrics.xMax, lessThan(.2));
  });

  test('RenderPlan over operators leaves gap btw fixed aspect and non-fixed',
      () {
    final r = Mono.Dot.over(Quads.Line.up).renderPlan;
    final lines = r.lines.toList();
    expect(lines.length, 2);
    final m0 = lines[0].metrics;
    final m1 = lines[1].metrics;
    // Previous width about same as Next
    expect(m0.width, moreOrLessEquals(m1.width));
    // Previous don't overlap with Next
    expect(m1.yMax, lessThan(m0.yMin));
    // Gap is not too big
    expect(m0.yMin - m1.yMax, lessThan(.25));
  });

  test('RenderPlan equality, hashcode, toString works', () {
    final dot = Mono.Dot.gram.renderPlan;
    final dotPlan = RenderPlan([
      PolyDot.anchors([Anchor.O])
    ]);
    final circle = Mono.Circle.gram.renderPlan;

    expect(dot == dot, isTrue);
    expect(dot == dotPlan, isTrue);
    expect(dot.hashCode == dotPlan.hashCode, isTrue);
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

  test('Unary Shrink operator works', () {
    final cross = RenderPlan([
      PolyStraight.anchors([Anchor.N, Anchor.S]),
      PolyStraight.anchors([Anchor.W, Anchor.E]),
    ]);

    final shrinkCross = cross.byUnary(Unary.Shrink);
    final filtered =
        RenderPlan(shrinkCross.lines.where((l) => l is! InvisiDot));

    expect(cross.width > filtered.width, isTrue);
    expect(cross.height > filtered.height, isTrue);
    expect(shrinkCross.width > filtered.width, isTrue);
    expect(shrinkCross.height > filtered.height, isTrue);

    expect(
        shrinkCross,
        RenderPlan([
          PolyStraight([Vector2(0, .25), Vector2(0, -.25)]),
          PolyStraight([Vector2(-.25, 0), Vector2(.25, 0)]),
          InvisiDot([Vector2(-0.5, -0.5), Vector2(0.5, 0.5)])
        ]));
  });

  test('Unary Up operator works', () {
    final fixedCross = RenderPlan([
      PolyStraight.anchors([Anchor.N, Anchor.S], isFixedAspect: true),
      PolyStraight.anchors([Anchor.W, Anchor.E], isFixedAspect: true),
    ]);

    final upFixedCross = fixedCross.byUnary(Unary.Up);
    final fixedFiltered =
        RenderPlan(upFixedCross.lines.where((l) => l is! InvisiDot));

    expect(fixedCross.width > fixedFiltered.width, isTrue);
    expect(fixedCross.height > fixedFiltered.height, isTrue);
    expect(upFixedCross.width, fixedFiltered.width);
    expect(upFixedCross.height > fixedFiltered.height, isTrue);

    expect(
        upFixedCross,
        RenderPlan([
          PolyStraight([Vector2(0, .5), Vector2(0, 0)], isFixedAspect: true),
          PolyStraight([Vector2(-.25, .25), Vector2(.25, .25)],
              isFixedAspect: true),
          InvisiDot([Vector2(0, -0.5)], isFixedAspect: true)
        ]));

    final flexCross = RenderPlan([
      PolyStraight.anchors([Anchor.N, Anchor.S], isFixedAspect: false),
      PolyStraight.anchors([Anchor.W, Anchor.E], isFixedAspect: false),
    ]);

    final upFlexCross = flexCross.byUnary(Unary.Up);
    final filtered =
        RenderPlan(upFlexCross.lines.where((l) => l is! InvisiDot));

    expect(flexCross.width, filtered.width);
    expect(flexCross.height > filtered.height, isTrue);
    expect(upFlexCross.width, filtered.width);
    expect(upFlexCross.height > filtered.height, isTrue);

    expect(
        upFlexCross,
        RenderPlan([
          PolyStraight([Vector2(0, .5), Vector2(0, -.16)]),
          PolyStraight([Vector2(-.5, .17), Vector2(.5, .17)]),
          InvisiDot([Vector2(0, -0.5)])
        ]));
  });

  test('Unary Down operator works', () {
    final fixedCross = RenderPlan([
      PolyStraight.anchors([Anchor.N, Anchor.S], isFixedAspect: true),
      PolyStraight.anchors([Anchor.W, Anchor.E], isFixedAspect: true),
    ]);

    final downFixedCross = fixedCross.byUnary(Unary.Down);
    final fixedFiltered =
        RenderPlan(downFixedCross.lines.where((l) => l is! InvisiDot));

    expect(fixedCross.width > fixedFiltered.width, isTrue);
    expect(fixedCross.height > fixedFiltered.height, isTrue);
    expect(downFixedCross.width, fixedFiltered.width);
    expect(downFixedCross.height > fixedFiltered.height, isTrue);

    expect(
        downFixedCross,
        RenderPlan([
          PolyStraight([Vector2(0, 0), Vector2(0, -.5)], isFixedAspect: true),
          PolyStraight([Vector2(-.25, -.25), Vector2(.25, -.25)],
              isFixedAspect: true),
          InvisiDot([Vector2(0, 0.5)], isFixedAspect: true)
        ]));

    final flexCross = RenderPlan([
      PolyStraight.anchors([Anchor.N, Anchor.S], isFixedAspect: false),
      PolyStraight.anchors([Anchor.W, Anchor.E], isFixedAspect: false),
    ]);

    final downFlexCross = flexCross.byUnary(Unary.Down);
    final filtered =
        RenderPlan(downFlexCross.lines.where((l) => l is! InvisiDot));

    expect(flexCross.width, filtered.width);
    expect(flexCross.height > filtered.height, isTrue);
    expect(downFlexCross.width, filtered.width);
    expect(downFlexCross.height > filtered.height, isTrue);

    expect(
        downFlexCross,
        RenderPlan([
          PolyStraight([Vector2(0, .16), Vector2(0, -.5)]),
          PolyStraight([Vector2(-.5, -.17), Vector2(.5, -.17)]),
          InvisiDot([Vector2(0, 0.5)])
        ]));
  });

  test('Unary Left operator works', () {
    final fixedCross = RenderPlan([
      PolyStraight.anchors([Anchor.N, Anchor.S], isFixedAspect: true),
      PolyStraight.anchors([Anchor.W, Anchor.E], isFixedAspect: true),
    ]);

    final leftFixedCross = fixedCross.byUnary(Unary.Left);
    final fixedFiltered =
        RenderPlan(leftFixedCross.lines.where((l) => l is! InvisiDot));

    expect(fixedCross.width > fixedFiltered.width, isTrue);
    expect(fixedCross.height > fixedFiltered.height, isTrue);
    expect(leftFixedCross.width > fixedFiltered.width, isTrue);
    expect(leftFixedCross.height, fixedFiltered.height);

    expect(
        leftFixedCross,
        RenderPlan([
          PolyStraight([Vector2(-.25, .25), Vector2(-.25, -.25)],
              isFixedAspect: true),
          PolyStraight([Vector2(-.5, 0), Vector2(0, 0)], isFixedAspect: true),
          InvisiDot([Vector2(.5, 0)], isFixedAspect: true)
        ]));

    final flexCross = RenderPlan([
      PolyStraight.anchors([Anchor.N, Anchor.S], isFixedAspect: false),
      PolyStraight.anchors([Anchor.W, Anchor.E], isFixedAspect: false),
    ]);

    final leftFlexCross = flexCross.byUnary(Unary.Left);
    final filtered =
        RenderPlan(leftFlexCross.lines.where((l) => l is! InvisiDot));

    expect(flexCross.width > filtered.width, isTrue);
    expect(flexCross.height, filtered.height);
    expect(leftFlexCross.width > filtered.width, isTrue);
    expect(leftFlexCross.height, filtered.height);

    expect(
        leftFlexCross,
        RenderPlan([
          PolyStraight([Vector2(-.17, .5), Vector2(-.17, -.5)]),
          PolyStraight([Vector2(-.5, 0), Vector2(.16, 0)]),
          InvisiDot([Vector2(.5, 0)])
        ]));
  });

  test('Unary Right operator works', () {
    final fixedCross = RenderPlan([
      PolyStraight.anchors([Anchor.N, Anchor.S], isFixedAspect: true),
      PolyStraight.anchors([Anchor.W, Anchor.E], isFixedAspect: true),
    ]);

    final rightFixedCross = fixedCross.byUnary(Unary.Right);
    final fixedFiltered =
        RenderPlan(rightFixedCross.lines.where((l) => l is! InvisiDot));

    expect(fixedCross.width > fixedFiltered.width, isTrue);
    expect(fixedCross.height > fixedFiltered.height, isTrue);
    expect(rightFixedCross.width > fixedFiltered.width, isTrue);
    expect(rightFixedCross.height, fixedFiltered.height);

    expect(
        rightFixedCross,
        RenderPlan([
          PolyStraight([Vector2(.25, .25), Vector2(.25, -.25)],
              isFixedAspect: true),
          PolyStraight([Vector2(0, 0), Vector2(.5, 0)], isFixedAspect: true),
          InvisiDot([Vector2(-.5, 0)], isFixedAspect: true)
        ]));

    final flexCross = RenderPlan([
      PolyStraight.anchors([Anchor.N, Anchor.S], isFixedAspect: false),
      PolyStraight.anchors([Anchor.W, Anchor.E], isFixedAspect: false),
    ]);

    final rightFlexCross = flexCross.byUnary(Unary.Right);
    final filtered =
        RenderPlan(rightFlexCross.lines.where((l) => l is! InvisiDot));

    expect(flexCross.width > filtered.width, isTrue);
    expect(flexCross.height, filtered.height);
    expect(rightFlexCross.width > filtered.width, isTrue);
    expect(rightFlexCross.height, filtered.height);

    expect(
        rightFlexCross,
        RenderPlan([
          PolyStraight([Vector2(.17, .5), Vector2(.17, -.5)]),
          PolyStraight([Vector2(-.16, 0), Vector2(.5, 0)]),
          InvisiDot([Vector2(-.5, 0)])
        ]));
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
    expect(lines[1].metrics.xMin - lines[0].metrics.xMax, lessThan(20));
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

  test('Brute force all level 1 gram combo RenderPlan', () {
    final table = GramTable();
    for (final m1 in Mono.values) {
      for (final f1 in Face.values) {
        final g1 = table.atMonoFace(m1, f1);
        for (final uop1 in [null, ...Unary.values]) {
          final expr1 = uop1 == null ? g1 : UnaryOpExpr(uop1, g1);
          for (final bop in [null, ...Binary.values]) {
            final exprs = <GrafonExpr>[];
            if (bop == null) {
              exprs.add(expr1);
            } else {
              for (final m2 in Mono.values) {
                for (final f2 in Face.values) {
                  final g2 = table.atMonoFace(m2, f2);
                  for (final uop2 in [null, ...Unary.values]) {
                    final expr2 = uop2 == null ? g2 : UnaryOpExpr(uop2, g2);
                    exprs.add(BinaryOpExpr(expr1, bop, expr2));
                  }
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
    }
  });
}
