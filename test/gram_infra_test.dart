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
import 'package:grafon/grafon_expr.dart';
import 'package:grafon/gram_infra.dart';
import 'package:grafon/gram_table.dart';
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

  test('Polar toString works', () {
    final p = Polar(angle: pi, length: .5);

    expect(p.toString(), "Polar(angle: 3.14, length: 0.50)");
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

  test('Anchor angle works', () {
    expect(Anchor.E.angle, closeTo(0, 0.1));
    expect(Anchor.N.angle, closeTo(1.57, 0.1));
    expect(Anchor.W.angle, closeTo(3.14, 0.1));
    expect(Anchor.S.angle, closeTo(4.71, 0.1));
  });

  test('Anchor x y works', () {
    expect(Anchor.E.x, moreOrLessEquals(0.5));
    expect(Anchor.E.y, moreOrLessEquals(0));
    expect(Anchor.N.x, moreOrLessEquals(0));
    expect(Anchor.N.y, moreOrLessEquals(0.5));
    expect(Anchor.W.x, moreOrLessEquals(-0.5));
    expect(Anchor.W.y, moreOrLessEquals(0));
    expect(Anchor.S.x, moreOrLessEquals(0));
    expect(Anchor.S.y, moreOrLessEquals(-.5));
    expect(Anchor.O.x, moreOrLessEquals(0));
    expect(Anchor.O.y, moreOrLessEquals(0));
  });

  test('findAnchor works', () {
    expect(AnchorHelper.findAnchor(Vector2(0, 0)), Anchor.O);
    expect(AnchorHelper.findAnchor(Vector2(.5, 0)), Anchor.E);
    expect(AnchorHelper.findAnchor(Vector2(0, .5)), Anchor.N);
    expect(AnchorHelper.findAnchor(Vector2(-.5, 0)), Anchor.W);
    expect(AnchorHelper.findAnchor(Vector2(0, -.5)), Anchor.S);
    expect(AnchorHelper.findAnchor(Vector2(123, 456)), null);
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
        outerAnchors.map((a) => a.vector).reduce((acc, v) => v + acc);

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

  test('LineMetrics equals, hashCode, toString works', () {
    final lm1 =
        LineMetrics(xMin: 1, yMin: 2, xMax: 3, yMax: 4, xAvg: 2, yAvg: 3);
    final lm1B =
        LineMetrics(xMin: 1, yMin: 2, xMax: 3, yMax: 4, xAvg: 2, yAvg: 3);
    final lm2 =
        LineMetrics(xMin: 2, yMin: 4, xMax: 6, yMax: 8, xAvg: 4, yAvg: 6);

    expect(lm1, lm1);
    expect(lm1, lm1B);
    expect(lm1 == lm2, isFalse);
    expect(lm1.hashCode, lm1B.hashCode);
    expect(lm1.toString(), lm1B.toString());
    expect(lm1.toString() == lm2.toString(), isFalse);
  });

  test('LengthDim equals, hashCode, toString works', () {
    final ld1 = LengthDim(length: 5, dxSum: 3, dySum: 4);
    final ld1B = LengthDim(length: 5, dxSum: 3, dySum: 4);
    final ld2 = LengthDim(length: 10, dxSum: 6, dySum: 8);

    expect(ld1, ld1);
    expect(ld1, ld1B);
    expect(ld1 == ld2, isFalse);
    expect(ld1.hashCode, ld1B.hashCode);
    expect(ld1.toString(), ld1B.toString());
    expect(ld1.toString() == ld2.toString(), isFalse);
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

  test('PolyStraight equality and hashcode', () {
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

  test('PolyStraight visiblePoints are same as all anchors', () {
    final pts = [Anchor.N, Anchor.S, Anchor.E, Anchor.W];
    final lines = PolyStraight.anchors(pts);
    expect(lines.visiblePoints, pts.map((a) => a.vector));
    expect(lines.numVisiblePts, 4);
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
    expect(spline.numVisiblePts, 2);
  });

  test('diffAspect works', () {
    final fixedDot = PolyDot.anchors([Anchor.O], isFixedAspect: true);
    expect(fixedDot.isFixedAspect, isTrue);
    expect(fixedDot.diffAspect(false).isFixedAspect, isFalse);
    expect(fixedDot.diffAspect(false).diffAspect(true).isFixedAspect, isTrue);

    final fixedInvisiDot = InvisiDot.anchors([Anchor.O], isFixedAspect: true);
    expect(fixedInvisiDot.isFixedAspect, isTrue);
    expect(fixedInvisiDot.diffAspect(false).isFixedAspect, isFalse);
    expect(fixedInvisiDot.diffAspect(false).diffAspect(true).isFixedAspect,
        isTrue);

    final fixedLine =
        PolyStraight.anchors([Anchor.N, Anchor.S], isFixedAspect: true);
    expect(fixedLine.isFixedAspect, isTrue);
    expect(fixedLine.diffAspect(false).isFixedAspect, isFalse);
    expect(fixedLine.diffAspect(false).diffAspect(true).isFixedAspect, isTrue);

    final fixedSpline = PolyCurve.anchors(
      [Anchor.N, Anchor.S, Anchor.E, Anchor.W],
      isFixedAspect: true,
    );
    expect(fixedSpline.isFixedAspect, isTrue);
    expect(fixedSpline.diffAspect(false).isFixedAspect, isFalse);
    expect(
        fixedSpline.diffAspect(false).diffAspect(true).isFixedAspect, isTrue);
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
    final m = MonoGram(paths1, Cons.h);
    expect(m, m);

    final m1 = MonoGram(paths1, Cons.h);
    expect(m, m1);
    expect(m.hashCode, m1.hashCode);

    final m1SA = MonoGram(paths1, Cons.s);
    expect(m == m1SA, isFalse);
    expect(m.hashCode == m1SA.hashCode, isFalse);

    final m2 = MonoGram(paths2, Cons.h);
    expect(m == m2, isFalse);
    expect(m.hashCode == m2.hashCode, isFalse);
  });

  test('MonoGram face, vowel, base vs head consonants', () {
    final xPaths = [
      PolyStraight.anchors([Anchor.NW, Anchor.SE]),
      PolyStraight.anchors([Anchor.NE, Anchor.SW])
    ];
    final xAHA = MonoGram(xPaths, Cons.h);
    expect(xAHA.face, Face.Center);
    expect(xAHA.vowel, Face.Center.vowel);
    expect(xAHA.cons, Cons.h);
  });

  test('MonoGram visualCenter is avg vectors of de-duplicated visible anchors',
      () {
    final xPaths = [
      PolyStraight.anchors([Anchor.NW, Anchor.SE]),
      PolyStraight.anchors([Anchor.NE, Anchor.SW])
    ];
    final xHA = MonoGram(xPaths, Cons.h);
    expect(xHA.center.x, moreOrLessEquals(0, epsilon: floatPrecision));
    expect(xHA.center.y, moreOrLessEquals(0, epsilon: floatPrecision));

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
    final circleHA = MonoGram(circlePaths, Cons.h);
    expect(circleHA.center.x, moreOrLessEquals(0, epsilon: floatPrecision));
    expect(circleHA.center.y, moreOrLessEquals(0, epsilon: floatPrecision));
  });

  test('RotatingQuads equality and hashcode', () {
    final anglePaths = [
      PolyStraight.anchors([Anchor.N, Anchor.E, Anchor.S])
    ];
    final angleHA = RotatingQuads(anglePaths, Cons.h);
    expect(angleHA, angleHA);

    final semiAngleHA = SemiRotatingQuads(anglePaths, Cons.h);
    expect(angleHA == semiAngleHA, isFalse);
    expect(angleHA.hashCode == semiAngleHA.hashCode, isFalse);

    final flipAngleHA = FlipQuads(anglePaths, Cons.h);
    expect(angleHA == flipAngleHA, isFalse);
    expect(angleHA.hashCode == flipAngleHA.hashCode, isFalse);

    final doubleFlipAngleHA = DoubleFlipQuads(anglePaths, Cons.h);
    expect(angleHA == doubleFlipAngleHA, isFalse);
    expect(angleHA.hashCode == doubleFlipAngleHA.hashCode, isFalse);

    final angleHA2 = RotatingQuads(anglePaths, Cons.h);
    expect(angleHA, equals(angleHA2));
    expect(angleHA.hashCode, angleHA2.hashCode);

    final angleSA = RotatingQuads(anglePaths, Cons.s);
    expect(angleHA == angleSA, isFalse);
    expect(angleHA.hashCode == angleSA.hashCode, isFalse);

    final gatePaths = [
      PolyStraight.anchors([Anchor.NE, Anchor.NW, Anchor.SW, Anchor.SE])
    ];
    final gateHA = RotatingQuads(gatePaths, Cons.h);
    expect(angleHA == gateHA, isFalse);
    expect(angleHA.hashCode == gateHA.hashCode, isFalse);
  });

  test('RotatingQuads face, vowel, base vs head consonants, visualCenter', () {
    final anglePaths = [
      PolyStraight.anchors([Anchor.N, Anchor.E, Anchor.S])
    ];
    final angleHA = RotatingQuads(anglePaths, Cons.h);
    expect(angleHA.cons, Cons.h);

    expect(angleHA[Face.Right].face, Face.Right);
    expect(angleHA[Face.Right].vowel, Face.Right.vowel);
    expect(angleHA[Face.Right].cons, Cons.h);
    expect(angleHA[Face.Right].lines, anglePaths);
    expect(angleHA[Face.Right].center.y,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(angleHA[Face.Right].center.x,
        moreOrLessEquals(0.25, epsilon: floatPrecision));

    expect(angleHA[Face.Up].face, Face.Up);
    expect(angleHA[Face.Up].vowel, Face.Up.vowel);
    expect(angleHA[Face.Up].cons, Cons.h);
    expect(angleHA[Face.Up].lines, turn(anglePaths, steps: 1, isSemi: false));
    expect(angleHA[Face.Up].center.x,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(angleHA[Face.Up].center.y,
        moreOrLessEquals(0.25, epsilon: floatPrecision));

    expect(angleHA[Face.Left].face, Face.Left);
    expect(angleHA[Face.Left].vowel, Face.Left.vowel);
    expect(angleHA[Face.Left].cons, Cons.h);
    expect(angleHA[Face.Left].lines, turn(anglePaths, steps: 2, isSemi: false));
    expect(angleHA[Face.Left].center.y,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(angleHA[Face.Left].center.x,
        moreOrLessEquals(-0.25, epsilon: floatPrecision));

    expect(angleHA[Face.Down].face, Face.Down);
    expect(angleHA[Face.Down].vowel, Face.Down.vowel);
    expect(angleHA[Face.Down].cons, Cons.h);
    expect(
        angleHA[Face.Down].lines, turn(anglePaths, steps: -1, isSemi: false));
    expect(angleHA[Face.Down].center.x,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(angleHA[Face.Down].center.y,
        moreOrLessEquals(-0.25, epsilon: floatPrecision));
  });

  test('SemiRotatingQuads equality and hashcode', () {
    final linePaths = [
      PolyStraight.anchors([Anchor.SW, Anchor.NE])
    ];
    final semiLineHA = SemiRotatingQuads(linePaths, Cons.h);
    expect(semiLineHA, semiLineHA);

    final lineAHA = RotatingQuads(linePaths, Cons.h);
    expect(semiLineHA == lineAHA, isFalse);
    expect(semiLineHA.hashCode == lineAHA.hashCode, isFalse);

    final flipLineHA = FlipQuads(linePaths, Cons.h);
    expect(semiLineHA == flipLineHA, isFalse);
    expect(semiLineHA.hashCode == flipLineHA.hashCode, isFalse);

    final doubleFlipLineHA = DoubleFlipQuads(linePaths, Cons.h);
    expect(semiLineHA == doubleFlipLineHA, isFalse);
    expect(semiLineHA.hashCode == doubleFlipLineHA.hashCode, isFalse);

    final semiLineHA2 = SemiRotatingQuads(linePaths, Cons.h);
    expect(semiLineHA, equals(semiLineHA2));
    expect(semiLineHA.hashCode, semiLineHA2.hashCode);

    final semiLineSA = SemiRotatingQuads(linePaths, Cons.s);
    expect(semiLineHA == semiLineSA, isFalse);
    expect(semiLineHA.hashCode == semiLineSA.hashCode, isFalse);

    final gatePaths = [
      PolyStraight.anchors([Anchor.NE, Anchor.NW, Anchor.SW, Anchor.SE])
    ];
    final semiGateHA = SemiRotatingQuads(gatePaths, Cons.h);
    expect(semiLineHA == semiGateHA, isFalse);
    expect(semiLineHA.hashCode == semiGateHA.hashCode, isFalse);
  });

  test('SemiRotatingQuads face, vowel, base/head consonants, visualCenter', () {
    final linePaths = [
      PolyStraight.anchors([Anchor.SW, Anchor.NE])
    ];
    final semiLineHA = SemiRotatingQuads(linePaths, Cons.h);
    expect(semiLineHA.cons, Cons.h);

    expect(semiLineHA[Face.Right].face, Face.Right);
    expect(semiLineHA[Face.Right].vowel, Face.Right.vowel);
    expect(semiLineHA[Face.Right].cons, Cons.h);
    expect(semiLineHA[Face.Right].lines, linePaths);
    expect(semiLineHA[Face.Right].center.y,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(semiLineHA[Face.Right].center.x,
        moreOrLessEquals(0, epsilon: floatPrecision));

    expect(semiLineHA[Face.Up].face, Face.Up);
    expect(semiLineHA[Face.Up].vowel, Face.Up.vowel);
    expect(semiLineHA[Face.Up].cons, Cons.h);
    expect(semiLineHA[Face.Up].lines, turn(linePaths, steps: 1, isSemi: true));
    expect(semiLineHA[Face.Up].center.x,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(semiLineHA[Face.Up].center.y,
        moreOrLessEquals(0, epsilon: floatPrecision));

    expect(semiLineHA[Face.Left].face, Face.Left);
    expect(semiLineHA[Face.Left].vowel, Face.Left.vowel);
    expect(semiLineHA[Face.Left].cons, Cons.h);
    expect(
        semiLineHA[Face.Left].lines, turn(linePaths, steps: 2, isSemi: true));
    expect(semiLineHA[Face.Left].center.y,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(semiLineHA[Face.Left].center.x,
        moreOrLessEquals(0, epsilon: floatPrecision));

    expect(semiLineHA[Face.Down].face, Face.Down);
    expect(semiLineHA[Face.Down].vowel, Face.Down.vowel);
    expect(semiLineHA[Face.Down].cons, Cons.h);
    expect(
        semiLineHA[Face.Down].lines, turn(linePaths, steps: 3, isSemi: true));
    expect(semiLineHA[Face.Down].center.x,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(semiLineHA[Face.Down].center.y,
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
    final flipFlowHA = FlipQuads(flowPaths, Cons.h);
    expect(flipFlowHA, flipFlowHA);

    final rotaFlowHA = RotatingQuads(flowPaths, Cons.h);
    expect(flipFlowHA == rotaFlowHA, isFalse);
    expect(flipFlowHA.hashCode == rotaFlowHA.hashCode, isFalse);

    final semiFlowHA = SemiRotatingQuads(flowPaths, Cons.h);
    expect(flipFlowHA == semiFlowHA, isFalse);
    expect(flipFlowHA.hashCode == semiFlowHA.hashCode, isFalse);

    final doubleFlipFlowHA = DoubleFlipQuads(flowPaths, Cons.h);
    expect(flipFlowHA == doubleFlipFlowHA, isFalse);
    expect(flipFlowHA.hashCode == doubleFlipFlowHA.hashCode, isFalse);

    final flipFlowHA2 = FlipQuads(flowPaths, Cons.h);
    expect(flipFlowHA, equals(flipFlowHA2));
    expect(flipFlowHA.hashCode, flipFlowHA2.hashCode);

    final flipFlowSA = FlipQuads(flowPaths, Cons.s);
    expect(flipFlowHA == flipFlowSA, isFalse);
    expect(flipFlowHA.hashCode == flipFlowSA.hashCode, isFalse);

    final gatePaths = [
      PolyStraight.anchors([Anchor.NE, Anchor.NW, Anchor.SW, Anchor.SE])
    ];
    final flipGateHA = FlipQuads(gatePaths, Cons.h);
    expect(flipFlowHA == flipGateHA, isFalse);
    expect(flipFlowHA.hashCode == flipGateHA.hashCode, isFalse);
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
    final flipFlowHA = FlipQuads(flowPaths, Cons.h);
    expect(flipFlowHA.cons, Cons.h);

    expect(flipFlowHA[Face.Right].face, Face.Right);
    expect(flipFlowHA[Face.Right].vowel, Face.Right.vowel);
    expect(flipFlowHA[Face.Right].cons, Cons.h);
    expect(flipFlowHA[Face.Right].lines, flowPaths);
    expect(flipFlowHA[Face.Right].center.y,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(flipFlowHA[Face.Right].center.x,
        moreOrLessEquals(0, epsilon: floatPrecision));

    expect(flipFlowHA[Face.Up].face, Face.Up);
    expect(flipFlowHA[Face.Up].vowel, Face.Up.vowel);
    expect(flipFlowHA[Face.Up].cons, Cons.h);
    expect(flipFlowHA[Face.Up].lines, turn(flowPaths));
    expect(flipFlowHA[Face.Up].center.x,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(flipFlowHA[Face.Up].center.y,
        moreOrLessEquals(0, epsilon: floatPrecision));

    expect(flipFlowHA[Face.Left].face, Face.Left);
    expect(flipFlowHA[Face.Left].vowel, Face.Left.vowel);
    expect(flipFlowHA[Face.Left].cons, Cons.h);
    expect(flipFlowHA[Face.Left].lines, hFlip(flowPaths));
    expect(flipFlowHA[Face.Left].center.y,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(flipFlowHA[Face.Left].center.x,
        moreOrLessEquals(0, epsilon: floatPrecision));

    expect(flipFlowHA[Face.Down].face, Face.Down);
    expect(flipFlowHA[Face.Down].vowel, Face.Down.vowel);
    expect(flipFlowHA[Face.Down].cons, Cons.h);
    expect(flipFlowHA[Face.Down].lines, vFlip(turn(flowPaths)));
    expect(flipFlowHA[Face.Down].center.x,
        moreOrLessEquals(0, epsilon: floatPrecision));
    expect(flipFlowHA[Face.Down].center.y,
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
    final dFlipSwirlHA = DoubleFlipQuads(swirlPaths, Cons.h);
    expect(dFlipSwirlHA, dFlipSwirlHA);

    final rotaSwirlHA = RotatingQuads(swirlPaths, Cons.h);
    expect(dFlipSwirlHA == rotaSwirlHA, isFalse);
    expect(dFlipSwirlHA.hashCode == rotaSwirlHA.hashCode, isFalse);

    final semiSwirlHA = SemiRotatingQuads(swirlPaths, Cons.h);
    expect(dFlipSwirlHA == semiSwirlHA, isFalse);
    expect(dFlipSwirlHA.hashCode == semiSwirlHA.hashCode, isFalse);

    final flipSwirlHA = FlipQuads(swirlPaths, Cons.h);
    expect(dFlipSwirlHA == flipSwirlHA, isFalse);
    expect(dFlipSwirlHA.hashCode == flipSwirlHA.hashCode, isFalse);

    final dFlipSwirlHA2 = DoubleFlipQuads(swirlPaths, Cons.h);
    expect(dFlipSwirlHA, equals(dFlipSwirlHA2));
    expect(dFlipSwirlHA.hashCode, dFlipSwirlHA2.hashCode);

    final dFlipSwirlSA = DoubleFlipQuads(swirlPaths, Cons.s);
    expect(dFlipSwirlHA == dFlipSwirlSA, isFalse);
    expect(dFlipSwirlHA.hashCode == dFlipSwirlSA.hashCode, isFalse);

    final gatePaths = [
      PolyStraight.anchors([Anchor.NE, Anchor.NW, Anchor.SW, Anchor.SE])
    ];
    final dFlipGateHA = DoubleFlipQuads(gatePaths, Cons.h);
    expect(dFlipSwirlHA == dFlipGateHA, isFalse);
    expect(dFlipSwirlHA.hashCode == dFlipGateHA.hashCode, isFalse);
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
    final dFlipSwirlHA = DoubleFlipQuads(swirlPaths, Cons.h);
    expect(dFlipSwirlHA.cons, Cons.h);

    expect(dFlipSwirlHA[Face.Right].face, Face.Right);
    expect(dFlipSwirlHA[Face.Right].vowel, Face.Right.vowel);
    expect(dFlipSwirlHA[Face.Right].cons, Cons.h);
    expect(dFlipSwirlHA[Face.Right].lines, swirlPaths);

    expect(dFlipSwirlHA[Face.Up].face, Face.Up);
    expect(dFlipSwirlHA[Face.Up].vowel, Face.Up.vowel);
    expect(dFlipSwirlHA[Face.Up].cons, Cons.h);
    expect(dFlipSwirlHA[Face.Up].lines, vFlip(swirlPaths));

    expect(dFlipSwirlHA[Face.Left].face, Face.Left);
    expect(dFlipSwirlHA[Face.Left].vowel, Face.Left.vowel);
    expect(dFlipSwirlHA[Face.Left].cons, Cons.h);
    expect(dFlipSwirlHA[Face.Left].lines, vFlip(hFlip(swirlPaths)));

    expect(dFlipSwirlHA[Face.Down].face, Face.Down);
    expect(dFlipSwirlHA[Face.Down].vowel, Face.Down.vowel);
    expect(dFlipSwirlHA[Face.Down].cons, Cons.h);
    expect(dFlipSwirlHA[Face.Down].lines, hFlip(swirlPaths));
  });

  test('test PolyCurve degenerate control pts', () {
    final line = PolyCurve.anchors([Anchor.N, Anchor.N, Anchor.S, Anchor.S]);
    expect(line.lengthDim.length, 1);
    final turn =
        PolyCurve.anchors([Anchor.W, Anchor.W, Anchor.O, Anchor.N, Anchor.N]);
    expect(turn.lengthDim.length == 1.0, isFalse);
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

  test('test PolyCurve compute Spline begin & end dominant control pts', () {
    final bc = PolyCurve.calcBegCtl(
      Anchor.NW.vector,
      Anchor.N.vector,
      Anchor.S.vector,
      controlType: SplineControlType.Dominant,
    );
    final ec = PolyCurve.calcEndCtl(
      Anchor.N.vector,
      Anchor.S.vector,
      Anchor.SE.vector,
      controlType: SplineControlType.Dominant,
    );
    expect(bc.x, moreOrLessEquals(0.6, epsilon: 0.1));
    expect(bc.y, moreOrLessEquals(0.1, epsilon: 0.1));
    expect(ec.x, moreOrLessEquals(-0.6, epsilon: 0.1));
    expect(ec.y, moreOrLessEquals(-0.1, epsilon: 0.1));
  });

  test('test SingleExpr get gram works', () {
    final table = GramTable();
    for (final m in Mono.values) {
      for (final f in Face.values) {
        final g = table.atMonoFace(m, f);
        for (final uop in [null, ...Unary.values]) {
          final expr = uop == null ? g : UnaryOpExpr(uop, g);
          expect(expr.gram, g);
          expect(expr.grams, [g]);
        }
      }
    }
  });
}
