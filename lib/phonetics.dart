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

/// Enums and utils for Phonetics related concepts for the Grafon language.
library phonetics;

import 'package:collection/collection.dart';

/// Basic vowels for the language. Can be combined into diphthong.
enum Vowel { nil, A, E, I, O, U }

extension VowelHelper on Vowel {
  String get phoneme =>
      this == Vowel.nil ? '' : this.toString().split('.').last.toLowerCase();
}

/// Basic consonants at the beginning of a syllable.
enum Consonant {
  nil,
  H,
  B,
  P,
  J,
  Ch,
  D,
  T,
  V,
  F,
  G,
  K,
  L,
  R,
  M,
  N,
  S,
  Z,
  Sh,
  Zh
}

/// Consonants are paired based on related vocalization.
/// One is used as the "Base" form, the other the "Head" form.
/// Head form overrides spatial operator to indicate "head" of cluster.
enum ConsPair { aHa, BaPa, ChaJa, DaTa, FaVa, GaKa, LaRa, MaNa, SaZa, ShaZha }

/// Extension to map Consonant to the Pair and provide short name
extension ConsonantHelper on Consonant {
  ConsPair get pair {
    switch (this) {
      case Consonant.B:
      case Consonant.P:
        return ConsPair.BaPa;

      case Consonant.Ch:
      case Consonant.J:
        return ConsPair.ChaJa;

      case Consonant.D:
      case Consonant.T:
        return ConsPair.DaTa;

      case Consonant.V:
      case Consonant.F:
        return ConsPair.FaVa;

      case Consonant.G:
      case Consonant.K:
        return ConsPair.GaKa;

      case Consonant.R:
      case Consonant.L:
        return ConsPair.LaRa;

      case Consonant.N:
      case Consonant.M:
        return ConsPair.MaNa;

      case Consonant.Z:
      case Consonant.S:
        return ConsPair.SaZa;

      case Consonant.Zh:
      case Consonant.Sh:
        return ConsPair.ShaZha;

      default:
        return ConsPair.aHa;
    }
  }

  String get phoneme =>
      this == Consonant.nil ? '' : this.toString().split('.').last;
}

/// Extension to map ConsonantPair to the base and head, and provide short name.
extension ConsPairHelper on ConsPair {
  Consonant get base {
    switch (this) {
      case ConsPair.BaPa:
        return Consonant.B;
      case ConsPair.ChaJa:
        return Consonant.Ch;
      case ConsPair.DaTa:
        return Consonant.D;
      case ConsPair.FaVa:
        return Consonant.F;
      case ConsPair.GaKa:
        return Consonant.G;
      case ConsPair.LaRa:
        return Consonant.L;
      case ConsPair.MaNa:
        return Consonant.M;
      case ConsPair.SaZa:
        return Consonant.S;
      case ConsPair.ShaZha:
        return Consonant.Sh;
      default:
        return Consonant.nil;
    }
  }

  Consonant get head {
    switch (this) {
      case ConsPair.BaPa:
        return Consonant.P;
      case ConsPair.ChaJa:
        return Consonant.J;
      case ConsPair.DaTa:
        return Consonant.T;
      case ConsPair.FaVa:
        return Consonant.V;
      case ConsPair.GaKa:
        return Consonant.K;
      case ConsPair.LaRa:
        return Consonant.R;
      case ConsPair.MaNa:
        return Consonant.N;
      case ConsPair.SaZa:
        return Consonant.Z;
      case ConsPair.ShaZha:
        return Consonant.Zh;
      default:
        return Consonant.H;
    }
  }

  String get shortName => this.toString().split('.').last;
}

/// enum for ending consonant pair for preceding gram in a binary operation.
enum EndConsPair { H, KG, NM, SZ }

/// extension to map base, tail ending consonant to enum, short name.
extension EndingConsPairHelper on EndConsPair {
  EndConsonant get base {
    switch (this) {
      case EndConsPair.H:
        return EndConsonant.nil;
      case EndConsPair.KG:
        return EndConsonant.K;
      case EndConsPair.NM:
        return EndConsonant.N;
      case EndConsPair.SZ:
        return EndConsonant.S;
      default:
        throw Exception("Unexpected BinaryEnding Enum ${this}");
    }
  }

  // use tail when it is the last operator in a cluster group
  EndConsonant get tail {
    switch (this) {
      case EndConsPair.H:
        return EndConsonant.H;
      case EndConsPair.KG:
        return EndConsonant.G;
      case EndConsPair.NM:
        return EndConsonant.M;
      case EndConsPair.SZ:
        return EndConsonant.Z;
      default:
        throw Exception("Unexpected BinaryEnding Enum ${this}");
    }
  }

