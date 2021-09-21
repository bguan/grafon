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

/// Infrastructure for the logo-gram and it's graphical definition for the
/// Grafon language. Polar coordinates is used for defining anchor points.
/// To avoid floating point errors, coordinates and angles are stored at
/// rounded base (i.e. Double to Integer) for storage and comparison
library gram_infra;

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:vector_math/vector_math.dart';

import 'constants.dart';
import 'expr_render.dart';
import 'grafon_expr.dart';
import 'gram_table.dart';
import 'phonetics.dart';

final double floatPrecision = pow(0.1, FLOAT_DECIMALS).toDouble();

final int _floatBase = pow(10, FLOAT_DECIMALS).round();
final int _floatStorageBase = _floatBase * _floatBase; // higher precision

double quantize(double x) => ((x * _floatBase).round() / _floatBase);

Vector2 quantizeV2(Vector2 v) => Vector2(quantize(v.x), quantize(v.y));

String quantStr(double x) => x.toStringAsFixed(FLOAT_DECIMALS);

String quantV2Str(Vector2 v) => "(${quantStr(v.x)}, ${quantStr(v.y)})";

/// Polar coordinate
class Polar {
  final int _angleBase; // clockwise 0' is North, 90' is East
  final int _lenBase; // distance from origin * Precision

  // Angle simplified by dart's Euclidean modulus
  Polar({double angle = 0, double length = 0})
      : _angleBase = ((angle % (2 * pi)) * (1.0 * _floatStorageBase)).round(),
        _lenBase = (length * (1.0 * _floatStorageBase)).round();

  double get angle => _angleBase / (_floatStorageBase * 1.0);

  double get length => _lenBase / (_floatStorageBase * 1.0);

  Vector2 get vector => quantizeV2(Vector2(cos(angle), sin(angle)) * length);

  @override
  int get hashCode => _angleBase.hashCode ^ _lenBase.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! Polar) return false;

    Polar that = other;
    if (quantize(length) != quantize(that.length)) return false;
    if (_lenBase == 0) return true; // angle doesn't matter

    return quantize(angle) == quantize(that.angle);
  }

  @override
  String toString() =>
      "Polar(angle: ${quantStr(angle)}, length: ${quantStr(length)})";
}

/// Anchor points to construct a Gram.
/// 8 directions distance of .5 from origin, 1 center pt, and
/// 8 shorter directions at distance of .35 from origin.
/// e.g. n (Inner North) is on N line, mid of straight line from NW to NE,
/// and n is roughly sqrt(2)/4 north of origin.
enum Anchor { E, NE, N, NW, W, SW, S, SE, e, ne, n, nw, w, sw, s, se, O }

/// Extending Anchor to returns its polar coordinate.
/// In standard grid of +/- 0.5 i.e. 1.0x1.0 square with Origin at 0,0.
/// Vector2 is used internally but always round to nearest integer.
extension AnchorHelper on Anchor {
  static const OUTER_DIST = GRAM_DIM / 2;
  static const INNER_DIST = .7 * GRAM_DIM / 2;

  static const List<Anchor> outerPoints = const [
    Anchor.E,
    Anchor.NE,
    Anchor.N,
    Anchor.NW,
    Anchor.W,
    Anchor.SW,
    Anchor.S,
    Anchor.SE,
  ];

