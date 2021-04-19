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

import 'package:vector_math/vector_math.dart';

import 'gram_infra.dart';
import 'gram_table.dart';
import 'operators.dart';
import 'phonetics.dart';

/// Classes and utils for Words and Expressions.

/// abstract base class for all Gram Expression.
abstract class GramExpression {
  String get pronunciation;

  /// Merge this expression with another.
  GramExpression merge(that) => BinaryExpr(this, Binary.Merge, that);

  /// Put this expression before that, this to left, that to right.
  GramExpression before(that) => BinaryExpr(this, Binary.Before, that);

  /// Put this expression over that, this above, that below.
  GramExpression over(that) => BinaryExpr(this, Binary.Over, that);

  /// Put this expression around that, this outside, that inside.
  GramExpression around(that) => BinaryExpr(this, Binary.Around, that);

  /// Combine this expression with that, not spatial, forming a compound word.
  GramExpression compound(that) => BinaryExpr(this, Binary.Compound, that);

  Vector2 get visualCenter;

  Iterable<PolyPath> get paths;
}

/// A Unary Gram Expression applies a Unary Operation on a single Gram.
/// Private subclass, use respective factory methods in SingleGram instead.
class UnaryExpr extends GramExpression {
  final Unary op;
  final Gram gram;

  UnaryExpr(this.op, this.gram);

  String toString() =>
      op.symbol +
      (gram is QuadGram
          ? GramTable.getEnumIfQuad(gram)!.shortName +
              ' ' +
              gram.face.shortName.toLowerCase()
          : GramTable.getMonoEnum(gram).shortName);

  String get pronunciation =>
      gram.pronunciation + op.ending.shortName.toLowerCase();

  @override
  Vector2 get visualCenter {
    final gc = gram.visualCenter;
    final v3 = op.matrix * Vector3(gc.x, gc.y, 1);
    return Vector2(v3[0], v3[1]);
  }

  @override
  Iterable<PolyPath> get paths {
    return gram.paths.map((p) => op.transform(p));
  }
}

/// BinaryExpr applies a Binary operation on a 2 expressions.
/// Private subclass, use respective factory methods in GramExpression instead.
class BinaryExpr extends GramExpression {
  final GramExpression expr1;
  final Binary op;
  final GramExpression expr2;

  BinaryExpr(this.expr1, this.op, this.expr2);

  String toString() => "$expr1 ${op.symbol} $expr2";

  String get pronunciation =>
      expr1.pronunciation + op.ending.base + expr2.pronunciation;

  @override
  Vector2 get visualCenter {
    Vector2 c1 = expr1.visualCenter;
    Vector3 v1 = op.matrices.item1 * Vector3(c1.x, c1.y, 1);
    Vector2 c2 = expr2.visualCenter;
    Vector3 v2 = op.matrices.item2 * Vector3(c2.x, c2.y, 1);
    Vector3 avg = (v1 + v2) / 2.0;
    return avg.xy;
  }

  @override
  Iterable<PolyPath> get paths {
    final newPaths1 = expr1.paths.map(op.transform1);
    final newPaths2 = expr2.paths.map(op.transform2);
    return [...newPaths1, ...newPaths2];
  }
}

class Cluster extends GramExpression {
  final Gram headGram;
  final Binary tailOp;
  final Gram tailGram;

  Cluster(this.headGram, this.tailOp, this.tailGram);

  String toString() => "($headGram ${tailOp.symbol} $tailGram)";

  @override
  String get pronunciation =>
      headGram.head.shortName +
      headGram.vowel.shortName.toLowerCase() +
      tailOp.ending.tail +
      tailGram.pronunciation;

  @override
  Vector2 get visualCenter {
    Vector2 c1 = headGram.visualCenter;
    Vector3 v1 = tailOp.matrices.item1 * Vector3(c1.x, c1.y, 1);
    Vector2 c2 = tailGram.visualCenter;
    Vector3 v2 = tailOp.matrices.item2 * Vector3(c2.x, c2.y, 1);
    Vector3 avg = (v1 + v2) / 2.0;
    return avg.xy;
  }

  @override
  Iterable<PolyPath> get paths {
    final newPaths1 = headGram.paths.map(tailOp.transform1);
    final newPaths2 = tailGram.paths.map(tailOp.transform2);
    return [...newPaths1, ...newPaths2];
  }
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
      headGram.head.shortName +
      headGram.vowel.shortName.toLowerCase() +
      headOp.ending.base +
      innerExpr.pronunciation +
      tailOp.ending.tail +
      tailGram.pronunciation;

  @override
  Vector2 get visualCenter {
    Vector2 c1 = headGram.visualCenter;
    Vector3 v1 = headOp.matrices.item1 * Vector3(c1.x, c1.y, 1);
    Vector2 c2 = innerExpr.visualCenter;
    Vector3 v2 = headOp.matrices.item2 * Vector3(c2.x, c2.y, 1);
    Vector3 avg12 = (v1 + v2) / 2.0;
    Vector3 v12 = tailOp.matrices.item1 * avg12;
    Vector2 c3 = tailGram.visualCenter;
    Vector3 v3 = tailOp.matrices.item2 * Vector3(c3.x, c3.y, 1);
    Vector3 avg123 = (v12 + v3) / 2.0;
    return avg123.xy;
  }

  @override
  Iterable<PolyPath> get paths {
    final newPaths1 = headGram.paths.map(headOp.transform1);
    final newPaths2 = innerExpr.paths.map(headOp.transform2);
    final newPaths3 = [...newPaths1, ...newPaths2].map(tailOp.transform1);
    final newPaths4 = tailGram.paths.map(tailOp.transform2);
    return [...newPaths3, ...newPaths4];
  }
}
