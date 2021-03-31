import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:grafon/gra_infra.dart';
import 'package:grafon/phonetics.dart';

void main() {
  test('Polar Coordinates test unequal distance', () {
    const p1 = Polar(angle: 0, distance: 1);
    const p2 = Polar(angle: 0, distance: 2);

    expect(p1 == p2, false);
  });

  test('Polar Coordinates test unequal angle', () {
    const p1 = Polar(angle: 1, distance: 2);
    const p2 = Polar(angle: 2, distance: 2);

    expect(p1 == p2, false);
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

  //TODO: write PolyPath (PolyDot, PolyLine, PolyCurve) tests
  //TODO: write flip, rotate tests
  //TODO: write MonoGra tests
  //TODO: write QuadGras tests (Rotating, SemiRotating, Flip, DoubleFlip)
}
