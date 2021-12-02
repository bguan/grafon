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

/// Library to deal with words
library grafon_word_parser;

import 'package:enum_to_string/enum_to_string.dart';
import 'package:petitparser/petitparser.dart';

import 'grafon_expr.dart';
import 'grafon_word.dart';
import 'gram_infra.dart';
import 'gram_table.dart';
import 'phonetics.dart';

/// Parser for GrafonWords i.e. from pronunciation string to GrafonWord
class GrafonParser {
  final _gTab = GramTable();

  Parser<Cons> consonant() {
    final consPat =
        Cons.values.where((c) => c != Cons.NIL).map((c) => c.shortName).join();
    return pattern(consPat)
        .map((s) => EnumToString.fromString(Cons.values, s)!);
  }

  Parser<Vowel> vowel() {
    final vowelPat = Vowel.values
        .where((v) => v != Vowel.NIL)
        .map((v) => v.shortName)
        .join();
    return pattern(vowelPat)
        .map((s) => EnumToString.fromString(Vowel.values, s)!);
  }

  Parser<Coda> coda() {
    final codaPat =
        Coda.values.where((c) => c != Coda.NIL).map((c) => c.shortName).join();
    return pattern(codaPat)
        .map((s) => EnumToString.fromString(Coda.values, s)!);
  }

  Parser<Syllable> syllable() {
    return (consonant().optional() & vowel() & coda().optional()).map((l) {
      if (l.length == 1) {
        return Syllable.v(l[0]);
      } else if (l.length == 3) {
        return Syllable(l[0], l[1], l[2]);
      } else if (l[0] is Vowel) {
        return Syllable.vc(l[0], l[1]);
      } else {
        return Syllable(l[0], l[1]);
      }
    });
  }

  Parser<Syllable> emptyMix() {
    return pattern(
      Mono.Empty.gram.pronunciation.syllables[0].vowel.shortName,
    ).map((_) => Mono.Empty.gram.pronunciation.syllables[0]);
  }

  Parser<Op> mix() {
    return pattern(Op.Mix.coda.shortName).map((_) => Op.Mix);
  }

  Parser<Op> next() {
    return pattern(Op.Next.coda.shortName).map((_) => Op.Next);
  }

  Parser<Op> over() {
    return pattern(Op.Over.coda.shortName).map((_) => Op.Over);
  }

  Parser<Op> wrap() {
    return pattern(Op.Wrap.coda.shortName).map((_) => Op.Wrap);
  }

  Parser<Gram> gram() {
    return (consonant().optional() & vowel()).map(
      (l) => _gTab.atConsVowel(
        l.length == 1 ? Cons.NIL : l[0],
        l[l.length == 1 ? 0 : 1],
      ),
    );
  }

  GrafonWord? parse(String voicing) {
    // final mixing = undefined();
    // final nexting = undefined();
    // final covering = undefined();
    // final wrapping = undefined();
  }
}
