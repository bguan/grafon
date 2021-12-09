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

/// Gram Table organizes Grams into rows and columns and useful enums.
/// Each row has a MonoGram and a QuadGrams, shares the same ConsonantPair.
/// Each column is associated with a Face, shares the same vowel.
library gram_table;

import 'package:enum_to_string/enum_to_string.dart';
import 'package:grafon/constants.dart';
import 'package:vector_math/vector_math.dart';

import 'grafon_expr.dart';
import 'gram_infra.dart';
import 'phonetics.dart';

/// enum for each MonoGram
enum Mono {
  Empty,
  Dot,
  Cross,
  Hex,
  Square,
  Grid,
  X,
  Diamond,
  Light,
  Sun,
  Blob,
  Circle,
  Eye,
  Star,
  Flower,
  Atom,
}

/// MonoHelper is a singleton to only instantiates MonoGrams only once
class _MonoHelper {
  static final _MonoHelper _singleton = _MonoHelper._internal();

  factory _MonoHelper() {
    return _singleton;
  }

  final emptyPaths = <PolyLine>[
    InvisiDot.anchors([], minHeight: GRAM_GAP, minWidth: GRAM_GAP)
  ];

  final dotPaths = [
    PolyDot.anchors([Anchor.O]),
    InvisiDot.anchors(
      [],
      minHeight: GRAM_GAP,
      minWidth: GRAM_GAP,
    ),
  ];

  final crossPaths = [
    PolyStraight.anchors([Anchor.N, Anchor.S], isFixedAspect: true),
    PolyStraight.anchors([Anchor.W, Anchor.E], isFixedAspect: true)
  ];

  final flowerPaths = [
    PolyCurve.anchors([
      Anchor.SW,
      Anchor.O,
      Anchor.SE,
      Anchor.O,
      Anchor.NE,
      Anchor.O,
      Anchor.NW,
      Anchor.O,
      Anchor.SW,
      Anchor.O,
      Anchor.SE,
    ], isFixedAspect: true),
  ];

  final squarePaths = [
    PolyStraight.anchors(
      [
        Anchor.NW,
        Anchor.NE,
        Anchor.SE,
        Anchor.SW,
        Anchor.NW,
      ],
      isFixedAspect: true,
    ),
  ];

  final gridPaths = [
    PolyExtended.anchors([Anchor.NW, Anchor.SW], isFixedAspect: true),
    PolyExtended.anchors([Anchor.NE, Anchor.SE], isFixedAspect: true),
    PolyExtended.anchors([Anchor.NW, Anchor.NE], isFixedAspect: true),
    PolyExtended.anchors([Anchor.SW, Anchor.SE], isFixedAspect: true),
  ];

  final xPaths = [
    PolyStraight.anchors([Anchor.NW, Anchor.SE], isFixedAspect: true),
    PolyStraight.anchors([Anchor.NE, Anchor.SW], isFixedAspect: true)
  ];

  final diamondPaths = [
    PolyStraight.anchors([
      Anchor.N,
      Anchor.E,
      Anchor.S,
      Anchor.W,
      Anchor.N,
    ], isFixedAspect: true)
  ];

  final sunPaths = [
    PolyStraight.anchors([Anchor.W, Anchor.E], isFixedAspect: true),
    PolyStraight.anchors([Anchor.NE, Anchor.SW], isFixedAspect: true),
    PolyStraight.anchors([Anchor.N, Anchor.S], isFixedAspect: true),
    PolyStraight.anchors([Anchor.NW, Anchor.SE], isFixedAspect: true),
  ];

  final lightPaths = [
    PolyStraight.anchors([Anchor.NE, Anchor.ne], isFixedAspect: true),
    PolyStraight.anchors([Anchor.NW, Anchor.nw], isFixedAspect: true),
    PolyStraight.anchors([Anchor.SW, Anchor.sw], isFixedAspect: true),
    PolyStraight.anchors([Anchor.SE, Anchor.se], isFixedAspect: true),
  ];

  final blobPaths = [
    PolyCurve.anchors([
      Anchor.w,
      Anchor.NW,
      Anchor.n,
      Anchor.NE,
      Anchor.e,
      Anchor.SE,
      Anchor.s,
      Anchor.SW,
      Anchor.w,
      Anchor.NW,
      Anchor.n,
    ], isFixedAspect: true)
  ];

