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
enum Binary { Next, Merge, Over, Wrap }

/// Extending Binary Enum to associate shortName, symbol and Coda
extension BinaryExtension on Binary {
  String get shortName => this.toString().split('.').last;

  String get symbol {
    switch (this) {
      case Binary.Over:
        return '/';
      case Binary.Wrap:
        return '@';
      case Binary.Merge:
        return '*';
      case Binary.Next:
      default:
        return '.';
    }
  }

  Coda get coda {
    switch (this) {
      case Binary.Merge:
        return Coda.th;
      case Binary.Over:
        return Coda.ch;
      case Binary.Wrap:
        return Coda.ng;
      case Binary.Next:
        return Coda.sh;
      default:
        return Coda.NIL;
    }
  }
}

/// Unary Operators can only operate on base Grams by transformation
enum Unary { Shrink, Right, Up, Left, Down }

/// Extending Binary Enum to associate shortName, symbol and vowel extension
extension UnaryExtension on Unary {
  String get shortName => this.toString().split('.').last;

  String get symbol {
    switch (this) {
      case Unary.Right:
        return '>';
      case Unary.Up:
        return '˄';
      case Unary.Left:
        return '<';
      case Unary.Down:
        return '˅';
      case Unary.Shrink:
      default:
        return '~';
    }
  }

  Vowel get extn {
    switch (this) {
      case Unary.Right:
        return Face.Right.vowel;
      case Unary.Up:
        return Face.Up.vowel;
      case Unary.Left:
        return Face.Left.vowel;
      case Unary.Down:
        return Face.Down.vowel;
      case Unary.Shrink:
      default:
        return Face.Center.vowel;
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

  /// Merge this expression with m.
  BinaryOpExpr merge(GrafonExpr g) => BinaryOpExpr(this, Binary.Merge, g);

  /// Put this expression before e, this to left, e to right.
  BinaryOpExpr next(GrafonExpr g) => BinaryOpExpr(this, Binary.Next, g);

  /// Put this expression over e, this above, e below.
  BinaryOpExpr over(GrafonExpr g) => BinaryOpExpr(this, Binary.Over, g);

  /// Put this expression around e, this outside, e inside.
  BinaryOpExpr wrap(GrafonExpr g) => BinaryOpExpr(this, Binary.Wrap, g);
}

/// abstract base class for single gram expression i.e. base gram & unary expr
abstract class SingleGramExpr extends GrafonExpr {
  Gram get gram;

  Syllable get syllable;

  @override
  int get hashCode => gram.hashCode ^ syllable.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! SingleGramExpr) return false;
    SingleGramExpr that = other;
    return gram == that.gram && syllable == that.syllable;
  }
}

/// A Unary Gram Expression applies a Unary Operation on a single Gram.
/// Factory methods exists in Gram instead of calling constructor directly.
class UnaryOpExpr extends SingleGramExpr {
  final Unary op;
  final Gram gram;
  late final renderPlan;

  UnaryOpExpr(this.op, this.gram) {
    renderPlan = gram.renderPlan.byUnary(op);
  }

  @override
  String toString() =>
      op.symbol +
      (gram is QuadGram
          ? gram.face.shortName +
              '_' +
              GramTable().getEnumIfQuad(gram)!.shortName
          : GramTable().getMonoEnum(gram).shortName);

  @override
  Syllable get syllable => gram.syllable.diffExtension(op.extn);

  @override
  Pronunciation get pronunciation => Pronunciation([syllable]);

  @override
  List<Gram> get grams => [gram];
}

/// abstract base class for multi gram expr i.e. binary and cluster
abstract class MultiGramExpr extends GrafonExpr {}

/// BinaryExpr applies a Binary operation on a 2 expressions.
/// Private subclass, use respective factory methods in GramExpression instead.
class BinaryOpExpr extends MultiGramExpr {
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
class ClusterExpr extends MultiGramExpr {
  final GrafonExpr subExpr;
  late final renderPlan;
  late final headGram;
  late final tailOp;
  late final pronunciation;

  ClusterExpr(this.subExpr) {
    renderPlan = subExpr.renderPlan;
    final sList = subExpr.pronunciation.syllables;
    pronunciation = Pronunciation([
      Mono.Empty.gram.syllable.diffCoda(Binary.Merge.coda),
      ...sList.take(sList.length - 1),
      sList.last.diffCoda(Binary.Merge.coda),
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
