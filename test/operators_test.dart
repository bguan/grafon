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
import 'package:vector_math/vector_math.dart';

/// Unit Tests for Operators
void main() {
  test('Unary Shrink operator works', () {
    final empty = PolyLine.anchors([]);
    final shrinkEmpty = Unary.Shrink.transform(empty);
    expect(shrinkEmpty, empty);

    final dot = PolyLine.anchors([Anchor.O]);
    final shrinkDot = Unary.Shrink.transform(dot);
    expect(shrinkDot, dot);

    final hLine = PolyLine.anchors([Anchor.W, Anchor.E]);
    expect(hLine.vectors, [Vector2(-0.5, 0), Vector2(0.5, 0)]);
    final shrinkHLine = Unary.Shrink.transform(hLine);
    expect(shrinkHLine, PolyLine([Vector2(-0.25, 0), Vector2(0.25, 0)]));

    final vLine = PolyLine.anchors([Anchor.N, Anchor.S]);
    expect(vLine.vectors, [Vector2(0, 0.5), Vector2(0, -0.5)]);
    final shrinkVLine = Unary.Shrink.transform(vLine);
    expect(shrinkVLine, PolyLine([Vector2(0, 0.25), Vector2(0, -0.25)]));
  });

  test('Unary Up operator works', () {
    final empty = PolyLine.anchors([]);
    final upEmpty = Unary.Up.transform(empty);
    expect(upEmpty, empty);

    final dot = PolyLine.anchors([Anchor.O]);
    expect(dot.vectors, [Vector2(0, 0)]);
    final upDot = Unary.Up.transform(dot);
    expect(upDot, PolyLine([Vector2(0, 0.25)]));

    final hLine = PolyLine.anchors([Anchor.W, Anchor.E]);
    expect(hLine.vectors, [Vector2(-0.5, 0), Vector2(0.5, 0)]);
    final upHLine = Unary.Up.transform(hLine);
    expect(upHLine, PolyLine([Vector2(-0.5, 0.25), Vector2(0.5, 0.25)]));

    final vLine = PolyLine.anchors([Anchor.N, Anchor.S]);
    expect(vLine.vectors, [Vector2(0, 0.5), Vector2(0, -0.5)]);
    final upVLine = Unary.Up.transform(vLine);
    expect(upVLine, PolyLine([Vector2(0, 0.5), Vector2(0, 0)]));
  });

  test('Unary Down operator works', () {
    final empty = PolyLine.anchors([]);
    final downEmpty = Unary.Down.transform(empty);
    expect(downEmpty, empty);

    final dot = PolyLine.anchors([Anchor.O]);
    expect(dot.vectors, [Vector2(0, 0)]);
    final downDot = Unary.Down.transform(dot);
    expect(downDot, PolyLine([Vector2(0, -0.25)]));

    final hLine = PolyLine.anchors([Anchor.W, Anchor.E]);
    expect(hLine.vectors, [Vector2(-0.5, 0), Vector2(0.5, 0)]);
    final downHLine = Unary.Down.transform(hLine);
    expect(downHLine, PolyLine([Vector2(-0.5, -0.25), Vector2(0.5, -0.25)]));

    final vLine = PolyLine.anchors([Anchor.N, Anchor.S]);
    expect(vLine.vectors, [Vector2(0, 0.5), Vector2(0, -0.5)]);
    final downVLine = Unary.Down.transform(vLine);
    expect(downVLine, PolyLine([Vector2(0, 0), Vector2(0, -0.5)]));
  });

  test('Unary Right operator works', () {
    final empty = PolyLine.anchors([]);
    final rightEmpty = Unary.Right.transform(empty);
    expect(rightEmpty, empty);

    final dot = PolyLine.anchors([Anchor.O]);
    expect(dot.vectors, [Vector2(0, 0)]);
    final rightDot = Unary.Right.transform(dot);
    expect(rightDot, PolyLine([Vector2(0.25, 0)]));

    final hLine = PolyLine.anchors([Anchor.W, Anchor.E]);
    expect(hLine.vectors, [Vector2(-0.5, 0), Vector2(0.5, 0)]);
    final rightHLine = Unary.Right.transform(hLine);
    expect(rightHLine, PolyLine([Vector2(0, 0), Vector2(0.5, 0)]));

    final vLine = PolyLine.anchors([Anchor.N, Anchor.S]);
    expect(vLine.vectors, [Vector2(0, 0.5), Vector2(0, -0.5)]);
    final rightVLine = Unary.Right.transform(vLine);
    expect(rightVLine, PolyLine([Vector2(0.25, 0.5), Vector2(0.25, -0.5)]));
  });

  test('Unary Left operator works', () {
    final empty = PolyLine.anchors([]);
    final leftEmpty = Unary.Left.transform(empty);
    expect(leftEmpty, empty);

    final dot = PolyLine.anchors([Anchor.O]);
    expect(dot.vectors, [Vector2(0, 0)]);
    final leftDot = Unary.Left.transform(dot);
    expect(leftDot, PolyLine([Vector2(-0.25, 0)]));

    final hLine = PolyLine.anchors([Anchor.W, Anchor.E]);
    expect(hLine.vectors, [Vector2(-0.5, 0), Vector2(0.5, 0)]);
    final leftHLine = Unary.Left.transform(hLine);
    expect(leftHLine, PolyLine([Vector2(-0.5, 0), Vector2(0, 0)]));

    final vLine = PolyLine.anchors([Anchor.N, Anchor.S]);
    expect(vLine.vectors, [Vector2(0, 0.5), Vector2(0, -0.5)]);
    final leftVLine = Unary.Left.transform(vLine);
    expect(leftVLine, PolyLine([Vector2(-0.25, 0.5), Vector2(-0.25, -0.5)]));
  });

  test('Binary Merge operator works', () {
    final hLine = PolyLine.anchors([Anchor.W, Anchor.E]);
    expect(hLine.vectors, [Vector2(-0.5, 0), Vector2(0.5, 0)]);
    final vLine = PolyLine.anchors([Anchor.N, Anchor.S]);
    expect(vLine.vectors, [Vector2(0, 0.5), Vector2(0, -0.5)]);

    final tfm1 = Binary.Merge.transform1(hLine);
    final tfm2 = Binary.Merge.transform2(vLine);
    expect(tfm1, hLine);
    expect(tfm2, vLine);
  });

  test('Binary Before operator works', () {
    final hLine = PolyLine.anchors([Anchor.W, Anchor.E]);
    expect(hLine.vectors, [Vector2(-0.5, 0), Vector2(0.5, 0)]);
    final vLine = PolyLine.anchors([Anchor.N, Anchor.S]);
    expect(vLine.vectors, [Vector2(0, 0.5), Vector2(0, -0.5)]);

    final tfm1 = Binary.Before.transform1(hLine);
    final tfm2 = Binary.Before.transform2(vLine);
    expect(tfm1, Unary.Left.transform(hLine));
    expect(tfm2, Unary.Right.transform(vLine));
  });

  test('Binary Over operator works', () {
    final hLine = PolyLine.anchors([Anchor.W, Anchor.E]);
    expect(hLine.vectors, [Vector2(-0.5, 0), Vector2(0.5, 0)]);
    final vLine = PolyLine.anchors([Anchor.N, Anchor.S]);
    expect(vLine.vectors, [Vector2(0, 0.5), Vector2(0, -0.5)]);

    final tfm1 = Binary.Over.transform1(hLine);
    final tfm2 = Binary.Over.transform2(vLine);
    expect(tfm1, Unary.Up.transform(hLine));
    expect(tfm2, Unary.Down.transform(vLine));
  });

  test('Binary Around operator works', () {
    final circle = PolySpline.anchors([
      Anchor.S,
      Anchor.W,
      Anchor.N,
      Anchor.E,
      Anchor.S,
      Anchor.W,
      Anchor.N,
    ]);
    expect(circle.vectors, [
      Vector2(0, -.5),
      Vector2(-0.5, 0),
      Vector2(0, .5),
      Vector2(0.5, 0),
      Vector2(0, -.5),
      Vector2(-0.5, 0),
      Vector2(0, .5),
    ]);
    final square = PolyLine.anchors([
      Anchor.W,
      Anchor.N,
      Anchor.E,
      Anchor.S,
      Anchor.W,
    ]);
    expect(square.vectors, [
      Vector2(-0.5, 0),
      Vector2(0, 0.5),
      Vector2(0.5, 0),
      Vector2(0, -0.5),
      Vector2(-.5, 0),
    ]);

    final tfm1 = Binary.Around.transform1(circle);
    final tfm2 = Binary.Around.transform2(square);
    expect(tfm1, circle);
    expect(tfm2, Unary.Shrink.transform(square));
  });
}
