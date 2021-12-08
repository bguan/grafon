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
enum Vowel { NIL, a, e, i, o, u }

/// Extending Vowel to tie to phoneme and approximate voicing
extension VowelHelper on Vowel {
  String get shortName =>
      this == Vowel.NIL ? '' : EnumToString.convertToString(this);

  /// IPA phoneme
  String get phoneme {
    switch (this) {
      case Vowel.a:
        return 'ɑː';
      case Vowel.e:
        return 'ɜː';
      case Vowel.i:
        return 'iː';
      case Vowel.o:
        return 'ɔː';
      case Vowel.u:
        return 'uː';
      case Vowel.NIL:
        return '  ';
      default:
        return shortName;
    }
  }

  /// hack to approximate intended voicing for english speakers
  String get approxVoice {
    switch (this) {
      case Vowel.a:
        return 'ar';
      case Vowel.e:
        return 'er';
      case Vowel.i:
        return 'ee';
      case Vowel.o:
        return 'or';
      case Vowel.u:
        return 'ooh';
      case Vowel.NIL:
      default:
        return '';
    }
  }
}

/// Consonants at the beginning of a syllable.
enum Cons { NIL, h, b, p, d, t, v, f, g, k, r, l, n, m, z, s }

/// Extension to map Consonant to the Pair and provide short name
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

  /// hack to approximate intended voicing for english speakers
  String get approxVoice {
    switch (this) {
      case Cons.NIL:
        return '';
      default:
        return this.shortName;
    }
  }
}

/// Coda is the ending consonant at the end of a syllable
enum Coda { NIL, ch, sh, ng }

/// Helper to map coda to get the group that its associated with and phoneme
extension CodaHelper on Coda {
  String get shortName =>
      this == Coda.NIL ? '' : EnumToString.convertToString(this);

  /// IPA Phoneme for base case
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

  String get approxVoice {
    // Hack to get TTS working

    StringBuffer s = StringBuffer();

    if (cons == Cons.NIL && vowel == Vowel.a) {
      s.write('ah-');
    } else if (cons == Cons.g && vowel == Vowel.i) {
      s.write('ghee');
    } else if (cons == Cons.g && vowel == Vowel.e) {
      s.write('gher');
    } else if (cons == Cons.f && vowel == Vowel.e) {
      s.write('fur');
    } else if (cons == Cons.m && vowel == Vowel.e) {
      s.write('mur');
    } else if (cons == Cons.z && vowel == Vowel.e) {
      s.write('zur');
    } else if (cons == Cons.n && vowel == Vowel.e) {
      s.write('nur');
    } else if (cons == Cons.n && vowel == Vowel.i) {
      s.write('ni');
    } else if (cons == Cons.r && vowel == Vowel.e) {
      s.write('rhur');
    } else if (cons == Cons.r && vowel == Vowel.o) {
      s.write('raw');
    } else if (cons == Cons.s && vowel == Vowel.a) {
      s.write('sah');
    } else {
      if (cons != Cons.NIL) s.write(cons.approxVoice);
      s.write(vowel.approxVoice);
    }

    s.write(coda.approxVoice);
    return s.toString();
  }

  /// make a syllable based on another with a different consonant
  Syllable diffConsonant(Cons c) => Syllable(c, vowel, coda);

  /// make a syllable based on another with a different vowel
  Syllable diffVowel(Vowel v) => Syllable(cons, v, coda);

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
  late final String _approxVoice; // what English speaker should pronounce

  /// constructor, precompute voicing, fragments, approx string representation
  Pronunciation(this.syllables) {
    final fragmentList = <String>[];
    final phonemeList = <String>[];
    final approxList = <String>[];

    for (int i = 0; i < syllables.length; i++) {
      final cur = syllables[i];
      final syllable = cur;
      fragmentList.add(syllable.shortName);
      phonemeList.add(syllable.pronunciation);
      approxList.add(syllable.approxVoice);
    }
    fragmentSequence = List.unmodifiable(fragmentList);
    _phonemes = phonemeList.join('.');
    _approxVoice = approxList.join('-');
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

  String get approxVoice => _approxVoice;

  Syllable operator [](int index) => syllables[index];

  Syllable get first => syllables[0];

  Syllable get last => syllables[length - 1];

  int get length => syllables.length;

  int get durationMillis =>
      syllables.fold(0, (sum, s) => s.durationMillis + sum);
}
