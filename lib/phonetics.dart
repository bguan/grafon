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

/// Basic vowels for the language. Can be combined into diphthong.
enum Vowel { A, E, I, O, U }

/// Basic consonants for the language. Can be combined into cluster.
enum Consonant { nil, H, B, P, J, Ch, D, T, V, F, G, K, L, R, M, N, S, Z }

/// Consonants are paired based on related vocalization.
/// One is used as the "Base" form, the other the "Head" form.
/// The softer (less ejective) is the Base, the louder (more ejective) is Head.
/// Head form overrides spatial operator to indicate "head" of cluster.
enum ConsPair { aHa, BaPa, JaCha, DaTa, VaFa, GaKa, RaLa, NaMa, ZaSa }

/// Extension to map Consonant to the Pair and provide short name
extension ConsonantExtension on Consonant {
  ConsPair get pair {
    switch (this) {
      case Consonant.B:
      case Consonant.P:
        return ConsPair.BaPa;

      case Consonant.Ch:
      case Consonant.J:
        return ConsPair.JaCha;

      case Consonant.D:
      case Consonant.T:
        return ConsPair.DaTa;

      case Consonant.V:
      case Consonant.F:
        return ConsPair.VaFa;

      case Consonant.G:
      case Consonant.K:
        return ConsPair.GaKa;

      case Consonant.R:
      case Consonant.L:
        return ConsPair.RaLa;

      case Consonant.N:
      case Consonant.M:
        return ConsPair.NaMa;

      case Consonant.Z:
      case Consonant.S:
        return ConsPair.ZaSa;

      default:
        return ConsPair.aHa;
    }
  }

  String get shortName => this.toString().split('.').last;
}

/// Extension to map ConsonantPair to the base and head, and provide short name.
extension ConsPairExtension on ConsPair {
  Consonant get base {
    switch (this) {
      case ConsPair.BaPa:
        return Consonant.B;
      case ConsPair.JaCha:
        return Consonant.J;
      case ConsPair.DaTa:
        return Consonant.D;
      case ConsPair.VaFa:
        return Consonant.V;
      case ConsPair.GaKa:
        return Consonant.G;
      case ConsPair.RaLa:
        return Consonant.R;
      case ConsPair.NaMa:
        return Consonant.N;
      case ConsPair.ZaSa:
        return Consonant.Z;
      default:
        return Consonant.nil;
    }
  }

  Consonant get head {
    switch (this) {
      case ConsPair.BaPa:
        return Consonant.P;
      case ConsPair.JaCha:
        return Consonant.Ch;
      case ConsPair.DaTa:
        return Consonant.T;
      case ConsPair.VaFa:
        return Consonant.F;
      case ConsPair.GaKa:
        return Consonant.K;
      case ConsPair.RaLa:
        return Consonant.L;
      case ConsPair.NaMa:
        return Consonant.M;
      case ConsPair.ZaSa:
        return Consonant.S;
      default:
        return Consonant.H;
    }
  }

  String get shortName => this.toString().split('.').last;
}

/// enum for ending consonant pair for preceding gram in a binary operation.
enum BinaryEnding { Ng, H, GK, NM, ZS }

/// extension to map base, tail ending consonant to enum, short name.
extension BinaryEndingExtension on BinaryEnding {
  String get shortName => this.toString().split('.').last;

  String get base {
    switch (this) {
      case BinaryEnding.H:
        return '';
      case BinaryEnding.GK:
        return 'g';
      case BinaryEnding.NM:
        return 'n';
      case BinaryEnding.ZS:
        return 'z';
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
      case BinaryEnding.GK:
        return 'k';
      case BinaryEnding.NM:
        return 'm';
      case BinaryEnding.ZS:
        return 's';
      case BinaryEnding.Ng:
        return '';
      default:
        throw Exception("Unexpected BinaryEnding Enum ${this}");
    }
  }
}
