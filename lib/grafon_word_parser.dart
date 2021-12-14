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

    final Parser<Cons> gramCons = ChoiceParser(
      Cons.values
          .where((c) => c != Cons.NIL)
          .map((c) => stringIgnoreCase(c.shortName)),
    ).map((s) => EnumToString.fromString(Cons.values, s)!);

    final Parser<Vowel> baseVowel = ChoiceParser(
      Vowel.values
          .where((v) => v.isBase)
          .map((v) => stringIgnoreCase(v.shortName)),
    ).map((s) => EnumToString.fromString(Vowel.values, s)!);

    final Parser<Gram> baseGram = (gramCons.optional() & baseVowel).map((l) {
      l.removeWhere((e) => e == null);
      return gTab.atConsVowel(
        l.length == 1 ? Cons.NIL : l[0],
        l[l.length == 1 ? 0 : 1],
      );
    });

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

    final Parser<Cons> head =
        (gramCons.optional() & stringIgnoreCase(Group.Head.ext))
            .map((l) => l.first == null ? Cons.NIL : l.first as Cons);

    final Parser<Group> tail =
        stringIgnoreCase(Group.Tail.ext).map((_) => Group.Tail);

    final builder = ExpressionBuilder();
    builder.group()
      ..primitive(baseGram)
      ..wrapper(
        head,
        tail,
        (h, GrafonExpr expr, t) => ClusterExpr.diffHeadCons(h as Cons, expr),
      );

    final binOp = (GrafonExpr a, Op op, GrafonExpr b) => BinaryOpExpr(a, op, b);
    builder.group()..left(mix, binOp);
    builder.group()..left(next, binOp);
    builder.group()..left(over, binOp);
    builder.group()..left(wrap, binOp);

    Parser<GrafonExpr> p = builder.build().end().cast();

    parser = DEBUG ? trace(p) : p;
  }

  GrafonExpr parse(String input) {
    Result<GrafonExpr> res = parser.parse(input);
    if (res.isSuccess) return res.value;

    throw FormatException(res.message);
  }
}
