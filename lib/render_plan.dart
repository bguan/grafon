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

/// Classes and utils for RenderPlan.
library render_planning;

import 'dart:math';

import 'package:vector_math/vector_math.dart';

import 'gram_infra.dart';
import 'operators.dart';

/// GramMetrics is a value class of rendering metrics for each gram expression.
/// Height is normalized to always be 1.0, width is adjusted for visual balance.
/// Origin is always (0, 0), visualCenter is center of visual balance.
class RenderPlan {
  static const STD_DIM = 1.0;
  static const MIN_WIDTH = 0.2;
  static const MIN_HEIGHT = 0.2;
  static const MIN_MASS = 0.2;
  static const STRAIGHT_TO_CURVE_EST = 0.7; // .5*sqrt(2)
  static const PEN_WTH_SCALE = 0.05;
  final Iterable<PolyLine> lines;
  late final double width, height, xMin, yMin, xMax, yMax, ratioWH, mass;
  late final Vector2 center;

  RenderPlan(this.lines) {
    double xMin = 0, yMin = 0, xMax = 0, yMax = 0, mass = 0;
    for (final l in lines) {
      late final bool isCurve;
      List<Vector2> curvePts = [];
      if (l is PolyCurve) {
        // use lines of anchor points and control points to approximate curve
        isCurve = true;
        final len = l.numPts;
        for (var i = 1; i < len - 2; i++) {
          final pre = l.vectors[max(0, i - 1)];
          final beg = l.vectors[max(1, i)];
          final end = l.vectors[min(i + 1, len - 1)];
          final next = l.vectors[min(i + 2, len - 1)];
          if (i == 1) curvePts.add(beg);
          if (pre == beg && end == next) {
            // degenerate case, just a straight line
            curvePts.add(end);
          } else {
            if ((pre == beg) || (end == next)) {
              final ctl = (pre == beg)
                  ? PolyCurve.calcEndCtl(
                      beg,
                      end,
                      next,
                      controlType: SplineControlType.StraightApproximate,
                    )
                  : PolyCurve.calcBegCtl(
                      pre,
                      beg,
                      end,
                      controlType: SplineControlType.StraightApproximate,
                    );
              curvePts.add(ctl);
              curvePts.add(end);
            } else {
              final begCtl = PolyCurve.calcBegCtl(
                pre,
                beg,
                end,
                controlType: SplineControlType.StraightApproximate,
              );
              final endCtl = PolyCurve.calcEndCtl(
                beg,
                end,
                next,
                controlType: SplineControlType.StraightApproximate,
              );
              curvePts.add(begCtl);
              curvePts.add(endCtl);
              curvePts.add(end);
            }
          }
        }
      } else {
        isCurve = false;
      }

      final pts = isCurve ? curvePts : l.vectors;

      if (pts.length < 1) break;

      var prev = pts.first;
      for (final p in pts) {
        xMin = min(xMin, p.x);
        yMin = min(yMin, p.y);
        xMax = max(xMax, p.x);
        yMax = max(yMax, p.y);
        if (p != prev) {
          mass += prev.distanceTo(p) * PEN_WTH_SCALE;
        }
      }
    }

    final width = xMax - xMin;
    final height = yMax - yMin;

    this.xMin = quantize(width < MIN_WIDTH ? -MIN_WIDTH / 2 : xMin);
    this.xMax = quantize(width < MIN_WIDTH ? MIN_WIDTH / 2 : xMax);
    this.yMin = quantize(height < MIN_HEIGHT ? -MIN_HEIGHT / 2 : yMin);
    this.yMax = quantize(height < MIN_HEIGHT ? MIN_HEIGHT / 2 : yMax);
    this.width = quantize(max(width, MIN_WIDTH));
    this.height = quantize(max(height, MIN_HEIGHT));
    this.ratioWH = quantize(this.width / this.height);
    this.mass = quantize(max(mass, MIN_MASS));
    this.center =
        quantizeV2(calcCenter(this.xMin, this.yMin, this.xMax, this.yMax));
  }

  @override
  int get hashCode {
    var hash = center.hashCode ^
        width.hashCode ^
        height.hashCode ^
        xMin.hashCode ^
        yMin.hashCode ^
        xMax.hashCode ^
        yMax.hashCode ^
        ratioWH.hashCode ^
        mass.hashCode;

    return lines.fold(hash, (h, l) => h ^ l.hashCode);
  }