  final circlePaths = [
    PolyCurve.anchors([
      Anchor.W,
      Anchor.N,
      Anchor.E,
      Anchor.S,
      Anchor.W,
      Anchor.N,
      Anchor.E,
    ], isFixedAspect: true),
  ];

  final starPaths = [
    PolyCurve.anchors([
      Anchor.N,
      Anchor.n,
      Anchor.e,
      Anchor.E,
    ], isFixedAspect: true),
    PolyCurve.anchors([
      Anchor.N,
      Anchor.n,
      Anchor.w,
      Anchor.W,
    ], isFixedAspect: true),
    PolyCurve.anchors([
      Anchor.W,
      Anchor.w,
      Anchor.s,
      Anchor.S,
    ], isFixedAspect: true),
    PolyCurve.anchors([
      Anchor.E,
      Anchor.e,
      Anchor.s,
      Anchor.S,
    ], isFixedAspect: true),
  ];

  final eyePaths = [
    PolyCurve.anchors([
      Anchor.W,
      Anchor.N,
      Anchor.E,
      Anchor.S,
      Anchor.W,
      Anchor.N,
      Anchor.E,
    ], isFixedAspect: true),
    PolyDot.anchors([
      Anchor.O,
    ], isFixedAspect: true),
  ];

  final atomPaths = [
    PolyCurve.anchors([
      Anchor.n,
      Anchor.NW,
      Anchor.w,
      Anchor.s,
      Anchor.SE,
      Anchor.e,
      Anchor.n,
      Anchor.NW,
      Anchor.w,
    ], isFixedAspect: true),
    PolyCurve.anchors([
      Anchor.n,
      Anchor.NE,
      Anchor.e,
      Anchor.s,
      Anchor.SW,
      Anchor.w,
      Anchor.n,
      Anchor.NE,
      Anchor.e,
    ], isFixedAspect: true),
  ];

  final hexPaths = [
    PolyStraight([
      Vector2(-.25, .4),
      Vector2(-.5, .0),
      Vector2(-.25, -.4),
      Vector2(.25, -.4),
      Vector2(.5, .0),
      Vector2(.25, .4),
      Vector2(-.25, .4),
    ]),
  ];

  late final Map<Mono, MonoGram> enum2mono;

  _MonoHelper._internal() {
    enum2mono = Map.unmodifiable({
      Mono.Empty: MonoGram(emptyPaths, Cons.NIL),
      Mono.Dot: MonoGram(dotPaths, Cons.h),
      Mono.Cross: MonoGram(crossPaths, Cons.b),
      Mono.Hex: MonoGram(hexPaths, Cons.p),
      Mono.Square: MonoGram(squarePaths, Cons.d),
      Mono.Grid: MonoGram(gridPaths, Cons.t),
      Mono.X: MonoGram(xPaths, Cons.g),
      Mono.Diamond: MonoGram(diamondPaths, Cons.k),
      Mono.Sun: MonoGram(sunPaths, Cons.s),
      Mono.Light: MonoGram(lightPaths, Cons.z),
      Mono.Blob: MonoGram(blobPaths, Cons.m),
      Mono.Circle: MonoGram(circlePaths, Cons.n),
      Mono.Star: MonoGram(starPaths, Cons.l),
      Mono.Eye: MonoGram(eyePaths, Cons.r),
      Mono.Atom: MonoGram(atomPaths, Cons.f),
      Mono.Flower: MonoGram(flowerPaths, Cons.v),
    });
  }
}

/// enum for each of the QuadGram grouping.
enum Quads {
  Line,
  Dots,
  Corner,
  Branch,
  Gate,
  Step,
  Angle,
  Triangle,
  Zap,
  Arrow,
  Bow,
  Arc,
  Swirl,
  Curve,
  Drop,
  Wave,
}

/// QuadHelper is a singleton to only instantiates QuadGrams only once
class _QuadHelper {
  static final _QuadHelper _singleton = _QuadHelper._internal();

  factory _QuadHelper() {
    return _singleton;
  }

  final linePaths = [
    PolyStraight.anchors([Anchor.NE, Anchor.SW]),
  ];

