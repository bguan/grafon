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
import 'package:petitparser/debug.dart';
import 'package:petitparser/petitparser.dart';

import 'grafon_expr.dart';
import 'gram_infra.dart';
import 'gram_table.dart';
import 'phonetics.dart';

/// Parser for GrafonWords i.e. from pronunciation string to GrafonWord
class GrafonParser {
  static const DEBUG = false;

  late final Parser<GrafonExpr> parser;

  GrafonParser() {
    final gTab = GramTable();

    final Parser<Cons> consonant = ChoiceParser(
      Cons.values
          .where((c) => c != Cons.NIL)
          .map((c) => stringIgnoreCase(c.shortName)),
    ).map((s) => EnumToString.fromString(Cons.values, s)!);

    final Parser<Vowel> vowel = ChoiceParser(
      Vowel.values
          .where((v) => v != Vowel.NIL)
          .map((v) => stringIgnoreCase(v.shortName)),
    ).map((s) => EnumToString.fromString(Vowel.values, s)!);

    final Parser<Gram> empty =
        pattern(Mono.Empty.gram.pronunciation.syllables[0].vowel.shortName)
            .map((_) => Mono.Empty.gram);

    final opCodaParsers = (Op op) {
      return (op.coda.shortName.isEmpty
              ? EpsilonParser("")
              : stringIgnoreCase(op.coda.shortName))
          .map((_) => op);
    };

    final Parser<Op> mix = opCodaParsers(Op.Mix);

    final Parser<Op> next = opCodaParsers(Op.Next);

    final Parser<Op> over = opCodaParsers(Op.Over);

    final Parser<Op> wrap = opCodaParsers(Op.Wrap);

    final Parser<GrafonExpr> gram = (consonant.optional() & vowel).map((l) {
      l.removeWhere((e) => e == null);
      return gTab.atConsVowel(
        l.length == 1 ? Cons.NIL : l[0],
        l[l.length == 1 ? 0 : 1],
      );
    });

    final expr = undefined<GrafonExpr>();

    final Parser<GrafonExpr> cluster = (empty & mix & expr & mix & empty).map(
      (l) => ClusterExpr(l[2]),
    );

    final Parser<GrafonExpr> term = ChoiceParser([gram, cluster]);

    final termCombiner = (List l, Op op) {
      var expr = l.first;
      var tail = l.skip(1);
      for (var opTerm in tail) {
        if (opTerm is! Iterable) {
          throw FormatException("Invalid parse of termCombiner: $l");
        }

        if (opTerm.isEmpty) continue;

        if (opTerm.first is! Iterable ||
            opTerm.first.isEmpty ||
            opTerm.first.first != op) {
          throw FormatException("Invalid parse of termCombiner: $l");
        }

        final nextTerm = opTerm.first.skip(1).first;
        if (nextTerm is! GrafonExpr) {
          throw FormatException(
              "Unexpected next term in termCombiner: $nextTerm");
        }
        expr = BinaryOpExpr(expr, op, nextTerm);
      }
      return expr;
    };

    final Parser<GrafonExpr> mixes = (term & (mix & term).star()).map(
      (l) => termCombiner(l, Op.Mix),
    );

    final Parser<GrafonExpr> series = (mixes & (next & mixes).star()).map(
      (l) => termCombiner(l, Op.Next),
    );

    final Parser<GrafonExpr> stacks = (series & (over & series).star()).map(
      (l) => termCombiner(l, Op.Over),
    );

    final Parser<GrafonExpr> wraps = (stacks & (wrap & stacks).star()).map(
      (l) => termCombiner(l, Op.Wrap),
    );

    expr.set(ChoiceParser([wraps, stacks, series, mixes, term]));
    parser = DEBUG ? progress(resolve(expr.end())) : resolve(expr.end());
  }

  GrafonExpr parse(String input) {
    Result<GrafonExpr> res = parser.parse(input);
    if (res.isSuccess) return res.value;

    throw FormatException(res.message);
  }
}
