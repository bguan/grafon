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

/// Classes and utils for render planning in device independent coordinates.
library render_planning;

import 'dart:math';

import 'package:vector_math/vector_math.dart';

import 'expression.dart';
import 'gram_infra.dart';

/// GramMetrics is a value class of rendering metrics for each gram expression.
/// Height is normalized to always be 1.0, width is adjusted for visual balance.
/// Origin is always (0, 0), visualCenter is center of visual balance.
class RenderPlan {
  static const STD_DIM = 1.0;
  static const MIN_WIDTH = 0.2;
  static const MIN_HEIGHT = 0.2;
  static const MIN_MASS = 0.2;
  static const STRAIGHT_TO_CURVE_EST = 0.7; // .5*sqrt(2)
  static const PEN_WTH_SCALE = 0.075;
  final Iterable<PolyLine> lines;
  late final double width, height, xMin, yMin, xMax, yMax;
  late final double mass, vmass, hmass;
  late final Vector2 center;

  RenderPlan(this.lines) {
    double xMin = 0,
        yMin = 0,
        xMax = 0,
        yMax = 0,
        mass = 0,
        vmass = 0,
        hmass = 0;
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
          vmass += p.y - prev.y;
          hmass += p.x - prev.x;
        }
      }
    }

    final width = xMax - xMin;
    final height = yMax - yMin;

    this.xMin = quantize(xMin);
    this.xMax = quantize(xMax);
    this.yMin = quantize(yMin);
    this.yMax = quantize(yMax);
    this.width = quantize(max(width, MIN_WIDTH));
    this.height = quantize(max(height, MIN_HEIGHT));
    this.mass = quantize(max(mass, MIN_MASS));
    this.hmass = quantize(max(hmass, MIN_MASS));
    this.vmass = quantize(max(vmass, MIN_MASS));
    this.center = quantizeV2(calcCenter(xMin, yMin, xMax, yMax));
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
        mass.hashCode ^
        hmass.hashCode ^
        vmass.hashCode;

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
        mass == that.mass &&
        hmass == that.hmass &&
        vmass == that.vmass;

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

  bool get hasSideGap => width > (xMax - xMin);

  bool get hasVertGap => height > (yMax - yMin);

  @override
  String toString() {
    final x1 = quantStr(xMin);
    final x2 = quantStr(xMax);
    final y1 = quantStr(yMin);
    final y2 = quantStr(yMax);
    final w = quantStr(width);
    final h = quantStr(height);
    final m = quantStr(mass);
    final hm = quantStr(hmass);
    final vm = quantStr(vmass);
    final c = quantV2Str(center);

    return "(x: $x1 to $x2, y: $y1 to $y2, w: $w, h: $h, m: $m ($hm, $vm), c: $c) " +
        lines.toString();
  }

  /// Calculate the center given min max X and Y.
  static Vector2 calcCenter(xMin, yMin, xMax, yMax) =>
      Vector2(xMin, yMin) + Vector2(xMax - xMin, yMax - yMin) / 2;

  /// Shift all points by (dx, dy).
  RenderPlan shift(num dx, num dy) {
    final newL = lines.map(
        (l) => l.diffPoints(l.vectors.map((v) => Vector2(v.x + dx, v.y + dy))));
    return RenderPlan(newL);
  }

  /// Merge this with another Render Plan.
  RenderPlan merge(RenderPlan that) {
    return RenderPlan([
      ...lines,
      ...that.lines,
    ]);
  }

  /// Scale height of a RenderPlan to hNew, enforce by InvisiDots if needed.
  RenderPlan scaleHeight(double hNew) {
    final hScale = hNew / this.height;
    var newR = remap((isF, v) => isF ? v * hScale : Vector2(v.x, v.y * hScale));

    // corner case if newR is not hNew, e.g. unchanged from oldR as Mono.Dot
    if ((newR.height - hNew).abs() > 0.1) {
      // add InvisiDots to stretch out the height
      final cx = newR.center.x;
      final cy = newR.center.y;
      newR = RenderPlan([
        ...newR.lines.where((l) => l is! InvisiDot),
        InvisiDot([Vector2(cx, cy - hNew / 2), Vector2(cx, cy + hNew / 2)]),
      ]);
    }

    return newR;
  }

  /// Scale width of a RenderPlan to wNew, enforce by InvisiDots if needed.
  RenderPlan scaleWidth(double wNew) {
    final wScale = wNew / this.width;
    var newR = remap((isF, v) => isF ? v * wScale : Vector2(v.x * wScale, v.y));

    // corner case if newR is not wNew, e.g. unchanged from oldR as Mono.Dot
    if ((newR.width - wNew).abs() > 0.1) {
      // add InvisiDots to stretch out the width
      final cx = newR.center.x;
      final cy = newR.center.y;
      newR = RenderPlan([
        ...newR.lines.where((l) => l is! InvisiDot),
        InvisiDot([Vector2(cx - wNew / 2, cy), Vector2(cx + wNew / 2, cy)])
      ]);
    }

    return newR;
  }

  /// Transform this render plan by unary operation to generate a new render.
  RenderPlan byUnary(Unary op) {
    // assume box is bound by min max X Y of -.5 to .5

    // reduce to 1/3 size
    final shrunk = remap((isFixed, v) => v / 3);
    switch (op) {
      case Unary.Up:
        // shift r's top to align with box top
        // extend the height down w InvisiDot at box bottom, maintain width
        return RenderPlan([
          ...shrunk.shift(0, .5 - shrunk.yMax).lines,
          InvisiDot([Vector2(-.25, -.5), Vector2(.25, -.5)])
        ]);
      case Unary.Down:
        // shift r's bottom to align with box bottom
        // extend the height up w InvisiDot at box top, maintain width
        return RenderPlan([
          ...shrunk.shift(0, -.5 - shrunk.yMin).lines,
          InvisiDot([Vector2(-.25, .5), Vector2(.25, .5)])
        ]);
      case Unary.Left:
        // shift r's left to align with box left
        // extend the width w InvisiDot at box right, maintain min height
        return RenderPlan([
          ...shrunk.shift(-.5 - shrunk.xMin, 0).lines,
          InvisiDot([Vector2(.5, -.25), Vector2(.5, .25)])
        ]);
      case Unary.Right:
        // shift r's left to align with box left
        // extend the width w InvisiDot at box left, maintain min height
        return RenderPlan([
          ...shrunk.shift(.5 - shrunk.xMax, 0).lines,
          InvisiDot([Vector2(-.5, -.25), Vector2(-.5, .25)])
        ]);
      case Unary.Shrink: // extending all sides to former min max
        return RenderPlan([
          ...shrunk.lines,
          InvisiDot([Vector2(-.5, -.5), Vector2(.5, .5)])
        ]);
      default:
        throw UnsupportedError('Unary operation $op not supported.');
    }
  }

  /// Transform this render plan by unary operation to generate a new render.
  RenderPlan byBinary(Binary op, RenderPlan that) {
    var r1 = this;
    var r2 = that;

    if (r1.center != Vector2(0, 0)) r1 = r1.shift(-r1.center.x, -r1.center.y);
    if (r2.center != Vector2(0, 0)) r2 = r2.shift(-r2.center.x, -r2.center.y);
    // both operands are centered, no need to trim surrounding whitespace
    switch (op) {
      case Binary.Next:
        // align the heights of r1 or r2 to the taller height
        if (r1.height > r2.height) {
          r2 = r2.scaleHeight(r1.height);
        } else if (r2.height > r1.height) {
          r1 = r1.scaleHeight(r2.height);
        }
        // move 2nd operand to right of 1st
        final gap =
            r1.hasSideGap || r2.hasSideGap ? 0 : .05 * (r2.width + r1.width);
        return r1.merge(r2.shift(.5 * r1.width + gap + .5 * r2.width, 0));
      case Binary.Over:
        // align the widths of r1 or r2 to the wider width
        if (r1.width > r2.width) {
          r2 = r2.scaleWidth(r1.width);
        } else if (r2.width > r1.width) {
          r1 = r1.scaleWidth(r2.width);
        }
        final gap =
            r1.hasVertGap || r2.hasVertGap ? 0 : .05 * (r1.height + r2.height);
        return r1.merge(r2.shift(0, -.5 * r1.height - gap - .5 * r2.height));
      case Binary.Wrap:
        // scale 2nd operand to 1/2 height of 1st
        var scale = .5 * r1.height / r2.height;
        // if r2 width after scaling is more than 1/2 of r1 width, scale more
        if (scale * r2.width > .5 * r1.width) {
          scale *= .5 * r1.width / (scale * r2.width);
        }
        return r1.merge(scale == 1 ? r2 : r2.remap((isFixed, v) => v * scale));
      case Binary.Merge:
        final hScale = r1.height / r2.height;
        final wScale = r1.width / r2.width;
        final scale = min(hScale, wScale);
        r2 = ((scale - 1).abs() < 0.1
            ? r2
            : r2.remap((isFixed, v) => v * scale));
        return r1.merge(r2);
      default:
        throw UnsupportedError('Binary Operation $op not supported!');
    }
  }

  /// compute flex rendering width by adjusting raw width
  double flexRenderWidth(double devHeight) {
    final hScale = devHeight / height;
    final rawWidth = hScale * width;
    return max(.75 * devHeight, rawWidth);
  }

  /// Transform this render plan by a function that remap points
  /// But InvisiDots are skipped to avoid distortion
  RenderPlan remap(Vector2 f(bool isFixed, Vector2 v)) => RenderPlan(lines
      .where((l) => l is! InvisiDot)
      .map((l) => l.diffPoints(l.vectors.map((v) => f(l.isFixedAspect, v)))));

  /// Change to device coordinates. Assume (0,0) is upper left corner.
  RenderPlan toDevice(double devHt, double devWth, [bool isFlexFit = true]) {
    final hScale = devHt / height;
    final scale = isFlexFit ? hScale : devHt;
    var scaled =
        ((scale - 1).abs() < 0.1 ? this : remap((isFixed, v) => v * scale));

    if (isFlexFit && (devWth - scaled.width).abs() > 0.1) {
      final wScale2 = devWth / scaled.width;
      scaled = scaled
          .remap((isFixed, v) => isFixed ? v : Vector2(v.x * wScale2, v.y));
    }

    final dx = max(devWth, scaled.width) / 2;
    // flip Y and recenter origin to devWth/2. devHt/2)
    return scaled
        .remap((isF, v) => Vector2(v.x + dx, devHt - (v.y + devHt / 2)));
  }
}
