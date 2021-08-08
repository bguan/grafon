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
  String get shortName =>
      this == Vowel.NIL ? '' : this.toString().split('.').last;

  /// IPA phoneme
  String get shortPhoneme {
    switch (this) {
      case Vowel.a:
        return 'ɑː';
      case Vowel.e:
        return 'ə';
      case Vowel.i:
        return 'iː';
      case Vowel.o:
        return 'ʊ';
      case Vowel.u:
        return 'uː';
      case Vowel.NIL:
        return '';
      default:
        return shortName;
    }
  }

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
        return '';
      default:
        return shortName;
    }
  }

  // hack to get intended sound with text-to-speech engine in en-GB
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

  String get shortName =>
      this == Cons.NIL ? '' : this.toString().split('.').last;

  /// IPA Phoneme
  String get phoneme {
    switch (this) {
      // case Cons.r:
      //   return 'ɹ';
      case Cons.j:
        return 'ʤ';
      case Cons.ch:
        return 'ʧ';
      case Cons.sh:
        return 'ʃ';
      case Cons.zh:
        return 'ʒ';
      case Cons.NIL:
        return '';
      default:
        return shortName;
    }
  }

  String get approxVoice {
    switch (this) {
      case Cons.h:
        return 'h';
      case Cons.b:
        return 'b';
      case Cons.p:
        return 'p';
      case Cons.j:
        return 'j';
      case Cons.ch:
        return 'ch';
      case Cons.d:
        return 'd';
      case Cons.t:
        return 't';
      case Cons.f:
        return 'f';
      case Cons.v:
        return 'v';
      case Cons.g:
        return 'g';
      case Cons.k:
        return 'k';
      case Cons.l:
        return 'l';
      case Cons.r:
        return 'ɹ';
      case Cons.m:
        return 'm';
      case Cons.n:
        return 'n';
      case Cons.s:
        return 's';
      case Cons.z:
        return 'z';
      case Cons.sh:
        return 'sh';
      case Cons.zh:
        return 'zh';
      case Cons.NIL:
      default:
        return '';
    }
  }
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
enum Coda { NIL, f, th, p, t, k, s, sh, ch, n, m, r, ng }

/// Helper to map coda to get the group that its associated with and phoneme
extension CodaHelper on Coda {
  CodaGroup get group {
    switch (this) {
      case Coda.NIL:
      case Coda.f:
      case Coda.th:
        return CodaGroup.nilFTh;

      case Coda.p:
      case Coda.t:
      case Coda.k:
        return CodaGroup.PTK;

      case Coda.n:
      case Coda.m:
      case Coda.r:
        return CodaGroup.MNR;

      case Coda.s:
      case Coda.sh:
      case Coda.ch:
        return CodaGroup.SShCh;

      case Coda.ng:
      default:
        throw UnsupportedError('$this does not belong to a Coda Pair');
    }
  }

  String get shortName =>
      this == Coda.NIL ? '' : this.toString().split('.').last;

  /// IPA Phoneme
  String get phoneme {
    switch (this) {
      case Coda.th:
        return 'θ';
      case Coda.r:
        return 'ɹ';
      case Coda.sh:
        return 'ʃ';
      case Coda.ch:
        return 'ʧ';
      case Coda.ng:
        return 'ŋ';
      case Coda.NIL:
        return '';
      default:
        return shortName;
    }
  }

  String get approxVoice => this == Coda.NIL ? '' : shortName;
}

/// Enum for Coda grouping for leading gram in a binary operation.
enum CodaGroup { nilFTh, PTK, MNR, SShCh }

/// Enum for the 3 forms in each CodaGroup
enum CodaForm { base, tail, alt }

/// Extension to map base, tail, alt Coda to enum, short name.
extension CodaGroupHelper on CodaGroup {
  Coda get base {
    switch (this) {
      case CodaGroup.PTK:
        return Coda.p;
      case CodaGroup.MNR:
        return Coda.m;
      case CodaGroup.SShCh:
        return Coda.s;
      case CodaGroup.nilFTh:
      default:
        return Coda.NIL;
    }
  }

