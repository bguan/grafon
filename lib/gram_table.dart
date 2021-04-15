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
  Dot,
  Cross,
  Square,
  X,
  Diamond,
  Sun,
  Circle,
  Flower,
  Blob,
}

/// MonoHelper is a singleton to only instantiates MonoGrams only once
class _MonoHelper {
  static final dotPaths = [
    PolyDot.anchors([Anchor.O])
  ];

  static final crossPaths = [
    PolyLine.anchors([Anchor.N, Anchor.S]),
    PolyLine.anchors([Anchor.W, Anchor.E])
  ];

  static final xPaths = [
    PolyLine.anchors([Anchor.NW, Anchor.SE]),
    PolyLine.anchors([Anchor.NE, Anchor.SW])
  ];

  static final squarePaths = [
    PolyLine.anchors([
      Anchor.NW,
      Anchor.NE,
      Anchor.SE,
      Anchor.SW,
      Anchor.NW,
    ])
  ];

  static final diamondPaths = [
    PolyLine.anchors([
      Anchor.N,
      Anchor.W,
      Anchor.S,
      Anchor.E,
      Anchor.N,
    ])
  ];

  static final sunPaths = [
    PolyLine.anchors([Anchor.W, Anchor.E]),
    PolyLine.anchors([Anchor.NE, Anchor.SW]),
    PolyLine.anchors([Anchor.N, Anchor.S]),
    PolyLine.anchors([Anchor.NW, Anchor.SE]),
  ];

  static final circlePaths = [
    PolySpline.anchors([
      Anchor.W,
      Anchor.N,
      Anchor.E,
      Anchor.S,
      Anchor.W,
      Anchor.N,
      Anchor.E,
    ])
  ];

  static final flowerPaths = [
    PolySpline.anchors([
      Anchor.E,
      Anchor.O,
      Anchor.S,
      Anchor.O,
      Anchor.W,
    ]),
    PolySpline.anchors([
      Anchor.S,
      Anchor.O,
      Anchor.W,
      Anchor.O,
      Anchor.N,
    ]),
    PolySpline.anchors([
      Anchor.N,
      Anchor.O,
      Anchor.E,
      Anchor.O,
      Anchor.S,
    ]),
    PolySpline.anchors([
      Anchor.W,
      Anchor.O,
      Anchor.N,
      Anchor.O,
      Anchor.E,
    ]),
  ];

  static final blobPaths = [
    PolySpline.anchors([
      Anchor.S,
      Anchor.NW,
      Anchor.N,
      Anchor.N,
      Anchor.NE,
      Anchor.S,
    ]),
    PolySpline.anchors([
      Anchor.W,
      Anchor.NE,
      Anchor.E,
      Anchor.E,
      Anchor.SE,
      Anchor.W,
    ]),
    PolySpline.anchors([
      Anchor.N,
      Anchor.SW,
      Anchor.S,
      Anchor.S,
      Anchor.SE,
      Anchor.N,
    ]),
    PolySpline.anchors([
      Anchor.E,
      Anchor.SW,
      Anchor.W,
      Anchor.W,
      Anchor.NW,
      Anchor.E,
    ]),
  ];

  static final Map<Mono, MonoGram> enum2mono = Map.unmodifiable({
    Mono.Dot: MonoGram(dotPaths, ConsPair.AHA),
    Mono.Cross: MonoGram(crossPaths, ConsPair.BAPA),
    Mono.X: MonoGram(xPaths, ConsPair.GAKA),
    Mono.Square: MonoGram(squarePaths, ConsPair.DATA),
    Mono.Diamond: MonoGram(diamondPaths, ConsPair.JACHA),
    Mono.Sun: MonoGram(sunPaths, ConsPair.ZASA),
    Mono.Circle: MonoGram(circlePaths, ConsPair.NAMA),
    Mono.Flower: MonoGram(flowerPaths, ConsPair.VAFA),
    Mono.Blob: MonoGram(blobPaths, ConsPair.RALA),
  });
}

