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
library expression;

import 'package:vector_math/vector_math.dart';

import 'gram_infra.dart';
import 'gram_table.dart';
import 'operators.dart';
import 'phonetics.dart';
import 'render_plan.dart';

/// Word is the abstract base class for all Gram Expression and Compound Word
abstract class Word {
  String get pronunciation;

  RenderPlan get renderPlan;

  Iterable<PolyLine> get lines => renderPlan.lines;

  Vector2 get center => renderPlan.center;

  double get width => renderPlan.width;

  double get height => renderPlan.height;

  double get ratioWH => renderPlan.ratioWH;
}

/// abstract base class for all Gram Expression.
abstract class GramExpression extends Word {
  /// Merge this expression with another.
  GramExpression merge(GramExpression that) =>
      BinaryExpr(this, Binary.Merge, that);

  /// Put this expression before that, this to left, that to right.
  GramExpression next(GramExpression that) =>
      BinaryExpr(this, Binary.Next, that);

  /// Put this expression over that, this above, that below.
  GramExpression over(GramExpression that) =>
      BinaryExpr(this, Binary.Over, that);

  /// Put this expression around that, this outside, that inside.
  GramExpression wrap(GramExpression that) =>
      BinaryExpr(this, Binary.Wrap, that);
}

/// A Unary Gram Expression applies a Unary Operation on a single Gram.
/// Use factory methods in Gram instead of calling this constructor directly.
class UnaryExpr extends GramExpression {
  final Unary op;
  final Gram gram;
  late final renderPlan;

  UnaryExpr(this.op, this.gram) {
    renderPlan = gram.renderPlan.byUnary(op);
  }

  String toString() =>
      op.symbol +
      (gram is QuadGram
          ? GramTable().getEnumIfQuad(gram)!.shortName +
              ' ' +
              gram.face.shortName.toLowerCase()
          : GramTable().getMonoEnum(gram).shortName);

  String get pronunciation =>
      gram.pronunciation + op.ending.shortName.toLowerCase();
}

/// BinaryExpr applies a Binary operation on a 2 expressions.
/// Private subclass, use respective factory methods in GramExpression instead.
class BinaryExpr extends GramExpression {
  final GramExpression expr1;
  final Binary op;
  final GramExpression expr2;
  late final renderPlan;

  BinaryExpr(this.expr1, this.op, this.expr2) {
    renderPlan = expr1.renderPlan.byBinary(op, expr2.renderPlan);
  }

  String toString() => "$expr1 ${op.symbol} $expr2";

  String get pronunciation =>
      expr1.pronunciation + op.ending.base + expr2.pronunciation;
}

class Cluster extends GramExpression {
  final Gram headGram;
  final Binary tailOp;
  final Gram tailGram;
  late final renderPlan;
  late final lines;

  Cluster(this.headGram, this.tailOp, this.tailGram) {
    renderPlan = headGram.renderPlan.byBinary(tailOp, tailGram.renderPlan);
  }

  String toString() => "($headGram ${tailOp.symbol} $tailGram)";

  @override
  String get pronunciation =>
      headGram.head.shortName +
      headGram.vowel.shortName.toLowerCase() +
      tailOp.ending.tail +
      tailGram.pronunciation;
}

class ExtendedCluster extends Cluster {
  final Binary headOp;
  final GramExpression innerExpr;
  late final renderPlan;
  late final lines;

  ExtendedCluster(headGram, this.headOp, this.innerExpr, tailOp, tailGram)
      : super(headGram, tailOp, tailGram) {
    final render1 = headGram.renderPlan.byBinary(headOp, innerExpr.renderPlan);
    renderPlan = render1.byBinary(tailOp, tailGram.renderPlan);
  }

  String toString() =>
      "($headGram ${headOp.symbol} $innerExpr ${tailOp.symbol} $tailGram)";

  @override
  String get pronunciation =>
      headGram.head.shortName +
      headGram.vowel.shortName.toLowerCase() +
      headOp.ending.base +
      innerExpr.pronunciation +
      tailOp.ending.tail +
      tailGram.pronunciation;
}

class CompoundWord extends Word {
  static const SEPARATOR_SYMBOL = ':';
  static const PRONUNCIATION_LINK = '-';

  final Iterable<GramExpression> exprs;
  late final Iterable<PolyLine> lines;
  late final RenderPlan renderPlan;

  CompoundWord(this.exprs) {
    if (exprs.length < 2)
      throw ArgumentError('Minimum words is 2; only ${exprs.length} given.');

    GramExpression? combo;
    for (final expr in exprs) {
      combo = (combo == null ? expr : combo.next(expr));
    }
    lines = combo!.lines;
    renderPlan = combo.renderPlan;
  }

  @override
  String toString() =>
      exprs.map((w) => w.toString()).join(" $SEPARATOR_SYMBOL ");

  @override
  String get pronunciation =>
      exprs.map((w) => w.pronunciation).join(PRONUNCIATION_LINK);
}