  Polar get polar {
    switch (this) {
      case Anchor.E:
        return Polar(angle: 0, length: OUTER_DIST);
      case Anchor.e:
        return Polar(angle: 0, length: INNER_DIST);
      case Anchor.NE:
        return Polar(angle: (1 / 4) * pi, length: OUTER_DIST);
      case Anchor.ne:
        return Polar(angle: (1 / 4) * pi, length: INNER_DIST);
      case Anchor.N:
        return Polar(angle: (1 / 2) * pi, length: OUTER_DIST);
      case Anchor.n:
        return Polar(angle: (1 / 2) * pi, length: INNER_DIST);
      case Anchor.NW:
        return Polar(angle: (3 / 4) * pi, length: OUTER_DIST);
      case Anchor.nw:
        return Polar(angle: (3 / 4) * pi, length: INNER_DIST);
      case Anchor.W:
        return Polar(angle: pi, length: OUTER_DIST);
      case Anchor.w:
        return Polar(angle: pi, length: INNER_DIST);
      case Anchor.SW:
        return Polar(angle: (5 / 4) * pi, length: OUTER_DIST);
      case Anchor.sw:
        return Polar(angle: (5 / 4) * pi, length: INNER_DIST);
      case Anchor.S:
        return Polar(angle: (3 / 2) * pi, length: OUTER_DIST);
      case Anchor.s:
        return Polar(angle: (3 / 2) * pi, length: INNER_DIST);
      case Anchor.SE:
        return Polar(angle: (7 / 4) * pi, length: OUTER_DIST);
      case Anchor.se:
        return Polar(angle: (7 / 4) * pi, length: INNER_DIST);
      default:
        return Polar(length: 0);
    }
  }

  Vector2 get vector => polar.vector;

  double get angle => this.polar.angle;

  double get length => this.polar.length;

  double get x => this.vector.x;

  double get y => this.vector.y;

  static Anchor? findAnchor(Vector2 v) {
    final qv = quantizeV2(v);
    for (final a in Anchor.values) {
      if (a.vector == qv) return a;
    }
    return null;
  }
}

/// A Gram has 5 orientations: Facing Right, Up, Left, Down or Center
enum Face { Center, Right, Up, Left, Down }

/// Extending Face enum to map to a Vowel
extension FaceHelper on Face {
  String get shortName => this.toString().split('.').last;

  static const List<Face> directionals = const [
    Face.Right,
    Face.Up,
    Face.Left,
    Face.Down,
  ];

  Vowel get vowel {
    switch (this) {
      case Face.Right:
        return Vowel.e;
      case Face.Up:
        return Vowel.i;
      case Face.Left:
        return Vowel.o;
      case Face.Down:
        return Vowel.u;
      default:
        return Vowel.a;
    }
  }
}

/// Map a Vowel to a Face
extension VowelHelper on Vowel {
  Face get face {
    switch (this) {
      case Vowel.e:
        return Face.Right;
      case Vowel.i:
        return Face.Up;
      case Vowel.o:
        return Face.Left;
      case Vowel.u:
        return Face.Down;
      default:
        return Face.Center;
    }
  }
}

/// Class to bundle useful metrics of lines of a render
class LineMetrics {
  late final double xMin, yMin, xMax, yMax, xAvg, yAvg, minWidth, minHeight;

  LineMetrics({
    this.xMin = -GRAM_DIM / 2,
    this.yMin = -GRAM_DIM / 2,
    this.xMax = GRAM_DIM / 2,
    this.yMax = GRAM_DIM / 2,
    this.xAvg = 0,
    this.yAvg = 0,
    this.minWidth: MIN_GRAM_WIDTH,
    this.minHeight: MIN_GRAM_HEIGHT,
  });

  @override
  int get hashCode {
    return xMin.hashCode ^
        yMin.hashCode ^
        xMax.hashCode ^
        yMax.hashCode ^
        xAvg.hashCode ^
        yAvg.hashCode ^
        minWidth.hashCode ^
        minHeight.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (other is! LineMetrics) return false;
    LineMetrics that = other;
    return xMin == that.xMin &&
        yMin == that.yMin &&
        xMax == that.xMax &&
        yMax == that.yMax &&
        minWidth == that.minWidth &&
        minHeight == that.minHeight &&
        xAvg == that.xAvg &&
        yAvg == that.yAvg;
  }

  @override
  String toString() {
    final x1 = quantStr(xMin);
    final x2 = quantStr(xMax);
    final y1 = quantStr(yMin);
    final y2 = quantStr(yMax);
    final w = quantStr(width);
    final h = quantStr(height);
    final xa = quantStr(xAvg);
    final ya = quantStr(yAvg);
    final mw = quantStr(minWidth);
    final mh = quantStr(minHeight);

    return 'LineMetrics(x:$x1~$x2, y:$y1~$y2, sz:$w*$h, min:$mw*$mh, avg:($xa,$ya))';
  }