/// Map a MonoGram to each Mono enum, its QuadGrams peer, and shortname.
extension MonoExtension on Mono {
  String get shortName => this.toString().split('.').last;

  Gram get gram => _MonoHelper.enum2mono[this]!;

  Quads get quadPeer =>
      Quads.values.firstWhere((q) => q.grams.consPair == this.gram.consPair);
}

/// enum for each of the QuadGram grouping.
enum Quads {
  Line,
  Corner,
  Angle,
  Gate,
  Triangle,
  Step,
  Arc,
  Flow,
  Swirl,
}

/// QuadHelper is a singleton to only instantiates QuadGrams only once
class _QuadHelper {
  static final cornerPaths = [
    PolyLine.anchors([Anchor.SE, Anchor.NE, Anchor.NW])
  ];

  static final linePaths = [
    PolyLine.anchors([Anchor.NE, Anchor.SW])
  ];

  static final anglePaths = [
    PolyLine.anchors([Anchor.NW, Anchor.IE, Anchor.SW]),
  ];

  static final gatePaths = [
    PolyLine.anchors([Anchor.NE, Anchor.NW, Anchor.SW, Anchor.SE])
  ];

  static final trianglePaths = [
    PolyLine.anchors([Anchor.NW, Anchor.IE, Anchor.SW, Anchor.NW])
  ];

  static final stepPaths = [
    PolyLine.anchors([Anchor.SW, Anchor.IS, Anchor.IN, Anchor.NE])
  ];

  static final arcPaths = [
    PolySpline.anchors([
      Anchor.W,
      Anchor.N,
      Anchor.E,
      Anchor.S,
      Anchor.W,
    ]),
  ];

  static final flowPaths = [
    PolySpline.anchors([
      Anchor.SW,
      Anchor.W,
      Anchor.E,
      Anchor.NE,
    ])
  ];

  static final swirlPaths = [
    PolySpline.anchors([
      Anchor.NW,
      Anchor.W,
      Anchor.S,
      Anchor.E,
      Anchor.IN,
      Anchor.O,
      Anchor.IE,
    ])
  ];

  static final Map<Quads, QuadGrams> enum2quads = Map.unmodifiable({
    Quads.Line: SemiRotatingQuads(linePaths, ConsPair.AHA),
    Quads.Corner: RotatingQuads(cornerPaths, ConsPair.BAPA),
    Quads.Angle: RotatingQuads(anglePaths, ConsPair.GAKA),
    Quads.Gate: RotatingQuads(gatePaths, ConsPair.DATA),
    Quads.Triangle: RotatingQuads(trianglePaths, ConsPair.JACHA),
    Quads.Step: SemiRotatingQuads(stepPaths, ConsPair.ZASA),
    Quads.Arc: RotatingQuads(arcPaths, ConsPair.NAMA),
    Quads.Flow: FlipQuads(flowPaths, ConsPair.VAFA),
    Quads.Swirl: DoubleFlipQuads(swirlPaths, ConsPair.RALA),
  });
}

/// extension to map quad enum to its QuadGrams, indexing by Face, & short name.
extension QuadExtension on Quads {
  QuadGrams get grams => _QuadHelper.enum2quads[this]!;

  Gram operator [](Face f) => grams[f];

  Gram get up => grams[Face.Up];

  Gram get down => grams[Face.Down];

  Gram get left => grams[Face.Left];

  Gram get right => grams[Face.Right];

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
    } else if (r is Quads) {
      final Quads q = r;
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
        : Quads.values
            .firstWhere((q) => q.grams.consPair == g.consPair)
            .monoPeer;
  }

  static Mono? getEnumIfMono(Gram g) {
    return g is MonoGram
        ? Mono.values.firstWhere((m) => m.gram.consPair == g.consPair)
        : null;
  }

  static Quads? getEnumIfQuad(Gram g) {
    return g is QuadGram
        ? Quads.values.firstWhere((q) => q.grams.consPair == g.consPair)
        : null;
  }
}
