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

import 'gram_infra.dart';
import 'phonetics.dart';

/// Gram Table organizes Grams into rows and columns and useful enums.
/// Each row has a MonoGram and a QuadGrams, shares the same ConsonantPair.
/// Each column is associated with a Face, shares the same vowel.

/// enum for each MonoGram
enum Mono {
  Space,
  Dot,
  Cross,
  Square,
  X,
  Sun,
  Circle,
  Flower,
  Blob,
}

/// Map a MonoGram to each Mono enum, its QuadGrams peer, and shortname.
extension MonoExtension on Mono {
  String get shortName => this.toString().split('.').last;

  Gram get gram {
    const List<PolyPath> spacePaths = [];

    const dotPaths = [
      PolyDot([Anchor.O])
    ];

    const xPaths = [
      PolyLine([Anchor.NW, Anchor.SE]),
      PolyLine([Anchor.NE, Anchor.SW])
    ];

    const crossPaths = [
      PolyLine([Anchor.N, Anchor.S]),
      PolyLine([Anchor.W, Anchor.E])
    ];

    const squarePaths = [
      PolyLine([
        Anchor.NW,
        Anchor.NE,
        Anchor.SE,
        Anchor.SW,
        Anchor.NW,
      ])
    ];

    const sunPaths = [
      PolyLine([Anchor.W, Anchor.E]),
      PolyLine([Anchor.NE, Anchor.SW]),
      PolyLine([Anchor.N, Anchor.S]),
      PolyLine([Anchor.NW, Anchor.SE]),
    ];

    const circlePaths = [
      PolySpline([
        Anchor.W,
        Anchor.N,
        Anchor.E,
        Anchor.S,
        Anchor.W,
        Anchor.N,
        Anchor.E,
      ])
    ];

    const flowerPaths = [
      PolySpline([
        Anchor.E,
        Anchor.O,
        Anchor.S,
        Anchor.O,
        Anchor.W,
      ]),
      PolySpline([
        Anchor.S,
        Anchor.O,
        Anchor.W,
        Anchor.O,
        Anchor.N,
      ]),
      PolySpline([
        Anchor.N,
        Anchor.O,
        Anchor.E,
        Anchor.O,
        Anchor.S,
      ]),
      PolySpline([
        Anchor.W,
        Anchor.O,
        Anchor.N,
        Anchor.O,
        Anchor.E,
      ]),
    ];

    const blobPaths = [
      PolySpline([
        Anchor.S,
        Anchor.NW,
        Anchor.N,
        Anchor.N,
        Anchor.NE,
        Anchor.S,
      ]),
      PolySpline([
        Anchor.W,
        Anchor.NE,
        Anchor.E,
        Anchor.E,
        Anchor.SE,
        Anchor.W,
      ]),
      PolySpline([
        Anchor.N,
        Anchor.SW,
        Anchor.S,
        Anchor.S,
        Anchor.SE,
        Anchor.N,
      ]),
      PolySpline([
        Anchor.E,
        Anchor.SW,
        Anchor.W,
        Anchor.W,
        Anchor.NW,
        Anchor.E,
      ]),
    ];

    switch (this) {
      case Mono.Dot:
        return const MonoGram(dotPaths, ConsPair.SAZA);
      case Mono.X:
        return const MonoGram(xPaths, ConsPair.GAKA);
      case Mono.Cross:
        return const MonoGram(crossPaths, ConsPair.BAPA);
      case Mono.Square:
        return const MonoGram(squarePaths, ConsPair.DATA);
      case Mono.Sun:
        return const MonoGram(sunPaths, ConsPair.JACHA);
      case Mono.Circle:
        return const MonoGram(circlePaths, ConsPair.MANA);
      case Mono.Flower:
        return const MonoGram(flowerPaths, ConsPair.VAFA);
      case Mono.Blob:
        return const MonoGram(blobPaths, ConsPair.LARA);
      default:
        return const MonoGram(spacePaths, ConsPair.AHA);
    }
  }

  Quad get quadPeer =>
      Quad.values.firstWhere((q) => q.grams.consPair == this.gram.consPair);
}

/// enum for each of the QuadGram grouping.
enum Quad {
  Line,
  Drip,
  Angle,
  Corner,
  Gate,
  Arrow,
  Arc,
  Flow,
  Swirl,
}

/// QuadHelper is a singleton to only instantiates QuadGrams only once
class _QuadHelper {
  static const dripPaths = [
    PolyDot([Anchor.NE, Anchor.SW])
  ];

  static const linePaths = [
    PolyLine([Anchor.NE, Anchor.SW])
  ];

  static const anglePaths = [
    PolyLine([Anchor.N, Anchor.E, Anchor.S]),
  ];