  double get height => max(yMax - yMin, minHeight);

  double get width => max(xMax - xMin, minWidth);

  LineMetrics.ofPoints(
    Iterable<Vector2> pts, {
    this.minWidth: MIN_GRAM_WIDTH,
    this.minHeight: MIN_GRAM_HEIGHT,
    isZeroAvg = false,
  }) {
    double xMin = double.maxFinite,
        yMin = double.maxFinite,
        xMax = -double.maxFinite,
        yMax = -double.maxFinite,
        xSum = 0,
        ySum = 0,
        num = 0;

    final visited = <Vector2>{};
    for (Vector2 p in pts) {
      if (!visited.contains(p)) {
        visited.add(p);
        // hack to align a Y branch neatly inside a Triangle in a mix.
        // only count if pt is not origin for avg.
        if (p.length > 0) num++;
        xSum += isZeroAvg ? 0 : p.x;
        ySum += isZeroAvg ? 0 : p.y;
        xMin = min(xMin, p.x);
        yMin = min(yMin, p.y);
        xMax = max(xMax, p.x);
        yMax = max(yMax, p.y);
      }
    }

    this.xMin = quantize(num == 0 ? 0 : xMin);
    this.xMax = quantize(num == 0 ? 0 : xMax);
    this.yMin = quantize(num == 0 ? 0 : yMin);
    this.yMax = quantize(num == 0 ? 0 : yMax);
    this.xAvg = quantize(xSum == 0 || num == 0 ? 0 : xSum / num);
    this.yAvg = quantize(ySum == 0 || num == 0 ? 0 : ySum / num);
  }
}

/// Class to bundle length related numbers
class LengthDim {
  final double length, dxSum, dySum;

  const LengthDim({this.length = 0, this.dxSum = 0, this.dySum = 0});

  @override
  int get hashCode {
    return length.hashCode ^ dxSum.hashCode ^ dySum.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (other is! LengthDim) return false;
    LengthDim that = other;
    return length == that.length && dxSum == that.dxSum && dySum == that.dySum;
  }

  @override
  String toString() {
    final lenStr = quantStr(length);
    final dxStr = quantStr(dxSum);
    final dyStr = quantStr(dySum);

    return 'LengthDim(len:$lenStr, dxSum:$dxStr, dySum:$dyStr)';
  }
}

/// Pen Stroke lines as series of anchor points joined by straight lines or curves
abstract class PolyLine {
  final List<Vector2> _baseVectors;
  final bool isFixedAspect;
  final bool isZeroAvg;
  late final int _hashCode;

  PolyLine(
    Iterable<Vector2> vs, {
    this.isFixedAspect = false,
    this.isZeroAvg = false,
  }) : this._baseVectors = List.unmodifiable(
            vs.map((v) => (v * (1.0 * _floatStorageBase))..round())) {
    this._hashCode = runtimeType.hashCode ^
        _baseVectors.length.hashCode ^
        isFixedAspect.hashCode ^
        isZeroAvg.hashCode ^
        ListEquality<Vector2>().hash(_baseVectors);
  }

  List<Vector2> get vectors => List.unmodifiable(
      _baseVectors.map((v) => quantizeV2(v / (1.0 * _floatStorageBase))));

  List<Vector2> get visiblePoints => vectors;

  int get numPts => _baseVectors.length;

  int get numVisiblePts => numPts;

  LineMetrics get metrics;

  LengthDim get lengthDim;

  PolyLine diffPoints(Iterable<Vector2> vs);

  PolyLine diffAspect(bool isFixedAspect);

  Vector2 get center =>
      visiblePoints.fold(Vector2(0, 0), (Vector2 sum, Vector2 v) => sum + v) /
      numVisiblePts.toDouble();

