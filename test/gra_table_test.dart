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

  test('Every Quad has shortName', () {
    for (final q in Quad.values) {
      expect(q.shortName, isNotEmpty);
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
}
