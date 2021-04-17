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

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grafon/gram_infra.dart';
import 'package:grafon/gram_table.dart';
import 'package:grafon/gram_tile.dart';
import 'package:grafon/phonetics.dart';
import 'package:mockito/mockito.dart';
import 'package:tuple/tuple.dart';
import 'package:vector_math/vector_math.dart';

/// Unit and Widget Tests for Gram View

/// Mocks to verify calls to Canvas and record params for later inspection
class MockCanvas extends Mock implements Canvas {
  final List<Tuple3<Offset, Offset, Paint>> drawLineArgs = [];
  final List<Tuple3<Offset, double, Paint>> drawCircleArgs = [];
  final List<Tuple2<Path, Paint>> drawPathArgs = [];

  @override
  void drawLine(Offset? p1, Offset? p2, Paint? paint) {
    if (p1 != null && p2 != null && paint != null) {
      // not in verification but in real call, record the params
      drawLineArgs.add(Tuple3(p1, p2, paint));
    }
    super.noSuchMethod(Invocation.method(#drawLine, [p1, p2, paint]));
  }

  @override
  void drawCircle(Offset? offset, double? radius, Paint? paint) {
    if (offset != null && radius != null && paint != null) {
      // not in verification but in real call, record the params
      drawCircleArgs.add(Tuple3(offset, radius, paint));
    }
    super.noSuchMethod(Invocation.method(#drawCircle, [offset, radius, paint]));
  }

  @override
  void drawPath(Path? path, Paint? paint) {
    if (path != null && paint != null) {
      // not in verification but in real call, record the params
      drawPathArgs.add(Tuple2(path, paint));
    }
    super.noSuchMethod(Invocation.method(#drawPath, [path, paint]));
  }
}

/// Entry point for Tests
void main() {
  testWidgets('GramTile has a CustomPaint for every Gram',
      (WidgetTester tester) async {
    for (final cp in ConsPair.values) {
      for (final v in Vowel.values) {
        final gram = GramTable.atConsPairVowel(cp, v);
        await tester.pumpWidget(GramTile(gram, Size(100, 100)));
        expect(find.byType(CustomPaint), findsOneWidget);
        final custPaint = find.byType(CustomPaint).evaluate().first;
        expect(custPaint.renderObject, isNotNull);
        final renderObj = custPaint.renderObject!;
        if (renderObj is RenderCustomPaint) {
          RenderCustomPaint render = renderObj;
          expect(render.painter, isA<GramPainter>());
        }
      }
    }
  });

  test('test GramPainter toCanvasCoord and Offset Calculation', () {
    final size = Size(100, 100);
    final coord = GramPainter.toCanvasCoord(Vector2(0, 0), size);
    expect(coord, Vector2(50, 50));
    final offset = GramPainter.toOffset(coord);
    expect(offset, Offset(50, 50));
  });

  test('test GramPainter on Dot based grams', () {
    final size = Size(100, 100);
    final scheme = ColorScheme.fromSwatch();

    final dotGram = Mono.Dot.gram;
    final painter = GramPainter(dotGram, scheme);
    final canvas = MockCanvas();

    final penWidth = 10.0; // since size is 100x100, pen width is 0.1 of that

    painter.paint(canvas, size);
    verify(canvas.drawCircle(any, penWidth / 2, any));

    verifyNever(canvas.drawLine(any, any, any));
    verifyNever(canvas.drawPath(any, any));
    verifyNoMoreInteractions(canvas);

    final offset = canvas.drawCircleArgs.first.item1;
    final radius = canvas.drawCircleArgs.first.item2;
    final paint = canvas.drawCircleArgs.first.item3;

    expect(offset.dx, 50.0);
    expect(offset.dy, 50.0);
    expect(radius, 5.0);
    expect(paint.strokeWidth, 10.0);
    expect(paint.color.value, scheme.primary.value);
    expect(paint.style, PaintingStyle.stroke);
    expect(paint.strokeCap, StrokeCap.round);
    expect(paint.strokeJoin, StrokeJoin.round);
  });

  test('test GramPainter on Line based grams', () {
    final size = Size(100, 100);
    final scheme = ColorScheme.fromSwatch();

    for (final m in [Mono.Dot, Mono.Cross, Mono.X, Mono.Square, Mono.Sun]) {
      for (final f in Face.values) {
        if (m == Mono.Dot && f == Face.Center) {
          // Dot Gram has no lines, but it's quad peers are lines
          continue;
        }
        final gram = GramTable.atMonoFace(m, f);
        final painter = GramPainter(gram, scheme);
        final canvas = MockCanvas();
        painter.paint(canvas, size);
        verify(canvas.drawLine(any, any, any));
        verifyNever(canvas.drawCircle(any, any, any));
        verifyNever(canvas.drawPath(any, any));
        verifyNoMoreInteractions(canvas);
      }
    }
  });

  test('test GramPainter on Spline based grams', () {
    final size = Size(100, 100);
    final scheme = ColorScheme.fromSwatch();
    final splineGrams = [
      Mono.Circle.gram,
      ...Quads.Arc.grams.all,
      Mono.Flower.gram,
      ...Quads.Flow.grams.all,
      Mono.Blob.gram,
      ...Quads.Swirl.grams.all,
    ];
    for (var gram in splineGrams) {
      final painter = GramPainter(gram, scheme);
      final canvas = MockCanvas();
      painter.paint(canvas, size);
      verify(canvas.drawPath(any, any));
      verifyNever(canvas.drawLine(any, any, any));
      verifyNever(canvas.drawCircle(any, any, any));
      verifyNoMoreInteractions(canvas);
    }
  });

  test('test GramPainter correctly handles visualCenter', () {
    final size = Size(100, 100);
    final scheme = ColorScheme.fromSwatch();
    final gram = QuadGram([
      PolyLine.anchors([Anchor.E, Anchor.N])
    ], Face.Up, ConsPair.AHA);

    final rad = AnchorHelper.OUTER_DIST;
    final avgX = (rad + 0.0) / 2; // should be .25
    final avgY = (0.0 + rad) / 2; // should be .25
    final canvasShiftX = -avgX * 100; // should be -25
    final canvasShiftY = avgY * 100; // should be +25
    final p1 = Offset(100 + canvasShiftX, 50 + canvasShiftY);
    final p2 = Offset(50 + canvasShiftX, 0 + canvasShiftY);
    final painter = GramPainter(gram, scheme);
    final canvas = MockCanvas();
    painter.paint(canvas, size);
    verify(canvas.drawLine(p1, p2, any));
    verifyNoMoreInteractions(canvas);
  });

  test('test GramPainter correctly handles PolySpline degenerate case', () {
    final size = Size(100, 100);
    final scheme = ColorScheme.fromSwatch();

    final gram = QuadGram([
      PolySpline.anchors([Anchor.N, Anchor.N, Anchor.S, Anchor.S])
    ], Face.Up, ConsPair.AHA);

    final p1 = Offset(50, 0);
    final p2 = Offset(50, 100);
    final painter = GramPainter(gram, scheme);
    final canvas = MockCanvas();
    painter.paint(canvas, size);
    verify(canvas.drawPath(any, any));
    verifyNoMoreInteractions(canvas);
    final path = canvas.drawPathArgs.first.item1;
    expect(path.contains(p1) && path.contains(p2), isTrue);
  });

  test('test GramPainter compute Spline begin & end normal control pts', () {
    final bc = GramPainter.calcBegCtl(
        Anchor.NW.vector, Anchor.N.vector, Anchor.S.vector);
    final ec = GramPainter.calcEndCtl(
        Anchor.N.vector, Anchor.S.vector, Anchor.SE.vector);
    expect(bc.x, moreOrLessEquals(0.3, epsilon: 0.1));
    expect(bc.y, moreOrLessEquals(0.3, epsilon: 0.1));
    expect(ec.x, moreOrLessEquals(-0.3, epsilon: 0.1));
    expect(ec.y, moreOrLessEquals(-0.3, epsilon: 0.1));
  });

  test('test GramPainter compute Spline begin & end dorminant control pts', () {
    final bc = GramPainter.calcBegCtl(
        Anchor.NW.vector, Anchor.N.vector, Anchor.S.vector,
        isDorminant: true);
    final ec = GramPainter.calcEndCtl(
        Anchor.N.vector, Anchor.S.vector, Anchor.SE.vector,
        isDorminant: true);
    expect(bc.x, moreOrLessEquals(0.6, epsilon: 0.1));
    expect(bc.y, moreOrLessEquals(0.1, epsilon: 0.1));
    expect(ec.x, moreOrLessEquals(-0.6, epsilon: 0.1));
    expect(ec.y, moreOrLessEquals(-0.1, epsilon: 0.1));
  });
}