  /// Use tail when it is the last operator in a cluster group
  Coda get tail {
    switch (this) {
      case CodaGroup.PTK:
        return Coda.t;
      case CodaGroup.MNR:
        return Coda.n;
      case CodaGroup.SShCh:
        return Coda.sh;
      case CodaGroup.nilFTh:
      default:
        return Coda.f;
    }
  }

  /// Use alt when coda is the same as the starting consonant of next syllable.
  /// The only exception is "ahHa". Simply change coda alt to "athHa" wont work.
  /// As "athHa" sounds to close to "athA", pronunciation will handle it.
  Coda get alt {
    switch (this) {
      case CodaGroup.PTK:
        return Coda.k;
      case CodaGroup.MNR:
        return Coda.r;
      case CodaGroup.SShCh:
        return Coda.ch;
      case CodaGroup.nilFTh:
      default:
        return Coda.th;
    }
  }

  String get shortName => this.toString().split('.').last;

  Coda operator [](CodaForm f) => f == CodaForm.base
      ? this.base
      : (f == CodaForm.tail ? this.tail : this.alt);
}

/// Extension to map CodaForm enum to short name.
extension CodaFormHelper on CodaForm {
  String get shortName => this.toString().split('.').last;
}

/// Class to handle Syllable and its manipulation
class Syllable {
  static const int CONS_MILLIS = 100;
  static const int VOWEL_MILLIS = 200;
  static const int END_VOWEL_MILLIS = 150;
  static const int CODA_MILLIS = 150;
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
  String toString() => [
        cons.shortName,
        vowel.shortName,
        endVowel.shortName,
        coda.shortName,
      ].join();

  String get pronunciation => [
        cons.phoneme,
        vowel.phoneme,
        endVowel == Vowel.NIL ? '' : 'ˌ${endVowel.shortPhoneme}',
        coda.phoneme,
      ].join();

  int get durationMillis =>
      (cons != Cons.NIL ? CONS_MILLIS : 0) +
      VOWEL_MILLIS +
      (endVowel != Vowel.NIL ? END_VOWEL_MILLIS : 0) +
      (coda != Coda.NIL ? CODA_MILLIS : 0);

