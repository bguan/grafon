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

import 'package:grafon/expression.dart';

import 'gram_infra.dart';
import 'phonetics.dart';

/// enum for each MonoGram
enum Mono {
  Dot,
  Cross,
  Square,
  X,
  Light,
  Sun,
  Circle,
  Flower,
  Blob,
}

/// enum for each of the QuadGram grouping.
enum Quads {
  Line,
  Corner,
  Angle,
  Gate,
  Step,
  Zap,
  Arc,
  Flow,
  Swirl,
}

/// MonoHelper is a singleton to only instantiates MonoGrams only once
class _MonoHelper {
  static final _MonoHelper _singleton = _MonoHelper._internal();

  factory _MonoHelper() {
    return _singleton;
  }

  final dotPaths = [
    PolyDot.anchors([Anchor.O], isFixedAspect: true)
  ];

  final crossPaths = [
    PolyStraight.anchors([Anchor.N, Anchor.S], isFixedAspect: true),
    PolyStraight.anchors([Anchor.W, Anchor.E], isFixedAspect: true)
  ];

  final xPaths = [
    PolyStraight.anchors([Anchor.NW, Anchor.SE], isFixedAspect: true),
    PolyStraight.anchors([Anchor.NE, Anchor.SW], isFixedAspect: true)
  ];

  final squarePaths = [
    PolyStraight.anchors([
      Anchor.NW,
      Anchor.NE,
      Anchor.SE,
      Anchor.SW,
      Anchor.NW,
    ], isFixedAspect: true)
  ];

  final sunPaths = [
    PolyStraight.anchors([Anchor.W, Anchor.E], isFixedAspect: true),
    PolyStraight.anchors([Anchor.NE, Anchor.SW], isFixedAspect: true),
    PolyStraight.anchors([Anchor.N, Anchor.S], isFixedAspect: true),
    PolyStraight.anchors([Anchor.NW, Anchor.SE], isFixedAspect: true),
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
    ], isFixedAspect: true)
  ];

  final blobPaths = [
    PolyCurve.anchors([
      Anchor.IW,
      Anchor.NW,
      Anchor.IN,
      Anchor.NE,
      Anchor.IE,
      Anchor.SE,
      Anchor.IS,
      Anchor.SW,
      Anchor.IW,
      Anchor.NW,
      Anchor.IN,
    ], isFixedAspect: true)
  ];

  final lightPaths = [
    PolyStraight.anchors([Anchor.E, Anchor.IE], isFixedAspect: true),
    PolyStraight.anchors([Anchor.N, Anchor.IN], isFixedAspect: true),
    PolyStraight.anchors([Anchor.W, Anchor.IW], isFixedAspect: true),
    PolyStraight.anchors([Anchor.S, Anchor.IS], isFixedAspect: true),
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

  late final Map<Mono, MonoGram> enum2mono;

  _MonoHelper._internal() {
    enum2mono = Map.unmodifiable({
      Mono.Dot: MonoGram(dotPaths, ConsPair.aHa),
      Mono.Cross: MonoGram(crossPaths, ConsPair.BaPa),
      Mono.X: MonoGram(xPaths, ConsPair.GaKa),
      Mono.Square: MonoGram(squarePaths, ConsPair.DaTa),
      Mono.Light: MonoGram(lightPaths, ConsPair.ChaJa),
      Mono.Sun: MonoGram(sunPaths, ConsPair.SaZa),
      Mono.Circle: MonoGram(circlePaths, ConsPair.MaNa),
      Mono.Flower: MonoGram(flowerPaths, ConsPair.FaVa),
      Mono.Blob: MonoGram(blobPaths, ConsPair.LaRa),
    });
  }
}

/// QuadHelper is a singleton to only instantiates QuadGrams only once
class _QuadHelper {
  static final _QuadHelper _singleton = _QuadHelper._internal();

  factory _QuadHelper() {
    return _singleton;
  }

  final cornerPaths = [
    PolyStraight.anchors([Anchor.SE, Anchor.NE, Anchor.NW])
  ];

  final linePaths = [
    PolyStraight.anchors([Anchor.NE, Anchor.SW])
  ];

  final anglePaths = [
    PolyStraight.anchors([Anchor.NW, Anchor.IE, Anchor.SW]),
  ];

  final gatePaths = [
    PolyStraight.anchors([Anchor.NW, Anchor.NE, Anchor.SE, Anchor.SW])
  ];

  final stepPaths = [
    PolyStraight.anchors([Anchor.NW, Anchor.IW, Anchor.IE, Anchor.SE])
  ];

  final zapPaths = [
    PolyStraight.anchors([Anchor.W, Anchor.IN, Anchor.IS, Anchor.E])
  ];

