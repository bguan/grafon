import 'package:tuple/tuple.dart';
import 'package:vector_math/vector_math.dart';

import 'atom_infra.dart';
import 'phonetics.dart';

enum BinaryEnding { H, DT, MN, SSh, Ng }

extension BinaryEndingExtension on BinaryEnding {
  String get shortName => this.toString().split('.').last;

  String get base {
    switch (this) {
      case BinaryEnding.H:
        return '';
      case BinaryEnding.DT:
        return 'd';
      case BinaryEnding.MN:
        return 'm';
      case BinaryEnding.SSh:
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
      case BinaryEnding.DT:
        return 't';
      case BinaryEnding.MN:
        return 'n';
      case BinaryEnding.SSh:
        return 'sh';
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
  static final shrinkRight = xShrink.multiplied(rightShift);
  static final shrinkUp = yShrink.multiplied(upShift);
  static final shrinkLeft = xShrink.multiplied(leftShift);
  static final shrinkDown = yShrink.multiplied(downShift);
}

/// Binary Operator works on a pair of Gra Expression
enum Binary { Before, Over, Around, Merge, Combo }

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
        return '~';
      case Binary.Combo:
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
        return BinaryEnding.DT;
      case Binary.Around:
        return BinaryEnding.MN;
      case Binary.Merge:
        return BinaryEnding.SSh;
      case Binary.Combo:
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
      case Binary.Combo:
        return Tuple2(
            TransformationHelper.noTransform, TransformationHelper.stepRight);
      default:
        throw Exception("Unexpected Binary Enum ${this}");
    }
  }
}

/// Unary Operator can only operate on Gra's
/// by supplying a transformation as well as ending vowel
enum Unary { ShrinkRight, ShrinkUp, ShrinkLeft, ShrinkDown }

extension UnaryExtension on Unary {
  String get shortName => this.toString().split('.').last;

  Vowel get ending {
    switch (this) {
      case Unary.ShrinkRight:
        return Face.Right.vowel;
      case Unary.ShrinkUp:
        return Face.Up.vowel;
      case Unary.ShrinkLeft:
        return Face.Left.vowel;
      case Unary.ShrinkDown:
        return Face.Down.vowel;
      default:
        throw Exception("Unexpected Unary Enum ${this}");
    }
  }

  Matrix3 get transform {
    switch (this) {
      case Unary.ShrinkRight:
        return TransformationHelper.shrinkRight;
      case Unary.ShrinkUp:
        return TransformationHelper.shrinkUp;
      case Unary.ShrinkLeft:
        return TransformationHelper.shrinkLeft;
      case Unary.ShrinkDown:
        return TransformationHelper.shrinkDown;
      default:
        throw Exception("Unexpected Unary Enum ${this}");
    }
  }
}