  @override
  bool operator ==(Object other) {
    if (other is! RenderPlan) return false;
    RenderPlan that = other;
    bool check = center == that.center &&
        width == that.width &&
        height == that.height &&
        xMin == that.xMin &&
        yMin == that.yMin &&
        xMax == that.xMax &&
        yMax == that.yMax &&
        ratioWH == that.ratioWH;

    if (!check) return false;
    if (lines == that.lines) return true;
    final l1 = lines.toList();
    final l2 = that.lines.toList();
    if (l1.length != l2.length) return false;
    for (int i = 0; i < l1.length; i++) {
      if (l1[i] != l2[i]) return false;
    }
    return true;
  }

  double get area => width * height;

  @override
  String toString() {
    final x1 = quantStr(xMin);
    final x2 = quantStr(xMax);
    final y1 = quantStr(yMin);
    final y2 = quantStr(yMax);
    final w = quantStr(width);
    final h = quantStr(height);
    final r = quantStr(ratioWH);
    final c = quantV2Str(center);

    return "Metrics(x: $x1 to $x2, y: $y1 to $y2, w: $w, h: $h, r: $r, c: $c)\n" +
        lines.toString();
  }

  /// Calculate the center given min max X and Y.
  static Vector2 calcCenter(xMin, yMin, xMax, yMax) =>
      Vector2(xMin, yMin) + Vector2(xMax - xMin, yMax - yMin) / 2;

  /// Take a RenderPlan and shift all points by (dx, dy) i.e. Translation.
  static RenderPlan shift(RenderPlan r, num dx, num dy) {
    final newL = r.lines.map(
        (l) => l.diffPoints(l.vectors.map((v) => Vector2(v.x + dx, v.y + dy))));
    return RenderPlan(newL);
  }

  /// Shift all points by (dx, dy).
  RenderPlan shiftWith(num dx, num dy) {
    return shift(this, dx, dy);
  }

  /// Merge 2 render plans to make a new one.
  static RenderPlan merge(RenderPlan r1, RenderPlan r2) =>
      RenderPlan([...r1.lines, ...r2.lines]);

  /// Merge this with another Render Plan.
  RenderPlan mergeWith(RenderPlan that) {
    return merge(this, that);
  }

  /// Scale height of a RenderPlan to hNew, enforce by InvisiDots if needed.
  RenderPlan scaleHeight(double hNew) {
    final hScale = hNew / this.height;
    final cx = center.x;
    final cy = center.y;
    var newR = map((isF, v) => isF ? v * hScale : Vector2(v.x, v.y * hScale));

    // corner case if newR is unchanged from oldR, e.g. Mono.Dot, add InvisiDots
    if (newR.height == this.height) {
      newR = RenderPlan([
        ...newR.lines,
        InvisiDot([Vector2(cx, cy - hNew / 2), Vector2(cx, cy + hNew / 2)]),
      ]);
    }

    return newR;
  }

  /// Scale width of a RenderPlan to wNew, enforce by InvisiDots if needed.
  RenderPlan scaleWidth(double wNew) {
    final wScale = wNew / this.width;
    var newR = map((isF, v) => isF ? v * wScale : Vector2(v.x * wScale, v.y));

    // corner case if newR is unchanged from oldR, e.g. Mono.Dot, add InvisiDots
    if (newR.width == this.width) {
      final cx = newR.center.x;
      final cy = newR.center.y;
      newR = RenderPlan([
        ...newR.lines,
        InvisiDot([Vector2(cx - wNew / 2, cy), Vector2(cx + wNew / 2, cy)])
      ]);
    }

    return newR;
  }

  /// Arrange a render plan by unary operation to generate a new render.
  static RenderPlan renderUnary(Unary op, RenderPlan r) {
    // center the renderPlan if needed
    if (r.center != Vector2(0, 0)) r = r.shiftWith(-r.center.x, -r.center.y);

    // normalize the height to 1 if needed
    if (r.height < 1) r = r.map((isFixed, v) => v * 1 / r.height);

    final w = r.width;
    final h = r.height;
    final y1 = r.yMin;
    final y2 = r.yMax;
    final x1 = r.xMin;
    final x2 = r.xMax;
    final cx = r.center.x;
    final cy = r.center.y;
    switch (op) {
      case Unary.Up: // extend the height down by adding InvisiDot
        return RenderPlan([
          ...r.lines,
          InvisiDot([Vector2(cx, y1 - 2 * h)])
        ]);
      case Unary.Down: // extend the height up by adding InvisiDot
        return RenderPlan([
          ...r.lines,
          InvisiDot([Vector2(cx, y2 + 2 * h)])
        ]);
      case Unary.Left: // extend the width by adding InvisiDot at former maxX
        return RenderPlan([
          ...r.lines,
          InvisiDot([Vector2(x2 + 2 * w, cy)])
        ]);
      case Unary.Right: // extend the width by adding InvisiDot at former minX
        return RenderPlan([
          ...r.lines,
          InvisiDot([Vector2(x1 - 2 * w, cy)])
        ]);
      case Unary.Shrink: // extending all sides to former min max
        return RenderPlan([
          ...r.lines,
          InvisiDot([
            Vector2(cx, cy - 1.5 * h),
            Vector2(cx, cy + 1.5 * h),
            Vector2(cx - 1.5 * w, cy),
            Vector2(cx + 1.5 * w, cy),
          ])
        ]);
      default:
        throw UnsupportedError('Unary operation $op not supported.');
    }
  }

