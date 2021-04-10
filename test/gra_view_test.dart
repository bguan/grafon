import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grafon/gra_infra.dart';
import 'package:grafon/gra_table.dart';
import 'package:grafon/gra_view.dart';
import 'package:grafon/phonetics.dart';
import 'package:mockito/mockito.dart';
import 'package:vector_math/vector_math.dart';

class MockCanvas extends Mock implements Canvas {}

void main() {
  testWidgets('GraView has a CustomPaint for every Gra',
      (WidgetTester tester) async {
    for (final cp in ConsPair.values) {
      for (final v in Vowel.values) {
        final gra = GraTable.atConsPairVowel(cp, v);
        await tester.pumpWidget(GraView(gra, Size(100, 100)));
        expect(find.byType(CustomPaint), findsOneWidget);
        final custPaint = find.byType(CustomPaint).evaluate().first;
        if (custPaint.renderObject is RenderCustomPaint) {
          RenderCustomPaint render = custPaint.renderObject;
          expect(render.painter, isA<GraPainter>());
        }
      }
    }
  });

  test('test GraPainter toCanvasCoord and Offset Calculation', () {
    final size = Size(100, 100);
    final scheme = ColorScheme.fromSwatch();
    final painter = GraPainter(Mono.Dot.gra, scheme);

    final coord = painter.toCanvasCoord(Vector2(0, 0), size);
    expect(coord, Vector2(50, 50));
    final offset = painter.toOffset(coord);
    expect(offset, Offset(50, 50));
  });

  test('test GraPainter on Dot based gras with mock canvas', () {
    final size = Size(100, 100);
    final scheme = ColorScheme.fromSwatch();

    for (final f in Face.values) {
      final gra = GraTable.atMonoFace(Mono.Dot, f);
      final painter = GraPainter(gra, scheme);
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
          // Space Gra has no lines, but it's quad peers are lines
          continue;
        }
        final gra = GraTable.atMonoFace(m, f);
        final painter = GraPainter(gra, scheme);
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
        final gra = GraTable.atMonoFace(m, f);
        final painter = GraPainter(gra, scheme);
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
