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
import 'package:grafon/grafon_widget.dart';
import 'package:grafon/gram_infra.dart';
import 'package:grafon/gram_table.dart';
import 'package:grafon/phonetics.dart';
import 'package:mockito/mockito.dart';
import 'package:tuple/tuple.dart';
import 'package:vector_math/vector_math.dart';

/// Unit and Widget Tests for Gram View

/// Mocks to verify calls to Canvas and record params for later inspection
class MockCanvas extends Mock implements Canvas {
  final List<Tuple3<Offset, double, Paint>> drawCircleArgs = [];
  final List<Tuple3<Offset, Offset, Paint>> drawLineArgs = [];
  final List<Tuple2<Path, Paint>> drawPathArgs = [];

  @override
  void drawCircle(Offset? c, double? r, Paint? paint) {
    if (c != null && r != null && paint != null) {
      // not in verification but in real call, record the params
      drawCircleArgs.add(Tuple3(c, r, paint));
    }
    super.noSuchMethod(Invocation.method(#drawCircle, [c, r, paint]));
  }

  @override
  void drawLine(Offset? p1, Offset? p2, Paint? paint) {
    if (p1 != null && p2 != null && paint != null) {
      // not in verification but in real call, record the params
      drawLineArgs.add(Tuple3(p1, p2, paint));
    }
    super.noSuchMethod(Invocation.method(#drawLine, [p1, p2, paint]));
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
        await tester.pumpWidget(GrafonTile(gram, height: 100));
        expect(find.byType(CustomPaint), findsOneWidget);
        final custPaint = find.byType(CustomPaint).evaluate().first;
        expect(custPaint.renderObject, isNotNull);
        final renderObj = custPaint.renderObject!;
        if (renderObj is RenderCustomPaint) {
          RenderCustomPaint render = renderObj;
          expect(render.painter, isA<GrafonPainter>());
        }
      }
    }
  });

  test('test GramPainter toCanvasCoord and Offset Calculation', () {
    final coord =
        GrafonPainter.toCanvasCoord(Vector2(0, 0), Size(100, 100), Size(1, 1));
    expect(coord, Vector2(50, 50));
    final offset = GrafonPainter.toOffset(coord);
    expect(offset, Offset(50, 50));
  });

  test('test GramPainter on Dot based grams', () {
    final size = Size(100, 100);
    final scheme = ColorScheme.fromSwatch();

    final dotGram = Mono.Dot.gram;
    final painter = GrafonPainter(dotGram, scheme: scheme);
    final canvas = MockCanvas();

    painter.paint(canvas, size);
    verify(canvas.drawCircle(any, any, any));

    verifyNever(canvas.drawPath(any, any));
    verifyNever(canvas.drawLine(any, any, any));
    verifyNoMoreInteractions(canvas);

    final c = canvas.drawCircleArgs.first.item1;
    final r = canvas.drawCircleArgs.first.item2;
    final paint = canvas.drawCircleArgs.first.item3;

    expect(c.dx, 50.0);
    expect(c.dy, 50.0);
    expect(paint.strokeWidth, 5.0);
    expect(paint.color.value, scheme.primary.value);
    expect(paint.style, PaintingStyle.stroke);
    expect(paint.strokeCap, StrokeCap.round);
    expect(paint.strokeJoin, StrokeJoin.round);
  });

  test('test GramPainter on Line based grams', () {
    final size = Size(100, 100);
    final scheme = ColorScheme.fromSwatch();

    for (Gram g in [
      ...Quads.Line.grams.all,
      Mono.Cross.gram,
      ...Quads.Corner.grams.all,
      Mono.X.gram,
      ...Quads.Angle.grams.all,
      Mono.Square.gram,
      ...Quads.Gate.grams.all,
      Mono.Sun.gram,
      Mono.Light.gram,
      ...Quads.Zap.grams.all,
    ]) {
      final painter = GrafonPainter(g, scheme: scheme);
      final canvas = MockCanvas();
      painter.paint(canvas, size);
      verify(canvas.drawLine(any, any, any));
      verifyNever(canvas.drawPath(any, any));
      verifyNoMoreInteractions(canvas);
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
      ...Quads.Swirl.grams.all,
    ];
    for (var gram in splineGrams) {
      final painter = GrafonPainter(gram, scheme: scheme);
      final canvas = MockCanvas();
      painter.paint(canvas, size);
      verify(canvas.drawPath(any, any));
      verifyNever(canvas.drawLine(any, any, any));
      verifyNoMoreInteractions(canvas);
    }
  });

  test('test GramPainter correctly handles visualCenter', () {
    final size = Size(100, 100);
    final scheme = ColorScheme.fromSwatch();
    final gram = QuadGram([
      PolyStraight.anchors([Anchor.E, Anchor.N])
    ], Face.Up, ConsPair.aHa);

    final rad = AnchorHelper.OUTER_DIST;
    final avgX = (rad + 0.0) / 2; // should be .25
    final avgY = (0.0 + rad) / 2; // should be .25
    final canvasShiftX = -avgX * 100; // should be -25
    final canvasShiftY = avgY * 100; // should be +25
    final p1 = Offset(100 + canvasShiftX, 50 + canvasShiftY); // (75, 75)
    final p2 = Offset(50 + canvasShiftX, 0 + canvasShiftY); // (25, 25)
    final painter = GrafonPainter(gram, scheme: scheme);
    final canvas = MockCanvas();
    painter.paint(canvas, size);
    verify(canvas.drawLine(p1, p2, any));
    verifyNoMoreInteractions(canvas);
  });

  test('test GramPainter correctly handles PolySpline degenerate case', () {
    final size = Size(100, 100);
    final scheme = ColorScheme.fromSwatch();

    final gram = QuadGram([
      PolyCurve.anchors([Anchor.N, Anchor.N, Anchor.S, Anchor.S])
    ], Face.Up, ConsPair.aHa);

    final p1 = Offset(50, 0);
    final p2 = Offset(50, 100);
    final painter = GrafonPainter(gram, scheme: scheme);
    final canvas = MockCanvas();
    painter.paint(canvas, size);
    verify(canvas.drawPath(any, any));
    verifyNoMoreInteractions(canvas);
    final path = canvas.drawPathArgs.first.item1;
    expect(path.contains(p1) && path.contains(p2), isTrue);
  });
}
