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

/// Logic and utils for Phonetics related concepts for the Grafon language.
library phonetics;

import 'package:collection/collection.dart';
import 'package:enum_to_string/enum_to_string.dart';

/// Basic vowels for the language. Can be combined into diphthong.
enum Vowel { NIL, a, e, i, o, u, wa, we, wi, wo, wu, ay, ey, iy, oy, uy }

/// Extending Vowel to tie to phoneme and approximate voicing
extension VowelHelper on Vowel {
  bool get isBase =>
      this == Vowel.a ||
      this == Vowel.e ||
      this == Vowel.i ||
      this == Vowel.o ||
      this == Vowel.u;

  bool get isHead =>
      this == Vowel.wa ||
      this == Vowel.we ||
      this == Vowel.wi ||
      this == Vowel.wo ||
      this == Vowel.wu;

  bool get isTail =>
      this == Vowel.ay ||
      this == Vowel.ey ||
      this == Vowel.iy ||
      this == Vowel.oy ||
      this == Vowel.uy;

  Vowel get baseForm {
    switch (this) {
      case Vowel.a:
      case Vowel.wa:
      case Vowel.ay:
        return Vowel.a;
      case Vowel.e:
      case Vowel.we:
      case Vowel.ey:
        return Vowel.e;
      case Vowel.i:
      case Vowel.wi:
      case Vowel.iy:
        return Vowel.i;
      case Vowel.o:
      case Vowel.wo:
      case Vowel.oy:
        return Vowel.o;
      case Vowel.u:
      case Vowel.wu:
      case Vowel.uy:
        return Vowel.u;
      default:
        return Vowel.NIL;
    }
  }

  Vowel get headForm {
    switch (this) {
      case Vowel.a:
      case Vowel.wa:
      case Vowel.ay:
        return Vowel.wa;
      case Vowel.e:
      case Vowel.we:
      case Vowel.ey:
        return Vowel.we;
      case Vowel.i:
      case Vowel.wi:
      case Vowel.iy:
        return Vowel.wi;
      case Vowel.o:
      case Vowel.wo:
      case Vowel.oy:
        return Vowel.wo;
      case Vowel.u:
      case Vowel.wu:
      case Vowel.uy:
        return Vowel.wu;
      default:
        return Vowel.NIL;
    }
  }

  Vowel get tailForm {
    switch (this) {
      case Vowel.a:
      case Vowel.wa:
      case Vowel.ay:
        return Vowel.ay;
      case Vowel.e:
      case Vowel.we:
      case Vowel.ey:
        return Vowel.ey;
      case Vowel.i:
      case Vowel.wi:
      case Vowel.iy:
        return Vowel.iy;
      case Vowel.o:
      case Vowel.wo:
      case Vowel.oy:
        return Vowel.oy;
      case Vowel.u:
      case Vowel.wu:
      case Vowel.uy:
        return Vowel.uy;
      default:
        return Vowel.NIL;
    }
  }

  String get shortName =>
      this == Vowel.NIL ? '' : EnumToString.convertToString(this);

  /// IPA phoneme
  String get phoneme {
    switch (this) {
      case Vowel.a:
        return 'ɑː';
      case Vowel.wa:
        return 'wɑː';
      case Vowel.ay:
        return 'ɑːj';
      case Vowel.e:
        return 'ɜː';
      case Vowel.we:
        return 'wɜː';
      case Vowel.ey:
        return 'ɜːj';
      case Vowel.i:
        return 'iː';
      case Vowel.wi:
        return 'wi:';
      case Vowel.iy:
        return 'iːj';
      case Vowel.o:
        return 'ɔː';
      case Vowel.wo:
        return 'wɔː';
      case Vowel.oy:
        return 'ɔːj';
      case Vowel.u:
        return 'uː';
      case Vowel.wu:
        return 'wuː';
      case Vowel.uy:
        return 'uːj';
      case Vowel.NIL:
        return '';
      default:
        return shortName;
    }
  }
}

/// Consonants at the beginning of a syllable.
enum Cons { NIL, h, b, p, d, t, v, f, g, k, r, l, n, m, z, s }

/// Extension to map Consonant to short name and phoneme
extension ConsonantHelper on Cons {
  String get shortName =>
      this == Cons.NIL ? '' : EnumToString.convertToString(this);

  /// IPA Phoneme
  String get phoneme {
    switch (this) {
      case Cons.r:
        return 'ɹ';
      case Cons.NIL:
        return '';
      default:
        return shortName;
    }
  }
}

/// Coda is the ending consonant at the end of a syllable
enum Coda { NIL, ch, sh, ng }

