import 'package:vector_math/vector_math.dart';

import 'phonetics.dart';

enum BinaryEnding { F, SSh, MNg, LR }

extension BinaryEndingExtension on BinaryEnding {
  String get base {
    switch (this) {
      case BinaryEnding.F:
        return '';
      case BinaryEnding.SSh:
        return 's';
      case BinaryEnding.MNg:
        return 'm';
      case BinaryEnding.LR:
        return 'l';
      default:
        throw Exception("Unexpected BinaryEnding Enum ${this}");
    }
  }

  // use tail when it is the last operator in a cluster group
  String get tail {
    switch (this) {
      case BinaryEnding.F:
        return 'f';
      case BinaryEnding.SSh:
        return 'sh';
      case BinaryEnding.MNg:
        return 'ng';
      case BinaryEnding.LR:
        return 'r';
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
enum Binary { BEFORE, OVER, AROUND, MERGE }

extension BinaryExtension on Binary {
  BinaryEnding get ending {
    switch (this) {
      case Binary.BEFORE:
        return BinaryEnding.F;
      case Binary.OVER:
        return BinaryEnding.SSh;
      case Binary.AROUND:
        return BinaryEnding.MNg;
      case Binary.MERGE:
        return BinaryEnding.LR;
      default:
        throw Exception("Unexpected Binary Enum ${this}");
    }
  }

  Matrix3 get transform1 {
    switch (this) {
      case Binary.BEFORE:
        return TransformationHelper.noTransform;
      case Binary.OVER:
        return TransformationHelper.shrinkUp;
      case Binary.AROUND:
        return TransformationHelper.noTransform;
      case Binary.MERGE:
        return TransformationHelper.noTransform;
      default:
        throw Exception("Unexpected Binary Enum ${this}");
    }
  }

  Matrix3 get transform2 {
    switch (this) {
      case Binary.BEFORE:
        return TransformationHelper.stepRight;
      case Binary.OVER:
        return TransformationHelper.shrinkDown;
      case Binary.AROUND:
        return TransformationHelper.shrinkIn;
      case Binary.MERGE:
        return TransformationHelper.noTransform;
      default:
        throw Exception("Unexpected Binary Enum ${this}");
    }
  }
}

/// Unary Operator can only operate on Gra's
/// by supplying a transformation as well as ending vowel
enum Unary { RIGHT, UP, LEFT, DOWN }

extension UnaryExtension on Unary {
  Vowel get ending {
    switch (this) {
      case Unary.RIGHT:
        return Vowel.A;
      case Unary.UP:
        return Vowel.I;
      case Unary.LEFT:
        return Vowel.O;
      case Unary.DOWN:
        return Vowel.U;
      default:
        throw Exception("Unexpected Unary Enum ${this}");
    }
  }

  Matrix3 get transform {
    switch (this) {
      case Unary.RIGHT:
        return TransformationHelper.shrinkRight;
      case Unary.UP:
        return TransformationHelper.shrinkUp;
      case Unary.LEFT:
        return TransformationHelper.shrinkLeft;
      case Unary.DOWN:
        return TransformationHelper.shrinkDown;
      default:
        throw Exception("Unexpected Unary Enum ${this}");
    }
  }
}