  String get shortName => this.toString().split('.').last;
}

enum EndConsonant { nil, H, K, G, N, M, S, Z, ng }

extension EndConsonantHelper on EndConsonant {
  EndConsPair get pair {
    switch (this) {
      case EndConsonant.nil:
      case EndConsonant.H:
        return EndConsPair.H;

      case EndConsonant.K:
      case EndConsonant.G:
        return EndConsPair.KG;

      case EndConsonant.N:
      case EndConsonant.M:
        return EndConsPair.NM;

      case EndConsonant.S:
      case EndConsonant.Z:
        return EndConsPair.SZ;

      default:
        throw UnsupportedError('$this does not belong to a Consonant Pair');
    }
  }

  String get phoneme => this == EndConsonant.nil
      ? ''
      : this.toString().split('.').last.toLowerCase();
}

/// Class to handle Syllable and its manipulation
class Syllable {
  final Consonant consonant;
  final Vowel vowel;
  final Vowel endVowel;
  final EndConsonant endConsonant;

  Syllable(this.consonant, this.vowel,
      [this.endVowel = Vowel.nil, this.endConsonant = EndConsonant.nil]);

  Syllable.v(this.vowel)
      : consonant = Consonant.nil,
        endVowel = Vowel.nil,
        endConsonant = EndConsonant.nil;

  Syllable.vc(this.vowel, this.endConsonant)
      : consonant = Consonant.nil,
        endVowel = Vowel.nil;

  Syllable.vv(this.vowel, this.endVowel)
      : consonant = Consonant.nil,
        endConsonant = EndConsonant.nil;

  Syllable.vvc(this.vowel, this.endVowel, this.endConsonant)
      : consonant = Consonant.nil;

  Syllable.cvc(this.consonant, this.vowel, this.endConsonant)
      : endVowel = Vowel.nil;

  @override
  bool operator ==(Object other) {
    if (other is! Syllable) return false;

    Syllable that = other;

    return this.consonant == that.consonant &&
        this.vowel == that.vowel &&
        this.endVowel == that.endVowel &&
        this.endConsonant == that.endConsonant;
  }

  @override
  int get hashCode =>
      consonant.hashCode ^
      vowel.hashCode ^
      endVowel.hashCode ^
      endConsonant.hashCode;

  @override
  String toString() =>
      (consonant == Consonant.nil
          ? vowel.phoneme.toUpperCase()
          : consonant.phoneme + vowel.phoneme) +
      endVowel.phoneme +
      endConsonant.phoneme;

  /// make a syllable based on another when it is the head of a cluster expr
  Syllable get headForm =>
      Syllable(consonant.pair.head, vowel, endVowel, endConsonant);

  /// make a syllable based on another when it's operator is tail of a cluster
  Syllable get tailOpForm =>
      Syllable(consonant, vowel, endVowel, endConsonant.pair.tail);

  /// make a syllable based on another with a different consonant
  Syllable diffConsonant(Consonant c) =>
      Syllable(c, vowel, endVowel, endConsonant);

  /// make a syllable based on another with a different vowel
  Syllable diffVowel(Vowel v) => Syllable(consonant, v, endVowel, endConsonant);

  /// make a syllable based on another with a different end vowel
  Syllable diffEndVowel(Vowel endVowel) =>
      Syllable(consonant, vowel, endVowel, endConsonant);

  /// make a syllable based on another with a different end consonant
  Syllable diffEndConsonant(EndConsonant e) =>
      Syllable(consonant, vowel, endVowel, e);
}

/// Class to represent Pronunciation as a sequence of Syllable and resp utils.
class Pronunciation {
  static const SEPARATOR_SYMBOL = '-';
  final List<Syllable> syllables;

  Pronunciation(Iterable<Syllable> syllables)
      : this.syllables = List.unmodifiable(syllables);

  @override
  bool operator ==(Object other) {
    if (other is! Pronunciation) return false;

    Pronunciation that = other;

    final leq = ListEquality<Syllable>().equals;

    return leq(this.syllables, that.syllables);
  }

  @override
  int get hashCode => ListEquality<Syllable>().hash(syllables);

  @override
  String toString() =>
      syllables.map((s) => s.toString()).join(SEPARATOR_SYMBOL);

  Syllable operator [](int index) => syllables[index];

  Syllable get first => syllables[0];

  Syllable get last => syllables[length - 1];

  int get length => syllables.length;
}

enum CodaHeadDup { nil2Th, H2Thr, K2sKr, G2sGr, N2nSr, M2mSr, S2Shr, Z2Zhr }
