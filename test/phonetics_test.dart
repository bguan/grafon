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

import 'package:grafon/phonetics.dart';
import 'package:test/test.dart';

/// Unit Test for phonetics
void main() {
  test('ConsPair should cover all consonants', () {
    final consFromPairs = Set.of([
      ...ConsPair.values.map((cp) => cp.base),
      ...ConsPair.values.map((cp) => cp.head)
    ]);

    expect(consFromPairs, Set.of(Cons.values));
  });

  test('Consonants should cover all ConsPair', () {
    final conspairFromCons = Set.of([
      ...Cons.values.map((c) => c.pair),
    ]);

    expect(conspairFromCons, Set.of(ConsPair.values));
  });

  test('Consonants phonemes should all be unique', () {
    final phonemes = Set.of([
      ...Cons.values.map((c) => c.phoneme),
    ]);

    expect(phonemes.length, Cons.values.length);
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

  test('Vowels phonemes should all be unique', () {
    final phonemes = Set.of([
      ...Vowel.values.map((v) => v.phoneme),
    ]);

    expect(phonemes.length, Vowel.values.length);
  });

  test('CodaGroup should cover all codas except "dh" and "ng"', () {
    final codaFromGroups = Set.of([
      ...CodaGroup.values.map((cg) => cg.base),
      ...CodaGroup.values.map((cg) => cg.tail),
      ...CodaGroup.values.map((cg) => cg.alt),
    ]);

    // ...dh and ...ng are special codas
    expect(codaFromGroups, Set.of(Coda.values)..removeAll([Coda.dh, Coda.ng]));
  });

  test('Codas except "ng" should cover all CodaGroups', () {
    final groupsFromCodas = Set.of([
      ...Coda.values.where((c) => c != Coda.ng).map((c) => c.group),
    ]);

    expect(groupsFromCodas, Set.of(CodaGroup.values));
  });

  test('Coda "ng" will throw exception if attempt to get its Group', () {
    expect(() => Coda.ng.group, throwsA(const TypeMatcher<UnsupportedError>()));
  });

  test('Coda phonemes should all be unique', () {
    final phonemes = Set.of([
      ...Coda.values.map((c) => c.phoneme),
    ]);

    expect(phonemes.length, Coda.values.length);
  });

  test('CodaGroup short names should all be unique', () {
    final shortNames = Set.of([
      ...CodaGroup.values.map((cg) => cg.shortName),
    ]);

    expect(shortNames.length, CodaGroup.values.length);
  });

  test('CodaGroup base, tail and alt should not overlap', () {
    final baseFromGroups = Set.of([
      ...CodaGroup.values.map((cg) => cg.base),
    ]);

    final tailFromGroups = Set.of([
      ...CodaGroup.values.map((cg) => cg.tail),
    ]);

    final altFromGroups = Set.of([
      ...CodaGroup.values.map((cg) => cg.alt),
    ]);

    expect(baseFromGroups.union(tailFromGroups).union(altFromGroups).length,
        CodaGroup.values.length * 3);
  });

  test('Syllable equals and hashcode works', () {
    final a1 = Syllable.v(Vowel.a);
    expect(a1, a1);
    expect(a1.hashCode, a1.hashCode);

    final a2 = Syllable.v(Vowel.a);
    expect(a1, a2);
    expect(a1.hashCode, a2.hashCode);

    final ba = Syllable(Cons.b, Vowel.a);
    expect(a1 == ba, isFalse);

    final aa = Syllable.vv(Vowel.a, Vowel.a);
    expect(a1 == aa, isFalse);

    final ah = Syllable.vc(Vowel.a, Coda.h);
    expect(a1 == ah, isFalse);

    final aah = Syllable.vvc(Vowel.a, Vowel.a, Coda.h);
    expect(a1 == aah, isFalse);
  });

  test('Syllable toString works', () {
    final a = Syllable.v(Vowel.a);
    expect(a.toString(), 'a');
    final ba = Syllable(Cons.b, Vowel.a);
    expect(ba.toString(), 'ba');
    final aa = Syllable.vv(Vowel.a, Vowel.a);
    expect(aa.toString(), 'aa');
    final ah = Syllable.vc(Vowel.a, Coda.h);
    expect(ah.toString(), 'ah');
    final aah = Syllable.vvc(Vowel.a, Vowel.a, Coda.h);
    expect(aah.toString(), 'aah');
    final baah = Syllable(Cons.b, Vowel.a, Vowel.a, Coda.h);
    expect(baah.toString(), 'baah');
  });

  test('Syllable headForm works', () {
    final a = Syllable.v(Vowel.a);
    expect(a.headForm, Syllable(Cons.h, Vowel.a));
    final ba = Syllable(Cons.b, Vowel.a);
    final pa = Syllable(Cons.p, Vowel.a);
    expect(ba.headForm, pa);
    expect(pa.headForm, pa);
  });

  test('Syllable tailOpForm works', () {
    final a = Syllable.v(Vowel.a);
    final ah = Syllable.vc(Vowel.a, Coda.h);
    expect(a.tailOpForm, ah);
    expect(ah.tailOpForm, ah);
  });

  test('Syllable altOpForm works', () {
    final a = Syllable.v(Vowel.a);
    final ah = Syllable.vc(Vowel.a, Coda.h);
    final ath = Syllable.vc(Vowel.a, Coda.th);
    expect(a.altOpForm, ath);
    expect(ah.altOpForm, ath);
    expect(ath.altOpForm, ath);
  });

  test('Syllable firstPhoneme works', () {
    final a = Syllable.v(Vowel.a);
    final ba = Syllable(Cons.b, Vowel.a);
    final ah = Syllable.vc(Vowel.a, Coda.h);
    expect(a.firstPhoneme, 'a');
    expect(ba.firstPhoneme, 'b');
    expect(ah.firstPhoneme, 'a');
  });

  test('Syllable lastPhoneme works', () {
    final a = Syllable.v(Vowel.a);
    final ba = Syllable(Cons.b, Vowel.a);
    final bai = Syllable(Cons.b, Vowel.a, Vowel.i);
    final ah = Syllable.vc(Vowel.a, Coda.h);
    final bais = Syllable(Cons.b, Vowel.a, Vowel.i, Coda.s);
    expect(a.lastPhoneme, 'a');
    expect(ba.lastPhoneme, 'a');
    expect(bai.lastPhoneme, 'i');
    expect(bais.lastPhoneme, 's');
    expect(ah.lastPhoneme, 'h');
  });

  test('Syllable diffXXX works', () {
    final bais = Syllable(Cons.b, Vowel.a, Vowel.i, Coda.s);
    expect(bais.diffConsonant(Cons.ch),
        Syllable(Cons.ch, Vowel.a, Vowel.i, Coda.s));
    expect(bais.diffVowel(Vowel.o), Syllable(Cons.b, Vowel.o, Vowel.i, Coda.s));
    expect(
        bais.diffEndVowel(Vowel.u), Syllable(Cons.b, Vowel.a, Vowel.u, Coda.s));
    expect(bais.diffCoda(Coda.m), Syllable(Cons.b, Vowel.a, Vowel.i, Coda.m));
  });

  test('Pronunciation equality works', () {
    final a = Syllable.v(Vowel.a);
    final ma = Syllable(Cons.m, Vowel.a);
    final aMa = Pronunciation([a, ma]);
    expect(aMa == aMa, true);
    expect(aMa.hashCode == aMa.hashCode, true);

    final aA = Pronunciation([a, a]);
    expect(aMa == aA, false);
    final maA = Pronunciation([ma, a]);
    expect(aMa == maA, false);
    final maMa = Pronunciation([ma, ma]);
    expect(aMa == maMa, false);
  });

  test('Simple Pronunciation works', () {
    final a = Syllable.v(Vowel.a);
    final ma = Syllable(Cons.m, Vowel.a);
    final aMa = Pronunciation([a, ma]);
    expect(aMa.voicing, aMa.syllables);
    expect(aMa.toString(), 'ama');

    final aHa = Pronunciation([a, a]);
    expect(aHa.voicing == aHa.syllables, isFalse);
    expect(aHa.voicing, [a.diffCoda(Coda.th), a]);
    expect(aHa.toString(), 'atha');

    final ah = Syllable.vc(Vowel.a, Coda.h);
    final ha = Syllable(Cons.h, Vowel.a);
    final ahHa = Pronunciation([ah, ha]);
    expect(ahHa.voicing == ahHa.syllables, isFalse);
    expect(ahHa.voicing, [ah.diffCoda(Coda.dh), ha]);
    expect(ahHa.toString(), 'adhha');

    final am = Syllable.vc(Vowel.a, Coda.m);
    final amMa = Pronunciation([am, ma]);
    expect(amMa.voicing == amMa.syllables, isFalse);
    expect(amMa.voicing, [am.diffCoda(Coda.m.group.alt), ma]);
    expect(amMa.toString(), 'apma');
  });
}
