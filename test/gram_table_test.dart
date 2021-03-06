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

import 'package:flutter_test/flutter_test.dart';
import 'package:grafon/grafon_expr.dart';
import 'package:grafon/gram_infra.dart';
import 'package:grafon/gram_table.dart';
import 'package:grafon/phonetics.dart';

/// Unit Tests for Gram Table
void main() {
  test('Every Mono has shortName', () {
    for (final m in Mono.values) {
      expect(m.shortName, isNotEmpty);
    }
  });

  test('Every Mono has ConsPair', () {
    for (final m in Mono.values) {
      expect(m.gram.consPair, isNotNull);
    }
  });

  test('Every ConsPair maps to a Mono', () {
    for (final cp in ConsPair.values) {
      expect(Mono.values.firstWhere((m) => m.gram.consPair == cp), isNotNull);
    }
  });

  test('Every Quad has shortName', () {
    for (final q in Quads.values) {
      expect(q.shortName, isNotEmpty);
    }
  });

  test('Every Quad has ConsPair', () {
    for (final q in Quads.values) {
      expect(q.grams.consPair, isNotNull);
    }
  });

  test('Every ConsPair maps to a Quad', () {
    for (final cp in ConsPair.values) {
      expect(Quads.values.firstWhere((q) => q.grams.consPair == cp), isNotNull);
    }
  });

  test('GramTable test atConsPairVowel', () {
    for (final cp in ConsPair.values) {
      for (final v in Vowel.values.where((e) => e != Vowel.NIL)) {
        final gra = GramTable().atConsPairVowel(cp, v);

        expect(gra.consPair, cp);
        expect(gra.vowel, v);
      }
    }
  });

  test('GramTable test atConsonantVowel', () {
    for (final c in Cons.values) {
      for (final v in Vowel.values.where((e) => e != Vowel.NIL)) {
        final gra = GramTable().atConsonantVowel(c, v);
        expect(gra.consPair, c.pair);
        expect(gra.vowel, v);
      }
    }
  });

  test('GramTable test atMonoFace', () {
    for (final m in Mono.values) {
      for (final f in Face.values) {
        final gra = GramTable().atMonoFace(m, f);
        expect(gra.face, f);
        if (f == Face.Center) {
          expect(gra, m.gram);
          expect(gra, isA<MonoGram>());
        } else {
          expect(m, m.quadPeer.monoPeer);
          expect(gra, m.quadPeer[f]);
          expect(gra, isA<QuadGram>());
        }
      }
    }
  });

  test('GramTable test at dynamics', () {
    for (final cp in ConsPair.values) {
      for (final v in Vowel.values.where((e) => e != Vowel.NIL)) {
        final gra = GramTable().at(cp, v);
        expect(gra.consPair, cp);
        expect(gra.vowel, v);
      }
      for (final f in Face.values) {
        final gra = GramTable().at(cp, f);
        expect(gra.face, f);
        expect(gra.consPair, cp);
      }
    }

    for (final c in Cons.values) {
      for (final v in Vowel.values.where((e) => e != Vowel.NIL)) {
        final gra = GramTable().at(c, v);
        expect(gra.consPair, c.pair);
        expect(gra.vowel, v);
      }
      for (final f in Face.values) {
        final gra = GramTable().at(c, f);
        expect(gra.face, f);
        expect(gra.consPair, c.pair);
      }
    }

    for (final m in Mono.values) {
      for (final f in Face.values) {
        final gra = GramTable().at(m, f);
        expect(gra.face, f);
        if (f == Face.Center) {
          expect(gra, m.gram);
          expect(gra, isA<MonoGram>());
        } else {
          expect(m, m.quadPeer.monoPeer);
          expect(gra, m.quadPeer[f]);
          expect(gra, isA<QuadGram>());
        }
      }
      for (final v in Vowel.values.where((e) => e != Vowel.NIL)) {
        final gra = GramTable().at(m, v);
        expect(gra.consPair, m.gram.consPair);
        expect(gra.vowel, v);
      }
    }

    for (final q in Quads.values) {
      for (final f in Face.values) {
        final gra = GramTable().at(q, f);
        expect(gra.face, f);
        if (f != Face.Center) {
          expect(gra, q[f]);
          expect(gra, isA<QuadGram>());
        } else {
          expect(gra, q.monoPeer.gram);
          expect(gra, isA<MonoGram>());
        }
      }
      for (final v in Vowel.values.where((v) => v != Vowel.NIL)) {
        final gra = GramTable().at(q, v);
        if (v.face != Face.Center) {
          expect(gra.consPair, q[v.face].gram.consPair);
        }
        expect(gra.vowel, v);
      }
    }

    expect(
      () => GramTable().at(0, Face.Center),
      throwsA(isA<UnsupportedError>()),
    );
    expect(
      () => GramTable().at(Mono.Dot, 0),
      throwsA(isA<UnsupportedError>()),
    );
  });

  test('GramTable numRows match num of Mono', () {
    expect(GramTable().numRows, Mono.values.length);
  });

  test('GramTable numRows match num of Quad', () {
    expect(GramTable().numRows, Quads.values.length);
  });

  test('GramTable numRows match num of ConsPair', () {
    expect(GramTable().numRows, ConsPair.values.length);
  });

  test('GramTable numCols match num of Vowels', () {
    expect(
        GramTable().numCols, Vowel.values.where((e) => e != Vowel.NIL).length);
  });

  test('GramTable numCols match num of Faces', () {
    expect(GramTable().numCols, Face.values.length);
  });

  test('GramTable test getEnumIfMono', () {
    for (final m in Mono.values) {
      Mono? mEnum = GramTable().getEnumIfMono(m.gram);
      expect(mEnum, m);
    }
    for (final q in Quads.values) {
      for (final f in FaceHelper.directionals) {
        Mono? mEnum = GramTable().getEnumIfMono(q.grams[f]);
        expect(mEnum, isNull);
      }
    }
  });

  test('GramTable test getEnumIfQuad', () {
    for (final m in Mono.values) {
      Quads? qEnum = GramTable().getEnumIfQuad(m.gram);
      expect(qEnum, isNull);
    }
    for (final q in Quads.values) {
      for (final f in FaceHelper.directionals) {
        Quads? qEnum = GramTable().getEnumIfQuad(q.grams[f]);
        expect(qEnum, q);
      }
    }
  });

  test('GramTable test getMonoEnum', () {
    for (final m in Mono.values) {
      Mono mEnum = GramTable().getMonoEnum(m.gram);
      expect(mEnum, m);
    }
    for (final q in Quads.values) {
      for (final f in FaceHelper.directionals) {
        Mono mEnum = GramTable().getMonoEnum(q.grams[f]);
        expect(mEnum, q.monoPeer);
      }
    }
  });

  test('Mono convenience helper for expression building works', () {
    for (final m in Mono.values) {
      expect(m.shrink().renderPlan, m.gram.renderPlan.byUnary(Unary.Shrink));
      expect(m.up().renderPlan, m.gram.renderPlan.byUnary(Unary.Up));
      expect(m.down().renderPlan, m.gram.renderPlan.byUnary(Unary.Down));
      expect(m.left().renderPlan, m.gram.renderPlan.byUnary(Unary.Left));
      expect(m.right().renderPlan, m.gram.renderPlan.byUnary(Unary.Right));

      final SingleGramExpr s = Mono.Dot.gram;
      final BinaryOpExpr b = Mono.Dot.next(Mono.Dot.gram);
      expect(m.next(s).renderPlan,
          m.gram.renderPlan.byBinary(Binary.Next, s.renderPlan));
      expect(m.nextCluster(b).renderPlan,
          m.gram.renderPlan.byBinary(Binary.Next, b.renderPlan));
      expect(m.merge(s).renderPlan,
          m.gram.renderPlan.byBinary(Binary.Merge, s.renderPlan));
      expect(m.mergeCluster(b).renderPlan,
          m.gram.renderPlan.byBinary(Binary.Merge, b.renderPlan));
      expect(m.over(s).renderPlan,
          m.gram.renderPlan.byBinary(Binary.Over, s.renderPlan));
      expect(m.overCluster(b).renderPlan,
          m.gram.renderPlan.byBinary(Binary.Over, b.renderPlan));
      expect(m.wrap(s).renderPlan,
          m.gram.renderPlan.byBinary(Binary.Wrap, s.renderPlan));
      expect(m.wrapCluster(b).renderPlan,
          m.gram.renderPlan.byBinary(Binary.Wrap, b.renderPlan));
    }
  });
}