  @override
  int get hashCode => _hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! PolyLine || other.runtimeType != this.runtimeType)
      return false;
    PolyLine that = other;
    return isFixedAspect == that.isFixedAspect &&
        isZeroAvg == that.isZeroAvg &&
        ListEquality<Vector2>().equals(this.vectors, that.vectors);
  }

  @override
  String toString() =>
      "$runtimeType with $numPts pts: ${vectors.map((v) => quantV2Str(v))}" +
      (isFixedAspect ? " fixed aspect." : "");

  /// Turn by either full step(s) of 90' or semi step of 45'
  PolyLine turn({int steps = 1, bool isSemi = false}) {
    List<Vector2> pts = [];
    for (Vector2 bv in _baseVectors) {
      Vector2 rotatedBase =
          Matrix2.rotation(steps * pi / (isSemi ? 4 : 2)) * bv;
      pts.add(rotatedBase / (1.0 * _floatStorageBase));
    }
    return this.diffPoints(pts);
  }

  /// Vertically Flip upside down
  PolyLine vFlip() {
    List<Vector2> pts = [];
    for (Vector2 v in vectors) {
      // No need to quantize as only flipping signs
      pts.add(Vector2(v.x, -v.y));
    }
    return this.diffPoints(pts);
  }

  /// Horizontally Flip left to right
  PolyLine hFlip() {
    List<Vector2> pts = [];
    for (Vector2 v in vectors) {
      // No need to quantize as only flipping signs
      pts.add(Vector2(-v.x, v.y));
    }
    return this.diffPoints(pts);
  }
}

/// Dot(s), different from Lines of 0 length as it has different metrics
class PolyDot extends PolyLine {
  late final LineMetrics metrics;

  PolyDot(
    Iterable<Vector2> vs, {
    isFixedAspect = false,
    isZeroAvg = false,
  })  : metrics = LineMetrics.ofPoints(vs),
        super(vs, isFixedAspect: isFixedAspect, isZeroAvg: isZeroAvg);

  PolyDot.anchors(
    List<Anchor> anchors, {
    isFixedAspect = false,
    isZeroAvg = false,
  }) : super(List.unmodifiable(anchors.map((a) => a.vector)),
            isFixedAspect: isFixedAspect) {
    metrics = LineMetrics.ofPoints(vectors);
  }

  @override
  PolyDot diffPoints(Iterable<Vector2> vs) => PolyDot(
        vs,
        isFixedAspect: this.isFixedAspect,
        isZeroAvg: this.isZeroAvg,
      );

  @override
  PolyDot diffAspect(bool isFixedAspect) => PolyDot(
        this.vectors,
        isFixedAspect: isFixedAspect,
        isZeroAvg: this.isZeroAvg,
      );

  @override
  LengthDim get lengthDim => const LengthDim();
}

/// Invisible Dots to aid in maintaining Metrics for placement control
class InvisiDot extends PolyLine {
  late final LineMetrics metrics;
  final double minWidth;
  final double minHeight;

  InvisiDot(
    Iterable<Vector2> vs, {
    isFixedAspect = false,
    isZeroAvg = false,
    this.minWidth: MIN_GRAM_WIDTH,
    this.minHeight: MIN_GRAM_HEIGHT,
  })  : metrics = LineMetrics.ofPoints(
          vs,
          minWidth: minWidth,
          minHeight: minHeight,
          isZeroAvg: isZeroAvg,
        ),
        super(
          vs,
          isFixedAspect: isFixedAspect,
          isZeroAvg: isZeroAvg,
        );

  InvisiDot.anchors(
    List<Anchor> anchors, {
    isFixedAspect = false,
    isZeroAvg = false,
    this.minWidth: MIN_GRAM_WIDTH,
    this.minHeight: MIN_GRAM_HEIGHT,
  }) : super(
          List.unmodifiable(anchors.map((a) => a.vector)),
          isFixedAspect: isFixedAspect,
          isZeroAvg: isZeroAvg,
        ) {
    metrics = LineMetrics.ofPoints(
      <Vector2>[],
      minWidth: minWidth,
      minHeight: minHeight,
      isZeroAvg: isZeroAvg,
    );
  }

  @override
  InvisiDot diffPoints(Iterable<Vector2> vs) => InvisiDot(
        vs,
        isFixedAspect: isFixedAspect,
        isZeroAvg: isZeroAvg,
        minWidth: metrics.minWidth,
        minHeight: metrics.minHeight,
      );

