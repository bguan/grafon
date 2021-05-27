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

import 'package:flutter_test/flutter_test.dart';
import 'package:grafon/grafon_expr.dart';
import 'package:grafon/grafon_word.dart';
import 'package:grafon/gram_table.dart';
import 'package:grafon/phonetics.dart';

/// Unit Tests for Expressions
void main() {
  test("CompoundWord throws exception when insufficient words", () {
    expect(() => CompoundWord([CoreWord(Mono.Sun.gram)]),
        throwsA(isA<ArgumentError>()));
  });

  test("CompoundWord symbol is different from all Binary operator symbols", () {
    final symbols = Binary.values.map((bin) => bin.symbol);
    expect(symbols.contains(CompoundWord.SEPARATOR_SYMBOL), isFalse);
  });

  test("CompoundWord pronunciation", () {
    final sun = Mono.Sun.gram; // or star
    final person = Mono.Dot.gram.over(Quads.Line.up);

    final starMan =
        CompoundWord([CoreWord(sun), CoreWord(person)]); // God? Alien?
    expect(starMan.toString(),
        "CompoundWord(CoreWord(Sun):CoreWord(Dot / Up_Line))");
    List<Syllable> syllables = starMan.pronunciation.syllables;
    expect(syllables.length, 3);
    expect(syllables[0], Syllable.cvc(Consonant.Sh, Vowel.A, Coda.ng));
    expect(syllables[1], Syllable.vc(Vowel.A, Coda.S));
    expect(syllables[2], Syllable.v(Vowel.I));
  });
}
