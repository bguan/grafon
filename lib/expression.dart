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

import 'gram_infra.dart';
import 'gram_table.dart';
import 'operators.dart';
import 'phonetics.dart';

/// Classes and utils for Words and Expressions.

/// abstract base class for all Gram Expression.
abstract class GramExpression {
  String get pronunciation;

  /// Merge this expression with another.
  GramExpression merge(that) => _BinaryExpr(this, Binary.Merge, that);

  /// Put this expression before that, this to left, that to right.
  GramExpression before(that) => _BinaryExpr(this, Binary.Before, that);

  /// Put this expression over that, this above, that below.
  GramExpression over(that) => _BinaryExpr(this, Binary.Over, that);

  /// Put this expression around that, this outside, that inside.
  GramExpression around(that) => _BinaryExpr(this, Binary.Around, that);

  /// Combine this expression with that, not spatial, forming a compound word.
  GramExpression compound(that) => _BinaryExpr(this, Binary.Compound, that);
}

/// the simplest Gram Expression is just the Gram itself.
class SingleGram extends GramExpression {
  final Gram gram;

  SingleGram(this.gram);

  String toString() => gram is QuadGram
      ? GramTable.getEnumIfQuad(gram)!.shortName + '.' + gram.face.shortName
      : GramTable.getMonoEnum(gram).shortName;

  String get pronunciation =>
      (gram.consPair == ConsPair.AHA ? '' : gram.consPair.base.shortName) +
      (gram.consPair == ConsPair.AHA
          ? gram.vowel.shortName
          : gram.vowel.shortName.toLowerCase());

  /// Shrinks a single Gram by half maintaining its center position.
  GramExpression shrink() => _UnaryExpr(Unary.Shrink, this.gram);

  /// Shrinks a single Gram by half then move it to upper quadrant.
  GramExpression up() => _UnaryExpr(Unary.Up, this.gram);

  /// Shrinks a single Gram by half then move it to down quadrant.
  GramExpression down() => _UnaryExpr(Unary.Down, this.gram);

  /// Shrinks a single Gram by half then move it to left quadrant.
  GramExpression left() => _UnaryExpr(Unary.Left, this.gram);

  /// Shrinks a single Gram by half then move it to right quadrant.
  GramExpression right() => _UnaryExpr(Unary.Right, this.gram);
}

/// A Unary Gram Expression applies a Unary Operation on a single Gram.
/// Private subclass, use respective factory methods in SingleGram instead.
class _UnaryExpr extends SingleGram {
  final Unary op;

  _UnaryExpr(this.op, Gram gram) : super(gram);

  String toString() =>
      op.symbol +
      (gram is QuadGram
          ? GramTable.getEnumIfQuad(gram)!.shortName + '.' + gram.face.shortName
          : GramTable.getMonoEnum(gram).shortName);

  String get pronunciation =>
      super.pronunciation + op.ending.shortName.toLowerCase();
}

/// BinaryExpr applies a Binary operation on a 2 expressions.
/// Private subclass, use respective factory methods in GramExpression instead.
class _BinaryExpr extends GramExpression {
  final GramExpression expr1;
  final Binary op;
  final GramExpression expr2;

  _BinaryExpr(this.expr1, this.op, this.expr2);

  String toString() => "$expr1 ${op.symbol} $expr2";

  String get pronunciation =>
      expr1.pronunciation + op.ending.base + expr2.pronunciation;
}

class Cluster extends GramExpression {
  final SingleGram headGram;
  final Binary tailOp;
  final SingleGram tailGram;

  Cluster(this.headGram, this.tailOp, this.tailGram);

  String toString() => "($headGram ${tailOp.symbol} $tailGram)";

  @override
  String get pronunciation =>
      headGram.gram.head.shortName +
      headGram.gram.vowel.shortName.toLowerCase() +
      tailOp.ending.tail +
      tailGram.pronunciation;
}

class ExtendedCluster extends Cluster {
  final Binary headOp;
  final GramExpression innerExpr;

  ExtendedCluster(headGram, this.headOp, this.innerExpr, tailOp, tailGram)
      : super(headGram, tailOp, tailGram);

  String toString() =>
      "($headGram ${headOp.symbol} $innerExpr ${tailOp.symbol} $tailGram)";

  @override
  String get pronunciation =>
      headGram.gram.head.shortName +
      headGram.gram.vowel.shortName.toLowerCase() +
      headOp.ending.base +
      innerExpr.pronunciation +
      tailOp.ending.tail +
      tailGram.pronunciation;
}
