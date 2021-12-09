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
import 'gram_table.dart';
import 'phonetics.dart';

/// Parser for GrafonWords i.e. from pronunciation string to GrafonWord
class GrafonParser {
  static const DEBUG = false;

  late final Parser<GrafonExpr> parser;

  GrafonParser() {
    final gTab = GramTable();

    final Parser<Cons> gramCons = ChoiceParser(
      Cons.values
          .where((c) => c != Cons.NIL && !c.isSpecial)
          .map((c) => stringIgnoreCase(c.shortName)),
    ).map((s) => EnumToString.fromString(Cons.values, s)!);

    final Parser<Vowel> vowel = ChoiceParser(
      Vowel.values
          .where((v) => v != Vowel.NIL)
          .map((v) => stringIgnoreCase(v.shortName)),
    ).map((s) => EnumToString.fromString(Vowel.values, s)!);

    final Parser<Group> beg =
        stringIgnoreCase(Group.beg.syllable.toString()).map((_) => Group.beg);

    final Parser<Group> end =
        stringIgnoreCase(Group.end.syllable.toString()).map((_) => Group.end);

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

    final Parser<GrafonExpr> gram = (gramCons.optional() & vowel).map((l) {
      l.removeWhere((e) => e == null);
      return gTab.atConsVowel(
        l.length == 1 ? Cons.NIL : l[0],
        l[l.length == 1 ? 0 : 1],
      );
    });

    final builder = ExpressionBuilder();
    builder.group()
      ..primitive(gram)
      ..wrapper(beg, end, (b, GrafonExpr expr, e) => ClusterExpr(expr));

    final binOp = (GrafonExpr a, Op op, GrafonExpr b) => BinaryOpExpr(a, op, b);
    builder.group()..left(mix, binOp);
    builder.group()..left(next, binOp);
    builder.group()..left(over, binOp);
    builder.group()..left(wrap, binOp);

    parser = builder.build().end().cast();
  }

  GrafonExpr parse(String input) {
    Result<GrafonExpr> res = parser.parse(input);
    if (res.isSuccess) return res.value;

    throw FormatException(res.message);
  }
}
