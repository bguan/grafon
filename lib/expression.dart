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
import 'phonetics.dart';
import 'render_plan.dart';

/// Unary Operator can only operate on Gra's
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
        return '|';
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

  EndConsPair get ending {
    switch (this) {
      case Binary.Merge:
        return EndConsPair.RL;
      case Binary.Next:
        return EndConsPair.H;
      case Binary.Over:
        return EndConsPair.SZ;
      case Binary.Wrap:
        return EndConsPair.NM;
      default:
        throw Exception("Unexpected Binary Enum ${this}");
    }
  }
}

/// abstract base class for all Gram Expression.
abstract class GramExpression {
  Iterable<Syllable> get pronunciation;

  RenderPlan get renderPlan;

  Iterable<PolyLine> get lines => renderPlan.lines;

  Vector2 get center => renderPlan.center;

  double get width => renderPlan.width;

  double get height => renderPlan.height;

  /// get all grams in expression
  Iterable<Gram> get grams;

  double flexRenderWidth(double devHeight) =>
      renderPlan.flexRenderWidth(devHeight);

  /// Merge this expression with a single.
  BinaryOpExpr merge(SingleGramExpression single) =>
      BinaryOpExpr(this, Binary.Merge, single);

  /// Put this expression before a single, this to left, the single to right.
  BinaryOpExpr next(SingleGramExpression single) =>
      BinaryOpExpr(this, Binary.Next, single);

  /// Put this expression over a single, this above, the single below.
  BinaryOpExpr over(SingleGramExpression single) =>
      BinaryOpExpr(this, Binary.Over, single);

  /// Put this expression around a single, this outside, the single inside.
  BinaryOpExpr wrap(SingleGramExpression single) =>
      BinaryOpExpr(this, Binary.Wrap, single);

  /// Merge this expression with a ClusterExpression.
  BinaryOpExpr mergeCluster(BinaryOpExpr expr) =>
      BinaryOpExpr(this, Binary.Merge, ClusterExpression(expr));

  /// Put this expression before a cluster, this to left, the cluster to right.
  BinaryOpExpr nextCluster(BinaryOpExpr expr) =>
      BinaryOpExpr(this, Binary.Next, ClusterExpression(expr));

  /// Put this expression over that, this above, the cluster below.
  BinaryOpExpr overCluster(BinaryOpExpr expr) =>
      BinaryOpExpr(this, Binary.Over, ClusterExpression(expr));

  /// Put this expression around that, this outside, the cluster inside.
  BinaryOpExpr wrapCluster(BinaryOpExpr expr) =>
      BinaryOpExpr(this, Binary.Wrap, ClusterExpression(expr));
}

abstract class SingleGramExpression extends GramExpression {
  Gram get gram;
}

abstract class MultiGramExpression extends GramExpression {}

/// A Unary Gram Expression applies a Unary Operation on a single Gram.
/// Use factory methods in Gram instead of calling this constructor directly.
class UnaryOpExpr extends SingleGramExpression {
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
          ? GramTable().getEnumIfQuad(gram)!.shortName +
              ' ' +
              gram.face.shortName.toLowerCase()
          : GramTable().getMonoEnum(gram).shortName);

  @override
  Iterable<Syllable> get pronunciation {
    final syllable = gram.pronunciation.first;
    return [syllable.diffSecondVowel(op.ending)];
  }

  @override
  Iterable<Gram> get grams => [gram];
}

/// BinaryExpr applies a Binary operation on a 2 expressions.
/// Private subclass, use respective factory methods in GramExpression instead.
class BinaryOpExpr extends MultiGramExpression {
  final GramExpression expr1;
  final Binary op;
  final GramExpression expr2;
  late final renderPlan;

  BinaryOpExpr(this.expr1, this.op, this.expr2) {
    renderPlan = expr1.renderPlan.byBinary(op, expr2.renderPlan);
  }

  @override
  String toString() => "$expr1 ${op.symbol} $expr2";

  @override
  Iterable<Syllable> get pronunciation {
    final p1 = expr1.pronunciation;
    final last = p1.last;
    final p1new = p1.map((s) => s != last ? s : last.diffEnd(op.ending.base));
    return [
      ...p1new,
      ...expr2.pronunciation,
    ];
  }

  @override
  Iterable<Gram> get grams => [...expr1.grams, ...expr2.grams];

  ClusterExpression toClusterExpression() => ClusterExpression(this);
}

/// Cluster Expression binds 2 grams with a binary operator into a single group.
/// Applying special pronunciation to the head gram and the tail op.
class ClusterExpression extends MultiGramExpression {
  final BinaryOpExpr binaryExpr;
  late final renderPlan;
  late final headGram;
  late final tailOp;

  ClusterExpression(this.binaryExpr) {
    renderPlan = binaryExpr.renderPlan;
  }

  @override
  String toString() => "(${binaryExpr.toString()})";

  @override
  Iterable<Syllable> get pronunciation {
    final p = binaryExpr.pronunciation.toList();
    final len = p.length;
    return [
      for (var i = 0; i < len; i++)
        if (i == 0 && i == len - 2) // first is also second last
          Syllable(
            p[i].consonant.pair.head,
            p[i].vowel,
            p[i].endVowel,
            p[i].endConsonant.pair.tail,
          )
        else if (i == 0) // Swap first syllable to head form
          p[i].diffConsonant(p[i].consonant.pair.head)
        else if (i == len - 2) // Swap second last syllable to tail form
          p[i].diffEnd(p[i].endConsonant.pair.tail)
        else // other syllable are untouched
          p[i],
    ];
  }

  @override
  Iterable<Gram> get grams => binaryExpr.grams;
}

/// Compound Words combines words into another word.
class CompoundWord extends GramExpression {
  static const SEPARATOR_SYMBOL = ':';
  static const PRONUNCIATION_LINK = EndConsonant.ng;

  final Iterable<GramExpression> words;
  late final RenderPlan renderPlan;

  CompoundWord(this.words) {
    if (words.length < 2)
      throw ArgumentError('Minimum words is 2; only ${words.length} given.');

    RenderPlan? render;
    for (var w in words) {
      if (render == null) {
        render = w.renderPlan;
        continue;
      }
      render = render.byBinary(Binary.Next, w.renderPlan);
    }
    renderPlan = render!;
  }

  @override
  String toString() =>
      words.map((w) => w.toString()).join(" $SEPARATOR_SYMBOL ");

  @override
  Iterable<Syllable> get pronunciation {
    List<Syllable> syllables = [];
    for (var w in words.take(words.length - 1)) {
      final wp = w.pronunciation;
      syllables.addAll(wp.take(wp.length - 1));
      final last = wp.last;
      syllables.add(
          Syllable(last.consonant, last.vowel, last.endVowel, EndConsonant.ng));
    }
    syllables.addAll(words.last.pronunciation);
    return syllables;
  }

  @override
  Iterable<Gram> get grams =>
      words.fold([], (Iterable<Gram> grams, expr) => [...grams, ...expr.grams]);
}