  final arcPaths = [
    PolyCurve.anchors([
      Anchor.NW,
      Anchor.N,
      Anchor.IE,
      Anchor.S,
      Anchor.SW,
    ]),
  ];

  final flowPaths = [
    PolyCurve.anchors([
      Anchor.SW,
      Anchor.W,
      Anchor.E,
      Anchor.NE,
    ])
  ];

  final swirlPaths = [
    PolyCurve.anchors([
      Anchor.N,
      Anchor.W,
      Anchor.S,
      Anchor.E,
      Anchor.IN,
      Anchor.O,
      Anchor.NE,
    ])
  ];

  late final Map<Quads, QuadGrams> enum2quads;

  _QuadHelper._internal() {
    enum2quads = Map.unmodifiable({
      Quads.Line: SemiRotatingQuads(linePaths, ConsPair.aHa),
      Quads.Corner: RotatingQuads(cornerPaths, ConsPair.BaPa),
      Quads.Angle: RotatingQuads(anglePaths, ConsPair.GaKa),
      Quads.Gate: RotatingQuads(gatePaths, ConsPair.DaTa),
      Quads.Step: FlipQuads(stepPaths, ConsPair.ChaJa),
      Quads.Zap: FlipQuads(zapPaths, ConsPair.SaZa),
      Quads.Arc: RotatingQuads(arcPaths, ConsPair.MaNa),
      Quads.Flow: FlipQuads(flowPaths, ConsPair.FaVa),
      Quads.Swirl: DoubleFlipQuads(swirlPaths, ConsPair.LaRa),
    });
  }
}

/// Map a MonoGram to each Mono enum, its QuadGrams peer, and shortname.
extension MonoExtension on Mono {
  String get shortName => this.toString().split('.').last;

  Gram get gram => _MonoHelper().enum2mono[this]!;

  Quads get quadPeer =>
      Quads.values.firstWhere((q) => q.grams.consPair == this.gram.consPair);

  GramExpression shrink() => gram.shrink();

  GramExpression up() => gram.up();

  GramExpression down() => gram.down();

  GramExpression left() => gram.left();

  GramExpression right() => gram.right();

  GramExpression merge(GramExpression that) => gram.merge(that);

  GramExpression next(GramExpression that) => gram.next(that);

  GramExpression over(GramExpression that) => gram.over(that);

  GramExpression wrap(GramExpression that) => gram.wrap(that);
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
      Mono.values.firstWhere((m) => m.gram.consPair == this.grams.consPair);

  String get shortName => this.toString().split('.').last;
}

/// GramTable is a Singleton to implement various Gram lookup efficiently
class GramTable {
  final Map<ConsPair, Map<Vowel, Gram>> _gramByConsPairVowel = {};

  static final GramTable _singleton = GramTable._internal();

  factory GramTable() {
    return _singleton;
  }

  GramTable._internal() {
    for (var cons in ConsPair.values) {
      final mono = Mono.values.firstWhere((m) => m.gram.consPair == cons);
      final quad = mono.quadPeer;
      _gramByConsPairVowel[cons] = Map.unmodifiable({
        Face.Center.vowel: mono.gram,
        for (var f in [Face.Right, Face.Up, Face.Left, Face.Down])
          f.vowel: quad[f]
      });
    }
  }

  Gram atConsPairVowel(ConsPair cp, Vowel v) => _gramByConsPairVowel[cp]![v]!;

  Gram atConsonantVowel(Consonant c, Vowel v) =>
      _gramByConsPairVowel[c.pair]![v]!;

  Gram atMonoFace(Mono m, Face f) =>
      _gramByConsPairVowel[m.gram.consPair]![f.vowel]!;

  Gram at(dynamic r, dynamic c) {
    Map<Vowel, Gram> v2g;
    if (r is ConsPair) {
      final ConsPair cp = r;
      v2g = _gramByConsPairVowel[cp]!;
    } else if (r is Consonant) {
      final Consonant c = r;
      v2g = _gramByConsPairVowel[c.pair]!;
    } else if (r is Mono) {
      final Mono m = r;
      v2g = _gramByConsPairVowel[m.gram.consPair]!;
    } else if (r is Quads) {
      final Quads q = r;
      v2g = _gramByConsPairVowel[q.grams.consPair]!;
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
        ? Mono.values.firstWhere((m) => m.gram.consPair == g.consPair)
        : Quads.values
            .firstWhere((q) => q.grams.consPair == g.consPair)
            .monoPeer;
  }

  Mono? getEnumIfMono(Gram g) {
    return g is MonoGram
        ? Mono.values.firstWhere((m) => m.gram.consPair == g.consPair)
        : null;
  }

  Quads? getEnumIfQuad(Gram g) {
    return g is QuadGram
        ? Quads.values.firstWhere((q) => q.grams.consPair == g.consPair)
        : null;
  }
}
