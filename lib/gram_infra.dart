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

import 'package:collection/collection.dart';
import 'package:vector_math/vector_math.dart';

import 'phonetics.dart';

/// Gram - the logogram and it's graphical definition for the Grafon language.

/// Polar coordinates is used for defining anchor points of a Gram
class Polar {
  static const DEFAULT_ANCHOR_DIST = 0.5;

  final double angle; // clockwise 0' is North, 90' is East
  final double distance; // distance from origin

  const Polar({this.angle = 0, this.distance = DEFAULT_ANCHOR_DIST});

  Vector2 get vector => Vector2(cos(angle), sin(angle)) * distance;

  @override
  int get hashCode => angle.hashCode ^ distance.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! Polar) return false;

    Polar that = other;
    if (distance != that.distance) return false;
    if (distance == 0.0) return true; // angle doesn't matter

    // dart's Euclidean modulus works nicely here
    return angle % (2 * pi) == that.angle % (2 * pi);
  }
}

/// Anchor points to construct a Gram.
/// 1 mid point + 8 directions distance of .5 from origin
enum Anchor { E, NE, N, NW, W, SW, S, SE, O }

/// Extending Anchor to returns its polar coordinate
extension AnchorHelper on Anchor {
  static List<Anchor> get outerPoints => const [
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
        return const Polar(angle: 0);
      case Anchor.NE:
        return const Polar(angle: .25 * pi);
      case Anchor.N:
        return const Polar(angle: .5 * pi);
      case Anchor.NW:
        return const Polar(angle: .75 * pi);
      case Anchor.W:
        return const Polar(angle: pi);
      case Anchor.SW:
        return const Polar(angle: 1.25 * pi);
      case Anchor.S:
        return const Polar(angle: 1.5 * pi);
      case Anchor.SE:
        return const Polar(angle: 1.75 * pi);
      default:
        return const Polar(distance: 0);
    }
  }

  Vector2 get vector => polar.vector;
}

/// A Gram has 5 orientations: Facing Right, Up, Left, Down or Center
enum Face { Center, Right, Up, Left, Down }

/// Map a Face to a Vowel
extension FaceHelper on Face {
  String get shortName => this.toString().split('.').last;

  static List<Face> get directionals => const [
        Face.Right,
        Face.Up,
        Face.Left,
        Face.Down,
      ];

  Vowel get vowel {
    switch (this) {
      case Face.Right:
        return Vowel.A;
      case Face.Up:
        return Vowel.I;
      case Face.Left:
        return Vowel.O;
      case Face.Down:
        return Vowel.U;
      default:
        return Vowel.E;
    }
  }
}

/// Map a Vowel to a Face
extension VowelHelper on Vowel {
  String get shortName => this.toString().split('.').last;

