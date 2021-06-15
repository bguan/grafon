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
    List<Syllable> voicing = starMan.pronunciation.voicing;
    expect(voicing.length, 3);
    expect(voicing[0], Syllable.cvc(Cons.sh, Vowel.a, Coda.ng));
    expect(voicing[1], Syllable.vc(Vowel.a, Coda.s));
    expect(voicing[2], Syllable.v(Vowel.i));
  });

  test("Word equality and hashcode works", () {
    final dot1 = CoreWord(Mono.Dot.gram);
    final dot2 = CoreWord(Mono.Dot.gram);
    final circle = CoreWord(Mono.Circle.gram);
    expect(dot1, dot1);
    expect(dot1, dot2);
    expect(dot1.hashCode, dot2.hashCode);
    expect(dot1 == circle, isFalse);
  });

  test("WordGroup equality and hashcode", () {
    final g1 = WordGroup('Test', CoreWord(Mono.Circle.gram), 'Test...',
        [CoreWord(Mono.Dot.gram)]);
    final g11 = WordGroup('Test', CoreWord(Mono.Circle.gram), 'Test...',
        [CoreWord(Mono.Dot.gram)]);
    final g2 = WordGroup('Test', CoreWord(Mono.Circle.gram), 'Test...',
        [CoreWord(Mono.Dot.gram), CoreWord(Mono.Dot.shrink())]);

    expect(g1, g1);
    expect(g1, g11);
    expect(g1.hashCode, g11.hashCode);
    expect(g1 == g2, isFalse);
  });

  test("WordGroup contains", () {
    final circle = CoreWord(Mono.Circle.gram);
    final dot = CoreWord(Mono.Dot.gram, "dot");
    final vLine = CoreWord(Quads.Line.up, "line.up");
    final g = WordGroup('Test', circle, '?', [dot, vLine]);

    expect(g.contains("dot"), isTrue);
    expect(g.contains("tod"), isFalse);
    expect(g.values.first, dot);
    expect(g.values.last, vLine);
    expect(g['dot'], dot);
    expect(g['line.up'], vLine);
    expect(g['nope'], null);
  });
}
