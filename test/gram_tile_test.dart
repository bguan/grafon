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
import 'package:vector_math/vector_math.dart';

/// Unit and Widget Tests for Gram View

/// Mock to verify calls to Canvas and record params for later inspection
class MockCanvas extends Mock implements Canvas {}

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
        if (custPaint.renderObject is RenderCustomPaint) {
          RenderCustomPaint render = custPaint.renderObject;
          expect(render.painter, isA<GramPainter>());
        }
      }
    }
  });

  test('test GramPainter toCanvasCoord and Offset Calculation', () {
    final size = Size(100, 100);
    final scheme = ColorScheme.fromSwatch();
    final painter = GramPainter(Mono.Dot.gram, scheme);

    final coord = GramPainter.toCanvasCoord(Vector2(0, 0), size);
    expect(coord, Vector2(50, 50));
    final offset = GramPainter.toOffset(coord);
    expect(offset, Offset(50, 50));
  });

  test('test GramPainter on Dot based grams', () {
    final size = Size(100, 100);
    final scheme = ColorScheme.fromSwatch();

    for (final f in Face.values) {
      final gram = GramTable.atMonoFace(Mono.Dot, f);
      final painter = GramPainter(gram, scheme);
      final canvas = MockCanvas();

      final penWidth = 10.0; // since size is 100x100, pen width is 0.1 of that

      painter.paint(canvas, size);
      verify(canvas.drawCircle(any, penWidth / 2, any));
      verifyNever(canvas.drawLine(any, any, any));
      verifyNever(canvas.drawPath(any, any));
      verifyNoMoreInteractions(canvas);
    }
  });

  test('test GramPainter on Line based grams', () {
    final size = Size(100, 100);
    final scheme = ColorScheme.fromSwatch();

    for (final m in [Mono.Space, Mono.Cross, Mono.X, Mono.Square, Mono.Sun]) {
      for (final f in Face.values) {
        if (m == Mono.Space && f == Face.Center) {
          // Space Gram has no lines, but it's quad peers are lines
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

    for (final m in [Mono.Circle, Mono.Flower, Mono.Blob]) {
      for (final f in Face.values) {
        final gram = GramTable.atMonoFace(m, f);
        final painter = GramPainter(gram, scheme);
        final canvas = MockCanvas();
        painter.paint(canvas, size);
        verify(canvas.drawPath(any, any));
        verifyNever(canvas.drawLine(any, any, any));
        verifyNever(canvas.drawCircle(any, any, any));
        verifyNoMoreInteractions(canvas);
      }
    }
  });

  test('test GramPainter correctly handles visualCenter', () {
    final size = Size(100, 100);
    final scheme = ColorScheme.fromSwatch();
    final gram = QuadGram([
      PolyLine([Anchor.E, Anchor.N])
    ], Face.Up, ConsPair.AHA);

    final rad = Polar.DEFAULT_ANCHOR_DIST;
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
      PolySpline([Anchor.N, Anchor.N, Anchor.S, Anchor.S])
    ], Face.Up, ConsPair.AHA);

    final p1 = Offset(50, 0);
    final p2 = Offset(50, 100);
    final painter = GramPainter(gram, scheme);
    final canvas = MockCanvas();
    painter.paint(canvas, size);
    final captured = verify(canvas.drawPath(captureAny, any)).captured;
    verifyNoMoreInteractions(canvas);
    expect(captured.length, 1);
    final Path path = captured.first;
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
