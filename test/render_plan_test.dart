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
import 'package:grafon/gram_infra.dart';
import 'package:grafon/operators.dart';
import 'package:grafon/render_plan.dart';

/// Unit Tests for RenderPlan
void main() {
  test('Unary Shrink operator works', () {
    final empty = RenderPlan([PolyStraight.anchors([])]);
    final shrinkEmpty = empty.byUnary(Unary.Shrink);
    expect(shrinkEmpty, empty);
  });
  // TODO: impl tests by migrating old operator tests
  // test('Unary Shrink operator works', () {
  //   final empty = PolyStraight.anchors([]);
  //   final shrinkEmpty = Unary.Shrink.apply(empty);
  //   expect(shrinkEmpty, empty);
  //
  //   final dot = PolyStraight.anchors([Anchor.O]);
  //   final shrinkDot = Unary.Shrink.apply(dot);
  //   expect(shrinkDot, dot);
  //
  //   final hLine = PolyStraight.anchors([Anchor.W, Anchor.E]);
  //   expect(hLine.vectors, [Vector2(-0.5, 0), Vector2(0.5, 0)]);
  //   final shrinkHLine = Unary.Shrink.apply(hLine);
  //   expect(shrinkHLine, PolyStraight([Vector2(-0.25, 0), Vector2(0.25, 0)]));
  //
  //   final vLine = PolyStraight.anchors([Anchor.N, Anchor.S]);
  //   expect(vLine.vectors, [Vector2(0, 0.5), Vector2(0, -0.5)]);
  //   final shrinkVLine = Unary.Shrink.apply(vLine);
  //   expect(shrinkVLine, PolyStraight([Vector2(0, 0.25), Vector2(0, -0.25)]));
  // });
  //
  // test('Unary Up operator works', () {
  //   final empty = PolyStraight.anchors([]);
  //   final upEmpty = Unary.Up.apply(empty);
  //   expect(upEmpty, empty);
  //
  //   final dot = PolyStraight.anchors([Anchor.O]);
  //   expect(dot.vectors, [Vector2(0, 0)]);
  //   final upDot = Unary.Up.apply(dot);
  //   expect(upDot, PolyStraight([Vector2(0, 0.25)]));
  //
  //   final hLine = PolyStraight.anchors([Anchor.W, Anchor.E]);
  //   expect(hLine.vectors, [Vector2(-0.5, 0), Vector2(0.5, 0)]);
  //   final upHLine = Unary.Up.apply(hLine);
  //   expect(upHLine, PolyStraight([Vector2(-0.5, 0.25), Vector2(0.5, 0.25)]));
  //
  //   final vLine = PolyStraight.anchors([Anchor.N, Anchor.S]);
  //   expect(vLine.vectors, [Vector2(0, 0.5), Vector2(0, -0.5)]);
  //   final upVLine = Unary.Up.apply(vLine);
  //   expect(upVLine, PolyStraight([Vector2(0, 0.5), Vector2(0, 0)]));
  // });
  //
  // test('Unary Down operator works', () {
  //   final empty = PolyStraight.anchors([]);
  //   final downEmpty = Unary.Down.apply(empty);
  //   expect(downEmpty, empty);
  //
  //   final dot = PolyStraight.anchors([Anchor.O]);
  //   expect(dot.vectors, [Vector2(0, 0)]);
  //   final downDot = Unary.Down.apply(dot);
  //   expect(downDot, PolyStraight([Vector2(0, -0.25)]));
  //
  //   final hLine = PolyStraight.anchors([Anchor.W, Anchor.E]);
  //   expect(hLine.vectors, [Vector2(-0.5, 0), Vector2(0.5, 0)]);
  //   final downHLine = Unary.Down.apply(hLine);
  //   expect(
  //       downHLine, PolyStraight([Vector2(-0.5, -0.25), Vector2(0.5, -0.25)]));
  //
  //   final vLine = PolyStraight.anchors([Anchor.N, Anchor.S]);
  //   expect(vLine.vectors, [Vector2(0, 0.5), Vector2(0, -0.5)]);
  //   final downVLine = Unary.Down.apply(vLine);
  //   expect(downVLine, PolyStraight([Vector2(0, 0), Vector2(0, -0.5)]));
  // });
  //
  // test('Unary Right operator works', () {
  //   final empty = PolyStraight.anchors([]);
  //   final rightEmpty = Unary.Right.apply(empty);
  //   expect(rightEmpty, empty);
  //
  //   final dot = PolyStraight.anchors([Anchor.O]);
  //   expect(dot.vectors, [Vector2(0, 0)]);
  //   final rightDot = Unary.Right.apply(dot);
  //   expect(rightDot, PolyStraight([Vector2(0.25, 0)]));
  //
  //   final hLine = PolyStraight.anchors([Anchor.W, Anchor.E]);
  //   expect(hLine.vectors, [Vector2(-0.5, 0), Vector2(0.5, 0)]);
  //   final rightHLine = Unary.Right.apply(hLine);
  //   expect(rightHLine, PolyStraight([Vector2(0, 0), Vector2(0.5, 0)]));
  //
  //   final vLine = PolyStraight.anchors([Anchor.N, Anchor.S]);
  //   expect(vLine.vectors, [Vector2(0, 0.5), Vector2(0, -0.5)]);
  //   final rightVLine = Unary.Right.apply(vLine);
  //   expect(rightVLine, PolyStraight([Vector2(0.25, 0.5), Vector2(0.25, -0.5)]));
  // });
  //
  // test('Unary Left operator works', () {
  //   final empty = PolyStraight.anchors([]);
  //   final leftEmpty = Unary.Left.apply(empty);
  //   expect(leftEmpty, empty);
  //
  //   final dot = PolyStraight.anchors([Anchor.O]);
  //   expect(dot.vectors, [Vector2(0, 0)]);
  //   final leftDot = Unary.Left.apply(dot);
  //   expect(leftDot, PolyStraight([Vector2(-0.25, 0)]));
  //
  //   final hLine = PolyStraight.anchors([Anchor.W, Anchor.E]);
  //   expect(hLine.vectors, [Vector2(-0.5, 0), Vector2(0.5, 0)]);
  //   final leftHLine = Unary.Left.apply(hLine);
  //   expect(leftHLine, PolyStraight([Vector2(-0.5, 0), Vector2(0, 0)]));
  //
  //   final vLine = PolyStraight.anchors([Anchor.N, Anchor.S]);
  //   expect(vLine.vectors, [Vector2(0, 0.5), Vector2(0, -0.5)]);
  //   final leftVLine = Unary.Left.apply(vLine);
  //   expect(
  //       leftVLine, PolyStraight([Vector2(-0.25, 0.5), Vector2(-0.25, -0.5)]));
  // });
  //
  // test('Binary Merge operator works', () {
  //   final hLine = PolyStraight.anchors([Anchor.W, Anchor.E]);
  //   expect(hLine.vectors, [Vector2(-0.5, 0), Vector2(0.5, 0)]);
  //   final vLine = PolyStraight.anchors([Anchor.N, Anchor.S]);
  //   expect(vLine.vectors, [Vector2(0, 0.5), Vector2(0, -0.5)]);
  //
  //   final tfm1 = Binary.Merge.apply1(hLine);
  //   final tfm2 = Binary.Merge.apply2(vLine);
  //   expect(tfm1, hLine);
  //   expect(tfm2, vLine);
  // });
  //
  // test('Binary Before operator works', () {
  //   final vLine = PolyStraight.anchors([Anchor.N, Anchor.S]);
  //   expect(vLine.vectors, [Vector2(0, 0.5), Vector2(0, -0.5)]);
  //   final hLine = PolyStraight.anchors([Anchor.W, Anchor.E]);
  //   expect(hLine.vectors, [Vector2(-0.5, 0), Vector2(0.5, 0)]);
  //
  //   final vLineBefore = Binary.Before.apply1(vLine, 0.1);
  //   expect(vLineBefore.runtimeType, PolyStraight);
  //   expect(vLineBefore.vectors, [Vector2(-0.45, 0.5), Vector2(-0.45, -0.5)]);
  //
  //   final vLineAfter = Binary.Before.apply2(vLine, 0.1);
  //   expect(vLineAfter.runtimeType, PolyStraight);
  //   expect(vLineAfter.vectors, [Vector2(0.45, 0.5), Vector2(0.45, -0.5)]);
  //
  //   final hLineBefore = Binary.Before.apply1(hLine, 0.1);
  //   expect(hLineBefore.runtimeType, PolyStraight);
  //   expect(hLineBefore.vectors, [Vector2(-0.5, 0), Vector2(-0.4, 0)]);
  //
  //   final hLineAfter = Binary.Before.apply2(hLine, 0.1);
  //   expect(hLineAfter.runtimeType, PolyStraight);
  //   expect(hLineAfter.vectors, [Vector2(0.4, 0), Vector2(0.5, 0)]);
  //
  //   // sanity check a Curve
  //   final hCurve = PolyCurve.anchors([Anchor.S, Anchor.W, Anchor.E, Anchor.N]);
  //   expect(hCurve.vectors,
  //       [Vector2(0, -0.5), Vector2(-0.5, 0), Vector2(0.5, 0), Vector2(0, 0.5)]);
  //
  //   final hCurveBefore = Binary.Before.apply1(hCurve, 0.1);
  //   expect(hCurveBefore.runtimeType, PolyCurve);
  //   expect(hCurveBefore.vectors, [
  //     Vector2(-0.45, -0.5),
  //     Vector2(-0.5, 0),
  //     Vector2(-0.4, 0),
  //     Vector2(-0.45, 0.5),
  //   ]);
  //
  //   final hCurveAfter = Binary.Before.apply2(hCurve, 0.1);
  //   expect(hCurveAfter.runtimeType, PolyCurve);
  //   expect(hCurveAfter.vectors, [
  //     Vector2(0.45, -0.5),
  //     Vector2(0.4, 0),
  //     Vector2(0.5, 0),
  //     Vector2(0.45, 0.5),
  //   ]);
  // });
  //
  // test('Binary Over operator works', () {
  //   final vLine = PolyStraight.anchors([Anchor.N, Anchor.S]);
  //   expect(vLine.vectors, [Vector2(0, 0.5), Vector2(0, -0.5)]);
  //   final hLine = PolyStraight.anchors([Anchor.W, Anchor.E]);
  //   expect(hLine.vectors, [Vector2(-0.5, 0), Vector2(0.5, 0)]);
  //
  //   final vLineOver = Binary.Over.apply1(vLine, 0.1);
  //   expect(vLineOver.runtimeType, PolyStraight);
  //   expect(vLineOver.vectors, [Vector2(0, 0.5), Vector2(0, 0.4)]);
  //
  //   final vLineUnder = Binary.Over.apply2(vLine, 0.1);
  //   expect(vLineUnder.runtimeType, PolyStraight);
  //   expect(vLineUnder.vectors, [Vector2(0, -0.4), Vector2(0, -0.5)]);
  //
  //   final hLineOver = Binary.Over.apply1(hLine, 0.1);
  //   expect(hLineOver.runtimeType, PolyStraight);
  //   expect(hLineOver.vectors, [Vector2(-0.5, 0.45), Vector2(0.5, 0.45)]);
  //
  //   final hLineUnder = Binary.Over.apply2(hLine, 0.1);
  //   expect(hLineUnder.runtimeType, PolyStraight);
  //   expect(hLineUnder.vectors, [Vector2(-0.5, -0.45), Vector2(0.5, -0.45)]);
  // });
  //
  // test('Binary Around operator works', () {
  //   final circle = PolyCurve.anchors([
  //     Anchor.S,
  //     Anchor.W,
  //     Anchor.N,
  //     Anchor.E,
  //     Anchor.S,
  //     Anchor.W,
  //     Anchor.N,
  //   ]);
  //
  //   expect(circle.vectors, [
  //     Vector2(0, -.5),
  //     Vector2(-0.5, 0),
  //     Vector2(0, .5),
  //     Vector2(0.5, 0),
  //     Vector2(0, -.5),
  //     Vector2(-0.5, 0),
  //     Vector2(0, .5),
  //   ]);
  //
  //   final square = PolyStraight.anchors([
  //     Anchor.W,
  //     Anchor.N,
  //     Anchor.E,
  //     Anchor.S,
  //     Anchor.W,
  //   ]);
  //
  //   expect(square.vectors, [
  //     Vector2(-0.5, 0),
  //     Vector2(0, 0.5),
  //     Vector2(0.5, 0),
  //     Vector2(0, -0.5),
  //     Vector2(-.5, 0),
  //   ]);
  //
  //   final circleOutside = Binary.Around.apply1(circle, 0.2);
  //   expect(circleOutside.runtimeType, PolyCurve);
  //   expect(circleOutside.vectors, circle.vectors);
  //
  //   final squareInside = Binary.Around.apply2(square, 0.2);
  //   expect(squareInside.runtimeType, PolyStraight);
  //   expect(squareInside.vectors, [
  //     Vector2(-0.1, 0),
  //     Vector2(0, 0.1),
  //     Vector2(0.1, 0),
  //     Vector2(0, -0.1),
  //     Vector2(-.1, 0),
  //   ]);
  // });
}
