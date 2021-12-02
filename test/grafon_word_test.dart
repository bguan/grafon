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
import 'package:grafon/constants.dart';
import 'package:grafon/grafon_expr.dart';
import 'package:grafon/grafon_word.dart';
import 'package:grafon/gram_table.dart';
import 'package:grafon/localized_string.dart';
import 'package:grafon/phonetics.dart';

/// Unit Tests for Expressions
void main() {
  test("CompoundWord throws exception when insufficient words", () {
    expect(() => CompoundWord.def([CoreWord.def(Mono.Sun.gram)]),
        throwsA(isA<ArgumentError>()));
  });

  test("CompoundWord symbol is different from all Binary operator symbols", () {
    final symbols = Op.values.map((bin) => bin.symbol);
    expect(symbols.contains(COMPOUND_SEP), isFalse);
  });

  test("CompoundWord pronunciation", () {
    final sun = Mono.Sun.gram; // or star
    final person = Mono.Dot.gram.over(Quads.Line.up);

    // God? Alien?
    final starMan = CompoundWord.def([CoreWord.def(sun), CoreWord.def(person)]);
    expect(starMan.toString(), "Sun : Dot / Up_Line");
    final ps = starMan.pronunciations.toList();
    expect(ps.length, 2);

    List<Syllable> v1 = ps[0].syllables;
    expect(v1.length, 1);
    expect(v1.first, Syllable(Cons.s, Vowel.a));

    List<Syllable> v2 = ps[1].syllables;
    expect(v2.length, 2);
    expect(v2[0], Syllable(Cons.h, Vowel.a, Coda.ng));
    expect(v2[1], Syllable.v(Vowel.i));
  });

  test("Word equality and hashcode works", () {
    final dot1 = CoreWord.def(Mono.Dot.gram);
    final dot2 = CoreWord.def(Mono.Dot.gram);
    final circle = CoreWord.def(Mono.Circle.gram);
    expect(dot1, dot1);
    expect(dot1, dot2);
    expect(dot1.hashCode, dot2.hashCode);
    expect(dot1 == circle, isFalse);
  });

  test("WordGroup equality and hashcode", () {
    final g1 = WordGroup(
      LocStr.def('Test'),
      CoreWord.def(Mono.Circle.gram),
      LocStr.def('Test...'),
      [CoreWord.def(Mono.Dot.gram)],
    );
    final g11 = WordGroup(
      LocStr.def('Test'),
      CoreWord.def(Mono.Circle.gram),
      LocStr.def('Test...'),
      [CoreWord.def(Mono.Dot.gram)],
    );
    final g2 = WordGroup(
      LocStr.def('Test'),
      CoreWord.def(Mono.Circle.gram),
      LocStr.def('Test...'),
      [
        CoreWord.def(Mono.Dot.gram),
        CoreWord.def(Mono.Dot.mix(Mono.Empty.gram))
      ],
    );

    expect(g1, g1);
    expect(g1, g11);
    expect(g1.hashCode, g11.hashCode);
    expect(g1 == g2, isFalse);
  });

  test("WordGroup keys and contains", () {
    final circle = CoreWord.def(Mono.Circle.gram);
    final dot = CoreWord.def(Mono.Dot.gram, "dot");
    final vLine = CoreWord.def(Quads.Line.up, "line.up");
    final g =
        WordGroup(LocStr.def('Test'), circle, LocStr.def('?'), [dot, vLine]);

    expect(g.contains("Dot"), isTrue);
    expect(g.contains("tod"), isFalse);
    expect(g.values.first, dot);
    expect(g.values.last, vLine);
    expect(g['Dot'], dot);
    expect(g['Up_Line'], vLine);
    expect(g['nope'], null);
    expect(g.keys.length, 2);
    expect(g.keys.first, "Dot");
    expect(g.keys.last, "Up_Line");
  });
}
