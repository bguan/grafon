import 'package:flutter_test/flutter_test.dart';
import 'package:grafon/gra_infra.dart';
import 'package:grafon/gra_table.dart';
import 'package:grafon/phonetics.dart';

void main() {
  test('Every Mono has shortName', () {
    for (final m in Mono.values) {
      expect(m.shortName, isNotEmpty);
    }
  });

  test('Every Mono has ConsPair', () {
    for (final m in Mono.values) {
      expect(m.gra.consPair, isNotNull);
    }
  });

  test('Every ConsPair maps to a Mono', () {
    for (final cp in ConsPair.values) {
      expect(Mono.values.firstWhere((m) => m.gra.consPair == cp), isNotNull);
    }
  });

  test('Every Quad has shortName', () {
    for (final q in Quad.values) {
      expect(q.shortName, isNotEmpty);
    }
  });

  test('Every Quad has ConsPair', () {
    for (final q in Quad.values) {
      expect(q.gras.consPair, isNotNull);
    }
  });

  test('Every ConsPair maps to a Quad', () {
    for (final cp in ConsPair.values) {
      expect(Quad.values.firstWhere((q) => q.gras.consPair == cp), isNotNull);
    }
  });

  test('GraTable test atConsPairVowel', () {
    for (final cp in ConsPair.values) {
      for (final v in Vowel.values) {
        final gra = GraTable.atConsPairVowel(cp, v);

        expect(gra.consPair, cp);
        expect(gra.vowel, v);
      }
    }
  });

  test('GraTable test atConsonantVowel', () {
    for (final c in Consonant.values) {
      for (final v in Vowel.values) {
        final gra = GraTable.atConsonantVowel(c, v);
        expect(gra.consPair, c.pair);
        expect(gra.vowel, v);
      }
    }
  });

  test('GraTable test atMonoFace', () {
    for (final m in Mono.values) {
      for (final f in Face.values) {
        final gra = GraTable.atMonoFace(m, f);
        expect(gra.face, f);
        if (f == Face.Center) {
          expect(gra, m.gra);
          expect(gra, isA<MonoGra>());
        } else {
          expect(m, m.quadPeer.monoPeer);
          expect(gra, m.quadPeer[f]);
          expect(gra, isA<QuadGra>());
        }
      }
    }
  });

  test('GraTable numRows match num of Mono', () {
    expect(GraTable.numRows, Mono.values.length);
  });

  test('GraTable numRows match num of Quad', () {
    expect(GraTable.numRows, Quad.values.length);
  });

  test('GraTable numRows match num of ConsPair', () {
    expect(GraTable.numRows, ConsPair.values.length);
  });

  test('GraTable numCols match num of Vowels', () {
    expect(GraTable.numCols, Vowel.values.length);
  });

  test('GraTable numCols match num of Faces', () {
    expect(GraTable.numCols, Face.values.length);
  });
}
