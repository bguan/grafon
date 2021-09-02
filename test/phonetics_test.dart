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
  test('Consonants phonemes should all be unique', () {
    final phonemes = Set.of([
      ...Cons.values.map((c) => c.phoneme),
    ]);

    expect(phonemes.length, Cons.values.length);
  });

  test('Vowels phonemes should all be unique', () {
    final phonemes = Set.of([
      ...Vowel.values.map((v) => v.phoneme),
    ]);

    expect(phonemes.length, Vowel.values.length);
  });

  test('Coda phonemes should all be unique', () {
    final phonemes = Set.of([
      ...Coda.values.map((c) => c.phoneme),
    ]);

    expect(phonemes.length, Coda.values.length);
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

    final as = Syllable.vc(Vowel.a, Coda.th);
    expect(a1 == as, isFalse);

    final aas = Syllable.vvc(Vowel.a, Vowel.a, Coda.th);
    expect(a1 == aas, isFalse);
  });

  test('Syllable toString works', () {
    final a = Syllable.v(Vowel.a);
    expect(a.toString(), 'a');
    final ba = Syllable(Cons.b, Vowel.a);
    expect(ba.toString(), 'ba');
    final aa = Syllable.vv(Vowel.a, Vowel.a);
    expect(aa.toString(), 'aa');
    final as = Syllable.vc(Vowel.a, Coda.sh);
    expect(as.toString(), 'ash');
    final aas = Syllable.vvc(Vowel.a, Vowel.a, Coda.sh);
    expect(aas.toString(), 'aash');
    final baas = Syllable(Cons.b, Vowel.a, Vowel.a, Coda.sh);
    expect(baas.toString(), 'baash');
  });

  test('Syllable firstPhoneme works', () {
    final a = Syllable.v(Vowel.a);
    final ba = Syllable(Cons.b, Vowel.a);
    final as = Syllable.vc(Vowel.a, Coda.th);
    expect(a.firstPhoneme, 'ɑː');
    expect(ba.firstPhoneme, 'b');
    expect(as.firstPhoneme, 'ɑː');
  });

  test('Syllable lastPhoneme works', () {
    final a = Syllable.v(Vowel.a);
    final ba = Syllable(Cons.b, Vowel.a);
    final bai = Syllable(Cons.b, Vowel.a, Vowel.i);
    final as = Syllable.vc(Vowel.a, Coda.sh);
    final bais = Syllable(Cons.b, Vowel.a, Vowel.i, Coda.sh);
    expect(a.lastPhoneme, 'ɑː');
    expect(ba.lastPhoneme, 'ɑː');
    expect(bai.lastPhoneme, 'iː');
    expect(bais.lastPhoneme, 'ʃ');
    expect(as.lastPhoneme, 'ʃ');
  });

  test('Syllable diffXXX works', () {
    final bais = Syllable(Cons.b, Vowel.a, Vowel.i, Coda.th);
    expect(bais.diffConsonant(Cons.p),
        Syllable(Cons.p, Vowel.a, Vowel.i, Coda.th));
    expect(
        bais.diffVowel(Vowel.o), Syllable(Cons.b, Vowel.o, Vowel.i, Coda.th));
    expect(bais.diffExtension(Vowel.u),
        Syllable(Cons.b, Vowel.a, Vowel.u, Coda.th));
    expect(bais.diffCoda(Coda.ng), Syllable(Cons.b, Vowel.a, Vowel.i, Coda.ng));
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
    final na = Syllable(Cons.n, Vowel.a);
    final aNa = Pronunciation([a, na]);
    expect(aNa.toString(), 'ɑː.nɑː');

    final aA = Pronunciation([a, a]);
    expect(aA.toString(), 'ɑː.ɑː');

    final as = Syllable.vc(Vowel.a, Coda.sh);
    final ha = Syllable(Cons.h, Vowel.a);
    final asHa = Pronunciation([as, ha]);
    expect(asHa.toString(), 'ɑːʃ.hɑː');

    final an = Syllable.vc(Vowel.a, Coda.ch);
    final anNa = Pronunciation([an, na]);
    expect(anNa.toString(), 'ɑːʧ.nɑː');
  });
}
