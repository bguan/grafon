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
enum Vowel { NIL, a, e, i, o, u }

extension VowelHelper on Vowel {
  String get phoneme =>
      this == Vowel.NIL ? '' : this.toString().split('.').last;
}

/// Consonants at the beginning of a syllable.
enum Cons { NIL, h, b, p, j, ch, d, t, v, f, g, k, l, r, m, n, s, z, sh, zh }

/// Consonants are paired based on related vocalization.
/// One is used as the "Base" form, the other the "Head" form.
/// Head form overrides spatial operator to indicate "head" of cluster.
enum ConsPair { h, bp, chj, dt, fv, gk, lr, mn, sz, shzh }

/// Extension to map Consonant to the Pair and provide short name
extension ConsonantHelper on Cons {
  ConsPair get pair {
    switch (this) {
      case Cons.b:
      case Cons.p:
        return ConsPair.bp;

      case Cons.ch:
      case Cons.j:
        return ConsPair.chj;

      case Cons.d:
      case Cons.t:
        return ConsPair.dt;

      case Cons.v:
      case Cons.f:
        return ConsPair.fv;

      case Cons.g:
      case Cons.k:
        return ConsPair.gk;

      case Cons.r:
      case Cons.l:
        return ConsPair.lr;

      case Cons.n:
      case Cons.m:
        return ConsPair.mn;

      case Cons.z:
      case Cons.s:
        return ConsPair.sz;

      case Cons.zh:
      case Cons.sh:
        return ConsPair.shzh;

      case Cons.h:
      default:
        return ConsPair.h;
    }
  }

  String get phoneme => this == Cons.NIL ? '' : this.toString().split('.').last;
}

/// Extension to map ConsonantPair to the base and head, and provide short name.
extension ConsPairHelper on ConsPair {
  Cons get base {
    switch (this) {
      case ConsPair.bp:
        return Cons.b;
      case ConsPair.chj:
        return Cons.ch;
      case ConsPair.dt:
        return Cons.d;
      case ConsPair.fv:
        return Cons.f;
      case ConsPair.gk:
        return Cons.g;
      case ConsPair.lr:
        return Cons.l;
      case ConsPair.mn:
        return Cons.m;
      case ConsPair.sz:
        return Cons.s;
      case ConsPair.shzh:
        return Cons.sh;
      case ConsPair.h:
      default:
        return Cons.NIL;
    }
  }

  Cons get head {
    switch (this) {
      case ConsPair.bp:
        return Cons.p;
      case ConsPair.chj:
        return Cons.j;
      case ConsPair.dt:
        return Cons.t;
      case ConsPair.fv:
        return Cons.v;
      case ConsPair.gk:
        return Cons.k;
      case ConsPair.lr:
        return Cons.r;
      case ConsPair.mn:
        return Cons.n;
      case ConsPair.sz:
        return Cons.z;
      case ConsPair.shzh:
        return Cons.zh;
      case ConsPair.h:
      default:
        return Cons.h;
    }
  }

  String get shortName => this.toString().split('.').last;
}

/// Coda is the ending consonant at the end of a syllable
enum Coda { NIL, h, th, dh, k, g, t, n, m, p, s, z, f, ng }

/// Helper to map coda to get the group that its associated with and phoneme
extension CodaHelper on Coda {
  CodaGroup get group {
    switch (this) {
      case Coda.NIL:
      case Coda.h:
      case Coda.th:
      case Coda.dh:
        return CodaGroup.hthdh;

      case Coda.k:
      case Coda.g:
      case Coda.t:
        return CodaGroup.kgt;

      case Coda.n:
      case Coda.m:
      case Coda.p:
        return CodaGroup.nmp;

      case Coda.s:
      case Coda.z:
      case Coda.f:
        return CodaGroup.szf;

      case Coda.ng:
      default:
        throw UnsupportedError('$this does not belong to a Coda Pair');
    }
  }

  String get phoneme => this == Coda.NIL ? '' : this.toString().split('.').last;
}

/// Enum for Coda grouping for leading gram in a binary operation.
enum CodaGroup { hthdh, kgt, nmp, szf }

/// Extension to map base, tail, alt Coda to enum, short name.
extension CodaGroupHelper on CodaGroup {
  Coda get base {
    switch (this) {
      case CodaGroup.kgt:
        return Coda.k;
      case CodaGroup.nmp:
        return Coda.n;
      case CodaGroup.szf:
        return Coda.s;
      case CodaGroup.hthdh:
      default:
        return Coda.NIL;
    }
  }

  /// Use tail when it is the last operator in a cluster group
  Coda get tail {
    switch (this) {
      case CodaGroup.kgt:
        return Coda.g;
      case CodaGroup.nmp:
        return Coda.m;
      case CodaGroup.szf:
        return Coda.z;
      case CodaGroup.hthdh:
      default:
        return Coda.h;
    }
  }