  String get approxVoice {
    // Hack to get TTS working
    final v = vowel.approxVoice;
    final e = endVowel.approxVoice;

    StringBuffer s = StringBuffer();

    if (cons == Cons.NIL && vowel == Vowel.a && endVowel == Vowel.u) {
      s.write('ah-');
    } else if (cons == Cons.NIL &&
        vowel == Vowel.a &&
        endVowel == Vowel.NIL &&
        coda == Coda.ng) {
      s.write('a');
    } else if (cons == Cons.g && vowel == Vowel.i) {
      s.write('ghee');
      if (e != '') s.write('-');
    } else if (cons == Cons.g && vowel == Vowel.e) {
      s.write('gher');
      if (e != '') s.write('-');
    } else if (cons == Cons.f && vowel == Vowel.e) {
      s.write('fur');
      if (e != '') s.write('-');
    } else if (cons == Cons.ch && vowel == Vowel.u) {
      s.write('choo');
      if (e != '') s.write('-');
    } else if (cons == Cons.ch && vowel == Vowel.e) {
      s.write('chur');
      if (e != '') s.write('-');
    } else if (cons == Cons.m && vowel == Vowel.e) {
      s.write('mur');
      if (e != '') s.write('-');
    } else if (cons == Cons.z && vowel == Vowel.e) {
      s.write('zur');
      if (e != '') s.write('-');
    } else if (cons == Cons.zh && vowel == Vowel.e) {
      s.write('zhe');
      if (e != '') s.write('-');
    } else if (cons == Cons.n && vowel == Vowel.e) {
      s.write('nur');
      if (e != '') s.write('-');
    } else if (cons == Cons.n && vowel == Vowel.i) {
      s.write('ni');
      if (e != '') s.write('-');
    } else if (cons == Cons.r && vowel == Vowel.e) {
      s.write('rhur');
      if (e != '') s.write('-');
    } else if (cons == Cons.r && vowel == Vowel.o) {
      s.write('raw');
      if (e != '') s.write('-');
    } else if (cons == Cons.s && vowel == Vowel.a) {
      s.write('sah');
      if (e != '') s.write('-');
    } else if (cons == Cons.sh && vowel == Vowel.a) {
      s.write('shaa');
      if (e != '') s.write('-');
    } else if (cons == Cons.zh && vowel == Vowel.a) {
      s.write("zhaar");
      if (e != '') s.write('-');
    } else if (cons == Cons.zh && vowel == Vowel.e) {
      s.write("zh'er");
      if (e != '') s.write('-');
    } else {
      if (cons != Cons.NIL) s.write(cons.approxVoice);
      if (endVowel == Vowel.NIL) {
        s.write(vowel.approxVoice);
      } else if (vowel == endVowel) {
        s.writeAll([v.length < 2 ? v : v.substring(0, v.length - 1), '-']);
      } else {
        s.writeAll([v.length < 2 ? v : v.substring(0, v.length - 1), 'h', '-']);
      }
    }

    if (coda == Coda.ch && endVowel != Vowel.NIL) {
      final e = endVowel.approxVoice;
      s.write(e.length < 2 ? v : e.substring(0, e.length - 1));
    } else {
      s.write(endVowel.approxVoice);
    }
    if ((cons == Cons.NIL &&
            vowel == Vowel.a &&
            endVowel == Vowel.a &&
            coda == Coda.s) ||
        (cons == Cons.s && vowel == Vowel.e && coda == Coda.s)) {
      s.write("'");
    }
    s.write(coda.approxVoice);
    return s.toString();
  }

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

  /// final syllables after applying disambiguation transformation
  late final List<Syllable> voicing;

  /// for linking discrete syllable fragment files into a long pronunciation
  late final List<String> fragmentSequence;

  /// voicing, transformed as needed
  late final String _voicingStr; // IPA phonemes
  late final String _approxVoice; // what a US English speaker should pronounce

  /// constructor, precompute voicing, fragments, approx string representation
  Pronunciation(this.syllables) {
    final syllableList = <Syllable>[];
    final fragmentList = <String>[];
    Syllable prev = syllables.first;
    Coda codaCarry = Coda.NIL;
    for (var next in syllables.skip(1)) {
      if (prev.lastPhoneme == next.firstPhoneme) {
        prev = prev.altOpForm;
      }
      syllableList.add(prev);
      // move leading syllable's coda to head of trailing if none
      if (next.cons == Cons.NIL) {
        fragmentList.add("${codaCarry.shortName}${prev.diffCoda(Coda.NIL)}");
        codaCarry = prev.coda;
      } else {
        fragmentList.add("${codaCarry.shortName}$prev");
        codaCarry = Coda.NIL;
      }
      prev = next;
    }
    syllableList.add(prev);
    fragmentList.add("${codaCarry.shortName}$prev");
    voicing = List.unmodifiable(syllableList);
    fragmentSequence = List.unmodifiable(fragmentList);
    _voicingStr = voicing.map((s) => s.pronunciation).join("");
    _approxVoice = voicing.map((s) => s.approxVoice).join("-");
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
  String toString() => _voicingStr;

  String get approxVoice => _approxVoice;

  Syllable operator [](int index) => voicing[index];

  Syllable get first => voicing[0];

  Syllable get last => voicing[length - 1];

  int get length => syllables.length;

  int get durationMillis =>
      syllables.fold(0, (sum, s) => s.durationMillis + sum);
}