  /// Transform this render plan by unary operation to generate a new render.
  RenderPlan byUnary(Unary op) {
    return renderUnary(op, this);
  }

  /// Arrange 2 render plans by binary operation to generate a new render.
  static RenderPlan renderBinary(Binary op, RenderPlan r1, RenderPlan r2) {
    if (r1.center != Vector2(0, 0)) r1 = shift(r1, -r1.center.x, -r1.center.y);
    if (r2.center != Vector2(0, 0)) r2 = shift(r2, -r2.center.x, -r2.center.y);
    // both operands are centered, no need to trim surrounding whitespace
    switch (op) {
      case Binary.Next:
        // align the heights of r1 or r2 to the taller height
        if (r1.height > r2.height) {
          r2 = r2.scaleHeight(r1.height);
        } else if (r2.height > r1.height) {
          r1 = r1.scaleHeight(r2.height);
        }
        // adjust r1 & r2 width by mass ratio
        // final w1Scale = r1.mass / (r1.mass + r2.mass);
        // final w2Scale = r2.mass / (r1.mass + r2.mass);
        // r1 = r1.scaleWidth(w1Scale * r1.width);
        // r2 = r2.scaleWidth(w2Scale * r2.width);
        // move 2nd operand to right of 1st
        return merge(r1, shift(r2, .5 * r1.width + .05 + .5 * r2.width, 0));
      case Binary.Over:
        // align the widths of r1 or r2 to the wider width
        if (r1.width > r2.width) {
          r2 = r2.scaleWidth(r1.width);
        } else if (r2.width > r1.width) {
          r1 = r1.scaleWidth(r2.width);
        }
        // adjust r1 and r2 height by mass ratio
        // final h1Scale = r1.mass / (r1.mass + r2.mass);
        // final h2Scale = r2.mass / (r1.mass + r2.mass);
        // r1 = r1.scaleHeight(h1Scale * r1.height);
        // r2 = r2.scaleHeight(h2Scale * r2.height);
        return merge(r1, shift(r2, 0, -.5 * r1.height - .05 - .5 * r2.height));
      case Binary.Wrap:
        // scale 2nd operand to 1/2 height of 1st
        var scale = .5 * r1.height / r2.height;
        // if r2 height after scaling is more than 1/2 or r1 height, scale more
        if (scale * r2.width > .5 * r1.width) {
          scale *= .5 * r1.width / (scale * r2.width);
        }
        return merge(r1, scale == 1 ? r2 : r2.map((isFixed, v) => v * scale));
      case Binary.Merge:
        // align the heights of both r1 to r2 to the taller height
        if (r1.height > r2.height) {
          r2 = r2.scaleHeight(r1.height);
        } else if (r2.height > r1.height) {
          r1 = r1.scaleHeight(r2.height);
        }
        return merge(r1, r2);
      default:
        throw UnsupportedError('Binary Operation $op not supported!');
    }
  }

  /// Transform this render plan by unary operation to generate a new render.
  RenderPlan byBinary(Binary op, RenderPlan that) {
    return renderBinary(op, this, that);
  }

  /// Transform this render plan by a function that remap points
  RenderPlan map(Vector2 f(bool isFixed, Vector2 v)) => RenderPlan(lines
      .map((l) => l.diffPoints(l.vectors.map((v) => f(l.isFixedAspect, v)))));

// TODO: impl a working toDevice to replace toCanvasCoord
// /// Change to device coordinates. Assume (0,0) is upper left corner.
// RenderPlan toDevice(double width, double height) {
//   return scaleWidth(width).scaleHeight(height).map(
//         (isF, v) => Vector2(v.x + width / 2, height - (v.y + height / 2)),
//       );
// }
}