  Face get face {
    switch (this) {
      case Vowel.A:
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

/// Pen Stroke Paths as series of anchor points joined by dots, lines or curves
abstract class PolyPath {
  final List<Anchor> anchors;

  const PolyPath(this.anchors);

  List<Anchor> get visibleAnchors => anchors;

  @override
  int get hashCode {
    var hash = this.runtimeType.hashCode;
    for (var a in anchors) {
      // order matters so hash is shifted for every anchor
      hash = hash << 1 ^ a.hashCode;
    }
    return hash;
  }

  @override
  bool operator ==(Object other) {
    if (other is! PolyPath) return false;

    PolyPath that = other;
    final leq = ListEquality<Anchor>().equals;

    return leq(this.anchors, that.anchors);
  }
}

/// Dotted pen stroke paths
class PolyDot extends PolyPath {
  const PolyDot(anchors) : super(anchors);

  /// dots ordering shouldn't matter
  @override
  bool operator ==(Object other) {
    if (other is! PolyDot) return false;

    PolyDot that = other;
    final seq = SetEquality<Anchor>().equals;

    return seq(Set.of(this.anchors), Set.of(that.anchors));
  }

  @override
  int get hashCode {
    var hash = this.runtimeType.hashCode;
    for (var a in Set.of(anchors)) hash ^= a.hashCode;
    return hash;
  }
}

/// Straight Line from anchor point to anchor point
class PolyLine extends PolyPath {
  const PolyLine(anchors) : super(anchors);

  @override
  bool operator ==(Object other) {
    if (other is! PolyLine) return false;
    return super == other;
  }
}

/// Curve Line thru everypoint, making sure tangent transition is smooth at each
/// first point and last point is for direction computation only
class PolySpline extends PolyPath {
  const PolySpline(anchors) : super(anchors);

  @override
  List<Anchor> get visibleAnchors => anchors.sublist(1, anchors.length - 1);

  @override
  bool operator ==(Object other) {
    if (other is! PolySpline) return false;
    return super == other;
  }
}

/// Gram is a Graphical Symbol i.e. logogram
/// Drawn by a series of pen stroke paths of dots, lines, and curves
/// Associated with a vowel and a starting consonant pair.
/// If at the Head of a new cluster, use Head consonant, else Base.
abstract class Gram {
  final List<PolyPath> paths;
  final ConsPair consPair;

  const Gram(this.paths, this.consPair);

  Face get face;

  Vowel get vowel => face.vowel;

  Consonant get base => consPair.base;

  Consonant get head => consPair.head;

  @override
  int get hashCode =>
      consPair.hashCode ^
      vowel.hashCode ^
      face.hashCode ^
      paths.fold(0, (int h, PolyPath p) => h ^ p.hashCode);

  @override
  bool operator ==(Object other) {
    if (other is! Gram) return false;

    Gram that = other;
    final eq = ListEquality<PolyPath>().equals;

    return this.consPair == that.consPair &&
        this.face == that.face &&
        this.vowel == that.vowel &&
        eq(this.paths, that.paths);
  }

  Vector2 get visualCenter {
    double x = 0, y = 0;
    int aCount = 0;
    final Set<Anchor> pathAnchors = Set.of([
      for (final p in paths) ...p.visibleAnchors,
    ]);

    for (final a in pathAnchors) {
      x += a.vector.x;
      y += a.vector.y;
      aCount++;
    }
    return Vector2(x / aCount, y / aCount);
  }
}

/// MonoGram looks the same when rotated 90' i.e. only 1 variation hence Mono
class MonoGram extends Gram {
  final face = Face.Center;

  const MonoGram(List<PolyPath> paths, ConsPair cons) : super(paths, cons);

  @override
  bool operator ==(Object other) {
    if (other is! MonoGram) return false;
    return super == other;
  }
}

/// QuadGram has 4 orientation, each form by rotating a base Gram by 90' or 45'
class QuadGram extends Gram {
  final Face face;

  const QuadGram(List<PolyPath> paths, this.face, ConsPair cons)
      : super(paths, cons);

  @override
  bool operator ==(Object other) {
    if (other is! QuadGram) return false;
    return super == other;
  }
}

/// Turn pen paths by either full step(s) of 90' or semi step of 45'
List<PolyPath> turn(List<PolyPath> paths,
    {int steps = 1, bool isSemi = false}) {
  List<PolyPath> turned = [];
  for (PolyPath p in paths) {
    List<Anchor> pts = [];
    for (Anchor a in p.anchors) {
      if (a == Anchor.O)
        pts.add(a);
      else
        pts.add(Anchor.values[(a.index + steps * (isSemi ? 1 : 2)) % 8]);
    }
    if (p is PolyLine) {
      turned.add(PolyLine(pts));
    } else if (p is PolySpline) {
      turned.add(PolySpline(pts));
    } else if (p is PolyDot) {
      turned.add(PolyDot(pts));
    } else {
      throw UnimplementedError("Not expecting $p");
    }
  }
  return turned;
}

/// Vertically Flip pen paths upside down
List<PolyPath> vFlip(List<PolyPath> paths) {
  List<PolyPath> flipped = [];
  for (PolyPath p in paths) {
    List<Anchor> pts = [];
    for (Anchor a in p.anchors) {
      switch (a) {
        case Anchor.N:
          pts.add(Anchor.S);
          break;
        case Anchor.NE:
          pts.add(Anchor.SE);
          break;
        case Anchor.SE:
          pts.add(Anchor.NE);
          break;
        case Anchor.S:
          pts.add(Anchor.N);
          break;
        case Anchor.SW:
          pts.add(Anchor.NW);
          break;
        case Anchor.NW:
          pts.add(Anchor.SW);
          break;
        default:
          pts.add(a);
      }
    }
    if (p is PolyLine) {
      flipped.add(PolyLine(pts));
    } else if (p is PolySpline) {
      flipped.add(PolySpline(pts));
    } else if (p is PolyDot) {
      flipped.add(PolyDot(pts));
    } else {
      throw UnimplementedError("Not expecting $p");
    }
  }
  return flipped;
}

/// Horizontally Flip pen strokes left to right
List<PolyPath> hFlip(List<PolyPath> paths) {
  List<PolyPath> flipped = [];
  for (PolyPath p in paths) {
    List<Anchor> pts = [];
    for (Anchor a in p.anchors) {
      switch (a) {
        case Anchor.NE:
          pts.add(Anchor.NW);
          break;
        case Anchor.E:
          pts.add(Anchor.W);
          break;
        case Anchor.SE:
          pts.add(Anchor.SW);
          break;
        case Anchor.SW:
          pts.add(Anchor.SE);
          break;
        case Anchor.W:
          pts.add(Anchor.E);
          break;
        case Anchor.NW:
          pts.add(Anchor.NE);
          break;
        default:
          pts.add(a);
      }
    }
    if (p is PolyLine) {
      flipped.add(PolyLine(pts));
    } else if (p is PolySpline) {
      flipped.add(PolySpline(pts));
    } else if (p is PolyDot) {
      flipped.add(PolyDot(pts));
    } else {
      throw UnimplementedError("Not expecting $p");
    }
  }
  return flipped;
}

/// Consist of 4 Quad Grams facing Right, Up, Left, Down.
abstract class QuadGrams {
  final ConsPair consPair;
  final Map<Face, Gram> face2gra;

  QuadGrams(
    this.consPair, {
    required List<PolyPath> r,
    required List<PolyPath> u,
    required List<PolyPath> l,
    required List<PolyPath> d,
  }) : face2gra = Map.unmodifiable({
          Face.Right: QuadGram(r, Face.Right, consPair),
          Face.Up: QuadGram(u, Face.Up, consPair),
          Face.Left: QuadGram(l, Face.Left, consPair),
          Face.Down: QuadGram(d, Face.Down, consPair)
        });

  Gram operator [](Face f) => face2gra[f]!;

  @override
  int get hashCode =>
      consPair.hashCode ^
      Face.values.fold(
          // use Face.values instead of face2gra.keys for fixed order
          0,
          (prev, f) => face2gra[f] == null
              ? prev
              : prev << 1 ^ f.hashCode ^ face2gra[f].hashCode);

  @override
  bool operator ==(Object other) {
    if (other is! QuadGrams) return false;

    QuadGrams that = other;

    return this.consPair == that.consPair &&
        this.face2gra[Face.Right] == that.face2gra[Face.Right] &&
        this.face2gra[Face.Up] == that.face2gra[Face.Up] &&
        this.face2gra[Face.Left] == that.face2gra[Face.Left] &&
        this.face2gra[Face.Down] == that.face2gra[Face.Down];
  }
}

/// In RotatingRow, quads are rotated by full step of 90'
class RotatingQuads extends QuadGrams {
  RotatingQuads(List<PolyPath> r, ConsPair cons)
      : super(cons, r: r, u: r2u(r), l: r2l(r), d: r2d(r));

  static List<PolyPath> r2u(List<PolyPath> rightPaths) => turn(rightPaths);

  static List<PolyPath> r2l(List<PolyPath> rightPaths) =>
      turn(rightPaths, steps: 2);

  static List<PolyPath> r2d(List<PolyPath> rightPaths) =>
      turn(rightPaths, steps: 3);
}

/// In SemiRotatingRow, quads are rotated by semi step of 45'
class SemiRotatingQuads extends QuadGrams {
  SemiRotatingQuads(List<PolyPath> r, ConsPair cons)
      : super(cons, r: r, u: r2u(r), l: r2l(r), d: r2d(r));

  static List<PolyPath> r2u(List<PolyPath> r) => turn(r, isSemi: true);

  static List<PolyPath> r2l(List<PolyPath> r) =>
      turn(r, steps: 2, isSemi: true);

  static List<PolyPath> r2d(List<PolyPath> r) =>
      turn(r, steps: 3, isSemi: true);
}

/// In FlipRow:
/// Right paths are flipped horizontally to make Left Path;
/// Up paths are obtained by rotating Right paths by 90';
/// Down paths are obtained by vertically flipping Up paths.
class FlipQuads extends QuadGrams {
  FlipQuads(List<PolyPath> r, ConsPair cons)
      : super(cons, r: r, u: r2u(r), l: r2l(r), d: r2d(r));

  static List<PolyPath> r2u(List<PolyPath> r) => turn(r);

  static List<PolyPath> r2l(List<PolyPath> r) => hFlip(r);

  static List<PolyPath> r2d(List<PolyPath> r) => vFlip(r2u(r));
}

/// In DoubleFlipRow:
/// Right paths are flipped horizontally and vertically to make Left Path;
/// Up paths are obtained by rotating Right paths by 90';
/// Down paths are obtained by vertically and horizontally flipping Up paths.
class DoubleFlipQuads extends QuadGrams {
  DoubleFlipQuads(List<PolyPath> r, ConsPair cons)
      : super(cons, r: r, u: r2u(r), l: r2l(r), d: r2d(r));

  static List<PolyPath> r2u(List<PolyPath> r) => hFlip(turn(r));

  static List<PolyPath> r2l(List<PolyPath> r) => vFlip(hFlip(r));

  static List<PolyPath> r2d(List<PolyPath> r) => hFlip(vFlip(r2u(r)));
}