  @override
  InvisiDot diffAspect(bool isFixedAspect) =>
      this.isFixedAspect == isFixedAspect
          ? this
          : InvisiDot(
              this.vectors,
              isFixedAspect: isFixedAspect,
              isZeroAvg: isZeroAvg,
              minWidth: metrics.minWidth,
              minHeight: metrics.minHeight,
            );

  @override
  LengthDim get lengthDim => const LengthDim();

  @override
  int get numVisiblePts => 0;

  @override
  String toString() => "${super.toString()} $metrics";
}

/// Straight Line from anchor point to anchor point
class PolyStraight extends PolyLine {
  late final LineMetrics metrics;
  late final LengthDim lengthDim;

  PolyStraight(
    Iterable<Vector2> vs, {
    isFixedAspect = false,
    isZeroAvg = false,
  })  : metrics = LineMetrics.ofPoints(vs, isZeroAvg: isZeroAvg),
        lengthDim = calcLengthDim(vs),
        super(
          vs,
          isFixedAspect: isFixedAspect,
          isZeroAvg: isZeroAvg,
        );

  PolyStraight.anchors(
    List<Anchor> anchors, {
    isFixedAspect = false,
    isZeroAvg = false,
  }) : super(
          List.unmodifiable(anchors.map((a) => a.vector)),
          isFixedAspect: isFixedAspect,
          isZeroAvg: isZeroAvg,
        ) {
    metrics = LineMetrics.ofPoints(vectors, isZeroAvg: isZeroAvg);
    lengthDim = calcLengthDim(vectors);
  }

  @override
  PolyStraight diffPoints(Iterable<Vector2> vs) => PolyStraight(
        vs,
        isFixedAspect: this.isFixedAspect,
        isZeroAvg: this.isZeroAvg,
      );

  @override
  PolyStraight diffAspect(bool isFixedAspect) =>
      this.isFixedAspect == isFixedAspect
          ? this
          : PolyStraight(
              this.vectors,
              isFixedAspect: isFixedAspect,
              isZeroAvg: this.isZeroAvg,
            );

  static LengthDim calcLengthDim(Iterable<Vector2> pts) {
    if (pts.length < 1) return LengthDim();

    double lSum = 0, dxSum = 0, dySum = 0;
    var prev = pts.first;
    for (final p in pts) {
      if (p != prev) {
        lSum += prev.distanceTo(p);
        dxSum += (p.x - prev.x).abs();
        dySum += (p.y - prev.y).abs();
        prev = p;
      }
    }
    return LengthDim(
      length: quantize(lSum),
      dxSum: quantize(dxSum),
      dySum: quantize(dySum),
    );
  }
}

/// Extended Straight Line from anchor point to anchor point
/// 1st & last pts are extended by a constant factor, added as anchor.
class PolyExtended extends PolyStraight {
  static const EXTENDED_LINE_RATIO = 0.3;

  static List<Vector2> extend(Iterable<Vector2> vs) {
    final vl = vs.toList();
    if (vs.length > 1) {
      final firstLine = vl[1] - vl[0];
      final partialReverse = -firstLine * EXTENDED_LINE_RATIO;
      final prePt = vl[0] + partialReverse;
      vl.insert(0, prePt);
      final lastLine = vl[vl.length - 1] - vl[vl.length - 2];
      final partialForward = lastLine * EXTENDED_LINE_RATIO;
      final postPt = vl[vl.length - 1] + partialForward;
      vl.add(postPt);
    }
    return vl;
  }

  PolyExtended(
    Iterable<Vector2> vs, {
    isFixedAspect = false,
    isZeroAvg: false,
  }) : super(
          extend(vs),
          isFixedAspect: isFixedAspect,
          isZeroAvg: isZeroAvg,
        );

  PolyExtended.anchors(
    List<Anchor> anchors, {
    isFixedAspect = false,
    isZeroAvg = false,
  }) : super(
          extend(anchors.map((a) => a.vector)),
          isFixedAspect: isFixedAspect,
          isZeroAvg: isZeroAvg,
        );

  @override
  PolyExtended diffPoints(Iterable<Vector2> vs) => PolyExtended(
        vs,
        isFixedAspect: this.isFixedAspect,
        isZeroAvg: this.isZeroAvg,
      );

