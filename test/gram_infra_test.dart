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
class PolyTester extends PolyLine {
  PolyTester(List<Vector2> vectors) : super(vectors);

  PolyTester.anchors(List<Anchor> anchors)
      : super(List.unmodifiable(anchors.map((a) => a.vector)));

  @override
  PolyLine diffPoints(Iterable<Vector2> vs) {
    throw UnimplementedError();
  }

  @override
  PolyLine diffAspect(bool isFixedAspect) {
    throw UnimplementedError();
  }

  @override
  LengthDim get lengthDim => const LengthDim();

  @override
  LineMetrics get metrics => LineMetrics();
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

    expect(vowelsFromFaces, Set.of(Vowel.values.where((e) => e != Vowel.NIL)));
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
      final line1 = PolyStraight.anchors([a1]);

      final emptyLine = PolyStraight.anchors(List<Anchor>.empty());
      expect(line1 == emptyLine, isFalse);
      expect(line1.hashCode == emptyLine.hashCode, isFalse);

      // PolyLine length is important
      final line11 = PolyStraight.anchors([a1, a1]);
      expect(line1.vectors == line11.vectors, isFalse);
      expect(line1.hashCode == line11.hashCode, isFalse);

      final spline = PolyCurve.anchors([a1, a1]);
      expect(line1 is PolyCurve, isFalse);
      expect(line1.hashCode == spline.hashCode, isFalse);