  /// Use alt when coda is the same as the starting consonant of next syllable.
  /// The only exception is "ahHa". Simply change coda alt to "athHa" wont work.
  /// As "athHa" sounds to close to "athA", pronunciation will handle it.
  Coda get alt {
    switch (this) {
      case CodaGroup.kgt:
        return Coda.t;
      case CodaGroup.nmp:
        return Coda.p;
      case CodaGroup.szf:
        return Coda.f;
      case CodaGroup.hthdh:
      default:
        return Coda.th; // 1 exception "aA" => "athA" but "ahHa" => "adhHa"
    }
  }

  String get shortName => this.toString().split('.').last;
}

/// Class to handle Syllable and its manipulation
class Syllable {
  final Cons cons;
  final Vowel vowel;
  final Vowel endVowel;
  final Coda coda;

  Syllable(this.cons, this.vowel,
      [this.endVowel = Vowel.NIL, this.coda = Coda.NIL]);

  Syllable.v(this.vowel)
      : cons = Cons.NIL,
        endVowel = Vowel.NIL,
        coda = Coda.NIL;

  Syllable.vc(this.vowel, this.coda)
      : cons = Cons.NIL,
        endVowel = Vowel.NIL;

  Syllable.vv(this.vowel, this.endVowel)
      : cons = Cons.NIL,
        coda = Coda.NIL;

  Syllable.vvc(this.vowel, this.endVowel, this.coda) : cons = Cons.NIL;

  Syllable.cvc(this.cons, this.vowel, this.coda) : endVowel = Vowel.NIL;

  @override
  bool operator ==(Object other) {
    if (other is! Syllable) return false;

    Syllable that = other;

    return this.cons == that.cons &&
        this.vowel == that.vowel &&
        this.endVowel == that.endVowel &&
        this.coda == that.coda;
  }

  @override
  int get hashCode =>
      cons.hashCode ^ vowel.hashCode ^ endVowel.hashCode ^ coda.hashCode;

  @override
  String toString() =>
      (cons == Cons.NIL ? vowel.phoneme : cons.phoneme + vowel.phoneme) +
      (endVowel == Vowel.NIL ? '' : endVowel.phoneme) +
      (coda == Coda.NIL ? '' : coda.phoneme);

  /// make a syllable based on another when it is the head of a cluster expr
  Syllable get headForm => Syllable(cons.pair.head, vowel, endVowel, coda);

  /// make a syllable based on another when it's operator is tail of a cluster
  Syllable get tailOpForm => Syllable(cons, vowel, endVowel, coda.group.tail);

  /// make a syllable based on another when it's operator is tail of a cluster
  Syllable get altOpForm => Syllable(cons, vowel, endVowel, coda.group.alt);

  /// make a syllable based on another with a different consonant
  Syllable diffConsonant(Cons c) => Syllable(c, vowel, endVowel, coda);

  /// make a syllable based on another with a different vowel
  Syllable diffVowel(Vowel v) => Syllable(cons, v, endVowel, coda);

  /// make a syllable based on another with a different end vowel
  Syllable diffEndVowel(Vowel endVowel) =>
      Syllable(cons, vowel, endVowel, coda);

  /// make a syllable based on another with a different end consonant
  Syllable diffCoda(Coda e) => Syllable(cons, vowel, endVowel, e);

  String get lastPhoneme => (coda != Coda.NIL)
      ? coda.phoneme
      : (endVowel != Vowel.NIL ? endVowel : vowel).phoneme;

  String get firstPhoneme => (cons != Cons.NIL) ? cons.phoneme : vowel.phoneme;
}

/// Class to represent Pronunciation as a sequence of Syllable and resp utils.
class Pronunciation {
  final Iterable<Syllable> syllables;

  /// input
  late final List<Syllable> voicing;

  /// voicing, transformed as needed
  late final String _voicingString;

  /// precompute voicing string representation

  Pronunciation(this.syllables) {
    final slist = <Syllable>[];
    var s = syllables.first;
    for (var next in syllables.skip(1)) {
      if (s.lastPhoneme != next.firstPhoneme) {
        slist.add(s);
      } else if (s.coda == Coda.h && next.cons == Cons.h) {
        // special case i.e. "ah-Ha" => "adh-Ha"
        slist.add(s.diffCoda(Coda.dh));
      } else {
        slist.add(s.altOpForm);
      }
      s = next;
    }
    slist.add(s);
    voicing = List.unmodifiable(slist);
    _voicingString = voicing.map((s) => s.toString()).join();
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
  String toString() => _voicingString;

  Syllable operator [](int index) => voicing[index];

  Syllable get first => voicing[0];

  Syllable get last => voicing[length - 1];

  int get length => syllables.length;
}