  @override
  PolyExtended diffAspect(bool isFixedAspect) =>
      this.isFixedAspect == isFixedAspect
          ? this
          : PolyExtended(
              this.vectors,
              isFixedAspect: isFixedAspect,
              isZeroAvg: this.isZeroAvg,
            );
}

/// diff Spline control point types to aid in curve computation & drawing.
enum SplineControlType { Dominant, Standard, StraightApproximate }

/// extending SplineControlType to return numeric value used in computation.
extension SplineControlTypeHelper on SplineControlType {
  double get scale {
    switch (this) {
      case SplineControlType.Dominant:
        return PolyCurve.DOMINANT_CTRL_SCALE;
      case SplineControlType.StraightApproximate:
        return PolyCurve.APPROX_STRAIGHT_SCALE;
      default:
        return PolyCurve.STD_CTRL_SCALE;
    }
  }
}

/// Curve Line thru every point, making sure tangent transition is smooth at each
/// first point and last point is for direction computation only.
/// Note: minimum number of anchor points in a PolyCurve is 4!
class PolyCurve extends PolyLine {
  static const DOMINANT_CTRL_SCALE = 0.6;
  static const STD_CTRL_SCALE = 0.4;
  static const APPROX_STRAIGHT_SCALE = 0.2;

  late final List<Vector2> approxPts;
  late final LineMetrics metrics;
  late final LengthDim lengthDim;

  PolyCurve(
    Iterable<Vector2> vs, {
    isFixedAspect = false,
    isZeroAvg: false,
  }) : super(
          vs,
          isFixedAspect: isFixedAspect,
          isZeroAvg: isZeroAvg,
        ) {
    approxPts = calcApproxPts(vs);
    metrics = LineMetrics.ofPoints(
      approxPts,
      isZeroAvg: isZeroAvg,
    );
    lengthDim = PolyStraight.calcLengthDim(approxPts);
  }

  PolyCurve.anchors(
    List<Anchor> anchors, {
    isFixedAspect = false,
    isZeroAvg = false,
  }) : super(
          List.unmodifiable(anchors.map((a) => a.vector)),
          isFixedAspect: isFixedAspect,
          isZeroAvg: isZeroAvg,
        ) {
    approxPts = calcApproxPts(vectors);
    metrics = LineMetrics.ofPoints(
      approxPts,
      isZeroAvg: isZeroAvg,
    );
    lengthDim = PolyStraight.calcLengthDim(approxPts);
  }

  @override
  int get numVisiblePts => _baseVectors.length - 2;

  @override
  List<Vector2> get visiblePoints =>
      vectors.length < 3 ? [] : vectors.sublist(1, vectors.length - 1);

  @override
  PolyCurve diffPoints(Iterable<Vector2> vs) => PolyCurve(
        vs,
        isFixedAspect: isFixedAspect,
        isZeroAvg: isZeroAvg,
      );

  @override
  PolyCurve diffAspect(bool isFixedAspect) =>
      this.isFixedAspect == isFixedAspect
          ? this
          : PolyCurve(
              this.vectors,
              isFixedAspect: isFixedAspect,
              isZeroAvg: isZeroAvg,
            );

  /// utility function to calc Spline beginning control point
  static Vector2 calcBegCtl(Vector2 pre, Vector2 beg, Vector2 end,
      {SplineControlType controlType = SplineControlType.Standard}) {
    final preV = pre - beg;
    final postV = end - beg;
    final bisect = preV.angleToSigned(postV) / 2;
    final dir =
        Matrix2.rotation(bisect > 0 ? pi / 2 - bisect : -(pi / 2 + bisect)) *
            postV.scaled(controlType.scale);
    return dir + beg;
  }

  /// utility function to calc Spline ending control point
  static Vector2 calcEndCtl(Vector2 beg, Vector2 end, Vector2 next,
      {SplineControlType controlType = SplineControlType.Standard}) {
    final preV = beg - end;
    final postV = next - end;
    final bisect = preV.angleToSigned(postV) / 2;
    final dir =
        Matrix2.rotation(bisect > 0 ? -(pi / 2 - bisect) : pi / 2 + bisect) *
            preV.scaled(controlType.scale);
    return dir + end;
  }

