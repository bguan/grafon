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

import 'package:tuple/tuple.dart';
import 'package:vector_math/vector_math.dart';

import 'gram_infra.dart';
import 'phonetics.dart';

/// Operators, unary and binary spatial combinations for the Grafon language.

/// enum for ending consonant pair for preceding gram in a binary operation.
enum BinaryEnding { Ng, H, LR, MN, SZ }

/// extension to map base, tail ending consonant to enum, short name.
extension BinaryEndingExtension on BinaryEnding {
  String get shortName => this.toString().split('.').last;

  String get base {
    switch (this) {
      case BinaryEnding.H:
        return '';
      case BinaryEnding.LR:
        return 'l';
      case BinaryEnding.MN:
        return 'm';
      case BinaryEnding.SZ:
        return 's';
      case BinaryEnding.Ng:
        return 'ng';
      default:
        throw Exception("Unexpected BinaryEnding Enum ${this}");
    }
  }

  // use tail when it is the last operator in a cluster group
  String get tail {
    switch (this) {
      case BinaryEnding.H:
        return 'h';
      case BinaryEnding.LR:
        return 'r';
      case BinaryEnding.MN:
        return 'n';
      case BinaryEnding.SZ:
        return 'z';
      case BinaryEnding.Ng:
        return '';
      default:
        throw Exception("Unexpected BinaryEnding Enum ${this}");
    }
  }
}

/// TransformationHelper to make sure only 1 instance of needed
/// transformation matrix instance is created.
class TransformationHelper {
  /// https://en.wikipedia.org/wiki/Affine_transformation#Image_transformation
  static final Matrix3 xShrink = Matrix3(.5, 0, 0, 0, 1, 0, 0, 0, 1);
  static final Matrix3 yShrink = Matrix3(1, 0, 0, 0, .5, 0, 0, 0, 1);
  static final Matrix3 shrinkIn = Matrix3(.7, 0, 0, 0, .7, 0, 0, 0, 1);
  static final Matrix3 rightShift = Matrix3(1, 0, .25, 0, 1, 0, 0, 0, 1);
  static final Matrix3 leftShift = Matrix3(1, 0, -.25, 0, 1, 0, 0, 0, 1);
  static final Matrix3 upShift = Matrix3(1, 0, 0, 0, 1, .25, 0, 0, 1);
  static final Matrix3 downShift = Matrix3(1, 0, 0, 0, 1, -.25, 0, 0, 1);

  /// Take Big Step to the Right, only for Binary
  static final Matrix3 stepRight = Matrix3(1, 0, 1, 0, 1, 0, 0, 0, 1);

  static final noTransform = Matrix3.identity();
  static final shrinkCenter = xShrink.multiplied(yShrink);
  static final shrinkRight = xShrink.multiplied(rightShift);
  static final shrinkUp = yShrink.multiplied(upShift);
  static final shrinkLeft = xShrink.multiplied(leftShift);
  static final shrinkDown = yShrink.multiplied(downShift);
}

/// Binary Operator works on a pair of Gram Expression
enum Binary { Merge, Before, Over, Around, Compound }

extension BinaryExtension on Binary {
  String get shortName => this.toString().split('.').last;

  String get symbol {
    switch (this) {
      case Binary.Before:
        return '|';
      case Binary.Over:
        return '/';
      case Binary.Around:
        return '@';
      case Binary.Merge:
        return '*';
      case Binary.Compound:
        return ':';
      default:
        throw Exception("Unexpected Binary Enum ${this}");
    }
  }

  BinaryEnding get ending {
    switch (this) {
      case Binary.Before:
        return BinaryEnding.H;
      case Binary.Over:
        return BinaryEnding.SZ;
      case Binary.Around:
        return BinaryEnding.MN;
      case Binary.Merge:
        return BinaryEnding.LR;
      case Binary.Compound:
        return BinaryEnding.Ng;
      default:
        throw Exception("Unexpected Binary Enum ${this}");
    }
  }

  Tuple2<Matrix3, Matrix3> get transforms {
    switch (this) {
      case Binary.Before:
        return Tuple2(
            TransformationHelper.shrinkLeft, TransformationHelper.shrinkRight);
      case Binary.Over:
        return Tuple2(
            TransformationHelper.shrinkUp, TransformationHelper.shrinkDown);
      case Binary.Around:
        return Tuple2(
            TransformationHelper.noTransform, TransformationHelper.shrinkIn);
      case Binary.Merge:
        return Tuple2(
            TransformationHelper.noTransform, TransformationHelper.noTransform);
      case Binary.Compound:
        return Tuple2(
            TransformationHelper.noTransform, TransformationHelper.stepRight);
      default:
        throw Exception("Unexpected Binary Enum ${this}");
    }
  }
}

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

  Matrix3 get transform {
    switch (this) {
      case Unary.Shrink:
        return TransformationHelper.shrinkCenter;
      case Unary.Right:
        return TransformationHelper.shrinkRight;
      case Unary.Up:
        return TransformationHelper.shrinkUp;
      case Unary.Left:
        return TransformationHelper.shrinkLeft;
      case Unary.Down:
        return TransformationHelper.shrinkDown;
      default:
        throw Exception("Unexpected Unary Enum ${this}");
    }
  }
}