      for (final a2 in Anchor.values) {
        final line2 = PolyStraight.anchors([a2]);
        if (a1 == a2) {
          expect(line1, equals(line2));
        } else {
          expect(line1 == line2, isFalse);
        }

        final line12 = PolyStraight.anchors([a1, a2]);
        final line12B = PolyStraight.anchors([a1, a2]);
        expect(line12, equals(line12B));
        expect(line12.hashCode, equals(line12B.hashCode));

        if (a1 != a2) {
          /// for PolyLines ordering matters
          final line21 = PolyStraight.anchors([a2, a1]);
          expect(line12 == line21, isFalse);
          expect(line12.hashCode == line21.hashCode, isFalse);
        }
      }
    }
  });

  test('PolyLine visiblePoints are same as all anchors', () {
    final nsew = [Anchor.N, Anchor.S, Anchor.E, Anchor.W];
    final lines = PolyStraight.anchors(nsew);
    expect(lines.visiblePoints, nsew.map((a) => a.vector));
  });

  test('PolySpline equality and hashcode', () {
    for (final a1 in Anchor.values) {
      final spline1 = PolyCurve.anchors([a1]);

      final emptySpline = PolyCurve.anchors(List<Anchor>.empty());
      expect(spline1 == emptySpline, isFalse);
      expect(spline1.hashCode == emptySpline.hashCode, isFalse);

      // PolySpline length is important
      final spline11 = PolyCurve.anchors([a1, a1]);
      expect(spline1 == spline11, isFalse);
      expect(spline1.hashCode == spline11.hashCode, isFalse);

      final line = PolyStraight.anchors([a1]);
      expect(spline1 == line, isFalse);
      expect(spline1.hashCode == line.hashCode, isFalse);

      for (final a2 in Anchor.values) {
        final spline2 = PolyCurve.anchors([a2]);
        if (a1 == a2) {
          expect(spline1, spline2);
          expect(spline1.hashCode, equals(spline2.hashCode));
        } else {
          expect(spline1 == spline2, isFalse);
          expect(spline1.hashCode == spline2.hashCode, isFalse);
        }

        final spline12 = PolyCurve.anchors([a1, a2]);
        final spline12B = PolyCurve.anchors([a1, a2]);
        expect(spline12, spline12B);
        expect(spline12.hashCode, equals(spline12B.hashCode));

        if (a1 != a2) {
          /// for PolySplines ordering matters
          final spline21 = PolyCurve.anchors([a2, a1]);
          expect(spline12 == spline21, isFalse);
          expect(spline12.hashCode == spline21.hashCode, isFalse);
        }
      }
    }
  });

  test('PolySpline visiblePoints are all visible except first and last', () {
    final spline = PolyCurve.anchors([Anchor.N, Anchor.S, Anchor.E, Anchor.W]);
    expect(spline.visiblePoints, [Anchor.S.vector, Anchor.E.vector]);
  });

  test('Metrics calculation for PolySpline is correct', () {
    final flow = PolyCurve.anchors([
      Anchor.SW,
      Anchor.W,
      Anchor.E,
      Anchor.NE,
    ]);
    final m = flow.metrics;
    final l = flow.lengthDim;

    expect(m.xMin, -.5);
    expect(m.xMax, .5);
    expect(m.yMin, -.17);
    expect(m.yMax, .17);
    expect(m.xAvg, .0);
    expect(m.yAvg, .0);
    expect(m.width, 1.0);
    expect(m.height, .34);
    expect(flow.center, Vector2(.0, .0));
    expect(l.length, 1.25);
    expect(l.dxSum, 1.0);
    expect(l.dySum, 0.67);
  });

  test('turn by default of 90° except at Origin', () {
    final paths = [
      PolyStraight.anchors([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolyStraight.anchors(
          [Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
      PolyCurve.anchors([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolyCurve.anchors([Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
    ];

    final turned = turn(paths);

    final expected = [
      PolyStraight.anchors([Anchor.W, Anchor.E, Anchor.N, Anchor.S, Anchor.O]),
      PolyStraight.anchors(
          [Anchor.NW, Anchor.NE, Anchor.SW, Anchor.SE, Anchor.O]),
      PolyCurve.anchors([Anchor.W, Anchor.E, Anchor.N, Anchor.S, Anchor.O]),
      PolyCurve.anchors([Anchor.NW, Anchor.NE, Anchor.SW, Anchor.SE, Anchor.O]),
    ];

    expect(turned, equals(expected));
  });

  test('turn by +/- 0,1,2,3,4 steps of 90° except at Origin', () {
    final paths = [
      PolyStraight.anchors([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolyStraight.anchors(
          [Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
      PolyCurve.anchors([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolyCurve.anchors([Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
    ];

    final expected1 = [
      PolyStraight.anchors([Anchor.W, Anchor.E, Anchor.N, Anchor.S, Anchor.O]),
      PolyStraight.anchors(
          [Anchor.NW, Anchor.NE, Anchor.SW, Anchor.SE, Anchor.O]),
      PolyCurve.anchors([Anchor.W, Anchor.E, Anchor.N, Anchor.S, Anchor.O]),
      PolyCurve.anchors([Anchor.NW, Anchor.NE, Anchor.SW, Anchor.SE, Anchor.O]),
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
      PolyStraight.anchors([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolyStraight.anchors(
          [Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
      PolyCurve.anchors([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolyCurve.anchors([Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
    ];

    final semiTurned = turn(paths, isSemi: true);

    final expected = [
      PolyStraight.anchors(
          [Anchor.NW, Anchor.SE, Anchor.NE, Anchor.SW, Anchor.O]),
      PolyStraight.anchors([Anchor.N, Anchor.E, Anchor.W, Anchor.S, Anchor.O]),
      PolyCurve.anchors([Anchor.NW, Anchor.SE, Anchor.NE, Anchor.SW, Anchor.O]),
      PolyCurve.anchors([Anchor.N, Anchor.E, Anchor.W, Anchor.S, Anchor.O]),
    ];

    expect(semiTurned, expected);
  });

  test('turn by +/- 0...8 steps of 45° i.e. semi-step, except at Origin', () {
    final paths = [
      PolyStraight.anchors([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolyStraight.anchors(
          [Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
      PolyCurve.anchors([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolyCurve.anchors([Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
    ];

    final expected1 = [
      PolyStraight.anchors(
          [Anchor.NW, Anchor.SE, Anchor.NE, Anchor.SW, Anchor.O]),
      PolyStraight.anchors([Anchor.N, Anchor.E, Anchor.W, Anchor.S, Anchor.O]),
      PolyCurve.anchors([Anchor.NW, Anchor.SE, Anchor.NE, Anchor.SW, Anchor.O]),
      PolyCurve.anchors([Anchor.N, Anchor.E, Anchor.W, Anchor.S, Anchor.O]),
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
      PolyStraight.anchors([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolyStraight.anchors(
          [Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
      PolyCurve.anchors([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolyCurve.anchors([Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
    ];

    final flipped = vFlip(paths);

    final expected = [
      PolyStraight.anchors([Anchor.S, Anchor.N, Anchor.E, Anchor.W, Anchor.O]),
      PolyStraight.anchors(
          [Anchor.SE, Anchor.NE, Anchor.SW, Anchor.NW, Anchor.O]),
      PolyCurve.anchors([Anchor.S, Anchor.N, Anchor.E, Anchor.W, Anchor.O]),
      PolyCurve.anchors([Anchor.SE, Anchor.NE, Anchor.SW, Anchor.NW, Anchor.O]),
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
      PolyStraight.anchors([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolyStraight.anchors(
          [Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
      PolyCurve.anchors([Anchor.N, Anchor.S, Anchor.E, Anchor.W, Anchor.O]),
      PolyCurve.anchors([Anchor.NE, Anchor.SE, Anchor.NW, Anchor.SW, Anchor.O]),
    ];

    final flipped = hFlip(paths);

    final expected = [
      PolyStraight.anchors([Anchor.N, Anchor.S, Anchor.W, Anchor.E, Anchor.O]),
      PolyStraight.anchors(
          [Anchor.NW, Anchor.SW, Anchor.NE, Anchor.SE, Anchor.O]),
      PolyCurve.anchors([Anchor.N, Anchor.S, Anchor.W, Anchor.E, Anchor.O]),
      PolyCurve.anchors([Anchor.NW, Anchor.SW, Anchor.NE, Anchor.SE, Anchor.O]),
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
      PolyCurve.anchors([Anchor.O])
    ];
    final paths2 = [
      PolyStraight.anchors([Anchor.O])
    ];
    final m = MonoGram(paths1, ConsPair.h);
    expect(m, m);

    final m1 = MonoGram(paths1, ConsPair.h);
    expect(m, m1);
    expect(m.hashCode, m1.hashCode);

    final m1SAZA = MonoGram(paths1, ConsPair.sz);
    expect(m == m1SAZA, isFalse);
    expect(m.hashCode == m1SAZA.hashCode, isFalse);

    final m2 = MonoGram(paths2, ConsPair.h);
    expect(m == m2, isFalse);
    expect(m.hashCode == m2.hashCode, isFalse);
  });

  test('MonoGram face, vowel, base vs head consonants', () {
    final xPaths = [
      PolyStraight.anchors([Anchor.NW, Anchor.SE]),
      PolyStraight.anchors([Anchor.NE, Anchor.SW])
    ];
    final xAHA = MonoGram(xPaths, ConsPair.h);
    expect(xAHA.face, Face.Center);
    expect(xAHA.vowel, Face.Center.vowel);
    expect(xAHA.base, Cons.NIL);
    expect(xAHA.head, Cons.h);
  });

  test('MonoGram visualCenter is avg vectors of deduped visible anchors', () {
    final xPaths = [
      PolyStraight.anchors([Anchor.NW, Anchor.SE]),
      PolyStraight.anchors([Anchor.NE, Anchor.SW])
    ];
    final xAHA = MonoGram(xPaths, ConsPair.h);
    expect(xAHA.center.x, moreOrLessEquals(0, epsilon: floatPrecision));
    expect(xAHA.center.y, moreOrLessEquals(0, epsilon: floatPrecision));

    final circlePaths = [
      PolyCurve.anchors([
        Anchor.W,
        Anchor.N,
        Anchor.E,
        Anchor.S,
        Anchor.W,
        Anchor.N,
        Anchor.E,
      ])
    ];
    final circleAHA = MonoGram(circlePaths, ConsPair.h);
    expect(circleAHA.center.x, moreOrLessEquals(0, epsilon: floatPrecision));
    expect(circleAHA.center.y, moreOrLessEquals(0, epsilon: floatPrecision));
  });

  test('RotatingQuads equality and hashcode', () {
    final anglePaths = [
      PolyStraight.anchors([Anchor.N, Anchor.E, Anchor.S])
    ];
    final angleAHA = RotatingQuads(anglePaths, ConsPair.h);
    expect(angleAHA, angleAHA);

    final semiAngleAHA = SemiRotatingQuads(anglePaths, ConsPair.h);
    expect(angleAHA == semiAngleAHA, isFalse);
    expect(angleAHA.hashCode == semiAngleAHA.hashCode, isFalse);

    final flipAngleAHA = FlipQuads(anglePaths, ConsPair.h);
    expect(angleAHA == flipAngleAHA, isFalse);
    expect(angleAHA.hashCode == flipAngleAHA.hashCode, isFalse);

    final doubleFlipAngleAHA = DoubleFlipQuads(anglePaths, ConsPair.h);
    expect(angleAHA == doubleFlipAngleAHA, isFalse);
    expect(angleAHA.hashCode == doubleFlipAngleAHA.hashCode, isFalse);

    final angleAHA2 = RotatingQuads(anglePaths, ConsPair.h);
    expect(angleAHA, equals(angleAHA2));
    expect(angleAHA.hashCode, angleAHA2.hashCode);

    final angleSAZA = RotatingQuads(anglePaths, ConsPair.sz);
    expect(angleAHA == angleSAZA, isFalse);
    expect(angleAHA.hashCode == angleSAZA.hashCode, isFalse);

    final gatePaths = [
      PolyStraight.anchors([Anchor.NE, Anchor.NW, Anchor.SW, Anchor.SE])
    ];
    final gateAHA = RotatingQuads(gatePaths, ConsPair.h);
    expect(angleAHA == gateAHA, isFalse);
    expect(angleAHA.hashCode == gateAHA.hashCode, isFalse);
  });

  test('RotatingQuads face, vowel, base vs head consonants, visualCenter', () {
    final anglePaths = [
      PolyStraight.anchors([Anchor.N, Anchor.E, Anchor.S])
    ];
    final angleAHA = RotatingQuads(anglePaths, ConsPair.h);
    expect(angleAHA.consPair.base, Cons.NIL);
    expect(angleAHA.consPair.head, Cons.h);

    expect(angleAHA[Face.Right].face, Face.Right);
    expect(angleAHA[Face.Right].vowel, Face.Right.vowel);
    expect(angleAHA[Face.Right].base, Cons.NIL);
    expect(angleAHA[Face.Right].head, Cons.h);
    expect(angleAHA[Face.Right].lines, anglePaths);
    expect(angleAHA[Face.Right].center.y,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(angleAHA[Face.Right].center.x,
        moreOrLessEquals(0.25, epsilon: floatPrecision));

    expect(angleAHA[Face.Up].face, Face.Up);
    expect(angleAHA[Face.Up].vowel, Face.Up.vowel);
    expect(angleAHA[Face.Up].base, Cons.NIL);
    expect(angleAHA[Face.Up].head, Cons.h);
    expect(angleAHA[Face.Up].lines, turn(anglePaths, steps: 1, isSemi: false));
    expect(angleAHA[Face.Up].center.x,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(angleAHA[Face.Up].center.y,
        moreOrLessEquals(0.25, epsilon: floatPrecision));

    expect(angleAHA[Face.Left].face, Face.Left);
    expect(angleAHA[Face.Left].vowel, Face.Left.vowel);
    expect(angleAHA[Face.Left].base, Cons.NIL);
    expect(angleAHA[Face.Left].head, Cons.h);
    expect(
        angleAHA[Face.Left].lines, turn(anglePaths, steps: 2, isSemi: false));
    expect(angleAHA[Face.Left].center.y,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(angleAHA[Face.Left].center.x,
        moreOrLessEquals(-0.25, epsilon: floatPrecision));

    expect(angleAHA[Face.Down].face, Face.Down);
    expect(angleAHA[Face.Down].vowel, Face.Down.vowel);
    expect(angleAHA[Face.Down].base, Cons.NIL);
    expect(angleAHA[Face.Down].head, Cons.h);
    expect(
        angleAHA[Face.Down].lines, turn(anglePaths, steps: -1, isSemi: false));
    expect(angleAHA[Face.Down].center.x,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(angleAHA[Face.Down].center.y,
        moreOrLessEquals(-0.25, epsilon: floatPrecision));
  });

  test('SemiRotatingQuads equality and hashcode', () {
    final linePaths = [
      PolyStraight.anchors([Anchor.SW, Anchor.NE])
    ];
    final semiLineAHA = SemiRotatingQuads(linePaths, ConsPair.h);
    expect(semiLineAHA, semiLineAHA);

    final lineAHA = RotatingQuads(linePaths, ConsPair.h);
    expect(semiLineAHA == lineAHA, isFalse);
    expect(semiLineAHA.hashCode == lineAHA.hashCode, isFalse);

    final flipLineAHA = FlipQuads(linePaths, ConsPair.h);
    expect(semiLineAHA == flipLineAHA, isFalse);
    expect(semiLineAHA.hashCode == flipLineAHA.hashCode, isFalse);

    final doubleFlipLineAHA = DoubleFlipQuads(linePaths, ConsPair.h);
    expect(semiLineAHA == doubleFlipLineAHA, isFalse);
    expect(semiLineAHA.hashCode == doubleFlipLineAHA.hashCode, isFalse);

    final semiLineAHA2 = SemiRotatingQuads(linePaths, ConsPair.h);
    expect(semiLineAHA, equals(semiLineAHA2));
    expect(semiLineAHA.hashCode, semiLineAHA2.hashCode);

    final semiLineSAZA = SemiRotatingQuads(linePaths, ConsPair.sz);
    expect(semiLineAHA == semiLineSAZA, isFalse);
    expect(semiLineAHA.hashCode == semiLineSAZA.hashCode, isFalse);

    final gatePaths = [
      PolyStraight.anchors([Anchor.NE, Anchor.NW, Anchor.SW, Anchor.SE])
    ];
    final semiGateAHA = SemiRotatingQuads(gatePaths, ConsPair.h);
    expect(semiLineAHA == semiGateAHA, isFalse);
    expect(semiLineAHA.hashCode == semiGateAHA.hashCode, isFalse);
  });

  test('SemiRotatingQuads face, vowel, base/head consonants, visualCenter', () {
    final linePaths = [
      PolyStraight.anchors([Anchor.SW, Anchor.NE])
    ];
    final semiLineAHA = SemiRotatingQuads(linePaths, ConsPair.h);
    expect(semiLineAHA.consPair.base, Cons.NIL);
    expect(semiLineAHA.consPair.head, Cons.h);

    expect(semiLineAHA[Face.Right].face, Face.Right);
    expect(semiLineAHA[Face.Right].vowel, Face.Right.vowel);
    expect(semiLineAHA[Face.Right].base, Cons.NIL);
    expect(semiLineAHA[Face.Right].head, Cons.h);
    expect(semiLineAHA[Face.Right].lines, linePaths);
    expect(semiLineAHA[Face.Right].center.y,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(semiLineAHA[Face.Right].center.x,
        moreOrLessEquals(0, epsilon: floatPrecision));

    expect(semiLineAHA[Face.Up].face, Face.Up);
    expect(semiLineAHA[Face.Up].vowel, Face.Up.vowel);
    expect(semiLineAHA[Face.Up].base, Cons.NIL);
    expect(semiLineAHA[Face.Up].head, Cons.h);
    expect(semiLineAHA[Face.Up].lines, turn(linePaths, steps: 1, isSemi: true));
    expect(semiLineAHA[Face.Up].center.x,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(semiLineAHA[Face.Up].center.y,
        moreOrLessEquals(0, epsilon: floatPrecision));

    expect(semiLineAHA[Face.Left].face, Face.Left);
    expect(semiLineAHA[Face.Left].vowel, Face.Left.vowel);
    expect(semiLineAHA[Face.Left].base, Cons.NIL);
    expect(semiLineAHA[Face.Left].head, Cons.h);
    expect(
        semiLineAHA[Face.Left].lines, turn(linePaths, steps: 2, isSemi: true));
    expect(semiLineAHA[Face.Left].center.y,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(semiLineAHA[Face.Left].center.x,
        moreOrLessEquals(0, epsilon: floatPrecision));

    expect(semiLineAHA[Face.Down].face, Face.Down);
    expect(semiLineAHA[Face.Down].vowel, Face.Down.vowel);
    expect(semiLineAHA[Face.Down].base, Cons.NIL);
    expect(semiLineAHA[Face.Down].head, Cons.h);
    expect(
        semiLineAHA[Face.Down].lines, turn(linePaths, steps: 3, isSemi: true));
    expect(semiLineAHA[Face.Down].center.x,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(semiLineAHA[Face.Down].center.y,
        moreOrLessEquals(0, epsilon: floatPrecision));
  });

  test('FlipQuads equality and hashcode', () {
    final flowPaths = [
      PolyCurve.anchors([
        Anchor.NW,
        Anchor.N,
        Anchor.S,
        Anchor.SE,
      ])
    ];
    final flipFlowAHA = FlipQuads(flowPaths, ConsPair.h);
    expect(flipFlowAHA, flipFlowAHA);

    final rotaFlowAHA = RotatingQuads(flowPaths, ConsPair.h);
    expect(flipFlowAHA == rotaFlowAHA, isFalse);
    expect(flipFlowAHA.hashCode == rotaFlowAHA.hashCode, isFalse);

    final semiFlowAHA = SemiRotatingQuads(flowPaths, ConsPair.h);
    expect(flipFlowAHA == semiFlowAHA, isFalse);
    expect(flipFlowAHA.hashCode == semiFlowAHA.hashCode, isFalse);

    final doubleFlipFlowAHA = DoubleFlipQuads(flowPaths, ConsPair.h);
    expect(flipFlowAHA == doubleFlipFlowAHA, isFalse);
    expect(flipFlowAHA.hashCode == doubleFlipFlowAHA.hashCode, isFalse);

    final flipFlowAHA2 = FlipQuads(flowPaths, ConsPair.h);
    expect(flipFlowAHA, equals(flipFlowAHA2));
    expect(flipFlowAHA.hashCode, flipFlowAHA2.hashCode);

    final flipFlowSAZA = FlipQuads(flowPaths, ConsPair.sz);
    expect(flipFlowAHA == flipFlowSAZA, isFalse);
    expect(flipFlowAHA.hashCode == flipFlowSAZA.hashCode, isFalse);

    final gatePaths = [
      PolyStraight.anchors([Anchor.NE, Anchor.NW, Anchor.SW, Anchor.SE])
    ];
    final flipGateAHA = FlipQuads(gatePaths, ConsPair.h);
    expect(flipFlowAHA == flipGateAHA, isFalse);
    expect(flipFlowAHA.hashCode == flipGateAHA.hashCode, isFalse);
  });

  test('FlipQuads face, vowel, base/head consonants, visualCenter', () {
    final flowPaths = [
      PolyCurve.anchors([
        Anchor.NW,
        Anchor.N,
        Anchor.S,
        Anchor.SE,
      ])
    ];
    final flipFlowAHA = FlipQuads(flowPaths, ConsPair.h);
    expect(flipFlowAHA.consPair.base, Cons.NIL);
    expect(flipFlowAHA.consPair.head, Cons.h);

    expect(flipFlowAHA[Face.Right].face, Face.Right);
    expect(flipFlowAHA[Face.Right].vowel, Face.Right.vowel);
    expect(flipFlowAHA[Face.Right].base, Cons.NIL);
    expect(flipFlowAHA[Face.Right].head, Cons.h);
    expect(flipFlowAHA[Face.Right].lines, flowPaths);
    expect(flipFlowAHA[Face.Right].center.y,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(flipFlowAHA[Face.Right].center.x,
        moreOrLessEquals(0, epsilon: floatPrecision));

    expect(flipFlowAHA[Face.Up].face, Face.Up);
    expect(flipFlowAHA[Face.Up].vowel, Face.Up.vowel);
    expect(flipFlowAHA[Face.Up].base, Cons.NIL);
    expect(flipFlowAHA[Face.Up].head, Cons.h);
    expect(flipFlowAHA[Face.Up].lines, turn(flowPaths));
    expect(flipFlowAHA[Face.Up].center.x,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(flipFlowAHA[Face.Up].center.y,
        moreOrLessEquals(0, epsilon: floatPrecision));

    expect(flipFlowAHA[Face.Left].face, Face.Left);
    expect(flipFlowAHA[Face.Left].vowel, Face.Left.vowel);
    expect(flipFlowAHA[Face.Left].base, Cons.NIL);
    expect(flipFlowAHA[Face.Left].head, Cons.h);
    expect(flipFlowAHA[Face.Left].lines, hFlip(flowPaths));
    expect(flipFlowAHA[Face.Left].center.y,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(flipFlowAHA[Face.Left].center.x,
        moreOrLessEquals(0, epsilon: floatPrecision));

    expect(flipFlowAHA[Face.Down].face, Face.Down);
    expect(flipFlowAHA[Face.Down].vowel, Face.Down.vowel);
    expect(flipFlowAHA[Face.Down].base, Cons.NIL);
    expect(flipFlowAHA[Face.Down].head, Cons.h);
    expect(flipFlowAHA[Face.Down].lines, vFlip(turn(flowPaths)));
    expect(flipFlowAHA[Face.Down].center.x,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(flipFlowAHA[Face.Down].center.y,
        moreOrLessEquals(0, epsilon: floatPrecision));
  });

  test('DoubleFlipQuads equality and hashcode', () {
    final swirlPaths = [
      PolyCurve.anchors([
        Anchor.N,
        Anchor.NW,
        Anchor.SW,
        Anchor.SE,
        Anchor.NE,
        Anchor.O,
        Anchor.E,
      ])
    ];
    final dflipSwirlAHA = DoubleFlipQuads(swirlPaths, ConsPair.h);
    expect(dflipSwirlAHA, dflipSwirlAHA);

    final rotaSwirlAHA = RotatingQuads(swirlPaths, ConsPair.h);
    expect(dflipSwirlAHA == rotaSwirlAHA, isFalse);
    expect(dflipSwirlAHA.hashCode == rotaSwirlAHA.hashCode, isFalse);

    final semiSwirlAHA = SemiRotatingQuads(swirlPaths, ConsPair.h);
    expect(dflipSwirlAHA == semiSwirlAHA, isFalse);
    expect(dflipSwirlAHA.hashCode == semiSwirlAHA.hashCode, isFalse);

    final flipSwirlAHA = FlipQuads(swirlPaths, ConsPair.h);
    expect(dflipSwirlAHA == flipSwirlAHA, isFalse);
    expect(dflipSwirlAHA.hashCode == flipSwirlAHA.hashCode, isFalse);

    final dflipSwirlAHA2 = DoubleFlipQuads(swirlPaths, ConsPair.h);
    expect(dflipSwirlAHA, equals(dflipSwirlAHA2));
    expect(dflipSwirlAHA.hashCode, dflipSwirlAHA2.hashCode);

    final dflipSwirlSAZA = DoubleFlipQuads(swirlPaths, ConsPair.sz);
    expect(dflipSwirlAHA == dflipSwirlSAZA, isFalse);
    expect(dflipSwirlAHA.hashCode == dflipSwirlSAZA.hashCode, isFalse);

    final gatePaths = [
      PolyStraight.anchors([Anchor.NE, Anchor.NW, Anchor.SW, Anchor.SE])
    ];
    final dflipGateAHA = DoubleFlipQuads(gatePaths, ConsPair.h);
    expect(dflipSwirlAHA == dflipGateAHA, isFalse);
    expect(dflipSwirlAHA.hashCode == dflipGateAHA.hashCode, isFalse);
  });

  test('DoubleFlipQuads face, vowel, base/head consonants, visualCenter', () {
    final swirlPaths = [
      PolyCurve.anchors([
        Anchor.N,
        Anchor.NW,
        Anchor.SW,
        Anchor.SE,
        Anchor.NE,
        Anchor.O,
        Anchor.E,
      ])
    ];
    final dflipSwirlAHA = DoubleFlipQuads(swirlPaths, ConsPair.h);
    expect(dflipSwirlAHA.consPair.base, Cons.NIL);
    expect(dflipSwirlAHA.consPair.head, Cons.h);

    expect(dflipSwirlAHA[Face.Right].face, Face.Right);
    expect(dflipSwirlAHA[Face.Right].vowel, Face.Right.vowel);
    expect(dflipSwirlAHA[Face.Right].base, Cons.NIL);
    expect(dflipSwirlAHA[Face.Right].head, Cons.h);
    expect(dflipSwirlAHA[Face.Right].lines, swirlPaths);

    expect(dflipSwirlAHA[Face.Up].face, Face.Up);
    expect(dflipSwirlAHA[Face.Up].vowel, Face.Up.vowel);
    expect(dflipSwirlAHA[Face.Up].base, Cons.NIL);
    expect(dflipSwirlAHA[Face.Up].head, Cons.h);
    expect(dflipSwirlAHA[Face.Up].lines, hFlip(turn(swirlPaths)));

    expect(dflipSwirlAHA[Face.Left].face, Face.Left);
    expect(dflipSwirlAHA[Face.Left].vowel, Face.Left.vowel);
    expect(dflipSwirlAHA[Face.Left].base, Cons.NIL);
    expect(dflipSwirlAHA[Face.Left].head, Cons.h);
    expect(dflipSwirlAHA[Face.Left].lines, vFlip(hFlip(swirlPaths)));

    expect(dflipSwirlAHA[Face.Down].face, Face.Down);
    expect(dflipSwirlAHA[Face.Down].vowel, Face.Down.vowel);
    expect(dflipSwirlAHA[Face.Down].base, Cons.NIL);
    expect(dflipSwirlAHA[Face.Down].head, Cons.h);
    expect(
        dflipSwirlAHA[Face.Down].lines, hFlip(vFlip(hFlip(turn(swirlPaths)))));
  });

  test('test PolyCurve compute Spline begin & end normal control pts', () {
    final bc = PolyCurve.calcBegCtl(
        Anchor.NW.vector, Anchor.N.vector, Anchor.S.vector);
    final ec = PolyCurve.calcEndCtl(
        Anchor.N.vector, Anchor.S.vector, Anchor.SE.vector);
    expect(bc.x, moreOrLessEquals(0.3, epsilon: 0.1));
    expect(bc.y, moreOrLessEquals(0.3, epsilon: 0.1));
    expect(ec.x, moreOrLessEquals(-0.3, epsilon: 0.1));
    expect(ec.y, moreOrLessEquals(-0.3, epsilon: 0.1));
  });

  test('test PolyCurve compute Spline begin & end dorminant control pts', () {
    final bc = PolyCurve.calcBegCtl(
      Anchor.NW.vector,
      Anchor.N.vector,
      Anchor.S.vector,
      controlType: SplineControlType.Dorminant,
    );
    final ec = PolyCurve.calcEndCtl(
      Anchor.N.vector,
      Anchor.S.vector,
      Anchor.SE.vector,
      controlType: SplineControlType.Dorminant,
    );
    expect(bc.x, moreOrLessEquals(0.6, epsilon: 0.1));
    expect(bc.y, moreOrLessEquals(0.1, epsilon: 0.1));
    expect(ec.x, moreOrLessEquals(-0.6, epsilon: 0.1));
    expect(ec.y, moreOrLessEquals(-0.1, epsilon: 0.1));
  });
}