  static List<Vector2> calcApproxPts(Iterable<Vector2> points) {
    List<Vector2> pts = points.toList();
    List<Vector2> curvePts = [];
    int len = pts.length;
    // use lines of anchor points and control points to approximate curve
    for (var i = 1; i < len - 2; i++) {
      final pre = pts[max(0, i - 1)];
      final beg = pts[max(1, i)];
      final end = pts[min(i + 1, len - 1)];
      final next = pts[min(i + 2, len - 1)];
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
    return curvePts;
  }
}

/// Gram is a Graphical Symbol i.e. logo-gram
/// Drawn by a series of pen stroke paths of dots, lines, and curves
/// Associated with a vowel and a starting consonant pair.
/// If at the Head of a new cluster, use Head consonant, else Base.
abstract class Gram extends GrafonExpr {
  final Iterable<PolyLine> _lines;
  final Cons cons;
  final RenderPlan renderPlan;
  late final int _hashCode;

  Gram(paths, this.cons, {recenter: true})
      : _lines = List.unmodifiable(paths),
        renderPlan = RenderPlan(paths, recenter: recenter) {
    this._hashCode = cons.hashCode ^
        vowel.hashCode ^
        face.hashCode ^
        lines.fold(0, (int h, PolyLine p) => h ^ p.hashCode);
  }

  @override
  Iterable<PolyLine> get lines => _lines;

  Face get face;

  Gram get gram => this;

  @override
  List<Gram> get grams => [this];

  Vowel get vowel => face.vowel;

  @override
  int get hashCode => _hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! Gram) return false;

    Gram that = other;
    final eq = IterableEquality<PolyLine>().equals;

    return this.cons == that.cons &&
        this.face == that.face &&
        this.vowel == that.vowel &&
        eq(this.lines, that.lines);
  }

  @override
  String toString() => this is QuadGram
      ? face.shortName + '_' + GramTable().getEnumIfQuad(this)!.shortName
      : GramTable().getMonoEnum(this).shortName;

  Syllable get syllable => Syllable(cons, vowel);

  @override
  Pronunciation get pronunciation => Pronunciation([syllable]);
}

/// MonoGram looks the same when rotated 90' i.e. only 1 variation hence Mono
class MonoGram extends Gram {
  final face = Face.Center;

  MonoGram(Iterable<PolyLine> paths, Cons cons, {recenter: true})
      : super(paths, cons, recenter: recenter);

  @override
  bool operator ==(Object other) {
    if (other is! MonoGram) return false;
    return super == other;
  }

  @override
  int get hashCode => super.hashCode;
}

/// QuadGram has 4 orientation, form by rotating Gram by 90' or 45',
/// or combining with vertical or horizontal mirroring
class QuadGram extends Gram {
  final Face face;

  QuadGram(Iterable<PolyLine> paths, this.face, Cons cons, {recenter: true})
      : super(paths, cons, recenter: recenter);

  @override
  bool operator ==(Object other) {
    if (other is! QuadGram) return false;
    return super == other;
  }

  @override
  int get hashCode => super.hashCode;
}

/// Consist of 4 Quad Grams facing Right, Up, Left, Down.
abstract class QuadGrams {
  final Cons cons;
  final Map<Face, Gram> f2g;
  late final int _hashCode;

  QuadGrams(
    this.cons, {
    required List<PolyLine> r,
    required List<PolyLine> u,
    required List<PolyLine> l,
    required List<PolyLine> d,
    recenter: true,
  }) : f2g = Map.unmodifiable({
          Face.Right: QuadGram(r, Face.Right, cons, recenter: recenter),
          Face.Up: QuadGram(u, Face.Up, cons, recenter: recenter),
          Face.Left: QuadGram(l, Face.Left, cons, recenter: recenter),
          Face.Down: QuadGram(d, Face.Down, cons, recenter: recenter)
        }) {
    this._hashCode = cons.hashCode ^
        Face.values.fold(
            // use Face.values instead of face2gra.keys for fixed order
            0,
            (prev, f) => f2g[f] == null
                ? prev
                : prev << 1 ^ f.hashCode ^ f2g[f].hashCode);
  }

