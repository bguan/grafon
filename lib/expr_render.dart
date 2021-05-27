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
library expr_render;

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:vector_math/vector_math.dart';

import 'grafon_expr.dart';
import 'gram_infra.dart';

/// GramMetrics is a value class of rendering metrics for each gram expression.
/// Height is normalized to always be 1.0, width is adjusted for visual balance.
/// Origin is always (0, 0), visualCenter is center of visual balance.
class RenderPlan {
  static const STD_DIM = 1.0;
  static const PEN_WTH_SCALE = 0.05;
  static const MIN_WIDTH = 0.2;
  static const MIN_HEIGHT = 0.2;
  static const MIN_MASS = 2 * PEN_WTH_SCALE * 2 * PEN_WTH_SCALE;
  static const STD_GAP = 0.15;
  final Iterable<PolyLine> lines;
  late final double xMin, yMin, xMax, yMax, xAvg, yAvg, width, height;
  late final double mass, vMass, hMass;
  late final Vector2 center;
  late final int _hashCode;

  RenderPlan(this.lines) {
    double xMin = double.maxFinite,
        yMin = double.maxFinite,
        xMax = -double.maxFinite,
        yMax = -double.maxFinite,
        mass = 0,
        vMass = 0,
        hMass = 0,
        xSum = 0,
        ySum = 0,
        num = 0;

    for (final l in lines) {
      final m = l.metrics;
      final d = l.lengthDim;
      xMin = min(xMin, m.xMin);
      yMin = min(yMin, m.yMin);
      xMax = max(xMax, m.xMax);
      yMax = max(yMax, m.yMax);
      num += l.numPts;
      xSum += m.xAvg * l.numPts;
      ySum += m.yAvg * l.numPts;
      mass += d.length * PEN_WTH_SCALE;
      hMass += d.dxSum * PEN_WTH_SCALE;
      vMass += d.dySum * PEN_WTH_SCALE;
    }

    this.xMin = quantize(num == 0 ? 0 : xMin);
    this.xMax = quantize(num == 0 ? 0 : xMax);
    this.yMin = quantize(num == 0 ? 0 : yMin);
    this.yMax = quantize(num == 0 ? 0 : yMax);
    this.xAvg = quantize(xSum == 0 || num == 0 ? 0 : xSum / num);
    this.yAvg = quantize(ySum == 0 || num == 0 ? 0 : ySum / num);
    this.mass = quantize(max(mass, MIN_MASS));
    this.hMass = quantize(max(hMass, MIN_MASS));
    this.vMass = quantize(max(vMass, MIN_MASS));
    this.center = quantizeV2(calcCenter(xMin, yMin, xMax, yMax));
    this.width = quantize(max(xMax - xMin, MIN_WIDTH));
    this.height = quantize(max(yMax - yMin, MIN_HEIGHT));
    this._hashCode = lines.fold(mass.hashCode, (h, l) => h ^ l.hashCode);
  }

  @override
  int get hashCode => _hashCode;

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
        xAvg == that.xAvg &&
        yAvg == that.yAvg &&
        mass == that.mass &&
        hMass == that.hMass &&
        vMass == that.vMass;

    if (!check) return false;
    final ieq = IterableEquality<PolyLine>().equals;

