import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:grafon/gra_infra.dart';
import 'package:grafon/phonetics.dart';

class PolyTester extends PolyPath {
  PolyTester(List<Anchor> anchors) : super(anchors);
}

void main() {
  test('Polar Coordinates test unequal distance', () {
    const p1 = Polar(angle: 0, distance: 1);
    const p2 = Polar(angle: 0, distance: 2);

    expect(p1, isNot(equals(p2)));
  });

  test('Polar Coordinates test unequal angle', () {
    const p1 = Polar(angle: 1, distance: 2);
    const p2 = Polar(angle: 2, distance: 2);

    expect(p1, isNot(equals(p2)));
  });

  test('Polar Coordinates test equivalent origins', () {
    const o = Polar(angle: 0, distance: 0);
    const o1 = Polar(angle: 1, distance: 0);

    expect(o1, o);
  });

  test('Polar Coordinates test equivalent angles', () {
    const p1 = Polar(angle: pi, distance: 1);
    const p2 = Polar(angle: -pi, distance: 1);

    expect(p1, p2);

    const p3 = Polar(angle: 3 * pi, distance: 1);

    expect(p1, p3);
  });

  test('Anchors should have different polar values', () {
    final polarsFromAnchors = Set.of([
      ...Anchor.values.map((a) => a.polar),
    ]);

    expect(polarsFromAnchors.length, Anchor.values.length);
  });

  test('Anchors should have different vector values', () {
    final vectorsFromAnchors = Set.of([
      ...Anchor.values.map((a) => a.vector),
    ]);

    expect(vectorsFromAnchors.length, Anchor.values.length);
  });

  test('Anchors at Origin should have 0 distance from center', () {
    expect(Anchor.O.vector.length, 0.0);
  });

  test('Outer Anchors (not Origin) should all be .5 distance from center', () {
    final outerAnchors = [...Anchor.values]..remove(Anchor.O);

    for (final a in outerAnchors) {
      expect(a.polar.distance, Polar.DEFAULT_ANCHOR_DIST);
      expect(a.vector.length,
          moreOrLessEquals(Polar.DEFAULT_ANCHOR_DIST, epsilon: 0.001));
    }
  });

  test('Outer Anchors (not Origin) should all sum to 0 distance', () {
    final outerAnchors = [...Anchor.values]..remove(Anchor.O);

    final sumOuterVectors =
        outerAnchors.map((a) => a.vector).reduce((accum, v) => v + accum);

    expect(sumOuterVectors.length, moreOrLessEquals(0.0, epsilon: 0.001));
  });

  test('Outer Anchors (not Origin) are ordered in 45 degree steps', () {
    final outerAnchors = [...Anchor.values]..remove(Anchor.O);
    for (var i = 0; i < outerAnchors.length; i++) {
      final from = outerAnchors[i];
      final to = outerAnchors[(i + 1) % outerAnchors.length];
      expect(from.vector.angleToSigned(to.vector),
          moreOrLessEquals(pi / 4, epsilon: 0.001));
    }
  });

  test('Vowels should cover all Faces', () {
    final facesFromVowels = Set.of([
      ...Vowel.values.map((v) => v.face),
    ]);

    expect(facesFromVowels, Set.of(Face.values));
  });

  test('Faces should cover all Vowels', () {
    final vowelsFromFaces = Set.of([
      ...Face.values.map((f) => f.vowel),
    ]);

    expect(vowelsFromFaces, Set.of(Vowel.values));
  });

  test('Vowels short names should all be unique', () {
    final shortNamesFromVowels = Set.of([
      ...Vowel.values.map((v) => v.shortName),
    ]);

    expect(shortNamesFromVowels.length, Vowel.values.length);
  });

  test('Faces short names should all be unique', () {
    final shortNamesFromFaces = Set.of([
      ...Face.values.map((f) => f.shortName),
    ]);

    expect(shortNamesFromFaces.length, Face.values.length);
  });

  test('PolyDot equality and hashcode', () {
    for (final a1 in Anchor.values) {
      final dot1 = PolyDot([a1]);

      final emptyDots = PolyDot(List<Anchor>.empty());
      expect(dot1, isNot(equals(emptyDots)));
      expect(dot1.hashCode, isNot(equals(emptyDots.hashCode)));

      // PolyDots repeated dots are redundant
      final doubleDots = PolyDot([a1, a1]);
      expect(dot1, equals(doubleDots));
      expect(dot1.hashCode, equals(doubleDots.hashCode));

      final line = PolyLine([a1]);
      expect(dot1, isNot(equals(line)));
      expect(dot1.hashCode, isNot(equals(line.hashCode)));

      final spline = PolySpline([a1]);
      expect(dot1, isNot(equals(spline)));
      expect(dot1.hashCode, isNot(equals(spline.hashCode)));

      for (final a2 in Anchor.values) {
        final dot2 = PolyDot([a2]);
        if (a1 == a2) {
          expect(dot1, equals(dot2));
          expect(dot1.hashCode, equals(dot2.hashCode));
        } else {
          expect(dot1, isNot(equals(dot2)));
          expect(dot1.hashCode, isNot(equals(dot2.hashCode)));
        }

        final doubleDots1 = PolyDot([a1, a2]);
        final doubleDots2 = PolyDot([a1, a2]);
        expect(doubleDots1, equals(doubleDots2));
        expect(doubleDots1.hashCode, equals(doubleDots2.hashCode));

        /// for PolyDots ordering doesn't matter
        final doubleDotsReversed = PolyDot([a2, a1]);
        expect(doubleDots1, equals(doubleDotsReversed));
        expect(doubleDots1.hashCode, equals(doubleDotsReversed.hashCode));
      }
    }
  });

  test('PolyDot visibleAnchors are same as all anchors', () {
    final dots = PolyDot([Anchor.N, Anchor.S, Anchor.E, Anchor.W]);
    expect(dots.visibleAnchors, [Anchor.N, Anchor.S, Anchor.E, Anchor.W]);
  });

  test('PolyLine equality and hashcode', () {
    for (final a1 in Anchor.values) {
      final line1 = PolyLine([a1]);

      final emptyLine = PolyDot(List<Anchor>.empty());
      expect(line1, isNot(equals(emptyLine)));
      expect(line1.hashCode, isNot(equals(emptyLine.hashCode)));

      // PolyLine length is important
      final line11 = PolyLine([a1, a1]);
      expect(line1, isNot(equals(line11)));
      expect(line1.hashCode, isNot(equals(line11.hashCode)));

      final dot = PolyDot([a1]);
      expect(line1, isNot(equals(dot)));
      expect(line1.hashCode, isNot(equals(dot.hashCode)));

      final spline = PolySpline([a1]);
      expect(line1, isNot(equals(spline)));
      expect(line1.hashCode, isNot(equals(spline.hashCode)));

      for (final a2 in Anchor.values) {
        final line2 = PolyLine([a2]);
        if (a1 == a2) {
          expect(line1, equals(line2));
        } else {
          expect(line1, isNot(equals(line2)));
        }

        final line12 = PolyLine([a1, a2]);
        final line12B = PolyLine([a1, a2]);
        expect(line12, equals(line12B));
        expect(line12.hashCode, equals(line12B.hashCode));

        if (a1 != a2) {
          /// for PolyLines ordering matters
          final line21 = PolyLine([a2, a1]);
          expect(line12, isNot(equals(line21)));
          expect(line12.hashCode, isNot(equals(line21.hashCode)));
        }
      }
    }
  });

  test('PolyLine visibleAnchors are same as all anchors', () {
    final lines = PolyLine([Anchor.N, Anchor.S, Anchor.E, Anchor.W]);
    expect(lines.visibleAnchors, [Anchor.N, Anchor.S, Anchor.E, Anchor.W]);
  });

  test('PolySpline equality and hashcode', () {
    for (final a1 in Anchor.values) {
      final spline1 = PolySpline([a1]);

      final emptySpline = PolySpline(List<Anchor>.empty());
      expect(spline1, isNot(equals(emptySpline)));
      expect(spline1.hashCode, isNot(equals(emptySpline.hashCode)));

      // PolySpline length is important
      final spline11 = PolySpline([a1, a1]);
      expect(spline1, isNot(equals(spline11)));
      expect(spline1.hashCode, isNot(equals(spline11.hashCode)));

      final dot = PolyDot([a1]);
      expect(spline1, isNot(equals(dot)));
      expect(spline1.hashCode, isNot(equals(dot.hashCode)));

      final line = PolyLine([a1]);
      expect(spline1, isNot(equals(line)));
      expect(spline1.hashCode, isNot(equals(line.hashCode)));

      for (final a2 in Anchor.values) {
        final spline2 = PolySpline([a2]);
        if (a1 == a2) {
          expect(spline1, equals(spline2));
          expect(spline1.hashCode, equals(spline2.hashCode));
        } else {
          expect(spline1, isNot(equals(spline2)));
          expect(spline1.hashCode, isNot(equals(spline2.hashCode)));
        }

        final spline12 = PolySpline([a1, a2]);
        final spline12B = PolySpline([a1, a2]);
        expect(spline12, equals(spline12B));
        expect(spline12.hashCode, equals(spline12B.hashCode));

        if (a1 != a2) {
          /// for PolySplines ordering matters
          final spline21 = PolySpline([a2, a1]);
          expect(spline12, isNot(equals(spline21)));
          expect(spline12.hashCode, isNot(equals(spline21.hashCode)));
        }
      }
    }
  });

  test('PolySpline visibleAnchors are all anchors except first and last', () {
    final spline = PolySpline([Anchor.N, Anchor.S, Anchor.E, Anchor.W]);
    expect(spline.visibleAnchors, [Anchor.S, Anchor.E]);
  });

  test('turn by default of 90° except at Origin', () {
    final paths = [
      PolyDot([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolyDot([Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
      PolyLine([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolyLine([Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
      PolySpline([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolySpline([Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
    ];

    final turned = turn(paths);

    final expected = [
      PolyDot([Anchor.W, Anchor.E, Anchor.N, Anchor.S, Anchor.O]),
      PolyDot([Anchor.NW, Anchor.NE, Anchor.SW, Anchor.SE, Anchor.O]),
      PolyLine([Anchor.W, Anchor.E, Anchor.N, Anchor.S, Anchor.O]),
      PolyLine([Anchor.NW, Anchor.NE, Anchor.SW, Anchor.SE, Anchor.O]),
      PolySpline([Anchor.W, Anchor.E, Anchor.N, Anchor.S, Anchor.O]),
      PolySpline([Anchor.NW, Anchor.NE, Anchor.SW, Anchor.SE, Anchor.O]),
    ];

    expect(turned, equals(expected));
  });

  test('turn by +/- 0,1,2,3,4 steps of 90° except at Origin', () {
    final paths = [
      PolyDot([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolyDot([Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
      PolyLine([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolyLine([Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
      PolySpline([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolySpline([Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
    ];

    final expected1 = [
      PolyDot([Anchor.W, Anchor.E, Anchor.N, Anchor.S, Anchor.O]),
      PolyDot([Anchor.NW, Anchor.NE, Anchor.SW, Anchor.SE, Anchor.O]),
      PolyLine([Anchor.W, Anchor.E, Anchor.N, Anchor.S, Anchor.O]),
      PolyLine([Anchor.NW, Anchor.NE, Anchor.SW, Anchor.SE, Anchor.O]),
      PolySpline([Anchor.W, Anchor.E, Anchor.N, Anchor.S, Anchor.O]),
      PolySpline([Anchor.NW, Anchor.NE, Anchor.SW, Anchor.SE, Anchor.O]),
    ];

    final turned0 = turn(paths, steps: 0);
    final turned1 = turn(paths, steps: 1);
    final turned2 = turn(paths, steps: 2);
    final turned3 = turn(paths, steps: 3);
    final turned4 = turn(paths, steps: 4);
    final turnedNeg1 = turn(paths, steps: -1);
    final turnedNeg2 = turn(paths, steps: -2);
    final turnedNeg3 = turn(paths, steps: -3);
    final turnedNeg4 = turn(paths, steps: -4);

    expect(turned0, equals(paths));
    expect(turned1, equals(expected1));
    expect(turned2, equals(turn(expected1)));
    expect(turned3, equals(turn(turn(expected1))));
    expect(turned4, equals(paths));

    expect(turnedNeg1, equals(turned3));
    expect(turnedNeg2, equals(turned2));
    expect(turnedNeg3, equals(turned1));
    expect(turnedNeg4, equals(paths));

    for (var s = -10; s <= 10; s++) {
      expect(turn(paths, steps: s), equals(turn(paths, steps: s % 4)));
    }
  });

  test('turn by default of 45° i.e. semi-step, except at Origin', () {
    final paths = [
      PolyDot([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolyDot([Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
      PolyLine([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolyLine([Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
      PolySpline([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolySpline([Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
    ];

    final semiTurned = turn(paths, isSemi: true);

    final expected = [
      PolyDot([Anchor.NW, Anchor.SE, Anchor.NE, Anchor.SW, Anchor.O]),
      PolyDot([Anchor.N, Anchor.E, Anchor.W, Anchor.S, Anchor.O]),
      PolyLine([Anchor.NW, Anchor.SE, Anchor.NE, Anchor.SW, Anchor.O]),
      PolyLine([Anchor.N, Anchor.E, Anchor.W, Anchor.S, Anchor.O]),
      PolySpline([Anchor.NW, Anchor.SE, Anchor.NE, Anchor.SW, Anchor.O]),
      PolySpline([Anchor.N, Anchor.E, Anchor.W, Anchor.S, Anchor.O]),
    ];

    expect(semiTurned, equals(expected));
  });

  test('turn by +/- 0...8 steps of 45° i.e. semi-step, except at Origin', () {
    final paths = [
      PolyDot([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolyDot([Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
      PolyLine([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolyLine([Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
      PolySpline([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolySpline([Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
    ];

    final expected1 = [
      PolyDot([Anchor.NW, Anchor.SE, Anchor.NE, Anchor.SW, Anchor.O]),
      PolyDot([Anchor.N, Anchor.E, Anchor.W, Anchor.S, Anchor.O]),
      PolyLine([Anchor.NW, Anchor.SE, Anchor.NE, Anchor.SW, Anchor.O]),
      PolyLine([Anchor.N, Anchor.E, Anchor.W, Anchor.S, Anchor.O]),
      PolySpline([Anchor.NW, Anchor.SE, Anchor.NE, Anchor.SW, Anchor.O]),
      PolySpline([Anchor.N, Anchor.E, Anchor.W, Anchor.S, Anchor.O]),
    ];

    final turned0 = turn(paths, steps: 0, isSemi: true);
    final turned1 = turn(paths, steps: 1, isSemi: true);
    final turned2 = turn(paths, steps: 2, isSemi: true);
    final turned3 = turn(paths, steps: 3, isSemi: true);
    final turned4 = turn(paths, steps: 4, isSemi: true);
    final turned5 = turn(paths, steps: 5, isSemi: true);
    final turned6 = turn(paths, steps: 6, isSemi: true);
    final turned7 = turn(paths, steps: 7, isSemi: true);
    final turned8 = turn(paths, steps: 8, isSemi: true);
    final turnedNeg1 = turn(paths, steps: -1, isSemi: true);
    final turnedNeg2 = turn(paths, steps: -2, isSemi: true);
    final turnedNeg3 = turn(paths, steps: -3, isSemi: true);
    final turnedNeg4 = turn(paths, steps: -4, isSemi: true);
    final turnedNeg5 = turn(paths, steps: -5, isSemi: true);
    final turnedNeg6 = turn(paths, steps: -6, isSemi: true);
    final turnedNeg7 = turn(paths, steps: -7, isSemi: true);
    final turnedNeg8 = turn(paths, steps: -8, isSemi: true);

    expect(turned0, paths);
    expect(turned1, expected1);
    expect(turned2, turn(expected1, isSemi: true));
    expect(turned2, turn(paths, isSemi: false));
    expect(turned3, turn(turn(expected1, isSemi: true), isSemi: true));
    expect(turned3, turn(expected1, isSemi: true, steps: 2));
    expect(turned3, turn(expected1, isSemi: false));
    expect(turned4, turn(expected1, isSemi: true, steps: 3));
    expect(turned4, equals(turn(paths, steps: 2, isSemi: false)));
    expect(turned5, turn(expected1, isSemi: true, steps: 4));
    expect(turned5, equals(turn(expected1, steps: 2, isSemi: false)));
    expect(turned8, equals(paths));

    expect(turnedNeg1, turned7);
    expect(turnedNeg2, turned6);
    expect(turnedNeg3, turned5);
    expect(turnedNeg4, turned4);
    expect(turnedNeg5, turned3);
    expect(turnedNeg6, turned2);
    expect(turnedNeg7, turned1);
    expect(turnedNeg8, paths);

    for (var s = -20; s <= 20; s++) {
      expect(turn(paths, steps: s, isSemi: true),
          turn(paths, steps: s % 8, isSemi: true));
    }
  });

  test('turn throws exception with unexpected PolyPath', () {
    final testPaths = [
      PolyDot([Anchor.O]),
      PolyTester([Anchor.O])
    ];
    expect(() => turn(testPaths), throwsA(isA<UnimplementedError>()));
  });

  test('vFlip all anchors except at Origin', () {
    final paths = [
      PolyDot([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolyDot([Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
      PolyLine([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolyLine([Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
      PolySpline([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolySpline([Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
    ];

    final flipped = vFlip(paths);

    final expected = [
      PolyDot([Anchor.S, Anchor.N, Anchor.E, Anchor.W, Anchor.O]),
      PolyDot([Anchor.SE, Anchor.NE, Anchor.SW, Anchor.NW, Anchor.O]),
      PolyLine([Anchor.S, Anchor.N, Anchor.E, Anchor.W, Anchor.O]),
      PolyLine([Anchor.SE, Anchor.NE, Anchor.SW, Anchor.NW, Anchor.O]),
      PolySpline([Anchor.S, Anchor.N, Anchor.E, Anchor.W, Anchor.O]),
      PolySpline([Anchor.SE, Anchor.NE, Anchor.SW, Anchor.NW, Anchor.O]),
    ];

    expect(flipped, equals(expected));
    expect(vFlip(flipped), equals(paths));
  });

  test('vFlip throws exception with unexpected PolyPath', () {
    final testPaths = [
      PolyDot([Anchor.O]),
      PolyTester([Anchor.O])
    ];
    expect(() => vFlip(testPaths), throwsA(isA<UnimplementedError>()));
  });

  test('hFlip all anchors except at Origin', () {
    final paths = [
      PolyDot([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolyDot([Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
      PolyLine([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolyLine([Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
      PolySpline([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolySpline([Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
    ];

    final flipped = hFlip(paths);

    final expected = [
      PolyDot([Anchor.N, Anchor.S, Anchor.W, Anchor.E, Anchor.O]),
      PolyDot([Anchor.NW, Anchor.SW, Anchor.NE, Anchor.SE, Anchor.O]),
      PolyLine([Anchor.N, Anchor.S, Anchor.W, Anchor.E, Anchor.O]),
      PolyLine([Anchor.NW, Anchor.SW, Anchor.NE, Anchor.SE, Anchor.O]),
      PolySpline([Anchor.N, Anchor.S, Anchor.W, Anchor.E, Anchor.O]),
      PolySpline([Anchor.NW, Anchor.SW, Anchor.NE, Anchor.SE, Anchor.O]),
    ];

    expect(flipped, equals(expected));
    expect(hFlip(flipped), equals(paths));
  });

  test('hFlip throws exception with unexpected PolyPath', () {
    final testPaths = [
      PolyDot([Anchor.O]),
      PolyTester([Anchor.O])
    ];
    expect(() => hFlip(testPaths), throwsA(isA<UnimplementedError>()));
  });

  test('MonoGra equality and hashcode', () {
    final dotPaths = [
      PolyDot([Anchor.O])
    ];
    final linePaths = [
      PolyLine([Anchor.O])
    ];
    final dotAHA = MonoGra(dotPaths, ConsPair.AHA);
    expect(dotAHA, dotAHA);

    final dotAHA2 = MonoGra(dotPaths, ConsPair.AHA);
    expect(dotAHA, dotAHA2);
    expect(dotAHA.hashCode, dotAHA2.hashCode);

    final dotSAZA = MonoGra(dotPaths, ConsPair.SAZA);
    expect(dotAHA, isNot(equals(dotSAZA)));
    expect(dotAHA.hashCode, isNot(equals(dotSAZA.hashCode)));

    final lineAHA = MonoGra(linePaths, ConsPair.AHA);
    expect(dotAHA, isNot(equals(lineAHA)));
    expect(dotAHA.hashCode, isNot(equals(lineAHA.hashCode)));
  });

  test('MonoGra face, vowel, base vs head consonants', () {
    final xPaths = [
      PolyLine([Anchor.NW, Anchor.SE]),
      PolyLine([Anchor.NE, Anchor.SW])
    ];
    final xAHA = MonoGra(xPaths, ConsPair.AHA);
    expect(xAHA.face, Face.Center);
    expect(xAHA.vowel, Face.Center.vowel);
    expect(xAHA.base, Consonant.nil);
    expect(xAHA.head, Consonant.H);
  });

  test('MonoGra visualCenter is avg vectors of deduped visible anchors', () {
    final xPaths = [
      PolyLine([Anchor.NW, Anchor.SE]),
      PolyLine([Anchor.NE, Anchor.SW])
    ];
    final xAHA = MonoGra(xPaths, ConsPair.AHA);
    expect(xAHA.visualCenter.x, moreOrLessEquals(0, epsilon: 0.001));
    expect(xAHA.visualCenter.y, moreOrLessEquals(0, epsilon: 0.001));

    final circlePaths = [
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
    final circleAHA = MonoGra(circlePaths, ConsPair.AHA);
    expect(circleAHA.visualCenter.x, moreOrLessEquals(0, epsilon: 0.001));
    expect(circleAHA.visualCenter.y, moreOrLessEquals(0, epsilon: 0.001));
  });

  test('RotatingQuads equality and hashcode', () {
    final anglePaths = [
      PolyLine([Anchor.N, Anchor.E, Anchor.S])
    ];
    final angleAHA = RotatingQuads(anglePaths, ConsPair.AHA);
    expect(angleAHA, angleAHA);

    final semiAngleAHA = SemiRotatingQuads(anglePaths, ConsPair.AHA);
    expect(angleAHA, isNot(equals(semiAngleAHA)));
    expect(angleAHA.hashCode, isNot(equals(semiAngleAHA.hashCode)));

    final flipAngleAHA = FlipQuads(anglePaths, ConsPair.AHA);
    expect(angleAHA, isNot(equals(flipAngleAHA)));
    expect(angleAHA.hashCode, isNot(equals(flipAngleAHA.hashCode)));

    final doubleFlipAngleAHA = DoubleFlipQuads(anglePaths, ConsPair.AHA);
    expect(angleAHA, isNot(equals(doubleFlipAngleAHA)));
    expect(angleAHA.hashCode, isNot(equals(doubleFlipAngleAHA.hashCode)));

    final angleAHA2 = RotatingQuads(anglePaths, ConsPair.AHA);
    expect(angleAHA, equals(angleAHA2));
    expect(angleAHA.hashCode, angleAHA2.hashCode);

    final angleSAZA = RotatingQuads(anglePaths, ConsPair.SAZA);
    expect(angleAHA, isNot(equals(angleSAZA)));
    expect(angleAHA.hashCode, isNot(equals(angleSAZA.hashCode)));

    final gatePaths = [
      PolyLine([Anchor.NE, Anchor.NW, Anchor.SW, Anchor.SE])
    ];
    final gateAHA = RotatingQuads(gatePaths, ConsPair.AHA);
    expect(angleAHA, isNot(equals(gateAHA)));
    expect(angleAHA.hashCode, isNot(equals(gateAHA.hashCode)));
  });

  test('RotatingQuads face, vowel, base vs head consonants, visualCenter', () {
    final anglePaths = [
      PolyLine([Anchor.N, Anchor.E, Anchor.S])
    ];
    final angleAHA = RotatingQuads(anglePaths, ConsPair.AHA);
    expect(angleAHA.consPair.base, Consonant.nil);
    expect(angleAHA.consPair.head, Consonant.H);

    expect(angleAHA[Face.Right].face, Face.Right);
    expect(angleAHA[Face.Right].vowel, Face.Right.vowel);
    expect(angleAHA[Face.Right].base, Consonant.nil);
    expect(angleAHA[Face.Right].head, Consonant.H);
    expect(angleAHA[Face.Right].paths, anglePaths);
    expect(angleAHA[Face.Right].visualCenter.y,
        moreOrLessEquals(0, epsilon: 0.001));
    expect(angleAHA[Face.Right].visualCenter.x,
        moreOrLessEquals(0.1667, epsilon: 0.001));

    expect(angleAHA[Face.Up].face, Face.Up);
    expect(angleAHA[Face.Up].vowel, Face.Up.vowel);
    expect(angleAHA[Face.Up].base, Consonant.nil);
    expect(angleAHA[Face.Up].head, Consonant.H);
    expect(angleAHA[Face.Up].paths, turn(anglePaths, steps: 1, isSemi: false));
    expect(
        angleAHA[Face.Up].visualCenter.x, moreOrLessEquals(0, epsilon: 0.001));
    expect(angleAHA[Face.Up].visualCenter.y,
        moreOrLessEquals(0.1667, epsilon: 0.001));

    expect(angleAHA[Face.Left].face, Face.Left);
    expect(angleAHA[Face.Left].vowel, Face.Left.vowel);
    expect(angleAHA[Face.Left].base, Consonant.nil);
    expect(angleAHA[Face.Left].head, Consonant.H);
    expect(
        angleAHA[Face.Left].paths, turn(anglePaths, steps: 2, isSemi: false));
    expect(angleAHA[Face.Left].visualCenter.y,
        moreOrLessEquals(0, epsilon: 0.001));
    expect(angleAHA[Face.Left].visualCenter.x,
        moreOrLessEquals(-0.1667, epsilon: 0.001));

    expect(angleAHA[Face.Down].face, Face.Down);
    expect(angleAHA[Face.Down].vowel, Face.Down.vowel);
    expect(angleAHA[Face.Down].base, Consonant.nil);
    expect(angleAHA[Face.Down].head, Consonant.H);
    expect(
        angleAHA[Face.Down].paths, turn(anglePaths, steps: -1, isSemi: false));
    expect(angleAHA[Face.Down].visualCenter.x,
        moreOrLessEquals(0, epsilon: 0.001));
    expect(angleAHA[Face.Down].visualCenter.y,
        moreOrLessEquals(-0.1667, epsilon: 0.001));
  });

  test('SemiRotatingQuads equality and hashcode', () {
    final linePaths = [
      PolyLine([Anchor.SW, Anchor.NE])
    ];
    final semiLineAHA = SemiRotatingQuads(linePaths, ConsPair.AHA);
    expect(semiLineAHA, semiLineAHA);

    final lineAHA = RotatingQuads(linePaths, ConsPair.AHA);
    expect(semiLineAHA, isNot(equals(lineAHA)));
    expect(semiLineAHA.hashCode, isNot(equals(lineAHA.hashCode)));

    final flipLineAHA = FlipQuads(linePaths, ConsPair.AHA);
    expect(semiLineAHA, isNot(equals(flipLineAHA)));
    expect(semiLineAHA.hashCode, isNot(equals(flipLineAHA.hashCode)));

    final doubleFlipLineAHA = DoubleFlipQuads(linePaths, ConsPair.AHA);
    expect(semiLineAHA, isNot(equals(doubleFlipLineAHA)));
    expect(semiLineAHA.hashCode, isNot(equals(doubleFlipLineAHA.hashCode)));

    final semiLineAHA2 = SemiRotatingQuads(linePaths, ConsPair.AHA);
    expect(semiLineAHA, equals(semiLineAHA2));
    expect(semiLineAHA.hashCode, semiLineAHA2.hashCode);

    final semiLineSAZA = SemiRotatingQuads(linePaths, ConsPair.SAZA);
    expect(semiLineAHA, isNot(equals(semiLineSAZA)));
    expect(semiLineAHA.hashCode, isNot(equals(semiLineSAZA.hashCode)));

    final gatePaths = [
      PolyLine([Anchor.NE, Anchor.NW, Anchor.SW, Anchor.SE])
    ];
    final semiGateAHA = SemiRotatingQuads(gatePaths, ConsPair.AHA);
    expect(semiLineAHA, isNot(equals(semiGateAHA)));
    expect(semiLineAHA.hashCode, isNot(equals(semiGateAHA.hashCode)));
  });

  test('SemiRotatingQuads face, vowel, base/head consonants, visualCenter', () {
    final linePaths = [
      PolyLine([Anchor.SW, Anchor.NE])
    ];
    final semiLineAHA = SemiRotatingQuads(linePaths, ConsPair.AHA);
    expect(semiLineAHA.consPair.base, Consonant.nil);
    expect(semiLineAHA.consPair.head, Consonant.H);

    expect(semiLineAHA[Face.Right].face, Face.Right);
    expect(semiLineAHA[Face.Right].vowel, Face.Right.vowel);
    expect(semiLineAHA[Face.Right].base, Consonant.nil);
    expect(semiLineAHA[Face.Right].head, Consonant.H);
    expect(semiLineAHA[Face.Right].paths, linePaths);
    expect(semiLineAHA[Face.Right].visualCenter.y,
        moreOrLessEquals(0, epsilon: 0.001));
    expect(semiLineAHA[Face.Right].visualCenter.x,
        moreOrLessEquals(0, epsilon: 0.001));

    expect(semiLineAHA[Face.Up].face, Face.Up);
    expect(semiLineAHA[Face.Up].vowel, Face.Up.vowel);
    expect(semiLineAHA[Face.Up].base, Consonant.nil);
    expect(semiLineAHA[Face.Up].head, Consonant.H);
    expect(semiLineAHA[Face.Up].paths, turn(linePaths, steps: 1, isSemi: true));
    expect(semiLineAHA[Face.Up].visualCenter.x,
        moreOrLessEquals(0, epsilon: 0.001));
    expect(semiLineAHA[Face.Up].visualCenter.y,
        moreOrLessEquals(0, epsilon: 0.001));

    expect(semiLineAHA[Face.Left].face, Face.Left);
    expect(semiLineAHA[Face.Left].vowel, Face.Left.vowel);
    expect(semiLineAHA[Face.Left].base, Consonant.nil);
    expect(semiLineAHA[Face.Left].head, Consonant.H);
    expect(
        semiLineAHA[Face.Left].paths, turn(linePaths, steps: 2, isSemi: true));
    expect(semiLineAHA[Face.Left].visualCenter.y,
        moreOrLessEquals(0, epsilon: 0.001));
    expect(semiLineAHA[Face.Left].visualCenter.x,
        moreOrLessEquals(0, epsilon: 0.001));

    expect(semiLineAHA[Face.Down].face, Face.Down);
    expect(semiLineAHA[Face.Down].vowel, Face.Down.vowel);
    expect(semiLineAHA[Face.Down].base, Consonant.nil);
    expect(semiLineAHA[Face.Down].head, Consonant.H);
    expect(
        semiLineAHA[Face.Down].paths, turn(linePaths, steps: 3, isSemi: true));
    expect(semiLineAHA[Face.Down].visualCenter.x,
        moreOrLessEquals(0, epsilon: 0.001));
    expect(semiLineAHA[Face.Down].visualCenter.y,
        moreOrLessEquals(0, epsilon: 0.001));
  });

  test('FlipQuads equality and hashcode', () {
    final flowPaths = [
      PolySpline([
        Anchor.NW,
        Anchor.N,
        Anchor.S,
        Anchor.SE,
      ])
    ];
    final flipFlowAHA = FlipQuads(flowPaths, ConsPair.AHA);
    expect(flipFlowAHA, flipFlowAHA);

    final rotaFlowAHA = RotatingQuads(flowPaths, ConsPair.AHA);
    expect(flipFlowAHA, isNot(equals(rotaFlowAHA)));
    expect(flipFlowAHA.hashCode, isNot(equals(rotaFlowAHA.hashCode)));

    final semiFlowAHA = SemiRotatingQuads(flowPaths, ConsPair.AHA);
    expect(flipFlowAHA, isNot(equals(semiFlowAHA)));
    expect(flipFlowAHA.hashCode, isNot(equals(semiFlowAHA.hashCode)));

    final doubleFlipFlowAHA = DoubleFlipQuads(flowPaths, ConsPair.AHA);
    expect(flipFlowAHA, isNot(equals(doubleFlipFlowAHA)));
    expect(flipFlowAHA.hashCode, isNot(equals(doubleFlipFlowAHA.hashCode)));

    final flipFlowAHA2 = FlipQuads(flowPaths, ConsPair.AHA);
    expect(flipFlowAHA, equals(flipFlowAHA2));
    expect(flipFlowAHA.hashCode, flipFlowAHA2.hashCode);

    final flipFlowSAZA = FlipQuads(flowPaths, ConsPair.SAZA);
    expect(flipFlowAHA, isNot(equals(flipFlowSAZA)));
    expect(flipFlowAHA.hashCode, isNot(equals(flipFlowSAZA.hashCode)));

    final gatePaths = [
      PolyLine([Anchor.NE, Anchor.NW, Anchor.SW, Anchor.SE])
    ];
    final flipGateAHA = FlipQuads(gatePaths, ConsPair.AHA);
    expect(flipFlowAHA, isNot(equals(flipGateAHA)));
    expect(flipFlowAHA.hashCode, isNot(equals(flipGateAHA.hashCode)));
  });

  test('FlipQuads face, vowel, base/head consonants, visualCenter', () {
    final flowPaths = [
      PolySpline([
        Anchor.NW,
        Anchor.N,
        Anchor.S,
        Anchor.SE,
      ])
    ];
    final flipFlowAHA = FlipQuads(flowPaths, ConsPair.AHA);
    expect(flipFlowAHA.consPair.base, Consonant.nil);
    expect(flipFlowAHA.consPair.head, Consonant.H);

    expect(flipFlowAHA[Face.Right].face, Face.Right);
    expect(flipFlowAHA[Face.Right].vowel, Face.Right.vowel);
    expect(flipFlowAHA[Face.Right].base, Consonant.nil);
    expect(flipFlowAHA[Face.Right].head, Consonant.H);
    expect(flipFlowAHA[Face.Right].paths, flowPaths);
    expect(flipFlowAHA[Face.Right].visualCenter.y,
        moreOrLessEquals(0, epsilon: 0.001));
    expect(flipFlowAHA[Face.Right].visualCenter.x,
        moreOrLessEquals(0, epsilon: 0.001));

    expect(flipFlowAHA[Face.Up].face, Face.Up);
    expect(flipFlowAHA[Face.Up].vowel, Face.Up.vowel);
    expect(flipFlowAHA[Face.Up].base, Consonant.nil);
    expect(flipFlowAHA[Face.Up].head, Consonant.H);
    expect(flipFlowAHA[Face.Up].paths, turn(flowPaths));
    expect(flipFlowAHA[Face.Up].visualCenter.x,
        moreOrLessEquals(0, epsilon: 0.001));
    expect(flipFlowAHA[Face.Up].visualCenter.y,
        moreOrLessEquals(0, epsilon: 0.001));

    expect(flipFlowAHA[Face.Left].face, Face.Left);
    expect(flipFlowAHA[Face.Left].vowel, Face.Left.vowel);
    expect(flipFlowAHA[Face.Left].base, Consonant.nil);
    expect(flipFlowAHA[Face.Left].head, Consonant.H);
    expect(flipFlowAHA[Face.Left].paths, hFlip(flowPaths));
    expect(flipFlowAHA[Face.Left].visualCenter.y,
        moreOrLessEquals(0, epsilon: 0.001));
    expect(flipFlowAHA[Face.Left].visualCenter.x,
        moreOrLessEquals(0, epsilon: 0.001));

    expect(flipFlowAHA[Face.Down].face, Face.Down);
    expect(flipFlowAHA[Face.Down].vowel, Face.Down.vowel);
    expect(flipFlowAHA[Face.Down].base, Consonant.nil);
    expect(flipFlowAHA[Face.Down].head, Consonant.H);
    expect(flipFlowAHA[Face.Down].paths, vFlip(turn(flowPaths)));
    expect(flipFlowAHA[Face.Down].visualCenter.x,
        moreOrLessEquals(0, epsilon: 0.001));
    expect(flipFlowAHA[Face.Down].visualCenter.y,
        moreOrLessEquals(0, epsilon: 0.001));
  });

  test('DoubleFlipQuads equality and hashcode', () {
    final swirlPaths = [
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
    final dflipSwirlAHA = DoubleFlipQuads(swirlPaths, ConsPair.AHA);
    expect(dflipSwirlAHA, dflipSwirlAHA);

    final rotaSwirlAHA = RotatingQuads(swirlPaths, ConsPair.AHA);
    expect(dflipSwirlAHA, isNot(equals(rotaSwirlAHA)));
    expect(dflipSwirlAHA.hashCode, isNot(equals(rotaSwirlAHA.hashCode)));

    final semiSwirlAHA = SemiRotatingQuads(swirlPaths, ConsPair.AHA);
    expect(dflipSwirlAHA, isNot(equals(semiSwirlAHA)));
    expect(dflipSwirlAHA.hashCode, isNot(equals(semiSwirlAHA.hashCode)));

    final flipSwirlAHA = FlipQuads(swirlPaths, ConsPair.AHA);
    expect(dflipSwirlAHA, isNot(equals(flipSwirlAHA)));
    expect(dflipSwirlAHA.hashCode, isNot(equals(flipSwirlAHA.hashCode)));

    final dflipSwirlAHA2 = DoubleFlipQuads(swirlPaths, ConsPair.AHA);
    expect(dflipSwirlAHA, equals(dflipSwirlAHA2));
    expect(dflipSwirlAHA.hashCode, dflipSwirlAHA2.hashCode);

    final dflipSwirlSAZA = DoubleFlipQuads(swirlPaths, ConsPair.SAZA);
    expect(dflipSwirlAHA, isNot(equals(dflipSwirlSAZA)));
    expect(dflipSwirlAHA.hashCode, isNot(equals(dflipSwirlSAZA.hashCode)));

    final gatePaths = [
      PolyLine([Anchor.NE, Anchor.NW, Anchor.SW, Anchor.SE])
    ];
    final dflipGateAHA = DoubleFlipQuads(gatePaths, ConsPair.AHA);
    expect(dflipSwirlAHA, isNot(equals(dflipGateAHA)));
    expect(dflipSwirlAHA.hashCode, isNot(equals(dflipGateAHA.hashCode)));
  });

  test('DoubleFlipQuads face, vowel, base/head consonants, visualCenter', () {
    final swirlPaths = [
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
    final dflipSwirlAHA = DoubleFlipQuads(swirlPaths, ConsPair.AHA);
    expect(dflipSwirlAHA.consPair.base, Consonant.nil);
    expect(dflipSwirlAHA.consPair.head, Consonant.H);

    expect(dflipSwirlAHA[Face.Right].face, Face.Right);
    expect(dflipSwirlAHA[Face.Right].vowel, Face.Right.vowel);
    expect(dflipSwirlAHA[Face.Right].base, Consonant.nil);
    expect(dflipSwirlAHA[Face.Right].head, Consonant.H);
    expect(dflipSwirlAHA[Face.Right].paths, swirlPaths);
    expect(dflipSwirlAHA[Face.Right].visualCenter.y,
        moreOrLessEquals(0, epsilon: 0.001));
    expect(dflipSwirlAHA[Face.Right].visualCenter.x,
        moreOrLessEquals(0, epsilon: 0.001));

    expect(dflipSwirlAHA[Face.Up].face, Face.Up);
    expect(dflipSwirlAHA[Face.Up].vowel, Face.Up.vowel);
    expect(dflipSwirlAHA[Face.Up].base, Consonant.nil);
    expect(dflipSwirlAHA[Face.Up].head, Consonant.H);
    expect(dflipSwirlAHA[Face.Up].paths, hFlip(turn(swirlPaths)));
    expect(dflipSwirlAHA[Face.Up].visualCenter.x,
        moreOrLessEquals(0, epsilon: 0.001));
    expect(dflipSwirlAHA[Face.Up].visualCenter.y,
        moreOrLessEquals(0, epsilon: 0.001));

    expect(dflipSwirlAHA[Face.Left].face, Face.Left);
    expect(dflipSwirlAHA[Face.Left].vowel, Face.Left.vowel);
    expect(dflipSwirlAHA[Face.Left].base, Consonant.nil);
    expect(dflipSwirlAHA[Face.Left].head, Consonant.H);
    expect(dflipSwirlAHA[Face.Left].paths, vFlip(hFlip(swirlPaths)));
    expect(dflipSwirlAHA[Face.Left].visualCenter.y,
        moreOrLessEquals(0, epsilon: 0.001));
    expect(dflipSwirlAHA[Face.Left].visualCenter.x,
        moreOrLessEquals(0, epsilon: 0.001));

    expect(dflipSwirlAHA[Face.Down].face, Face.Down);
    expect(dflipSwirlAHA[Face.Down].vowel, Face.Down.vowel);
    expect(dflipSwirlAHA[Face.Down].base, Consonant.nil);
    expect(dflipSwirlAHA[Face.Down].head, Consonant.H);
    expect(
        dflipSwirlAHA[Face.Down].paths, hFlip(vFlip(hFlip(turn(swirlPaths)))));
    expect(dflipSwirlAHA[Face.Down].visualCenter.x,
        moreOrLessEquals(0, epsilon: 0.001));
    expect(dflipSwirlAHA[Face.Down].visualCenter.y,
        moreOrLessEquals(0, epsilon: 0.001));
  });
}
