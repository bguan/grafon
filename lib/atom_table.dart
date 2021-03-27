import 'atom_infra.dart';
import 'phonetics.dart';

enum Mono {
  Space,
  Dot,
  X,
  Cross,
  Square,
  Diamond,
  Sun,
  Circle,
  Flower,
  Blob,
}

extension MonoExtension on Mono {
  String get shortName => this.toString().split('.').last;

  Gra get gra {
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
      PolyLine([Anchor.NW, Anchor.NE, Anchor.SE, Anchor.SW, Anchor.NW])
    ];

    const diamondPaths = [
      PolyLine([Anchor.N, Anchor.E, Anchor.S, Anchor.W, Anchor.N])
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
        return const MonoGra(dotPaths, ConsPair.SASHA);
      case Mono.X:
        return const MonoGra(xPaths, ConsPair.ZAZHA);
      case Mono.Cross:
        return const MonoGra(crossPaths, ConsPair.BAPA);
      case Mono.Square:
        return const MonoGra(squarePaths, ConsPair.DATA);
      case Mono.Diamond:
        return const MonoGra(diamondPaths, ConsPair.GAKA);
      case Mono.Sun:
        return const MonoGra(sunPaths, ConsPair.JACHA);
      case Mono.Circle:
        return const MonoGra(circlePaths, ConsPair.MANA);
      case Mono.Flower:
        return const MonoGra(flowerPaths, ConsPair.VAFA);
      case Mono.Blob:
        return const MonoGra(blobPaths, ConsPair.LARA);
      default:
        return const MonoGra(spacePaths, ConsPair.AHA);
    }
  }

  Quad get quadPeer =>
      Quad.values.firstWhere((q) => q.gras.consPair == this.gra.consPair);
}

enum Quad { Line, Drip, Angle, Corner, Gate, Triangle, Arrow, Arc, Flow, Swirl }

/// QuadHelper is a singleton to only instantiates QuadGras and Quad once
class _QuadHelper {
  static const dripPaths = [
    PolyDot([Anchor.NE, Anchor.SW])
  ];

  static const linePaths = [
    PolyLine([Anchor.NE, Anchor.SW])
  ];

  static const anglePaths = [
    PolyLine([Anchor.NW, Anchor.E, Anchor.SW]),
  ];

  static const cornerPaths = [
    PolyLine([Anchor.SE, Anchor.NE, Anchor.NW])
  ];

  static const gatePaths = [
    PolyLine([Anchor.NE, Anchor.NW, Anchor.SW, Anchor.SE])
  ];

  static const trianglePaths = [
    PolyLine([Anchor.NW, Anchor.E, Anchor.SW, Anchor.NW]),
  ];

  static const arrowPaths = [
    PolyLine([Anchor.N, Anchor.E, Anchor.S]),
    PolyLine([Anchor.W, Anchor.E])
  ];

  static const arcPaths = [
    PolySpline([
      Anchor.W,
      Anchor.NW,
      Anchor.E,
      Anchor.SW,
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

  static final Map<Quad, QuadGras> enum2quads = Map.unmodifiable({
    Quad.Line: SemiRotatingQuads(linePaths, ConsPair.AHA),
    Quad.Drip: SemiRotatingQuads(dripPaths, ConsPair.SASHA),
    Quad.Angle: RotatingQuads(anglePaths, ConsPair.ZAZHA),
    Quad.Corner: RotatingQuads(cornerPaths, ConsPair.BAPA),
    Quad.Gate: RotatingQuads(gatePaths, ConsPair.DATA),
    Quad.Triangle: RotatingQuads(trianglePaths, ConsPair.GAKA),
    Quad.Arrow: RotatingQuads(arrowPaths, ConsPair.JACHA),
    Quad.Arc: RotatingQuads(arcPaths, ConsPair.MANA),
    Quad.Flow: FlipQuads(flowPaths, ConsPair.VAFA),
    Quad.Swirl: DoubleFlipQuads(swirlPaths, ConsPair.LARA),
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
        Face.Center.vowel: mono.gra,
        for (var f in [Face.Right, Face.Up, Face.Left, Face.Down])
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
