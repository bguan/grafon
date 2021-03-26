import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

import 'atom_infra.dart';

class GraView extends StatelessWidget {
  final Gra gra;
  final Size size;

  GraView(this.gra, this.size) : super();

  @override
  Widget build(BuildContext ctx) {
    return CustomPaint(
      size: size,
      painter: GraPainter(gra, Theme.of(ctx).colorScheme),
    );
  }
}

class GraPainter extends CustomPainter {
  static const STROKE_WIDTH_SCALE = 0.1;
  static const DOMINANT_CTRL_SCALE = 0.707;
  static const STD_CTRL_SCALE = 0.4;
  final Gra gra;
  final ColorScheme scheme;

  GraPainter(this.gra, this.scheme);

  Vector2 toCanvasCoord(Vector2 v, Size size) => v.clone()
    ..multiply(Vector2(size.width, -size.height))
    ..add(Vector2(size.width / 2, size.height / 2));

  Offset toOffset(Vector2 v) => Offset(v.x, v.y);

  @override
  void paint(Canvas canvas, Size size) {
    final penWidth = size.shortestSide * STROKE_WIDTH_SCALE;

    final paint = Paint()
      ..color = scheme.primary
      ..strokeWidth = penWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final p in gra.paths) {
      if (p is PolyDot) {
        drawPolyDot(p, size, canvas, paint);
      } else if (p is PolyLine) {
        drawPolyLine(p, size, canvas, paint);
      } else if (p is PolySpline) {
        drawPolySpline(p, size, canvas, paint);
      }
    }
  }

  void drawPolySpline(PolySpline p, Size size, Canvas canvas, Paint paint) {
    var path = new Path();
    final len = p.anchors.length;
    for (var i = 2; i < len - 1; i++) {
      final pre = p.anchors[max(0, i - 2)].vector;
      final beg = p.anchors[i - 1].vector;
      final end = p.anchors[i].vector;
      final next = p.anchors[min(i + 1, len - 1)].vector;
      if (i == 2) {
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

  void drawPolyLine(PolyLine p, Size size, Canvas canvas, Paint paint) {
    for (var i = 1; i < p.anchors.length; i++) {
      final from = toCanvasCoord(p.anchors[i - 1].vector, size);
      final to = toCanvasCoord(p.anchors[i].vector, size);
      canvas.drawLine(toOffset(from), toOffset(to), paint);
    }
  }

  void drawPolyDot(PolyDot p, Size size, Canvas canvas, Paint paint) {
    for (var a in p.anchors) {
      final point = toCanvasCoord(a.vector, size);
      canvas.drawCircle(toOffset(point), paint.strokeWidth / 2, paint);
    }
  }

  Vector2 calcBegCtl(Vector2 pre, Vector2 beg, Vector2 end,
      {isDorminant = false}) {
    final preV = pre - beg;
    final postV = end - beg;
    final bisect = preV.angleToSigned(postV) / 2;
    final dir =
        Matrix2.rotation(bisect > 0 ? pi / 2 - bisect : -(pi / 2 + bisect)) *
            postV.scaled(isDorminant ? DOMINANT_CTRL_SCALE : STD_CTRL_SCALE);
    return dir + beg;
  }

  Vector2 calcEndCtl(Vector2 beg, Vector2 end, Vector2 next,
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
    if (oldDelegate is! GraPainter) return true;

    GraPainter oldPainter = oldDelegate;
    return gra != oldPainter.gra;
  }
}