  final dotsPaths = [
    InvisiDot.anchors(
      [],
      minHeight: GRAM_GAP / 2,
      minWidth: GRAM_GAP / 2,
    ),
    PolyDot.anchors([Anchor.ne, Anchor.sw]),
  ];

  final cornerPaths = [
    PolyStraight.anchors([Anchor.S, Anchor.O, Anchor.E]),
  ];

  final dropPaths = [
    PolyCurve.anchors([
      Anchor.W,
      Anchor.w,
      Anchor.ne,
      Anchor.E,
      Anchor.se,
      Anchor.w,
      Anchor.W,
    ]),
  ];

  final gatePaths = [
    PolyStraight.anchors([Anchor.NW, Anchor.NE, Anchor.SE, Anchor.SW]),
  ];

  final stepPaths = [
    PolyStraight.anchors([Anchor.SW, Anchor.w, Anchor.e, Anchor.NE]),
  ];

  final anglePaths = [
    PolyStraight.anchors(
      [Anchor.NW, Anchor.e, Anchor.SW],
      isZeroAvg: true, // this hack allows pretty mix of angle in squares & gate
    ),
  ];

  final trianglePaths = [
    PolyStraight.anchors(
      [Anchor.NW, Anchor.e, Anchor.SW, Anchor.NW],
    ),
  ];

  final arrowPaths = [
    PolyStraight.anchors([Anchor.W, Anchor.E], isFixedAspect: true),
    PolyStraight.anchors([Anchor.n, Anchor.E], isFixedAspect: true),
    PolyStraight.anchors([Anchor.s, Anchor.E], isFixedAspect: true),
  ];

  final zapPaths = [
    PolyStraight(
      [Anchor.W * 1, Anchor.S * .4, Anchor.N * .4, Anchor.E * 1],
    ),
  ];

  final bowPaths = [
    PolyCurve.anchors([
      Anchor.NW,
      Anchor.N,
      Anchor.ne,
      Anchor.O,
      Anchor.w,
    ]),
    PolyCurve.anchors([
      Anchor.SW,
      Anchor.S,
      Anchor.se,
      Anchor.O,
      Anchor.w,
    ]),
  ];

  final arcPaths = [
    PolyCurve.anchors([
      Anchor.NW,
      Anchor.N,
      Anchor.E,
      Anchor.S,
      Anchor.SW,
    ]),
    InvisiDot.anchors([Anchor.E])
  ];

  final curvePaths = [
    PolyCurve.anchors([
      Anchor.S,
      Anchor.SW,
      Anchor.NE,
      Anchor.E,
    ]),
  ];

  final swirlPaths = [
    PolyCurve.anchors([
      Anchor.S,
      Anchor.W,
      Anchor.N,
      Anchor.E,
      Anchor.s,
      Anchor.O,
      Anchor.SE,
    ])
  ];

  final wavePaths = [
    PolyCurve.anchors([
      Anchor.SW,
      Anchor.W,
      Anchor.E,
      Anchor.NE,
    ])
  ];

  final branchPaths = [
    PolyStraight(
      [
        Anchor.NE * 1,
        Anchor.E * 0.233, // calibrated to align it nicely in triangle
        Anchor.w * 1,
        Anchor.E * 0.233, // calibrated to align it nicely in triangle
        Anchor.SE * 1
      ],
    ),
  ];

  late final Map<Quads, QuadGrams> enum2quads;

  _QuadHelper._internal() {
    enum2quads = Map.unmodifiable({
      Quads.Line: SemiRotatingQuads(linePaths, Cons.NIL),
      Quads.Dots: SemiRotatingQuads(dotsPaths, Cons.h),
      Quads.Corner: FlipQuads(cornerPaths, Cons.b),
      Quads.Branch: RotatingQuads(branchPaths, Cons.p),
      Quads.Gate: RotatingQuads(gatePaths, Cons.d),
      Quads.Step: RotaFlipQuads(stepPaths, Cons.t),
      Quads.Angle: RotatingQuads(anglePaths, Cons.g),
      Quads.Triangle: RotatingQuads(trianglePaths, Cons.k),
      Quads.Arrow: RotatingQuads(arrowPaths, Cons.s),
      Quads.Zap: RotaFlipQuads(zapPaths, Cons.z),
      Quads.Bow: RotatingQuads(bowPaths, Cons.m),
      Quads.Arc: RotatingQuads(arcPaths, Cons.n),
      Quads.Curve: FlipQuads(curvePaths, Cons.l, recenter: false),
      Quads.Swirl: RotaFlipQuads(swirlPaths, Cons.r),
      Quads.Wave: RotaFlipQuads(wavePaths, Cons.f),
      Quads.Drop: RotatingQuads(dropPaths, Cons.v),
    });
  }
}

