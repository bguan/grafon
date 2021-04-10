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

/// Mock Canvas to verify calls to Canvas
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

  test('test GraPainter toCanvasCoord and Offset Calculation', () {
    final size = Size(100, 100);
    final scheme = ColorScheme.fromSwatch();
    final painter = GramPainter(Mono.Dot.gram, scheme);

    final coord = painter.toCanvasCoord(Vector2(0, 0), size);
    expect(coord, Vector2(50, 50));
    final offset = painter.toOffset(coord);
    expect(offset, Offset(50, 50));
  });

  test('test GraPainter on Dot based gras with mock canvas', () {
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

  test('test GraPainter on Line based gras with mock canvas', () {
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

  test('test GraPainter on Spline based gras with mock canvas', () {
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
}