    return ieq(this.lines, that.lines);
  }

  double get area => width * height;

  double get widthRatio => width / height;

  @override
  String toString() {
    final x1 = quantStr(xMin);
    final x2 = quantStr(xMax);
    final y1 = quantStr(yMin);
    final y2 = quantStr(yMax);
    final w = quantStr(width);
    final h = quantStr(height);
    final m = quantStr(mass);
    final hm = quantStr(hMass);
    final vm = quantStr(vMass);
    final c = quantV2Str(center);
    final xa = quantStr(xAvg);
    final ya = quantStr(yAvg);

    return '(x:$x1~$x2, y:$y1~$y2, sz:$w*$h, c:$c, avg:($xa,$ya), m:$m($hm,$vm))' +
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

  // Move the center of the render plan to (0,0) if necessary
  RenderPlan reCenter() {
    final c = center;
    return (c == Vector2(0, 0) ? this : shift(-c.x, -c.y));
  }

  RenderPlan relaxFixedAspect() =>
      RenderPlan(lines.map((l) => l.diffAspect(false)));

  /// Merge this with another Render Plan.
  RenderPlan merge(RenderPlan that) {
    return RenderPlan([...lines, ...that.lines]);
  }

  /// Scale height of a RenderPlan to hNew, enforce by InvisiDots if needed.
  RenderPlan scaleHeight(double hNew) {
    final hScale = hNew / this.height;
    var newR = remap((isF, v) => isF ? v * hScale : Vector2(v.x, v.y * hScale));

    // corner case if newR is not hNew, e.g. unchanged from oldR as Mono.Dot
    if ((newR.height - hNew).abs() > 0.1) {
      // add InvisiDots to stretch out the height
      final cx = center.x;
      final cy = center.y;
      newR = RenderPlan([
        ...this.lines,
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
      final cx = center.x;
      final cy = center.y;
      newR = RenderPlan([
        ...this.lines,
        InvisiDot([Vector2(cx - wNew / 2, cy), Vector2(cx + wNew / 2, cy)]),
      ]);
    }

    return newR;
  }

  /// Transform this render plan by unary operation to generate a new render.
  RenderPlan byUnary(Unary op) {
    // assume box is bound by min max X Y of -.5 to .5
    final shrunk =
        remap((isFixed, v) => v * (op == Unary.Shrink ? 1 / 2 : 1 / 3));
    late final List<PolyLine> lines;
    switch (op) {
      case Unary.Up:
        // shift r's top to align with box top
        // extend the height down w InvisiDot at box bottom, maintain width
        lines = [
          ...shrunk.shift(0, .25 - shrunk.center.y).lines,
          InvisiDot([Vector2(-.35, -.35), Vector2(.35, .35)])
        ];
        break;
      case Unary.Down:
        // shift r's bottom to align with box bottom
        // extend the height up w InvisiDot at box top, maintain width
        lines = [
          ...shrunk.shift(0, -.25 + shrunk.center.y).lines,
          InvisiDot([Vector2(-.35, -.35), Vector2(.35, .35)])
        ];
        break;
      case Unary.Left:
        // shift r's left to align with box left
        // extend the width w InvisiDot at box right, maintain min height
        lines = [
          ...shrunk.shift(-.25 + shrunk.center.x, 0).lines,
          InvisiDot([Vector2(-.35, -.35), Vector2(.35, .35)])
        ];
        break;
      case Unary.Right:
        // shift r's left to align with box left
        // extend the width w InvisiDot at box left, maintain min height
        lines = [
          ...shrunk.shift(.25 - shrunk.center.x, 0).lines,
          InvisiDot([Vector2(-.35, -.35), Vector2(.35, .35)])
        ];
        break;
      case Unary.Shrink: // extending all sides to former min max
        lines = [
          ...shrunk.lines,
          InvisiDot([Vector2(-.35, -.35), Vector2(.35, .35)])
        ];
        break;
      default:
        throw UnsupportedError('Unary operation $op not supported.');
    }
    return RenderPlan(lines).reCenter();
  }

  /// Transform this render plan by unary operation to generate a new render.
  RenderPlan byBinary(Binary op, RenderPlan that) {
    var r1 = this;
    var r2 = that;

    r1 = r1.reCenter();
    r2 = r2.reCenter();
    // both operands are centered, no need to trim surrounding whitespace
    switch (op) {
      case Binary.Next:
        // align the heights of r1 or r2 to the taller height
        if (r1.height > r2.height) {
          r2 = r2.scaleHeight(r1.height).reCenter();
        } else if (r2.height > r1.height) {
          r1 = r1.scaleHeight(r2.height).reCenter();
        }
        // move 2nd operand to right of 1st
        return r1.merge(r2.shift(.5 * r1.width + STD_GAP + .5 * r2.width, 0));
      case Binary.Over:
        // align the widths of r1 or r2 to the wider width
        if (r1.width > r2.width) {
          r2 = r2.scaleWidth(r1.width).reCenter();
        } else if (r2.width > r1.width) {
          r1 = r1.scaleWidth(r2.width).reCenter();
        }
        return r1
            .merge(r2.shift(0, -.5 * r1.height - STD_GAP - .5 * r2.height))
            .reCenter();
      case Binary.Wrap:
        final hScale = r1.height / r2.height;
        r2 = r2.remap((isF, v) => v * hScale / 2).reCenter();
        // if r2 width more than .75 of r1 width, scale r1
        if (r2.width / r1.width > .8) {
          r1 = r1.relaxFixedAspect().scaleWidth(1.6 * r2.width).reCenter();
        }
        // align r2's avg(x,y) to r1's avg(x,y)
        r2 = r2.shift(r1.xAvg - r2.xAvg, r1.yAvg - r2.yAvg);
        return r1.merge(r2).reCenter();
      case Binary.Merge:
        // scale heights of r1 or r2 to taller height if too short
        if (r1.height > r2.height) {
          r2 = r2.scaleHeight(r1.height).reCenter();
        } else if (r2.height > r1.height) {
          r1 = r1.scaleHeight(r2.height).reCenter();
        }
        // scale widths of r1 or r2 to wider width if too narrow
        if (r1.width > r2.width && r2.width / r1.width < .5) {
          r2 = r2.scaleWidth(r1.width).reCenter();
        } else if (r2.width > r1.width && r1.width / r2.width < .5) {
          r1 = r1.scaleWidth(r2.width).reCenter();
        }
        return r1.merge(r2).reCenter();
      default:
        throw UnsupportedError('Binary Operation $op not supported!');
    }
  }

  /// compute flex rendering width by adjusting raw width
  double calcWidthByHeight(double devHeight) => widthRatio * devHeight;

  /// Transform this render plan by a function that remap points
  RenderPlan remap(Vector2 f(bool isFixed, Vector2 v)) => RenderPlan(lines
      .map((l) => l.diffPoints(l.vectors.map((v) => f(l.isFixedAspect, v)))));

  /// Change to device coordinates. Assume (0,0) is upper left corner.
  RenderPlan toDevice(double devHt, double devWth) {
    final hScale = devHt / height;
    final wScale = devWth / width;
    final scale = min(hScale, wScale);
    final render =
        ((scale - 1).abs() < 0.1 ? this : remap((isF, v) => v * scale));
    // flip Y and recenter origin to devWth/2. devHt/2)
    return render.reCenter().remap(
        (isF, v) => Vector2(v.x + devWth / 2, devHt - (v.y + devHt / 2)));
  }
}
