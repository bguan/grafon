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

/// Classes and utils for Words and Expressions.

/// library for expression
library grafon_expr;

import 'package:enum_to_string/enum_to_string.dart';
import 'package:vector_math/vector_math.dart';

import 'expr_render.dart';
import 'generated/l10n.dart';
import 'gram_infra.dart';
import 'gram_table.dart';
import 'phonetics.dart';

/// Binary Operator works on a pair of Gram Expression
enum Op { Mix, Next, Over, Wrap }

/// Extending Op Enum to associate shortName, symbol and Coda
extension OpExtension on Op {
  String get shortName => EnumToString.convertToString(this);

  String get symbol {
    switch (this) {
      case Op.Over:
        return '/';
      case Op.Wrap:
        return '@';
      case Op.Mix:
        return '*';
      case Op.Next:
      default:
        return '+';
    }
  }

  Coda get coda {
    switch (this) {
      case Op.Mix:
        return Coda.ch;
      case Op.Over:
        return Coda.sh;
      case Op.Wrap:
        return Coda.ng;
      case Op.Next:
      default:
        return Coda.NIL;
    }
  }
}

/// Grouping Operators
enum Group { Base, Head, Tail }

/// Extending Group Enum to associate shortName, symbol and pronunciation
extension GroupExtension on Group {
  String get shortName => EnumToString.convertToString(this);

  String get symbol {
    switch (this) {
      case Group.Head:
        return '(';
      case Group.Tail:
        return ')';
      default:
        return '';
    }
  }

  String get ext {
    switch (this) {
      case Group.Head:
        return 'w';
      case Group.Tail:
        return 'y';
      default:
        return '';
    }
  }

  Vowel modVowel(Vowel v) {
    switch (this) {
      case Group.Head:
        return v.headForm;
      case Group.Tail:
        return v.tailForm;
      default:
        return v.baseForm;
    }
  }
}

/// abstract base class for all Grafon Expression.
abstract class GrafonExpr {
  Pronunciation get pronunciation;

  RenderPlan get renderPlan;

  Iterable<PolyLine> get lines => renderPlan.lines;

  Vector2 get center => renderPlan.center;

  double get width => renderPlan.width;

  double get height => renderPlan.height;

  /// get all grams in expression
  List<Gram> get grams;

  /// Mix this expression with m.
  BinaryOpExpr mix(GrafonExpr g) => BinaryOpExpr(this, Op.Mix, g);

  /// Put this expression before e, this to left, e to right.
  BinaryOpExpr next(GrafonExpr g) => BinaryOpExpr(this, Op.Next, g);

  /// Put this expression over e, this above, e below.
  BinaryOpExpr over(GrafonExpr g) => BinaryOpExpr(this, Op.Over, g);

  /// Put this expression around e, this outside, e inside.
  BinaryOpExpr wrap(GrafonExpr g) => BinaryOpExpr(this, Op.Wrap, g);

  /// generate a localized text string for the expression
  String localize(S l10n);

  GrafonExpr swapHeadCons(Cons c) {
    if (c == Cons.NIL) return this;

    GramTable table = GramTable();
    if (this is Gram) {
      Gram g = this as Gram;
      Syllable s = g.syllable;
      assert(s.cons == Cons.NIL);
      return table.atConsVowel(c, g.syllable.vowel);
    }

    BinaryOpExpr bin = this as BinaryOpExpr;

    return BinaryOpExpr(bin.expr1.swapHeadCons(c), bin.op, bin.expr2);
  }
}

/// BinaryExpr applies a Binary operation on a 2 expressions.
/// Private subclass, use respective factory methods in GramExpression instead.
class BinaryOpExpr extends GrafonExpr {
  final GrafonExpr expr1;
  final Op op;
  final GrafonExpr expr2;
  late final renderPlan;

  BinaryOpExpr(this.expr1, this.op, this.expr2) {
    if (expr1 == Mono.Empty.gram && expr2 == Mono.Empty.gram) {
      renderPlan = Mono.Empty.gram.renderPlan;
    } else if (expr1 == Mono.Empty.gram) {
      switch (op) {
        case Op.Next:
          renderPlan = expr2.renderPlan.right();
          break;
        case Op.Over:
          renderPlan = expr2.renderPlan.down();
          break;
        case Op.Wrap:
          renderPlan = expr2.renderPlan.shrink();
          break;
        case Op.Mix:
        default:
          renderPlan = expr2.renderPlan;
      }
    } else if (expr2 == Mono.Empty.gram) {
      switch (op) {
        case Op.Next:
          renderPlan = expr1.renderPlan.left();
          break;
        case Op.Over:
          renderPlan = expr1.renderPlan.up();
          break;
        case Op.Wrap:
        case Op.Mix:
        default:
          renderPlan = expr1.renderPlan;
      }
    } else {
      renderPlan = expr1.renderPlan.byBinary(op, expr2.renderPlan);
    }
  }

  @override
  String toString() => "$expr1 ${op.symbol} $expr2";

  @override
  String localize(S l10n) =>
      "${expr1.localize(l10n)} ${op.symbol} ${expr2.localize(l10n)}";

  @override
  Pronunciation get pronunciation {
    final p1 = expr1.pronunciation;
    return Pronunciation([
      ...p1.syllables.take(p1.length - 1),
      p1.last.diffCoda(op.coda),
      ...expr2.pronunciation.syllables,
    ]);
  }

  @override
  List<Gram> get grams => [...expr1.grams, ...expr2.grams];

  ClusterExpr toClusterExpression() => ClusterExpr(this);

  @override
  int get hashCode => expr1.hashCode << 2 ^ op.hashCode << 1 ^ expr2.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! BinaryOpExpr) return false;
    BinaryOpExpr that = other;
    return expr1 == that.expr1 && expr2 == that.expr2 && op == that.op;
  }
}

/// Cluster Expression ties a binary expr into a single group.
/// Applying special pronunciation to the head gram and the tail op.
class ClusterExpr extends GrafonExpr {
  late final GrafonExpr subExpr;
  late final renderPlan;
  late final headGram;
  late final tailOp;
  late final pronunciation;

  ClusterExpr(this.subExpr) {
    renderPlan = subExpr.renderPlan;
    final sList = subExpr.pronunciation.syllables;
    final head = sList.first;
    final body = sList.sublist(1, sList.length - 1);
    final tail = sList.last;
    pronunciation = Pronunciation([
      head.headVowel(),
      ...body,
      tail.tailVowel(),
    ]);
  }

  ClusterExpr.diffHeadCons(Cons headCons, GrafonExpr baseSubExpr)
      : this(baseSubExpr.swapHeadCons(headCons));

  @override
  String toString() =>
      "${Group.Head.symbol}${subExpr.toString()}${Group.Tail.symbol}";

  @override
  String localize(S l10n) =>
      "${Group.Head.symbol}${subExpr.localize(l10n)}${Group.Tail.symbol}";

  @override
  List<Gram> get grams => subExpr.grams;

  @override
  int get hashCode => subExpr.hashCode << 1 ^ pronunciation.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! ClusterExpr) return false;
    ClusterExpr that = other;
    return subExpr == that.subExpr && pronunciation == that.pronunciation;
  }
}
