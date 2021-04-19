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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

import 'expression.dart';
import 'gram_infra.dart';

/// Class to provide widget rendering of Gram expressions.
class GramExprTile extends StatelessWidget {
  final GramExpression gram;
  final Size? size;

  GramExprTile(this.gram, {this.size}) : super();

  @override
  Widget build(BuildContext ctx) {
    final useSize = size ?? MediaQuery.of(ctx).size;
    return CustomPaint(
      size: useSize,
      painter: GramExprPainter(gram, Theme.of(ctx).colorScheme),
    );
  }
}

/// The custom painter to provide canvas rendering logic
class GramExprPainter extends CustomPainter {
  static const STROKE_WIDTH_SCALE = 0.1;
  static const DOMINANT_CTRL_SCALE = 0.6;
  static const STD_CTRL_SCALE = 0.4;
  final GramExpression gram;
  final ColorScheme scheme;

  GramExprPainter(this.gram, this.scheme);

  static Vector2 toCanvasCoord(Vector2 v, Size size) => v.clone()
    ..multiply(Vector2(size.width, -size.height))
    ..add(Vector2(size.width / 2, size.height / 2));

  static Offset toOffset(Vector2 v) => Offset(v.x, v.y);

  @override
  void paint(Canvas canvas, Size size) {
    final penWidth = (size.shortestSide * STROKE_WIDTH_SCALE).clamp(1.0, 10.0);

    final paint = Paint()
      ..color = scheme.primary
      ..strokeWidth = penWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final centerShift = -gram.visualCenter;

    for (final p in gram.paths) {
      if (p is PolyLine) {
        drawPolyLine(p, centerShift, size, canvas, paint);
      } else if (p is PolySpline) {
        drawPolySpline(p, centerShift, size, canvas, paint);
      }
    }
  }

  void drawPolySpline(
    PolySpline p,
    Vector2 centerShift,
    Size size,
    Canvas canvas,
    Paint paint,
  ) {
    var path = Path();
    final len = p.numPts;
    for (var i = 1; i < len - 2; i++) {
      final pre = p.vectors[max(0, i - 1)] + centerShift;
      final beg = p.vectors[max(1, i)] + centerShift;
      final end = p.vectors[min(i + 1, len - 1)] + centerShift;
      final next = p.vectors[min(i + 2, len - 1)] + centerShift;
      if (i == 1) {
        final initCoord = toCanvasCoord(beg, size);
        path.moveTo(initCoord.x, initCoord.y);
      }
      final toCoord = toCanvasCoord(end, size);
      if (pre == beg && end == next) {
        // degenerate case, just a straight line
        path.lineTo(toCoord.x, toCoord.y);
      } else {
        if (pre == beg) {
          // use a dorminant endCtl as bezier Ctl
          final ctl = calcEndCtl(beg, end, next, isDorminant: true);
          final ctlCoord = toCanvasCoord(ctl, size);
          path.quadraticBezierTo(ctlCoord.x, ctlCoord.y, toCoord.x, toCoord.y);
        } else if (end == next) {
          // use a dorminant begCtl as bezier Ctl
          final ctl = calcBegCtl(pre, beg, end, isDorminant: true);
          final ctlCoord = toCanvasCoord(ctl, size);
          path.quadraticBezierTo(ctlCoord.x, ctlCoord.y, toCoord.x, toCoord.y);
        } else {
          final begCtl = calcBegCtl(pre, beg, end);
          final endCtl = calcEndCtl(beg, end, next);
          final begCtlCoord = toCanvasCoord(begCtl, size);
          final endCtlCoord = toCanvasCoord(endCtl, size);
          path.cubicTo(
            begCtlCoord.x,
            begCtlCoord.y,
            endCtlCoord.x,
            endCtlCoord.y,
            toCoord.x,
            toCoord.y,
          );
        }
      }
    }
    canvas.drawPath(path, paint);
  }

  void drawPolyLine(
    PolyLine p,
    Vector2 centerShift,
    Size size,
    Canvas canvas,
    Paint paint,
  ) {
    final len = p.numPts;
    // enter loop once even if len is 1 to draw dots as line of same point
    for (var i = 0; i < max(1, len - 1); i++) {
      final from = toCanvasCoord(p.vectors[i] + centerShift, size);
      final to =
          toCanvasCoord(p.vectors[min(i + 1, len - 1)] + centerShift, size);

      final origStrokeWidth = paint.strokeWidth;

      // in degenerate case of from == to i.e. a Point, double stroke width
      if (from == to) paint.strokeWidth = 2 * origStrokeWidth;
      canvas.drawLine(toOffset(from), toOffset(to), paint);
      paint.strokeWidth = origStrokeWidth;
    }
  }

  static Vector2 calcBegCtl(Vector2 pre, Vector2 beg, Vector2 end,
      {isDorminant = false}) {
    final preV = pre - beg;
    final postV = end - beg;
    final bisect = preV.angleToSigned(postV) / 2;
    final dir =
        Matrix2.rotation(bisect > 0 ? pi / 2 - bisect : -(pi / 2 + bisect)) *
            postV.scaled(isDorminant ? DOMINANT_CTRL_SCALE : STD_CTRL_SCALE);
    return dir + beg;
  }

  static Vector2 calcEndCtl(Vector2 beg, Vector2 end, Vector2 next,
      {isDorminant = false}) {
    final preV = beg - end;
    final postV = next - end;
    final bisect = preV.angleToSigned(postV) / 2;
    final dir =
        Matrix2.rotation(bisect > 0 ? -(pi / 2 - bisect) : pi / 2 + bisect) *
            preV.scaled(isDorminant ? DOMINANT_CTRL_SCALE : STD_CTRL_SCALE);
    return dir + end;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! GramExprPainter) return true;

    GramExprPainter oldPainter = oldDelegate;
    return gram != oldPainter.gram;
  }
}