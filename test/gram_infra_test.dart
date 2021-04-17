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

import 'package:flutter_test/flutter_test.dart';
import 'package:grafon/gram_infra.dart';
import 'package:grafon/phonetics.dart';
import 'package:vector_math/vector_math.dart';

/// Unit Tests for Gram Infra

/// Dummy subclass of PolyPath for testing
class PolyTester extends PolyPath {
  PolyTester(List<Vector2> vectors) : super(vectors);

  PolyTester.anchors(List<Anchor> anchors)
      : super(List.unmodifiable(anchors.map((a) => a.vector)));
}

void main() {
  test('Polar Coordinates test unequal distance', () {
    final p1 = Polar(angle: 0, length: 1);
    final p2 = Polar(angle: 0, length: 2);

    expect(p1 == p2, isFalse);
  });

  test('Polar Coordinates test unequal angle', () {
    final p1 = Polar(angle: 1, length: 2);
    final p2 = Polar(angle: 2, length: 2);

    expect(p1 == p2, isFalse);
  });

  test('Polar Coordinates test equivalent origins', () {
    final o = Polar(angle: 0, length: 0);
    final o1 = Polar(angle: 1, length: 0);

    expect(o1, o);
  });

  test('Polar Coordinates test equivalent angles', () {
    final p1 = Polar(angle: pi, length: 1);
    final p2 = Polar(angle: -pi, length: 1);

    expect(p1, p2);

    final p3 = Polar(angle: 3 * pi, length: 1);

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

  test('Anchor outerPoints should only have anchor with outer distance', () {
    final outerAnchors = [...Anchor.values]
      ..removeWhere((a) => a.length < AnchorHelper.OUTER_DIST);
    expect(AnchorHelper.outerPoints.contains(Anchor.O), isFalse);
    for (final a in outerAnchors) {
      expect(AnchorHelper.outerPoints.contains(a), isTrue);
    }
  });

  test('Outer Anchors (not Origin) should all be .5 distance from center', () {
    final outerAnchors = AnchorHelper.outerPoints;

    for (final a in outerAnchors) {
      expect(a.polar.length, AnchorHelper.OUTER_DIST);
      expect(a.vector.length,
          moreOrLessEquals(AnchorHelper.OUTER_DIST, epsilon: floatPrecision));
    }
  });

  test('Outer Anchors (not Origin) should all sum to 0 distance', () {
    final outerAnchors = AnchorHelper.outerPoints;

    final sumOuterVectors =
        outerAnchors.map((a) => a.vector).reduce((accum, v) => v + accum);

    expect(
        sumOuterVectors.length, moreOrLessEquals(0.0, epsilon: floatPrecision));
  });

  test('Outer Anchors (not Origin) are ordered in 45 degree steps', () {
    final outerAnchors = AnchorHelper.outerPoints;
    for (var i = 0; i < outerAnchors.length; i++) {
      final from = outerAnchors[i];
      final to = outerAnchors[(i + 1) % outerAnchors.length];
      expect(from.vector.angleToSigned(to.vector),
          moreOrLessEquals(pi / 4, epsilon: floatPrecision));
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

  test('Face directionals should have all faces except center', () {
    final directions = [...Face.values]..remove(Face.Center);
    expect(FaceHelper.directionals.contains(Face.Center), isFalse);
    for (final f in directions) {
      expect(FaceHelper.directionals.contains(f), isTrue);
    }
  });

  test('PolyLine equality and hashcode', () {
    for (final a1 in Anchor.values) {
      final line1 = PolyLine.anchors([a1]);

      final emptyLine = PolyLine.anchors(List<Anchor>.empty());
      expect(line1 == emptyLine, isFalse);
      expect(line1.hashCode == emptyLine.hashCode, isFalse);

      // PolyLine length is important
      final line11 = PolyLine.anchors([a1, a1]);
      expect(line1.vectors == line11.vectors, isFalse);
      expect(line1.hashCode == line11.hashCode, isFalse);

      final spline = PolySpline.anchors([a1]);
      expect(line1 is PolySpline, isFalse);
      expect(line1.hashCode == spline.hashCode, isFalse);

      for (final a2 in Anchor.values) {
        final line2 = PolyLine.anchors([a2]);
        if (a1 == a2) {
          expect(line1, equals(line2));
        } else {
          expect(line1 == line2, isFalse);
        }

        final line12 = PolyLine.anchors([a1, a2]);
        final line12B = PolyLine.anchors([a1, a2]);
        expect(line12, equals(line12B));
        expect(line12.hashCode, equals(line12B.hashCode));

        if (a1 != a2) {
          /// for PolyLines ordering matters
          final line21 = PolyLine.anchors([a2, a1]);
          expect(line12 == line21, isFalse);
          expect(line12.hashCode == line21.hashCode, isFalse);
        }
      }
    }
  });

  test('PolyLine visiblePoints are same as all anchors', () {
    final nsew = [Anchor.N, Anchor.S, Anchor.E, Anchor.W];
    final lines = PolyLine.anchors(nsew);
    expect(lines.visiblePoints, nsew.map((a) => a.vector));
  });

  test('PolySpline equality and hashcode', () {
    for (final a1 in Anchor.values) {
      final spline1 = PolySpline.anchors([a1]);

      final emptySpline = PolySpline.anchors(List<Anchor>.empty());
      expect(spline1 == emptySpline, isFalse);
      expect(spline1.hashCode == emptySpline.hashCode, isFalse);

      // PolySpline length is important
      final spline11 = PolySpline.anchors([a1, a1]);
      expect(spline1 == spline11, isFalse);
      expect(spline1.hashCode == spline11.hashCode, isFalse);

      final line = PolyLine.anchors([a1]);
      expect(spline1 == line, isFalse);
      expect(spline1.hashCode == line.hashCode, isFalse);

      for (final a2 in Anchor.values) {
        final spline2 = PolySpline.anchors([a2]);
        if (a1 == a2) {
          expect(spline1, spline2);
          expect(spline1.hashCode, equals(spline2.hashCode));
        } else {
          expect(spline1 == spline2, isFalse);
          expect(spline1.hashCode == spline2.hashCode, isFalse);
        }

        final spline12 = PolySpline.anchors([a1, a2]);
        final spline12B = PolySpline.anchors([a1, a2]);
        expect(spline12, spline12B);
        expect(spline12.hashCode, equals(spline12B.hashCode));

        if (a1 != a2) {
          /// for PolySplines ordering matters
          final spline21 = PolySpline.anchors([a2, a1]);
          expect(spline12 == spline21, isFalse);
          expect(spline12.hashCode == spline21.hashCode, isFalse);
        }
      }
    }
  });

  test('PolySpline visiblePoints are all visible except first and last', () {
    final spline = PolySpline.anchors([Anchor.N, Anchor.S, Anchor.E, Anchor.W]);
    expect(spline.visiblePoints, [Anchor.S.vector, Anchor.E.vector]);
  });

  test('turn by default of 90° except at Origin', () {
    final paths = [
      PolyLine.anchors([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolyLine.anchors([Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
      PolySpline.anchors([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolySpline.anchors(
          [Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
    ];

    final turned = turn(paths);

    final expected = [
      PolyLine.anchors([Anchor.W, Anchor.E, Anchor.N, Anchor.S, Anchor.O]),
      PolyLine.anchors([Anchor.NW, Anchor.NE, Anchor.SW, Anchor.SE, Anchor.O]),
      PolySpline.anchors([Anchor.W, Anchor.E, Anchor.N, Anchor.S, Anchor.O]),
      PolySpline.anchors(
          [Anchor.NW, Anchor.NE, Anchor.SW, Anchor.SE, Anchor.O]),
    ];

    expect(turned, equals(expected));
  });

  test('turn by +/- 0,1,2,3,4 steps of 90° except at Origin', () {
    final paths = [
      PolyLine.anchors([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolyLine.anchors([Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
      PolySpline.anchors([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolySpline.anchors(
          [Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
    ];

    final expected1 = [
      PolyLine.anchors([Anchor.W, Anchor.E, Anchor.N, Anchor.S, Anchor.O]),
      PolyLine.anchors([Anchor.NW, Anchor.NE, Anchor.SW, Anchor.SE, Anchor.O]),
      PolySpline.anchors([Anchor.W, Anchor.E, Anchor.N, Anchor.S, Anchor.O]),
      PolySpline.anchors(
          [Anchor.NW, Anchor.NE, Anchor.SW, Anchor.SE, Anchor.O]),
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
      PolyLine.anchors([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolyLine.anchors([Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
      PolySpline.anchors([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolySpline.anchors(
          [Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
    ];

    final semiTurned = turn(paths, isSemi: true);

    final expected = [
      PolyLine.anchors([Anchor.NW, Anchor.SE, Anchor.NE, Anchor.SW, Anchor.O]),
      PolyLine.anchors([Anchor.N, Anchor.E, Anchor.W, Anchor.S, Anchor.O]),
      PolySpline.anchors(
          [Anchor.NW, Anchor.SE, Anchor.NE, Anchor.SW, Anchor.O]),
      PolySpline.anchors([Anchor.N, Anchor.E, Anchor.W, Anchor.S, Anchor.O]),
    ];

    expect(semiTurned, expected);
  });

  test('turn by +/- 0...8 steps of 45° i.e. semi-step, except at Origin', () {
    final paths = [
      PolyLine.anchors([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolyLine.anchors([Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
      PolySpline.anchors([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolySpline.anchors(
          [Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
    ];

    final expected1 = [
      PolyLine.anchors([Anchor.NW, Anchor.SE, Anchor.NE, Anchor.SW, Anchor.O]),
      PolyLine.anchors([Anchor.N, Anchor.E, Anchor.W, Anchor.S, Anchor.O]),
      PolySpline.anchors(
          [Anchor.NW, Anchor.SE, Anchor.NE, Anchor.SW, Anchor.O]),
      PolySpline.anchors([Anchor.N, Anchor.E, Anchor.W, Anchor.S, Anchor.O]),
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
      PolyTester.anchors([Anchor.O])
    ];
    expect(() => turn(testPaths), throwsA(isA<UnimplementedError>()));
  });

  test('vFlip all anchors except at Origin', () {
    final paths = [
      PolyLine.anchors([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolyLine.anchors([Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
      PolySpline.anchors([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolySpline.anchors(
          [Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
    ];

    final flipped = vFlip(paths);

    final expected = [
      PolyLine.anchors([Anchor.S, Anchor.N, Anchor.E, Anchor.W, Anchor.O]),
      PolyLine.anchors([Anchor.SE, Anchor.NE, Anchor.SW, Anchor.NW, Anchor.O]),
      PolySpline.anchors([Anchor.S, Anchor.N, Anchor.E, Anchor.W, Anchor.O]),
      PolySpline.anchors(
          [Anchor.SE, Anchor.NE, Anchor.SW, Anchor.NW, Anchor.O]),
    ];

    expect(flipped, equals(expected));
    expect(vFlip(flipped), equals(paths));
  });

  test('vFlip throws exception with unexpected PolyPath', () {
    final testPaths = [
      PolyTester.anchors([Anchor.O])
    ];
    expect(() => vFlip(testPaths), throwsA(isA<UnimplementedError>()));
  });

  test('hFlip all anchors except at Origin', () {
    final paths = [
      PolyLine.anchors([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolyLine.anchors([Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
      PolySpline.anchors([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolySpline.anchors(
          [Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
    ];

    final flipped = hFlip(paths);

    final expected = [
      PolyLine.anchors([Anchor.N, Anchor.S, Anchor.W, Anchor.E, Anchor.O]),
      PolyLine.anchors([Anchor.NW, Anchor.SW, Anchor.NE, Anchor.SE, Anchor.O]),
      PolySpline.anchors([Anchor.N, Anchor.S, Anchor.W, Anchor.E, Anchor.O]),
      PolySpline.anchors(
          [Anchor.NW, Anchor.SW, Anchor.NE, Anchor.SE, Anchor.O]),
    ];

    expect(flipped, equals(expected));
    expect(hFlip(flipped), equals(paths));
  });

  test('hFlip throws exception with unexpected PolyPath', () {
    final testPaths = [
      PolyTester.anchors([Anchor.O])
    ];
    expect(() => hFlip(testPaths), throwsA(isA<UnimplementedError>()));
  });

  test('MonoGram equality and hashcode', () {
    final paths1 = [
      PolySpline.anchors([Anchor.O])
    ];
    final paths2 = [
      PolyLine.anchors([Anchor.O])
    ];
    final m = MonoGram(paths1, ConsPair.AHA);
    expect(m, m);

    final m1 = MonoGram(paths1, ConsPair.AHA);
    expect(m, m1);
    expect(m.hashCode, m1.hashCode);

    final m1SAZA = MonoGram(paths1, ConsPair.ZASA);
    expect(m == m1SAZA, isFalse);
    expect(m.hashCode == m1SAZA.hashCode, isFalse);

    final m2 = MonoGram(paths2, ConsPair.AHA);
    expect(m == m2, isFalse);
    expect(m.hashCode == m2.hashCode, isFalse);
  });

  test('MonoGram face, vowel, base vs head consonants', () {
    final xPaths = [
      PolyLine.anchors([Anchor.NW, Anchor.SE]),
      PolyLine.anchors([Anchor.NE, Anchor.SW])
    ];
    final xAHA = MonoGram(xPaths, ConsPair.AHA);
    expect(xAHA.face, Face.Center);
    expect(xAHA.vowel, Face.Center.vowel);
    expect(xAHA.base, Consonant.nil);
    expect(xAHA.head, Consonant.H);
  });

  test('MonoGram visualCenter is avg vectors of deduped visible anchors', () {
    final xPaths = [
      PolyLine.anchors([Anchor.NW, Anchor.SE]),
      PolyLine.anchors([Anchor.NE, Anchor.SW])
    ];
    final xAHA = MonoGram(xPaths, ConsPair.AHA);
    expect(xAHA.visualCenter.x, moreOrLessEquals(0, epsilon: floatPrecision));
    expect(xAHA.visualCenter.y, moreOrLessEquals(0, epsilon: floatPrecision));

    final circlePaths = [
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
    final circleAHA = MonoGram(circlePaths, ConsPair.AHA);
    expect(
        circleAHA.visualCenter.x, moreOrLessEquals(0, epsilon: floatPrecision));
    expect(
        circleAHA.visualCenter.y, moreOrLessEquals(0, epsilon: floatPrecision));
  });

  test('RotatingQuads equality and hashcode', () {
    final anglePaths = [
      PolyLine.anchors([Anchor.N, Anchor.E, Anchor.S])
    ];
    final angleAHA = RotatingQuads(anglePaths, ConsPair.AHA);
    expect(angleAHA, angleAHA);

    final semiAngleAHA = SemiRotatingQuads(anglePaths, ConsPair.AHA);
    expect(angleAHA == semiAngleAHA, isFalse);
    expect(angleAHA.hashCode == semiAngleAHA.hashCode, isFalse);

    final flipAngleAHA = FlipQuads(anglePaths, ConsPair.AHA);
    expect(angleAHA == flipAngleAHA, isFalse);
    expect(angleAHA.hashCode == flipAngleAHA.hashCode, isFalse);

    final doubleFlipAngleAHA = DoubleFlipQuads(anglePaths, ConsPair.AHA);
    expect(angleAHA == doubleFlipAngleAHA, isFalse);
    expect(angleAHA.hashCode == doubleFlipAngleAHA.hashCode, isFalse);

    final angleAHA2 = RotatingQuads(anglePaths, ConsPair.AHA);
    expect(angleAHA, equals(angleAHA2));
    expect(angleAHA.hashCode, angleAHA2.hashCode);

    final angleSAZA = RotatingQuads(anglePaths, ConsPair.ZASA);
    expect(angleAHA == angleSAZA, isFalse);
    expect(angleAHA.hashCode == angleSAZA.hashCode, isFalse);

    final gatePaths = [
      PolyLine.anchors([Anchor.NE, Anchor.NW, Anchor.SW, Anchor.SE])
    ];
    final gateAHA = RotatingQuads(gatePaths, ConsPair.AHA);
    expect(angleAHA == gateAHA, isFalse);
    expect(angleAHA.hashCode == gateAHA.hashCode, isFalse);
  });

  test('RotatingQuads face, vowel, base vs head consonants, visualCenter', () {
    final anglePaths = [
      PolyLine.anchors([Anchor.N, Anchor.E, Anchor.S])
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
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(angleAHA[Face.Right].visualCenter.x,
        moreOrLessEquals(0.1667, epsilon: floatPrecision));

    expect(angleAHA[Face.Up].face, Face.Up);
    expect(angleAHA[Face.Up].vowel, Face.Up.vowel);
    expect(angleAHA[Face.Up].base, Consonant.nil);
    expect(angleAHA[Face.Up].head, Consonant.H);
    expect(angleAHA[Face.Up].paths, turn(anglePaths, steps: 1, isSemi: false));
    expect(angleAHA[Face.Up].visualCenter.x,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(angleAHA[Face.Up].visualCenter.y,
        moreOrLessEquals(0.1667, epsilon: floatPrecision));

    expect(angleAHA[Face.Left].face, Face.Left);
    expect(angleAHA[Face.Left].vowel, Face.Left.vowel);
    expect(angleAHA[Face.Left].base, Consonant.nil);
    expect(angleAHA[Face.Left].head, Consonant.H);
    expect(
        angleAHA[Face.Left].paths, turn(anglePaths, steps: 2, isSemi: false));
    expect(angleAHA[Face.Left].visualCenter.y,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(angleAHA[Face.Left].visualCenter.x,
        moreOrLessEquals(-0.1667, epsilon: floatPrecision));

    expect(angleAHA[Face.Down].face, Face.Down);
    expect(angleAHA[Face.Down].vowel, Face.Down.vowel);
    expect(angleAHA[Face.Down].base, Consonant.nil);
    expect(angleAHA[Face.Down].head, Consonant.H);
    expect(
        angleAHA[Face.Down].paths, turn(anglePaths, steps: -1, isSemi: false));
    expect(angleAHA[Face.Down].visualCenter.x,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(angleAHA[Face.Down].visualCenter.y,
        moreOrLessEquals(-0.1667, epsilon: floatPrecision));
  });

  test('SemiRotatingQuads equality and hashcode', () {
    final linePaths = [
      PolyLine.anchors([Anchor.SW, Anchor.NE])
    ];
    final semiLineAHA = SemiRotatingQuads(linePaths, ConsPair.AHA);
    expect(semiLineAHA, semiLineAHA);

    final lineAHA = RotatingQuads(linePaths, ConsPair.AHA);
    expect(semiLineAHA == lineAHA, isFalse);
    expect(semiLineAHA.hashCode == lineAHA.hashCode, isFalse);

    final flipLineAHA = FlipQuads(linePaths, ConsPair.AHA);
    expect(semiLineAHA == flipLineAHA, isFalse);
    expect(semiLineAHA.hashCode == flipLineAHA.hashCode, isFalse);

    final doubleFlipLineAHA = DoubleFlipQuads(linePaths, ConsPair.AHA);
    expect(semiLineAHA == doubleFlipLineAHA, isFalse);
    expect(semiLineAHA.hashCode == doubleFlipLineAHA.hashCode, isFalse);

    final semiLineAHA2 = SemiRotatingQuads(linePaths, ConsPair.AHA);
    expect(semiLineAHA, equals(semiLineAHA2));
    expect(semiLineAHA.hashCode, semiLineAHA2.hashCode);

    final semiLineSAZA = SemiRotatingQuads(linePaths, ConsPair.ZASA);
    expect(semiLineAHA == semiLineSAZA, isFalse);
    expect(semiLineAHA.hashCode == semiLineSAZA.hashCode, isFalse);

    final gatePaths = [
      PolyLine.anchors([Anchor.NE, Anchor.NW, Anchor.SW, Anchor.SE])
    ];
    final semiGateAHA = SemiRotatingQuads(gatePaths, ConsPair.AHA);
    expect(semiLineAHA == semiGateAHA, isFalse);
    expect(semiLineAHA.hashCode == semiGateAHA.hashCode, isFalse);
  });

  test('SemiRotatingQuads face, vowel, base/head consonants, visualCenter', () {
    final linePaths = [
      PolyLine.anchors([Anchor.SW, Anchor.NE])
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
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(semiLineAHA[Face.Right].visualCenter.x,
        moreOrLessEquals(0, epsilon: floatPrecision));

    expect(semiLineAHA[Face.Up].face, Face.Up);
    expect(semiLineAHA[Face.Up].vowel, Face.Up.vowel);
    expect(semiLineAHA[Face.Up].base, Consonant.nil);
    expect(semiLineAHA[Face.Up].head, Consonant.H);
    expect(semiLineAHA[Face.Up].paths, turn(linePaths, steps: 1, isSemi: true));
    expect(semiLineAHA[Face.Up].visualCenter.x,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(semiLineAHA[Face.Up].visualCenter.y,
        moreOrLessEquals(0, epsilon: floatPrecision));

    expect(semiLineAHA[Face.Left].face, Face.Left);
    expect(semiLineAHA[Face.Left].vowel, Face.Left.vowel);
    expect(semiLineAHA[Face.Left].base, Consonant.nil);
    expect(semiLineAHA[Face.Left].head, Consonant.H);
    expect(
        semiLineAHA[Face.Left].paths, turn(linePaths, steps: 2, isSemi: true));
    expect(semiLineAHA[Face.Left].visualCenter.y,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(semiLineAHA[Face.Left].visualCenter.x,
        moreOrLessEquals(0, epsilon: floatPrecision));

    expect(semiLineAHA[Face.Down].face, Face.Down);
    expect(semiLineAHA[Face.Down].vowel, Face.Down.vowel);
    expect(semiLineAHA[Face.Down].base, Consonant.nil);
    expect(semiLineAHA[Face.Down].head, Consonant.H);
    expect(
        semiLineAHA[Face.Down].paths, turn(linePaths, steps: 3, isSemi: true));
    expect(semiLineAHA[Face.Down].visualCenter.x,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(semiLineAHA[Face.Down].visualCenter.y,
        moreOrLessEquals(0, epsilon: floatPrecision));
  });

  test('FlipQuads equality and hashcode', () {
    final flowPaths = [
      PolySpline.anchors([
        Anchor.NW,
        Anchor.N,
        Anchor.S,
        Anchor.SE,
      ])
    ];
    final flipFlowAHA = FlipQuads(flowPaths, ConsPair.AHA);
    expect(flipFlowAHA, flipFlowAHA);

    final rotaFlowAHA = RotatingQuads(flowPaths, ConsPair.AHA);
    expect(flipFlowAHA == rotaFlowAHA, isFalse);
    expect(flipFlowAHA.hashCode == rotaFlowAHA.hashCode, isFalse);

    final semiFlowAHA = SemiRotatingQuads(flowPaths, ConsPair.AHA);
    expect(flipFlowAHA == semiFlowAHA, isFalse);
    expect(flipFlowAHA.hashCode == semiFlowAHA.hashCode, isFalse);

    final doubleFlipFlowAHA = DoubleFlipQuads(flowPaths, ConsPair.AHA);
    expect(flipFlowAHA == doubleFlipFlowAHA, isFalse);
    expect(flipFlowAHA.hashCode == doubleFlipFlowAHA.hashCode, isFalse);

    final flipFlowAHA2 = FlipQuads(flowPaths, ConsPair.AHA);
    expect(flipFlowAHA, equals(flipFlowAHA2));
    expect(flipFlowAHA.hashCode, flipFlowAHA2.hashCode);

    final flipFlowSAZA = FlipQuads(flowPaths, ConsPair.ZASA);
    expect(flipFlowAHA == flipFlowSAZA, isFalse);
    expect(flipFlowAHA.hashCode == flipFlowSAZA.hashCode, isFalse);

    final gatePaths = [
      PolyLine.anchors([Anchor.NE, Anchor.NW, Anchor.SW, Anchor.SE])
    ];
    final flipGateAHA = FlipQuads(gatePaths, ConsPair.AHA);
    expect(flipFlowAHA == flipGateAHA, isFalse);
    expect(flipFlowAHA.hashCode == flipGateAHA.hashCode, isFalse);
  });

  test('FlipQuads face, vowel, base/head consonants, visualCenter', () {
    final flowPaths = [
      PolySpline.anchors([
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
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(flipFlowAHA[Face.Right].visualCenter.x,
        moreOrLessEquals(0, epsilon: floatPrecision));

    expect(flipFlowAHA[Face.Up].face, Face.Up);
    expect(flipFlowAHA[Face.Up].vowel, Face.Up.vowel);
    expect(flipFlowAHA[Face.Up].base, Consonant.nil);
    expect(flipFlowAHA[Face.Up].head, Consonant.H);
    expect(flipFlowAHA[Face.Up].paths, turn(flowPaths));
    expect(flipFlowAHA[Face.Up].visualCenter.x,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(flipFlowAHA[Face.Up].visualCenter.y,
        moreOrLessEquals(0, epsilon: floatPrecision));

    expect(flipFlowAHA[Face.Left].face, Face.Left);
    expect(flipFlowAHA[Face.Left].vowel, Face.Left.vowel);
    expect(flipFlowAHA[Face.Left].base, Consonant.nil);
    expect(flipFlowAHA[Face.Left].head, Consonant.H);
    expect(flipFlowAHA[Face.Left].paths, hFlip(flowPaths));
    expect(flipFlowAHA[Face.Left].visualCenter.y,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(flipFlowAHA[Face.Left].visualCenter.x,
        moreOrLessEquals(0, epsilon: floatPrecision));

    expect(flipFlowAHA[Face.Down].face, Face.Down);
    expect(flipFlowAHA[Face.Down].vowel, Face.Down.vowel);
    expect(flipFlowAHA[Face.Down].base, Consonant.nil);
    expect(flipFlowAHA[Face.Down].head, Consonant.H);
    expect(flipFlowAHA[Face.Down].paths, vFlip(turn(flowPaths)));
    expect(flipFlowAHA[Face.Down].visualCenter.x,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(flipFlowAHA[Face.Down].visualCenter.y,
        moreOrLessEquals(0, epsilon: floatPrecision));
  });

  test('DoubleFlipQuads equality and hashcode', () {
    final swirlPaths = [
      PolySpline.anchors([
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
    expect(dflipSwirlAHA == rotaSwirlAHA, isFalse);
    expect(dflipSwirlAHA.hashCode == rotaSwirlAHA.hashCode, isFalse);

    final semiSwirlAHA = SemiRotatingQuads(swirlPaths, ConsPair.AHA);
    expect(dflipSwirlAHA == semiSwirlAHA, isFalse);
    expect(dflipSwirlAHA.hashCode == semiSwirlAHA.hashCode, isFalse);

    final flipSwirlAHA = FlipQuads(swirlPaths, ConsPair.AHA);
    expect(dflipSwirlAHA == flipSwirlAHA, isFalse);
    expect(dflipSwirlAHA.hashCode == flipSwirlAHA.hashCode, isFalse);

    final dflipSwirlAHA2 = DoubleFlipQuads(swirlPaths, ConsPair.AHA);
    expect(dflipSwirlAHA, equals(dflipSwirlAHA2));
    expect(dflipSwirlAHA.hashCode, dflipSwirlAHA2.hashCode);

    final dflipSwirlSAZA = DoubleFlipQuads(swirlPaths, ConsPair.ZASA);
    expect(dflipSwirlAHA == dflipSwirlSAZA, isFalse);
    expect(dflipSwirlAHA.hashCode == dflipSwirlSAZA.hashCode, isFalse);

    final gatePaths = [
      PolyLine.anchors([Anchor.NE, Anchor.NW, Anchor.SW, Anchor.SE])
    ];
    final dflipGateAHA = DoubleFlipQuads(gatePaths, ConsPair.AHA);
    expect(dflipSwirlAHA == dflipGateAHA, isFalse);
    expect(dflipSwirlAHA.hashCode == dflipGateAHA.hashCode, isFalse);
  });

  test('DoubleFlipQuads face, vowel, base/head consonants, visualCenter', () {
    final swirlPaths = [
      PolySpline.anchors([
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
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(dflipSwirlAHA[Face.Right].visualCenter.x,
        moreOrLessEquals(0, epsilon: floatPrecision));

    expect(dflipSwirlAHA[Face.Up].face, Face.Up);
    expect(dflipSwirlAHA[Face.Up].vowel, Face.Up.vowel);
    expect(dflipSwirlAHA[Face.Up].base, Consonant.nil);
    expect(dflipSwirlAHA[Face.Up].head, Consonant.H);
    expect(dflipSwirlAHA[Face.Up].paths, hFlip(turn(swirlPaths)));
    expect(dflipSwirlAHA[Face.Up].visualCenter.x,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(dflipSwirlAHA[Face.Up].visualCenter.y,
        moreOrLessEquals(0, epsilon: floatPrecision));

    expect(dflipSwirlAHA[Face.Left].face, Face.Left);
    expect(dflipSwirlAHA[Face.Left].vowel, Face.Left.vowel);
    expect(dflipSwirlAHA[Face.Left].base, Consonant.nil);
    expect(dflipSwirlAHA[Face.Left].head, Consonant.H);
    expect(dflipSwirlAHA[Face.Left].paths, vFlip(hFlip(swirlPaths)));
    expect(dflipSwirlAHA[Face.Left].visualCenter.y,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(dflipSwirlAHA[Face.Left].visualCenter.x,
        moreOrLessEquals(0, epsilon: floatPrecision));

    expect(dflipSwirlAHA[Face.Down].face, Face.Down);
    expect(dflipSwirlAHA[Face.Down].vowel, Face.Down.vowel);
    expect(dflipSwirlAHA[Face.Down].base, Consonant.nil);
    expect(dflipSwirlAHA[Face.Down].head, Consonant.H);
    expect(
        dflipSwirlAHA[Face.Down].paths, hFlip(vFlip(hFlip(turn(swirlPaths)))));
    expect(dflipSwirlAHA[Face.Down].visualCenter.x,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(dflipSwirlAHA[Face.Down].visualCenter.y,
        moreOrLessEquals(0, epsilon: floatPrecision));
  });
}
