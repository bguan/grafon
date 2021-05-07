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

/// Infrastructure for the logogram and it's graphical definition for the
/// Grafon language. Polar coordinates is used for defining anchor points.
library gram_infra;

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:vector_math/vector_math.dart';

import 'expression.dart';
import 'gram_table.dart';
import 'operators.dart';
import 'phonetics.dart';
import 'render_plan.dart';

/// Rounding Base to convert Double to Integer for storage and comparison
const int FLOAT_DECIMALS = 2;
final double floatPrecision = pow(0.1, FLOAT_DECIMALS).toDouble();
final int _floatBase = pow(10, FLOAT_DECIMALS).round();
final int _floatStorageBase =
    _floatBase * _floatBase; // store at higher precision

double quantize(double x) => ((x * _floatBase).round() / _floatBase);

Vector2 quantizeV2(Vector2 v) => Vector2(quantize(v.x), quantize(v.y));

String quantStr(double x) => x.toStringAsFixed(FLOAT_DECIMALS);

String quantV2Str(Vector2 v) => "(${quantStr(v.x)}, ${quantStr(v.y)})";

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
/// 8 directions distance of .5 from origin, 1 center pt
enum Anchor {
  E,
  NE,
  N,
  NW,
  W,
  SW,
  S,
  SE,
  IE,
  IN,
  IW,
  IS,
  O,
}

/// Extending Anchor to returns its polar coordinate.
/// In standard grid of +/- 0.5 i.e. 1.0x1.0 square with Origin at 0,0.
/// Vector2 is used internally but always round to nearest integer.
extension AnchorHelper on Anchor {
  static const OUTER_DIST = RenderPlan.STD_DIM / 2;
  static const INNER_DIST = .7 * RenderPlan.STD_DIM / 2;

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
      case Anchor.IE:
        return Polar(angle: 0, length: INNER_DIST);
      case Anchor.NE:
        return Polar(angle: (1 / 4) * pi, length: OUTER_DIST);
      case Anchor.N:
        return Polar(angle: (1 / 2) * pi, length: OUTER_DIST);
      case Anchor.IN:
        return Polar(angle: (1 / 2) * pi, length: INNER_DIST);
      case Anchor.NW:
        return Polar(angle: (3 / 4) * pi, length: OUTER_DIST);
      case Anchor.W:
        return Polar(angle: pi, length: OUTER_DIST);
      case Anchor.IW:
        return Polar(angle: pi, length: INNER_DIST);
      case Anchor.SW:
        return Polar(angle: (5 / 4) * pi, length: OUTER_DIST);
      case Anchor.S:
        return Polar(angle: (3 / 2) * pi, length: OUTER_DIST);
      case Anchor.IS:
        return Polar(angle: (3 / 2) * pi, length: INNER_DIST);
      case Anchor.SE:
        return Polar(angle: (7 / 4) * pi, length: OUTER_DIST);
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

/// Map a Face to a Vowel
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
        return Vowel.E;
      case Face.Up:
        return Vowel.I;
      case Face.Left:
        return Vowel.O;
      case Face.Down:
        return Vowel.U;
      default:
        return Vowel.A;
    }
  }
}

/// Map a Vowel to a Face
extension VowelHelper on Vowel {
  String get shortName => this.toString().split('.').last;

  Face get face {
    switch (this) {
      case Vowel.E:
        return Face.Right;
      case Vowel.I:
        return Face.Up;
      case Vowel.O:
        return Face.Left;
      case Vowel.U:
        return Face.Down;
      default:
        return Face.Center;
    }
  }
}

/// Pen Stroke lines as series of anchor points joined by straight lines or curves
abstract class PolyLine {
  final List<Vector2> _baseVectors;
  final bool isFixedAspect;

  PolyLine(Iterable<Vector2> vs, {this.isFixedAspect = false})
      : this._baseVectors = List.unmodifiable(
            vs.map((v) => (v * (1.0 * _floatStorageBase))..round()));

  List<Vector2> get vectors => List.unmodifiable(
      _baseVectors.map((v) => quantizeV2(v / (1.0 * _floatStorageBase))));

  List<Vector2> get visiblePoints => vectors;

  int get numPts => _baseVectors.length;

  PolyLine diffPoints(Iterable<Vector2> vs);

  @override
  int get hashCode {
    var hash = this.runtimeType.hashCode;
    for (var v in _baseVectors) {
      // order matters so hash is shifted for every anchor
      hash = hash << 1 ^
          (v.x.round() * _floatStorageBase).hashCode ^
          v.y.round().hashCode;
    }
    return hash;
  }

  @override
  bool operator ==(Object other) {
    if (other is! PolyLine || other.runtimeType != this.runtimeType)
      return false;

    PolyLine that = other;
    final leq = ListEquality<Vector2>().equals;

    return leq(this.vectors, that.vectors);
  }

