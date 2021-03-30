enum Vowel { E, A, I, O, U }

enum Consonant { nil, H, B, P, J, Ch, D, T, V, F, G, K, L, R, M, N, S, Z }

enum ConsPair { AHA, BAPA, JACHA, DATA, VAFA, GAKA, LARA, MANA, SAZA }

extension ConsonantExtension on Consonant {
  ConsPair get pair {
    switch (this) {
      case Consonant.B:
      case Consonant.P:
        return ConsPair.BAPA;

      case Consonant.J:
      case Consonant.Ch:
        return ConsPair.JACHA;

      case Consonant.D:
      case Consonant.T:
        return ConsPair.DATA;

      case Consonant.V:
      case Consonant.F:
        return ConsPair.VAFA;

      case Consonant.G:
      case Consonant.K:
        return ConsPair.GAKA;

      case Consonant.L:
      case Consonant.R:
        return ConsPair.LARA;

      case Consonant.M:
      case Consonant.N:
        return ConsPair.MANA;

      case Consonant.S:
      case Consonant.Z:
        return ConsPair.SAZA;

      default:
        return ConsPair.AHA;
    }
  }

  String get shortName => this.toString().split('.').last;
}

extension ConsPairExtension on ConsPair {
  Consonant get base {
    switch (this) {
      case ConsPair.BAPA:
        return Consonant.B;
      case ConsPair.JACHA:
        return Consonant.J;
      case ConsPair.DATA:
        return Consonant.D;
      case ConsPair.VAFA:
        return Consonant.V;
      case ConsPair.GAKA:
        return Consonant.G;
      case ConsPair.LARA:
        return Consonant.L;
      case ConsPair.MANA:
        return Consonant.M;
      case ConsPair.SAZA:
        return Consonant.S;
      default:
        return Consonant.nil;
    }
  }

  Consonant get head {
    switch (this) {
      case ConsPair.BAPA:
        return Consonant.P;
      case ConsPair.JACHA:
        return Consonant.Ch;
      case ConsPair.DATA:
        return Consonant.T;
      case ConsPair.VAFA:
        return Consonant.F;
      case ConsPair.GAKA:
        return Consonant.K;
      case ConsPair.LARA:
        return Consonant.R;
      case ConsPair.MANA:
        return Consonant.N;
      case ConsPair.SAZA:
        return Consonant.Z;
      default:
        return Consonant.H;
    }
  }
}