/// Map a MonoGram to each Mono enum, its QuadGrams peer, and shortname.
extension MonoExtension on Mono {
  String get shortName => EnumToString.convertToString(this);

  Gram get gram => _MonoHelper().enum2mono[this]!;

  Quads get quadPeer =>
      Quads.values.firstWhere((q) => q.grams.cons == this.gram.cons);

  BinaryOpExpr mix(GrafonExpr e) => gram.mix(e);

  BinaryOpExpr next(GrafonExpr e) => gram.next(e);

  BinaryOpExpr over(GrafonExpr e) => gram.over(e);

  BinaryOpExpr wrap(GrafonExpr e) => gram.wrap(e);
}

/// extension to map quad enum to its QuadGrams, indexing by Face, & short name.
extension QuadExtension on Quads {
  QuadGrams get grams => _QuadHelper().enum2quads[this]!;

  Gram operator [](Face f) => grams[f];

  Gram get up => grams[Face.Up];

  Gram get down => grams[Face.Down];

  Gram get left => grams[Face.Left];

  Gram get right => grams[Face.Right];

  Mono get monoPeer =>
      Mono.values.firstWhere((m) => m.gram.cons == this.grams.cons);

  String get shortName => EnumToString.convertToString(this);
}

/// GramTable is a Singleton to implement various Gram lookup efficiently
class GramTable {
  final Map<Cons, Map<Vowel, Gram>> _gramByConsVowel = {};

  static final GramTable _singleton = GramTable._internal();

  factory GramTable() {
    return _singleton;
  }

  GramTable._internal() {
    for (var cons in Cons.values.where((c) => !c.isSpecial)) {
      final mono = Mono.values.firstWhere((m) => m.gram.cons == cons);
      final quad = mono.quadPeer;
      _gramByConsVowel[cons] = Map.unmodifiable({
        Face.Center.vowel: mono.gram,
        for (var f in [Face.Right, Face.Up, Face.Left, Face.Down])
          f.vowel: quad[f]
      });
    }
  }

  Gram atConsVowel(Cons c, Vowel v) => _gramByConsVowel[c]![v]!;

  Gram atMonoFace(Mono m, Face f) => atConsVowel(m.gram.cons, f.vowel);

  List<Gram> consRow(Cons c) => _gramByConsVowel[c]!.values.toList();

  List<Gram> monoRow(Mono m) => consRow(m.gram.cons);

  Gram at(dynamic r, dynamic c) {
    Map<Vowel, Gram> v2g;
    if (r is Cons) {
      final Cons c = r;
      v2g = _gramByConsVowel[c]!;
    } else if (r is Mono) {
      final Mono m = r;
      v2g = _gramByConsVowel[m.gram.cons]!;
    } else if (r is Quads) {
      final Quads q = r;
      v2g = _gramByConsVowel[q.grams.cons]!;
    } else {
      throw UnsupportedError("GramTable do not support lookup with $r");
    }

    Gram g;
    if (c is Vowel) {
      final Vowel v = c;
      g = v2g[v]!;
    } else if (c is Face) {
      final Face f = c;
      g = v2g[f.vowel]!;
    } else {
      throw UnsupportedError("GramTable do not support lookup with $c");
    }

    return g;
  }

  final numRows = Mono.values.length;
  final numCols = Face.values.length;

  Mono getMonoEnum(Gram g) {
    return g is MonoGram
        ? Mono.values.firstWhere((m) => m.gram.cons == g.cons)
        : Quads.values.firstWhere((q) => q.grams.cons == g.cons).monoPeer;
  }

  Mono? getEnumIfMono(Gram g) {
    return g is MonoGram
        ? Mono.values.firstWhere((m) => m.gram.cons == g.cons)
        : null;
  }

  Quads? getEnumIfQuad(Gram g) {
    return g is QuadGram
        ? Quads.values.firstWhere((q) => q.grams.cons == g.cons)
        : null;
  }
}