  @override
  String toString() =>
      "$runtimeType with $numPts points: ${vectors.map((v) => quantV2Str(v))}";

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
  PolyDot(Iterable<Vector2> vs, {isFixedAspect = false})
      : super(vs, isFixedAspect: isFixedAspect);

  PolyDot.anchors(List<Anchor> anchors, {isFixedAspect = false})
      : super(List.unmodifiable(anchors.map((a) => a.vector)),
            isFixedAspect: isFixedAspect);

  @override
  PolyDot diffPoints(Iterable<Vector2> vs) {
    return PolyDot(vs, isFixedAspect: this.isFixedAspect);
  }
}

/// Invisible Dots to aid in maintaining Metrics for placement control
class InvisiDot extends PolyLine {
  InvisiDot(Iterable<Vector2> vs, {isFixedAspect = false})
      : super(vs, isFixedAspect: isFixedAspect);

  InvisiDot.anchors(List<Anchor> anchors, {isFixedAspect = false})
      : super(List.unmodifiable(anchors.map((a) => a.vector)),
            isFixedAspect: isFixedAspect);

  @override
  InvisiDot diffPoints(Iterable<Vector2> vs) {
    return InvisiDot(vs);
  }
}

/// Straight Line from anchor point to anchor point
class PolyStraight extends PolyLine {
  PolyStraight(Iterable<Vector2> vs, {isFixedAspect = false})
      : super(vs, isFixedAspect: isFixedAspect);

  PolyStraight.anchors(List<Anchor> anchors, {isFixedAspect = false})
      : super(List.unmodifiable(anchors.map((a) => a.vector)),
            isFixedAspect: isFixedAspect);

  @override
  PolyStraight diffPoints(Iterable<Vector2> vs) {
    return PolyStraight(vs, isFixedAspect: this.isFixedAspect);
  }
}

enum SplineControlType { Dorminant, Standard, StraightApproximate }

extension SplineControlTypeHelper on SplineControlType {
  double get scale {
    switch (this) {
      case SplineControlType.Dorminant:
        return PolyCurve.DOMINANT_CTRL_SCALE;
      case SplineControlType.StraightApproximate:
        return PolyCurve.APPROX_STRAIGHT_SCALE;
      default:
        return PolyCurve.STD_CTRL_SCALE;
    }
  }
}

/// Curve Line thru everypoint, making sure tangent transition is smooth at each
/// first point and last point is for direction computation only.
/// Note: minimum number of anchor points is 4!
class PolyCurve extends PolyLine {
  static const DOMINANT_CTRL_SCALE = 0.6;
  static const STD_CTRL_SCALE = 0.4;
  static const APPROX_STRAIGHT_SCALE = 0.2;

  PolyCurve(Iterable<Vector2> vs, {isFixedAspect = false})
      : super(vs, isFixedAspect: isFixedAspect);

  PolyCurve.anchors(List<Anchor> anchors, {isFixedAspect = false})
      : super(List.unmodifiable(anchors.map((a) => a.vector)),
            isFixedAspect: isFixedAspect);

  @override
  List<Vector2> get visiblePoints =>
      vectors.length < 3 ? [] : vectors.sublist(1, vectors.length - 1);

  @override
  PolyCurve diffPoints(Iterable<Vector2> vs) {
    return PolyCurve(vs, isFixedAspect: this.isFixedAspect);
  }

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
}

/// Gram is a Graphical Symbol i.e. logogram
/// Drawn by a series of pen stroke paths of dots, lines, and curves
/// Associated with a vowel and a starting consonant pair.
/// If at the Head of a new cluster, use Head consonant, else Base.
abstract class Gram extends GramExpression {
  final Iterable<PolyLine> _lines;
  final ConsPair consPair;
  final RenderPlan renderPlan;

  Gram(paths, this.consPair)
      : _lines = List.unmodifiable(paths),
        renderPlan = RenderPlan(paths);

  @override
  Iterable<PolyLine> get lines => _lines;

  Face get face;

  Vowel get vowel => face.vowel;

  Consonant get base => consPair.base;

  Consonant get head => consPair.head;

  @override
  int get hashCode =>
      consPair.hashCode ^
      vowel.hashCode ^
      face.hashCode ^
      lines.fold(0, (int h, PolyLine p) => h ^ p.hashCode);

  @override
  bool operator ==(Object other) {
    if (other is! Gram) return false;

    Gram that = other;
    final eq = IterableEquality<PolyLine>().equals;

    return this.consPair == that.consPair &&
        this.face == that.face &&
        this.vowel == that.vowel &&
        eq(this.lines, that.lines);
  }

