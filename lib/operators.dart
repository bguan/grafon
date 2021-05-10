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

/// Operators, unary and binary spatial combinations for the Grafon language.
library operators;

import 'gram_infra.dart';
import 'phonetics.dart';

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

  BinaryEnding get ending {
    switch (this) {
      case Binary.Merge:
        return BinaryEnding.RL;
      case Binary.Next:
        return BinaryEnding.H;
      case Binary.Over:
        return BinaryEnding.SZ;
      case Binary.Wrap:
        return BinaryEnding.NM;
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
}