  static const cornerPaths = [
    PolyLine([Anchor.SE, Anchor.NE, Anchor.NW])
  ];

  static const gatePaths = [
    PolyLine([Anchor.NE, Anchor.NW, Anchor.SW, Anchor.SE])
  ];

  static const arrowPaths = [
    PolyLine([Anchor.N, Anchor.E, Anchor.S]),
    PolyLine([Anchor.W, Anchor.E])
  ];

  static const arcPaths = [
    PolySpline([
      Anchor.W,
      Anchor.N,
      Anchor.E,
      Anchor.S,
      Anchor.W,
    ]),
  ];

  static const flowPaths = [
    PolySpline([
      Anchor.NW,
      Anchor.N,
      Anchor.S,
      Anchor.SE,
    ])
  ];

  static const swirlPaths = [
    PolySpline([
      Anchor.N,
      Anchor.NW,
      Anchor.SW,
      Anchor.SE,
      Anchor.NE,
      Anchor.O,
      Anchor.E,
    ])
  ];

  static final Map<Quad, QuadGrams> enum2quads = Map.unmodifiable({
    Quad.Line: SemiRotatingQuads(linePaths, ConsPair.AHA),
    Quad.Drip: SemiRotatingQuads(dripPaths, ConsPair.SAZA),
    Quad.Angle: RotatingQuads(anglePaths, ConsPair.GAKA),
    Quad.Corner: RotatingQuads(cornerPaths, ConsPair.BAPA),
    Quad.Gate: RotatingQuads(gatePaths, ConsPair.DATA),
    Quad.Arrow: RotatingQuads(arrowPaths, ConsPair.JACHA),
    Quad.Arc: RotatingQuads(arcPaths, ConsPair.MANA),
    Quad.Flow: FlipQuads(flowPaths, ConsPair.VAFA),
    Quad.Swirl: DoubleFlipQuads(swirlPaths, ConsPair.LARA),
  });
}

/// extension to map quad enum to its QuadGrams, indexing by Face, & short name.
extension QuadExtension on Quad {
  QuadGrams get grams => _QuadHelper.enum2quads[this]!;

  Gram operator [](Face f) => grams[f];

  Mono get monoPeer =>
      Mono.values.firstWhere((m) => m.gram.consPair == this.grams.consPair);

  String get shortName => this.toString().split('.').last;
}

/// GramTable is a static helper to implement various lookup efficiently
abstract class GramTable {
  static Map<ConsPair, Map<Vowel, Gram>> _gramByConsPairVowel() {
    Map<ConsPair, Map<Vowel, Gram>> c2v2g = {};
    for (var cons in ConsPair.values) {
      final mono = Mono.values.firstWhere((m) => m.gram.consPair == cons);
      final quad = mono.quadPeer;
      c2v2g[cons] = Map.unmodifiable({
        Face.Center.vowel: mono.gram,
        for (var f in [Face.Right, Face.Up, Face.Left, Face.Down])
          f.vowel: quad[f]
      });
    }
    return Map.unmodifiable(c2v2g);
  }

  static final Map<ConsPair, Map<Vowel, Gram>> _map = _gramByConsPairVowel();

  static Gram atConsPairVowel(ConsPair cp, Vowel v) => _map[cp]![v]!;

  static Gram atConsonantVowel(Consonant c, Vowel v) => _map[c.pair]![v]!;

  static Gram atMonoFace(Mono m, Face f) => _map[m.gram.consPair]![f.vowel]!;

  static Gram at(dynamic r, dynamic c) {
    Map<Vowel, Gram> v2g;
    if (r is ConsPair) {
      final ConsPair cp = r;
      v2g = _map[cp]!;
    } else if (r is Consonant) {
      final Consonant c = r;
      v2g = _map[c.pair]!;
    } else if (r is Mono) {
      final Mono m = r;
      v2g = _map[m.gram.consPair]!;
    } else if (r is Quad) {
      final Quad q = r;
      v2g = _map[q.grams.consPair]!;
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

  static final numRows = Mono.values.length;
  static final numCols = Face.values.length;

  static Mono getMonoEnum(Gram g) {
    return g is MonoGram
        ? Mono.values.firstWhere((m) => m.gram.consPair == g.consPair)
        : Quad.values
            .firstWhere((q) => q.grams.consPair == g.consPair)
            .monoPeer;
  }

  static Mono? getEnumIfMono(Gram g) {
    return g is MonoGram
        ? Mono.values.firstWhere((m) => m.gram.consPair == g.consPair)
        : null;
  }

  static Quad? getEnumIfQuad(Gram g) {
    return g is QuadGram
        ? Quad.values.firstWhere((q) => q.grams.consPair == g.consPair)
        : null;
  }
}