  String toString() => this is QuadGram
      ? GramTable.getEnumIfQuad(this)!.shortName +
          ' ' +
          face.shortName.toLowerCase()
      : GramTable.getMonoEnum(this).shortName;

  String get pronunciation =>
      (consPair == ConsPair.aHa ? '' : consPair.base.shortName) +
      (consPair == ConsPair.aHa
          ? vowel.shortName
          : vowel.shortName.toLowerCase());

  /// Shrinks a single Gram by half maintaining its center position.
  GramExpression shrink() => UnaryExpr(Unary.Shrink, this);

  /// Shrinks a single Gram by half then move it to upper quadrant.
  GramExpression up() => UnaryExpr(Unary.Up, this);

  /// Shrinks a single Gram by half then move it to down quadrant.
  GramExpression down() => UnaryExpr(Unary.Down, this);

  /// Shrinks a single Gram by half then move it to left quadrant.
  GramExpression left() => UnaryExpr(Unary.Left, this);

  /// Shrinks a single Gram by half then move it to right quadrant.
  GramExpression right() => UnaryExpr(Unary.Right, this);
}

/// MonoGram looks the same when rotated 90' i.e. only 1 variation hence Mono
class MonoGram extends Gram {
  final face = Face.Center;

  MonoGram(Iterable<PolyLine> paths, ConsPair cons) : super(paths, cons);

  @override
  bool operator ==(Object other) {
    if (other is! MonoGram) return false;
    return super == other;
  }

  @override
  int get hashCode => super.hashCode;
}

/// QuadGram has 4 orientation, each form by rotating a base Gram by 90' or 45'
class QuadGram extends Gram {
  final Face face;

  QuadGram(Iterable<PolyLine> paths, this.face, ConsPair cons)
      : super(paths, cons);

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
  final ConsPair consPair;
  final Map<Face, Gram> f2g;

  QuadGrams(
    this.consPair, {
    required List<PolyLine> r,
    required List<PolyLine> u,
    required List<PolyLine> l,
    required List<PolyLine> d,
  }) : f2g = Map.unmodifiable({
          Face.Right: QuadGram(r, Face.Right, consPair),
          Face.Up: QuadGram(u, Face.Up, consPair),
          Face.Left: QuadGram(l, Face.Left, consPair),
          Face.Down: QuadGram(d, Face.Down, consPair)
        });

  Gram operator [](Face f) => f2g[f]!;

  List<Gram> get all => f2g.values.toList();

  @override
  int get hashCode =>
      consPair.hashCode ^
      Face.values.fold(
          // use Face.values instead of face2gra.keys for fixed order
          0,
          (prev, f) =>
              f2g[f] == null ? prev : prev << 1 ^ f.hashCode ^ f2g[f].hashCode);

  @override
  bool operator ==(Object other) {
    if (other is! QuadGrams) return false;

    QuadGrams that = other;

    return this.consPair == that.consPair &&
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
  RotatingQuads(List<PolyLine> r, ConsPair cons)
      : super(cons, r: r, u: r2u(r), l: r2l(r), d: r2d(r));

  static List<PolyLine> r2u(List<PolyLine> rightPaths) => turn(rightPaths);

  static List<PolyLine> r2l(List<PolyLine> rightPaths) =>
      turn(rightPaths, steps: 2);

  static List<PolyLine> r2d(List<PolyLine> rightPaths) =>
      turn(rightPaths, steps: 3);
}

/// In SemiRotatingRow, quads are rotated by semi step of 45'
class SemiRotatingQuads extends QuadGrams {
  SemiRotatingQuads(List<PolyLine> r, ConsPair cons)
      : super(cons, r: r, u: r2u(r), l: r2l(r), d: r2d(r));

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
  FlipQuads(List<PolyLine> r, ConsPair cons)
      : super(cons, r: r, u: r2u(r), l: r2l(r), d: r2d(r));

  static List<PolyLine> r2u(List<PolyLine> r) => turn(r);

  static List<PolyLine> r2l(List<PolyLine> r) => hFlip(r);

  static List<PolyLine> r2d(List<PolyLine> r) => vFlip(r2u(r));
}

/// In DoubleFlipRow:
/// Right paths are flipped horizontally and vertically to make Left Path;
/// Up paths are obtained by rotating Right paths by 90';
/// Down paths are obtained by vertically and horizontally flipping Up paths.
class DoubleFlipQuads extends QuadGrams {
  DoubleFlipQuads(List<PolyLine> r, ConsPair cons)
      : super(cons, r: r, u: r2u(r), l: r2l(r), d: r2d(r));

  static List<PolyLine> r2u(List<PolyLine> r) => hFlip(turn(r));

  static List<PolyLine> r2l(List<PolyLine> r) => vFlip(hFlip(r));

  static List<PolyLine> r2d(List<PolyLine> r) => hFlip(vFlip(r2u(r)));
}
