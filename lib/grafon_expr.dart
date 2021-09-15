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

import 'package:vector_math/vector_math.dart';

import 'expr_render.dart';
import 'gram_infra.dart';
import 'gram_table.dart';
import 'phonetics.dart';

/// Binary Operator works on a pair of Gram Expression
enum Binary { Next, Mix, Over, Wrap }

/// Extending Binary Enum to associate shortName, symbol and Coda
extension BinaryExtension on Binary {
  String get shortName => this.toString().split('.').last;

  String get symbol {
    switch (this) {
      case Binary.Over:
        return '/';
      case Binary.Wrap:
        return '@';
      case Binary.Mix:
        return '*';
      case Binary.Next:
      default:
        return '.';
    }
  }

  Coda get coda {
    switch (this) {
      case Binary.Mix:
        return Coda.k;
      case Binary.Over:
        return Coda.s;
      case Binary.Wrap:
        return Coda.n;
      case Binary.Next:
      default:
        return Coda.NIL;
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
  BinaryOpExpr mix(GrafonExpr g) => BinaryOpExpr(this, Binary.Mix, g);

  /// Put this expression before e, this to left, e to right.
  BinaryOpExpr next(GrafonExpr g) => BinaryOpExpr(this, Binary.Next, g);

  /// Put this expression over e, this above, e below.
  BinaryOpExpr over(GrafonExpr g) => BinaryOpExpr(this, Binary.Over, g);

  /// Put this expression around e, this outside, e inside.
  BinaryOpExpr wrap(GrafonExpr g) => BinaryOpExpr(this, Binary.Wrap, g);
}

/// BinaryExpr applies a Binary operation on a 2 expressions.
/// Private subclass, use respective factory methods in GramExpression instead.
class BinaryOpExpr extends GrafonExpr {
  final GrafonExpr expr1;
  final Binary op;
  final GrafonExpr expr2;
  late final renderPlan;

  BinaryOpExpr(this.expr1, this.op, this.expr2) {
    renderPlan = expr1.renderPlan.byBinary(op, expr2.renderPlan);
  }

  @override
  String toString() => "$expr1 ${op.symbol} $expr2";

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
  final GrafonExpr subExpr;
  late final renderPlan;
  late final headGram;
  late final tailOp;
  late final pronunciation;

  ClusterExpr(this.subExpr) {
    renderPlan = subExpr.renderPlan;
    final sList = subExpr.pronunciation.syllables;
    pronunciation = Pronunciation([
      Mono.Empty.gram.syllable.diffCoda(Binary.Mix.coda),
      ...sList.take(sList.length - 1),
      sList.last.diffCoda(Binary.Mix.coda),
      Mono.Empty.gram.syllable,
    ]);
  }

  @override
  String toString() => "(${subExpr.toString()})";

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
