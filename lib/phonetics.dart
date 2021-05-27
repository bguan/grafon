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
enum CodaTrio { HTh, KGT, NMP, SZR }

/// extension to map base, tail ending consonant to enum, short name.
extension CodaTrioHelper on CodaTrio {
  Coda get base {
    switch (this) {
      case CodaTrio.HTh:
        return Coda.nil;
      case CodaTrio.KGT:
        return Coda.K;
      case CodaTrio.NMP:
        return Coda.N;
      case CodaTrio.SZR:
        return Coda.S;
      default:
        throw Exception("Unexpected BinaryEnding Enum ${this}");
    }
  }

  // use tail when it is the last operator in a cluster group
  Coda get tail {
    switch (this) {
      case CodaTrio.HTh:
        return Coda.H;
      case CodaTrio.KGT:
        return Coda.G;
      case CodaTrio.NMP:
        return Coda.M;
      case CodaTrio.SZR:
        return Coda.Z;
      default:
        throw Exception("Unexpected BinaryEnding Enum ${this}");
    }
  }

  // use alt when the end is the same as the starting consonant of next syllable
  Coda get alt {
    switch (this) {
      case CodaTrio.HTh:
        return Coda.Th;
      case CodaTrio.KGT:
        return Coda.T;
      case CodaTrio.NMP:
        return Coda.P;
      case CodaTrio.SZR:
        return Coda.R;
      default:
        throw Exception("Unexpected BinaryEnding Enum ${this}");
    }
  }

  String get shortName => this.toString().split('.').last;
}

enum Coda { nil, H, Th, K, G, T, N, M, P, S, Z, R, ng }

extension CodaHelper on Coda {
  CodaTrio get trio {
    switch (this) {
      case Coda.nil:
      case Coda.H:
      case Coda.Th:
        return CodaTrio.HTh;

      case Coda.K:
      case Coda.G:
      case Coda.T:
        return CodaTrio.KGT;

      case Coda.N:
      case Coda.M:
      case Coda.P:
        return CodaTrio.NMP;

      case Coda.S:
      case Coda.Z:
      case Coda.R:
        return CodaTrio.SZR;

      default:
        throw UnsupportedError('$this does not belong to a Consonant Pair');
    }
  }

  String get phoneme =>
      this == Coda.nil ? '' : this.toString().split('.').last.toLowerCase();
}

/// Class to handle Syllable and its manipulation
class Syllable {
  final Consonant consonant;
  final Vowel vowel;
  final Vowel endVowel;
  final Coda coda;

  Syllable(this.consonant, this.vowel,
      [this.endVowel = Vowel.nil, this.coda = Coda.nil]);

  Syllable.v(this.vowel)
      : consonant = Consonant.nil,
        endVowel = Vowel.nil,
        coda = Coda.nil;

  Syllable.vc(this.vowel, this.coda)
      : consonant = Consonant.nil,
        endVowel = Vowel.nil;

  Syllable.vv(this.vowel, this.endVowel)
      : consonant = Consonant.nil,
        coda = Coda.nil;

  Syllable.vvc(this.vowel, this.endVowel, this.coda)
      : consonant = Consonant.nil;

  Syllable.cvc(this.consonant, this.vowel, this.coda) : endVowel = Vowel.nil;

  @override
  bool operator ==(Object other) {
    if (other is! Syllable) return false;

    Syllable that = other;

    return this.consonant == that.consonant &&
        this.vowel == that.vowel &&
        this.endVowel == that.endVowel &&
        this.coda == that.coda;
  }

  @override
  int get hashCode =>
      consonant.hashCode ^ vowel.hashCode ^ endVowel.hashCode ^ coda.hashCode;

  @override
  String toString() =>
      (consonant == Consonant.nil
          ? vowel.phoneme.toUpperCase()
          : consonant.phoneme + vowel.phoneme) +
      endVowel.phoneme +
      coda.phoneme;

  /// make a syllable based on another when it is the head of a cluster expr
  Syllable get headForm => Syllable(consonant.pair.head, vowel, endVowel, coda);

  /// make a syllable based on another when it's operator is tail of a cluster
  Syllable get tailOpForm =>
      Syllable(consonant, vowel, endVowel, coda.trio.tail);

  /// make a syllable based on another when it's operator is tail of a cluster
  Syllable get altOpForm => Syllable(consonant, vowel, endVowel, coda.trio.alt);

  /// make a syllable based on another with a different consonant
  Syllable diffConsonant(Consonant c) => Syllable(c, vowel, endVowel, coda);

  /// make a syllable based on another with a different vowel
  Syllable diffVowel(Vowel v) => Syllable(consonant, v, endVowel, coda);

  /// make a syllable based on another with a different end vowel
  Syllable diffEndVowel(Vowel endVowel) =>
      Syllable(consonant, vowel, endVowel, coda);

  /// make a syllable based on another with a different end consonant
  Syllable diffEndConsonant(Coda e) => Syllable(consonant, vowel, endVowel, e);
}

/// Class to represent Pronunciation as a sequence of Syllable and resp utils.
class Pronunciation {
  static const SEPARATOR_SYMBOL = '-';
  late final List<Syllable> syllables;

  Pronunciation(Iterable<Syllable> syllables) {
    final slist = <Syllable>[];
    var s = syllables.first;
    for (final next in syllables.skip(1)) {
      if (s.coda.phoneme == next.consonant.phoneme &&
          (s.coda != Coda.nil || s.endVowel == next.vowel))
        slist.add(s.altOpForm);
      else
        slist.add(s);
      s = next;
    }
    slist.add(s);
    this.syllables = List.unmodifiable(slist);
  }

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
