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

/// Unary Operator can only operate on Gram's
/// by supplying a transformation as well as ending vowel
enum Unary { Shrink, Right, Up, Left, Down }

extension UnaryExtension on Unary {
  String get shortName => this.toString().split('.').last;

  String get symbol {
    switch (this) {
      case Unary.Shrink:
        return '~';
      case Unary.Right:
        return '>';
      case Unary.Up:
        return '+';
      case Unary.Left:
        return '<';
      case Unary.Down:
        return '-';
      default:
        throw Exception("Unexpected Unary Enum ${this}");
    }
  }

  Vowel get ending {
    switch (this) {
      case Unary.Shrink:
        return Face.Center.vowel;
      case Unary.Right:
        return Face.Right.vowel;
      case Unary.Up:
        return Face.Up.vowel;
      case Unary.Left:
        return Face.Left.vowel;
      case Unary.Down:
        return Face.Down.vowel;
      default:
        throw Exception("Unexpected Unary Enum ${this}");
    }
  }
}

/// Binary Operator works on a pair of Gram Expression
enum Binary { Merge, Next, Over, Wrap }

extension BinaryExtension on Binary {
  String get shortName => this.toString().split('.').last;

  String get symbol {
    switch (this) {
      case Binary.Next:
        return '.';
      case Binary.Over:
        return '/';
      case Binary.Wrap:
        return '@';
      case Binary.Merge:
        return '*';
      default:
        throw Exception("Unexpected Binary Enum ${this}");
    }
  }

  CodaGroup get coda {
    switch (this) {
      case Binary.Merge:
        return CodaGroup.kgt;
      case Binary.Next:
        return CodaGroup.hthdh;
      case Binary.Over:
        return CodaGroup.szf;
      case Binary.Wrap:
        return CodaGroup.nmp;
      default:
        throw Exception("Unexpected Binary Enum ${this}");
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
  Iterable<Gram> get grams;

  /// Merge this expression with a single.
  BinaryOpExpr merge(SingleGramExpr single) =>
      BinaryOpExpr(this, Binary.Merge, single);

  /// Put this expression before a single, this to left, the single to right.
  BinaryOpExpr next(SingleGramExpr single) =>
      BinaryOpExpr(this, Binary.Next, single);

  /// Put this expression over a single, this above, the single below.
  BinaryOpExpr over(SingleGramExpr single) =>
      BinaryOpExpr(this, Binary.Over, single);

  /// Put this expression around a single, this outside, the single inside.
  BinaryOpExpr wrap(SingleGramExpr single) =>
      BinaryOpExpr(this, Binary.Wrap, single);

  /// Merge this expression with a ClusterExpression.
  BinaryOpExpr mergeCluster(BinaryOpExpr expr) =>
      BinaryOpExpr(this, Binary.Merge, ClusterExpr(expr));

  /// Put this expression before a cluster, this to left, the cluster to right.
  BinaryOpExpr nextCluster(BinaryOpExpr expr) =>
      BinaryOpExpr(this, Binary.Next, ClusterExpr(expr));

  /// Put this expression over that, this above, the cluster below.
  BinaryOpExpr overCluster(BinaryOpExpr expr) =>
      BinaryOpExpr(this, Binary.Over, ClusterExpr(expr));

  /// Put this expression around that, this outside, the cluster inside.
  BinaryOpExpr wrapCluster(BinaryOpExpr expr) =>
      BinaryOpExpr(this, Binary.Wrap, ClusterExpr(expr));
}

abstract class SingleGramExpr extends GrafonExpr {
  Gram get gram;

  Syllable get syllable;
}

abstract class MultiGramExpr extends GrafonExpr {}

/// A Unary Gram Expression applies a Unary Operation on a single Gram.
/// Use factory methods in Gram instead of calling this constructor directly.
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
  Syllable get syllable => gram.syllable.diffEndVowel(op.ending);

  @override
  Pronunciation get pronunciation => Pronunciation([syllable]);

  @override
  Iterable<Gram> get grams => [gram];
}

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
      p1[p1.length - 1].diffCoda(op.coda.base),
      ...expr2.pronunciation.syllables,
    ]);
  }

  @override
  Iterable<Gram> get grams => [...expr1.grams, ...expr2.grams];

  ClusterExpr toClusterExpression() => ClusterExpr(this);
}

/// Cluster Expression binds 2 grams with a binary operator into a single group.
/// Applying special pronunciation to the head gram and the tail op.
class ClusterExpr extends MultiGramExpr {
  final BinaryOpExpr binaryExpr;
  late final renderPlan;
  late final headGram;
  late final tailOp;

  ClusterExpr(this.binaryExpr) {
    renderPlan = binaryExpr.renderPlan;
  }

  @override
  String toString() => "(${binaryExpr.toString()})";

  @override
  Pronunciation get pronunciation {
    final sList = binaryExpr.pronunciation.voicing;
    return Pronunciation([
      for (var i = 0; i < sList.length; i++)
        if (i == 0 && i == sList.length - 2) // first is also second last
          Syllable(
            sList[i].cons.pair.head,
            sList[i].vowel,
            sList[i].endVowel,
            sList[i].coda.group.tail,
          )
        else if (i == 0) // Swap 1st syllable to head form
          sList[i].diffConsonant(sList[i].cons.pair.head)
        else if (i == sList.length - 2) // Swap 2nd last syllable to tail form
          sList[i].diffCoda(sList[i].coda.group.tail)
        else // other syllable are untouched
          sList[i],
    ]);
  }

  @override
  Iterable<Gram> get grams => binaryExpr.grams;
}
