import 'package:grafon/phonetics.dart';
import 'package:test/test.dart';

void main() {
  test('ConsPair should cover all consonants', () {
    final consFromPairs = Set.of([
      ...ConsPair.values.map((cp) => cp.base),
      ...ConsPair.values.map((cp) => cp.head)
    ]);

    expect(consFromPairs, Set.of(Consonant.values));
  });

  test('Consonants should cover all ConsPair', () {
    final conspairFromCons = Set.of([
      ...Consonant.values.map((c) => c.pair),
    ]);

    expect(conspairFromCons, Set.of(ConsPair.values));
  });

  test('Consonants short names should all be unique', () {
    final shortNamesFromCons = Set.of([
      ...Consonant.values.map((c) => c.shortName),
    ]);

    expect(shortNamesFromCons.length, Consonant.values.length);
  });

  test('ConsPairs short names should all be unique', () {
    final shortNamesFromConspair = Set.of([
      ...ConsPair.values.map((cp) => cp.shortName),
    ]);

    expect(shortNamesFromConspair.length, ConsPair.values.length);
  });

  test('ConsPair base and head should not overlap', () {
    final baseFromPairs = Set.of([
      ...ConsPair.values.map((cp) => cp.base),
    ]);

    final headFromPairs = Set.of([
      ...ConsPair.values.map((cp) => cp.head),
    ]);

    expect(baseFromPairs.intersection(headFromPairs), Set.of([]));
  });
}
