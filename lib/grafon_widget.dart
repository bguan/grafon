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
library grafon_widget;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:grafon/expr_render.dart';
import 'package:vector_math/vector_math.dart' as vm;

import 'constants.dart';
import 'gram_infra.dart';

/// Class to provide widget rendering of Gram expressions.
class GrafonTile extends StatelessWidget {
  static const HEIGHT_SCREEN_RATIO = 0.1;
  late final RenderPlan renderPlan;
  final double? height;
  final double? width;
  final bool isDebug;

  GrafonTile(this.renderPlan, {this.height, this.width, this.isDebug = false})
      : super();

  @override
  Widget build(BuildContext ctx) {
    final ht = height ?? MediaQuery.of(ctx).size.height * HEIGHT_SCREEN_RATIO;
    final wth = width ?? renderPlan.calcWidthByHeight(ht);
    return CustomPaint(
      size: Size(wth, ht),
      painter: GrafonPainter(
        renderPlan,
        scheme: Theme.of(ctx).colorScheme,
        isDebug: isDebug,
      ),
    );
  }
}

/// The custom painter to provide canvas rendering logic
class GrafonPainter extends CustomPainter {
  final RenderPlan renderPlan;
  final ColorScheme scheme;
  final bool isDebug;

  GrafonPainter(this.renderPlan, {this.isDebug = false, required this.scheme});

  static Offset toOffset(vm.Vector2 v) => Offset(v.x, v.y);

  @override
  void paint(Canvas canvas, Size size) {
    final penWidth = max(size.height * PEN_WTH_SCALE, MIN_PEN_WIDTH);

    final linePaint = Paint()
      ..color = scheme.primary
      ..strokeWidth = penWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dotPaint = Paint()
      ..color = scheme.primary
      ..strokeWidth = DOT_LINE_WTH_RATIO * penWidth
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final invisiPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = penWidth
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final render = renderPlan
        .shift(-renderPlan.center.x, -renderPlan.center.y)
        .toDevice(size.height, size.width);

    for (var l in render.lines) {
      if (l is PolyDot) {
        drawPolyDot(l, canvas, dotPaint);
      } else if (l is InvisiDot && isDebug) {
        drawInvisiDot(l, canvas, invisiPaint);
      } else if (l is PolyStraight) {
        drawPolyStraight(l, canvas, linePaint);
      } else if (l is PolyCurve) {
        drawPolySpline(l, canvas, linePaint);
      } else if (l is PolyExtended) {
        drawPolyExtended(l, canvas, linePaint);
      }
    }
  }

  /// Draw a series of invisible dots at all anchor points, used as spacers
  void drawInvisiDot(
    InvisiDot l,
    Canvas canvas,
    Paint paint,
  ) {
    final len = l.numPts;
    for (var i = 0; i < len; i++) {
      final v = l.vectors[i];
      canvas.drawCircle(toOffset(v), paint.strokeWidth / 2, paint);
    }
  }

  /// Draw a series of visible dots at all anchor points
  void drawPolyDot(
    PolyDot l,
    Canvas canvas,
    Paint paint,
  ) {
    final len = l.numPts;
    for (var i = 0; i < len; i++) {
      final v = l.vectors[i];
      canvas.drawCircle(toOffset(v), paint.strokeWidth, paint);
    }
  }

  /// Draw a series of straight lines connecting all anchor points
  void drawPolyStraight(
    PolyStraight l,
    Canvas canvas,
    Paint paint,
  ) {
    final len = l.numPts;
    // enter loop once even if len is 1 to draw dots as line of same point
    for (var i = 0; i < max(1, len - 1); i++) {
      final pt = l.vectors[i];
      final nextPt = l.vectors[min(i + 1, len - 1)];
      // in degenerate case of from == to i.e. a Point
      canvas.drawLine(toOffset(pt), toOffset(nextPt), paint);
    }
  }

  /// Same as PolyStraight except extending beyond the first and last points
  void drawPolyExtended(
    PolyExtended l,
    Canvas canvas,
    Paint paint,
  ) {
    final len = l.numPts;
    // enter loop once even if len is 1 to draw dots as line of same point
    for (var i = 0; i < max(1, len - 1); i++) {
      final pt = l.vectors[i];
      final nextPt = l.vectors[min(i + 1, len - 1)];
      canvas.drawLine(toOffset(pt), toOffset(nextPt), paint);
    }
  }

  /// Draw a series of curves connecting anchor points with smooth gradients.
  /// First and last anchor points are used only to set direction, not visible.
  void drawPolySpline(
    PolyCurve l,
    Canvas canvas,
    Paint paint,
  ) {
    var path = Path();
    final len = l.numPts;
    for (var i = 1; i < len - 2; i++) {
      final pre = l.vectors[max(0, i - 1)];
      final beg = l.vectors[max(1, i)];
      final end = l.vectors[min(i + 1, len - 1)];
      final next = l.vectors[min(i + 2, len - 1)];
      if (i == 1) {
        path.moveTo(beg.x, beg.y);
      }
      if (pre == beg && end == next) {
        // degenerate case, just a straight line
        path.lineTo(end.x, end.y);
      } else {
        if (pre == beg) {
          // use a dominant endCtl as bezier Ctl
          final ctl = PolyCurve.calcEndCtl(
            beg,
            end,
            next,
            controlType: SplineControlType.Dominant,
          );
          path.quadraticBezierTo(ctl.x, ctl.y, ctl.x, ctl.y);
        } else if (end == next) {
          // use a dominant begCtl as bezier Ctl
          final ctl = PolyCurve.calcBegCtl(
            pre,
            beg,
            end,
            controlType: SplineControlType.Dominant,
          );
          path.quadraticBezierTo(ctl.x, ctl.y, ctl.x, ctl.y);
        } else {
          final begCtl = PolyCurve.calcBegCtl(pre, beg, end);
          final endCtl = PolyCurve.calcEndCtl(beg, end, next);
          path.cubicTo(begCtl.x, begCtl.y, endCtl.x, endCtl.y, end.x, end.y);
        }
      }
    }
    canvas.drawPath(path, paint);
  }

  @override

  /// only repaint if the underlying render plan has changed.
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! GrafonPainter) return true;

    GrafonPainter oldPainter = oldDelegate;
    return renderPlan != oldPainter.renderPlan;
  }
}