/// Helper to map coda to get short name and phoneme
extension CodaHelper on Coda {
  String get shortName =>
      this == Coda.NIL ? '' : EnumToString.convertToString(this);

  /// IPA Phoneme
  String get phoneme {
    switch (this) {
      case Coda.NIL:
        return '';
      case Coda.ch:
        return 'ʧ';
      case Coda.sh:
        return 'ʃ';
      case Coda.ng:
        return 'ŋ';
      default:
        return this.shortName;
    }
  }

  /// approximate intended voicing for english speakers
  String get approxVoice => shortName;
}

/// Class to handle Syllable and its manipulation
class Syllable {
  static const int CONS_MILLIS = 100;
  static const int VOWEL_MILLIS = 200;
  static const int EXT_MILLIS = 150;
  static const int CODA_MILLIS = 150;
  static const SILENCE = const Syllable(Cons.NIL, Vowel.NIL);
  final Cons cons;
  final Vowel vowel;
  final Coda coda;

  const Syllable(this.cons, this.vowel, [this.coda = Coda.NIL]);

  Syllable.v(this.vowel)
      : cons = Cons.NIL,
        coda = Coda.NIL;

  Syllable.vc(this.vowel, this.coda) : cons = Cons.NIL;

  Syllable.vvc(this.vowel, this.coda) : cons = Cons.NIL;

  @override
  bool operator ==(Object other) {
    if (other is! Syllable) return false;

    Syllable that = other;

    return this.cons == that.cons &&
        this.vowel == that.vowel &&
        this.coda == that.coda;
  }

  @override
  int get hashCode => cons.hashCode ^ vowel.hashCode ^ coda.hashCode;

  @override
  String toString() => [
        cons.shortName,
        vowel.shortName,
        coda.shortName,
      ].join();

  bool get isSilence => vowel == Vowel.NIL;

  String get shortName => toString();

  String get pronunciation => [
        cons.phoneme,
        vowel.phoneme,
        coda.phoneme,
      ].join();

  int get durationMillis =>
      (cons != Cons.NIL ? CONS_MILLIS : 0) +
      VOWEL_MILLIS +
      (coda != Coda.NIL ? CODA_MILLIS : 0);

  /// make a syllable based on another with a different consonant
  Syllable diffConsonant(Cons c) => Syllable(c, vowel, coda);

  /// make a syllable based on another with a different vowel
  Syllable diffVowel(Vowel v) => Syllable(cons, v, coda);

  /// make a syllable based on vowel in its head form
  Syllable headVowel() => Syllable(cons, vowel.headForm, coda);

  /// make a syllable based on vowel in its tail form
  Syllable tailVowel() => Syllable(cons, vowel.tailForm, coda);

  /// make a syllable based on another with a different vowel extension
  Syllable diffExtension(Vowel e) => Syllable(cons, vowel, coda);

  /// make a syllable based on another with a different end consonant
  Syllable diffCoda(Coda c) => Syllable(cons, vowel, c);

  String get lastPhoneme => (coda != Coda.NIL) ? coda.phoneme : vowel.phoneme;

  String get firstPhoneme => (cons != Cons.NIL) ? cons.phoneme : vowel.phoneme;
}

/// Class to represent Pronunciation as a sequence of Syllable incl
/// logic to remap some parts for disambiguation or better speech generation.
class Pronunciation {
  final List<Syllable> syllables;

  /// for linking discrete syllable fragment files into a long pronunciation
  late final List<String> fragmentSequence;

  /// voicing, transformed as needed
  late final String _phonemes; // IPA phonemes

  /// constructor, precompute voicing, fragments representation
  Pronunciation(this.syllables) {
    final fragmentList = <String>[];
    final phonemeList = <String>[];

    for (int i = 0; i < syllables.length; i++) {
      final cur = syllables[i];
      final syllable = cur;
      fragmentList.add(syllable.shortName);
      phonemeList.add(syllable.pronunciation);
    }
    fragmentSequence = List.unmodifiable(fragmentList);
    _phonemes = phonemeList.join('.');
  }

  @override
  bool operator ==(Object other) {
    if (other is! Pronunciation) return false;

    Pronunciation that = other;

    final ieq = IterableEquality<Syllable>().equals;

    return ieq(this.syllables, that.syllables);
  }

  @override
  int get hashCode => IterableEquality<Syllable>().hash(syllables);

  @override
  String toString() => _phonemes;

  String get phonemes => _phonemes;

  Syllable operator [](int index) => syllables[index];

  Syllable get first => syllables[0];

  Syllable get last => syllables[length - 1];

  int get length => syllables.length;

  int get durationMillis =>
      syllables.fold(0, (sum, s) => s.durationMillis + sum);
}
