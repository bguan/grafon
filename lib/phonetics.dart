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
enum Consonant { nil, H, B, P, D, T, V, F, G, K, L, R, M, N, S, Z }

/// Consonants are paired based on related vocalization.
/// One is used as the "Base" form, the other the "Head" form.
/// The softer (less ejective) is the Base, the louder (more ejective) is Head.
/// Head form overrides spatial operator to indicate "head" of cluster.
enum ConsPair { AHA, BAPA, DATA, VAFA, GAKA, RALA, NAMA, ZASA }

/// Extension to map Consonant to the Pair and provide short name
extension ConsonantExtension on Consonant {
  ConsPair get pair {
    switch (this) {
      case Consonant.B:
      case Consonant.P:
        return ConsPair.BAPA;

      case Consonant.D:
      case Consonant.T:
        return ConsPair.DATA;

      case Consonant.V:
      case Consonant.F:
        return ConsPair.VAFA;

      case Consonant.G:
      case Consonant.K:
        return ConsPair.GAKA;

      case Consonant.R:
      case Consonant.L:
        return ConsPair.RALA;

      case Consonant.N:
      case Consonant.M:
        return ConsPair.NAMA;

      case Consonant.Z:
      case Consonant.S:
        return ConsPair.ZASA;

      default:
        return ConsPair.AHA;
    }
  }

  String get shortName => this.toString().split('.').last;
}

/// Extension to map ConsonantPair to the base and head, and provide short name.
extension ConsPairExtension on ConsPair {
  Consonant get base {
    switch (this) {
      case ConsPair.BAPA:
        return Consonant.B;
      case ConsPair.DATA:
        return Consonant.D;
      case ConsPair.VAFA:
        return Consonant.V;
      case ConsPair.GAKA:
        return Consonant.G;
      case ConsPair.RALA:
        return Consonant.R;
      case ConsPair.NAMA:
        return Consonant.N;
      case ConsPair.ZASA:
        return Consonant.Z;
      default:
        return Consonant.nil;
    }
  }

  Consonant get head {
    switch (this) {
      case ConsPair.BAPA:
        return Consonant.P;
      case ConsPair.DATA:
        return Consonant.T;
      case ConsPair.VAFA:
        return Consonant.F;
      case ConsPair.GAKA:
        return Consonant.K;
      case ConsPair.RALA:
        return Consonant.L;
      case ConsPair.NAMA:
        return Consonant.M;
      case ConsPair.ZASA:
        return Consonant.S;
      default:
        return Consonant.H;
    }
  }

  String get shortName => this.toString().split('.').last;
}
