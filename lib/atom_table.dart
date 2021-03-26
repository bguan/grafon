import 'atom_infra.dart';
import 'phonetics.dart';

enum Mono { Dot, Splat, X, Cross, Square, Diamond, Sun, Circle, Flower, Empty }

extension MonoExtension on Mono {
  String get shortName => this.toString().split('.').last;

  Gra get gra {
    const _dotPaths = [
      PolyDot([Anchor.O])
    ];

    const _splatPaths = [
      PolyDot([Anchor.NE]),
      PolyDot([Anchor.NW]),
      PolyDot([Anchor.SW]),
      PolyDot([Anchor.SE]),
    ];

    const _xPaths = [
      PolyLine([Anchor.NW, Anchor.SE]),
      PolyLine([Anchor.NE, Anchor.SW])
    ];

    const _crossPaths = [
      PolyLine([Anchor.N, Anchor.S]),
      PolyLine([Anchor.W, Anchor.E])
    ];

    const _squarePaths = [
      PolyLine([Anchor.NW, Anchor.NE, Anchor.SE, Anchor.SW, Anchor.NW])
    ];

    const _diamondPaths = [
      PolyLine([Anchor.N, Anchor.E, Anchor.S, Anchor.W, Anchor.N])
    ];

    const _sunPaths = [
      PolyLine([Anchor.W, Anchor.E]),
      PolyLine([Anchor.NE, Anchor.SW]),
      PolyLine([Anchor.N, Anchor.S]),
      PolyLine([Anchor.NW, Anchor.SE]),
    ];

    const _circlePaths = [
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

    const _flowerPaths = [
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

    const List<PolyPath> _emptyPaths = [];

    switch (this) {
      case Mono.Dot:
        return const MonoGra(_dotPaths, ConsPair.AHA);
      case Mono.Splat:
        return const MonoGra(_splatPaths, ConsPair.SASHA);
      case Mono.X:
        return const MonoGra(_xPaths, ConsPair.ZAZHA);
      case Mono.Cross:
        return const MonoGra(_crossPaths, ConsPair.BAPA);
      case Mono.Square:
        return const MonoGra(_squarePaths, ConsPair.DATA);
      case Mono.Diamond:
        return const MonoGra(_diamondPaths, ConsPair.GAKA);
      case Mono.Sun:
        return const MonoGra(_sunPaths, ConsPair.JACHA);
      case Mono.Circle:
        return const MonoGra(_circlePaths, ConsPair.MANA);
      case Mono.Flower:
        return const MonoGra(_flowerPaths, ConsPair.VAFA);
      default:
        return const MonoGra(_emptyPaths, ConsPair.LARA);
    }
  }

  Quad get quadPeer =>
      Quad.values.firstWhere((q) => q.gras.consPair == this.gra.consPair);
}

enum Quad { Line, Drip, Angle, Corner, Gate, Triangle, Arrow, Arc, Flow, Swirl }

/// QuadHelper is a singleton to only instantiates QuadGras and Quad once
class _QuadHelper {
  static const _dripPaths = [
    PolyDot([Anchor.NE, Anchor.SW])
  ];

  static const _linePaths = [
    PolyLine([Anchor.NE, Anchor.SW])
  ];

  static const _anglePaths = [
    PolyLine([Anchor.NW, Anchor.E, Anchor.SW])
  ];

  static const _cornerPaths = [
    PolyLine([Anchor.SE, Anchor.NE, Anchor.NW])
  ];

  static const _gatePaths = [
    PolyLine([Anchor.NE, Anchor.NW, Anchor.SW, Anchor.SE])
  ];

  static const _trianglePaths = [
    PolyLine([Anchor.NW, Anchor.E, Anchor.SW, Anchor.NW])
  ];

  static const _arrowPaths = [
    PolyLine([Anchor.N, Anchor.E, Anchor.S]),
    PolyLine([Anchor.W, Anchor.E])
  ];

  static const _arcPaths = [
    PolySpline([
      Anchor.W,
      Anchor.NW,
      Anchor.E,
      Anchor.SW,
      Anchor.W,
    ])
  ];

  static const _flowPaths = [
    PolySpline([
      Anchor.NW,
      Anchor.N,
      Anchor.S,
      Anchor.SE,
    ])
  ];

  static const _swirlPaths = [
    PolySpline([
      Anchor.NE,
      Anchor.O,
      Anchor.N,
      Anchor.E,
      Anchor.S,
      Anchor.W,
      Anchor.N,
    ])
  ];

  static final Map<Quad, QuadGras> enum2quads = Map.unmodifiable({
    Quad.Line: SemiRotatingQuads(_linePaths, ConsPair.AHA),
    Quad.Drip: SemiRotatingQuads(_dripPaths, ConsPair.SASHA),
    Quad.Angle: RotatingQuads(_anglePaths, ConsPair.ZAZHA),
    Quad.Corner: RotatingQuads(_cornerPaths, ConsPair.BAPA),
    Quad.Gate: RotatingQuads(_gatePaths, ConsPair.DATA),
    Quad.Triangle: RotatingQuads(_trianglePaths, ConsPair.GAKA),
    Quad.Arrow: RotatingQuads(_arrowPaths, ConsPair.JACHA),
    Quad.Arc: RotatingQuads(_arcPaths, ConsPair.MANA),
    Quad.Flow: FlipQuads(_flowPaths, ConsPair.VAFA),
    Quad.Swirl: DoubleFlipQuads(_swirlPaths, ConsPair.LARA),
  });
}

extension QuadExtension on Quad {
  QuadGras get gras => _QuadHelper.enum2quads[this];

  Gra operator [](Face f) => gras[f];

  Mono get monoPeer =>
      Mono.values.firstWhere((m) => m.gra.consPair == this.gras.consPair);

  String get shortName => this.toString().split('.').last;
}

/// GraTable is a static helper to implement various lookup efficiently
class GraTable {
  static Map<ConsPair, Map<Vowel, Gra>> _graByConsPairVowel() {
    Map<ConsPair, Map<Vowel, Gra>> c2v2g = {};
    for (var cons in ConsPair.values) {
      final mono = Mono.values.firstWhere((m) => m.gra.consPair == cons);
      final quad = mono.quadPeer;
      c2v2g[cons] = Map.unmodifiable({
        Face.CENTER.vowel: mono.gra,
        for (var f in [Face.RIGHT, Face.UP, Face.LEFT, Face.DOWN])
          f.vowel: quad[f]
      });
    }
    return Map.unmodifiable(c2v2g);
  }

  static final Map<ConsPair, Map<Vowel, Gra>> _map = _graByConsPairVowel();

  static Gra atConsPairVowel(ConsPair cp, Vowel v) => _map[cp][v];

  static Gra atConsonantVowel(Consonant c, Vowel v) => _map[c.pair][v];

  static Gra atMonoFace(Mono m, Face f) => _map[m.gra.consPair][f.vowel];
  static final numRows = Mono.values.length;
  static final numCols = Face.values.length;
}