  Gram operator [](Face f) => f2g[f]!;

  List<Gram> get all => f2g.values.toList();

  @override
  int get hashCode => _hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! QuadGrams) return false;

    QuadGrams that = other;

    return this.cons == that.cons &&
        this.f2g[Face.Right] == that.f2g[Face.Right] &&
        this.f2g[Face.Up] == that.f2g[Face.Up] &&
        this.f2g[Face.Left] == that.f2g[Face.Left] &&
        this.f2g[Face.Down] == that.f2g[Face.Down];
  }
}

/// Turn pen paths by either full step(s) of 90' or semi step of 45'
List<PolyLine> turn(List<PolyLine> paths,
        {int steps = 1, bool isSemi = false}) =>
    List.unmodifiable(paths.map((p) => p.turn(steps: steps, isSemi: isSemi)));

/// Vertically Flip pen paths upside down
List<PolyLine> vFlip(List<PolyLine> paths) =>
    List.unmodifiable(paths.map((p) => p.vFlip()));

/// Horizontally Flip pen paths upside down
List<PolyLine> hFlip(List<PolyLine> paths) =>
    List.unmodifiable(paths.map((p) => p.hFlip()));

/// In RotatingRow, quads are rotated by full step of 90'
class RotatingQuads extends QuadGrams {
  RotatingQuads(List<PolyLine> r, Cons cons, {recenter: true})
      : super(cons, r: r, u: r2u(r), l: r2l(r), d: r2d(r), recenter: recenter);

  static List<PolyLine> r2u(List<PolyLine> rightPaths) => turn(rightPaths);

  static List<PolyLine> r2l(List<PolyLine> rightPaths) =>
      turn(rightPaths, steps: 2);

  static List<PolyLine> r2d(List<PolyLine> rightPaths) =>
      turn(rightPaths, steps: 3);
}

/// In SemiRotatingRow, quads are rotated by semi step of 45'
class SemiRotatingQuads extends QuadGrams {
  SemiRotatingQuads(List<PolyLine> r, Cons cons, {recenter: true})
      : super(cons, r: r, u: r2u(r), l: r2l(r), d: r2d(r), recenter: recenter);

  static List<PolyLine> r2u(List<PolyLine> r) => turn(r, isSemi: true);

  static List<PolyLine> r2l(List<PolyLine> r) =>
      turn(r, steps: 2, isSemi: true);

  static List<PolyLine> r2d(List<PolyLine> r) =>
      turn(r, steps: 3, isSemi: true);
}

/// In FlipRow:
/// Right paths are flipped horizontally to make Left Path;
/// Up paths are obtained by rotating Right paths by 90';
/// Down paths are obtained by vertically flipping Up paths.
class FlipQuads extends QuadGrams {
  FlipQuads(List<PolyLine> r, Cons cons, {recenter: true})
      : super(cons, r: r, u: r2u(r), l: r2l(r), d: r2d(r), recenter: recenter);

  static List<PolyLine> r2u(List<PolyLine> r) => turn(r);

  static List<PolyLine> r2l(List<PolyLine> r) => hFlip(r);

  static List<PolyLine> r2d(List<PolyLine> r) => vFlip(r2u(r));
}

/// In DoubleFlipRow:
/// Right paths are flipped vertically to make up Path;
/// Left paths are obtained by flipping right path horizontally;
/// Down paths are obtained by flipping up paths horizontally.
class DoubleFlipQuads extends QuadGrams {
  DoubleFlipQuads(List<PolyLine> r, Cons cons, {recenter: true})
      : super(cons, r: r, u: r2u(r), l: r2l(r), d: r2d(r), recenter: recenter);

  static List<PolyLine> r2u(List<PolyLine> r) => vFlip(r);

  static List<PolyLine> r2l(List<PolyLine> r) => hFlip(r);

  static List<PolyLine> r2d(List<PolyLine> r) => hFlip(r2u(r));
}
