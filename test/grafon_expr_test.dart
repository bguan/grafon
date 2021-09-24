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

/// Unit Tests for Expressions
void main() {
  test('Binary symbol should all be unique', () {
    final symbolsFromBinary = Set.of([
      ...Binary.values.map((b) => b.symbol),
    ]);
    expect(symbolsFromBinary.length, Binary.values.length);
  });

  test('Binary shortName should all be unique', () {
    final namesFromBinary = Set.of([
      ...Binary.values.map((b) => b.shortName),
    ]);
    expect(namesFromBinary.length, Binary.values.length);
  });

  test('Binary ending should all be unique', () {
    final endingsFromBinary = Set.of([
      ...Binary.values.map((b) => b.coda),
    ]);
    expect(endingsFromBinary.length, Binary.values.length);
  });

  test('SingleGram to String matches gram equivalent', () {
    for (final m in Mono.values) {
      final mg = GramTable().atMonoFace(m, Face.Center);
      expect(mg.toString(), m.shortName);
      for (final f in FaceHelper.directionals) {
        final qg = GramTable().atMonoFace(m, f);
        expect(qg.toString(), "${f.shortName}_${m.quadPeer.shortName}");
      }
    }
  });

  test('Grafon Expr lines, width, height works', () {
    final cross = Mono.Cross.gram;
    expect(cross.lines.length, 2);
    expect(cross.lines.first,
        PolyStraight.anchors([Anchor.N, Anchor.S], isFixedAspect: true));
    expect(cross.lines.last,
        PolyStraight.anchors([Anchor.W, Anchor.E], isFixedAspect: true));
    expect(cross.width, moreOrLessEquals(1.0));
    expect(cross.height, moreOrLessEquals(1.0));

    final x = Quads.Line.right.mix(Quads.Line.left);
    expect(x.lines.length, 2);
    expect(x.lines.first, PolyStraight.anchors([Anchor.NE, Anchor.SW]));
  });

  test('SingleGram pronunciation matches gram equivalent', () {
    for (final c in Cons.values) {
      for (final v in Vowel.values.where((e) => e != Vowel.NIL)) {
        final g = GramTable().atConsVowel(c, v);
        expect(
          g.pronunciation.first,
          Syllable(c, v, Coda.NIL),
        );
      }
    }
  });

  test('merge() grams, toString & pronunciation is correct', () {
    final x = Mono.X.gram;
    final hLine = Quads.Line.down;
    final six = x.mix(hLine);

    expect(six.grams.length, 2);
    expect(six.grams.first, x);
    expect(six.grams.last, hLine);

    expect(six.toString(), "X * Down_Line");
    expect(six.pronunciation.length, 2);
    expect(six.pronunciation.first, Syllable(Cons.g, Vowel.a, Coda.k));
    expect(six.pronunciation.last, Syllable.v(Vowel.u));

    final vLine = Quads.Line.up;
    final hash = vLine.next(vLine).mix(ClusterExpr(hLine.over(hLine)));

    expect(hash.grams.length, 4);
    expect(hash.grams[0], vLine);
    expect(hash.grams[1], vLine);
    expect(hash.grams[2], hLine);
    expect(hash.grams[3], hLine);

    expect(hash.toString(), "Up_Line . Up_Line * (Down_Line / Down_Line)");
    expect(hash.pronunciation.length, 6);
    expect(hash.pronunciation[0], Syllable.v(Vowel.i));
    expect(hash.pronunciation[1], Syllable.vc(Vowel.i, Coda.k));
    expect(hash.pronunciation[2], Syllable.vc(Vowel.a, Coda.k));
    expect(hash.pronunciation[3], Syllable.vc(Vowel.u, Coda.s));
    expect(hash.pronunciation[4], Syllable.vc(Vowel.u, Coda.k));
    expect(hash.pronunciation[5], Syllable.v(Vowel.a));
  });

  test('over() grams, toString & pronunciation is correct', () {
    final dot = Mono.Dot.gram;
    final vLine = Quads.Line.up;
    final child = dot.over(vLine);

    expect(child.grams.length, 2);
    expect(child.grams[0], dot);
    expect(child.grams[1], vLine);

    expect(child.toString(), "Dot / Up_Line");
    expect(child.pronunciation.length, 2);
    expect(child.pronunciation.first, Syllable(Cons.h, Vowel.a, Coda.s));
    expect(child.pronunciation.last, Syllable.v(Vowel.i));
    expect(child.pronunciation.toString(), 'hɑːʃ.iː');

    final cornerDown = Quads.Corner.down;
    final cornerLeft = Quads.Corner.left;
    final feet = dot.over(ClusterExpr(cornerDown.next(cornerLeft)));

    expect(feet.grams.length, 3);
    expect(feet.grams[0], dot);
    expect(feet.grams[1], cornerDown);
    expect(feet.grams[2], cornerLeft);

    expect(feet.toString(), "Dot / (Down_Corner . Left_Corner)");
    expect(feet.pronunciation.length, 5);
    expect(feet.pronunciation[0], Syllable(Cons.h, Vowel.a, Coda.s));
    expect(feet.pronunciation[1], Syllable.vc(Vowel.a, Coda.k));
    expect(feet.pronunciation[2], Syllable(Cons.b, Vowel.u));
    expect(feet.pronunciation[3], Syllable(Cons.b, Vowel.o, Coda.k));
    expect(feet.pronunciation[4], Syllable.v(Vowel.a));
    expect(feet.pronunciation.toString(), 'hɑːʃ.ɑːk.buː.bɔːʧ.ɑː');
  });

  test('next() grams, toString & pronunciation is correct', () {
    final lArc = Quads.Arc.left;
    final rFlow = Quads.Flow.right;
    final talk = lArc.next(rFlow);

    expect(talk.grams.length, 2);
    expect(talk.grams[0], lArc);
    expect(talk.grams[1], rFlow);

    expect(talk.toString(), "Left_Arc . Right_Flow");
    expect(talk.pronunciation.length, 2);
    expect(talk.pronunciation.first, Syllable(Cons.n, Vowel.o));
    expect(talk.pronunciation.last, Syllable(Cons.f, Vowel.e));

    final rSlash = Quads.Line.right;
    final bSlash = Quads.Line.left;
    final shout = lArc.next(ClusterExpr(rSlash.over(bSlash)));

    expect(shout.grams.length, 3);
    expect(shout.grams[0], lArc);
    expect(shout.grams[1], rSlash);
    expect(shout.grams[2], bSlash);

    expect(shout.toString(), "Left_Arc . (Right_Line / Left_Line)");
    expect(shout.pronunciation.length, 5);
    expect(shout.pronunciation[0], Syllable(Cons.n, Vowel.o));
    expect(shout.pronunciation[1], Syllable.vc(Vowel.a, Coda.k));
    expect(shout.pronunciation[2], Syllable.vc(Vowel.e, Coda.s));
    expect(shout.pronunciation[3], Syllable.vc(Vowel.o, Coda.k));
    expect(shout.pronunciation[4], Syllable.v(Vowel.a));

    expect(shout.pronunciation.toString(), 'nɔː.ɑːʧ.ɜːʃ.ɔːʧ.ɑː');
  });

  test('wrap() grams, toString & pronunciation is correct', () {
    final circle = Mono.Circle.gram;
    final dot = Mono.Dot.gram;
    final eye = circle.wrap(dot);

    expect(eye.grams.length, 2);
    expect(eye.grams[0], circle);
    expect(eye.grams[1], dot);

    expect(eye.toString(), "Circle @ Dot");
    expect(eye.pronunciation.length, 2);
    expect(eye.pronunciation.first, Syllable(Cons.n, Vowel.a, Coda.n));
    expect(eye.pronunciation.last, Syllable(Cons.h, Vowel.a));
    expect(eye.pronunciation.toString(), 'nɑːn.hɑː');

    final gateDown = Quads.Gate.down;
    final family = circle.wrap(ClusterExpr(dot.next(dot).over(gateDown)));

    expect(family.grams.length, 4);
    expect(family.grams[0], circle);
    expect(family.grams[1], dot);
    expect(family.grams[2], dot);
    expect(family.grams[3], gateDown);

    expect(family.toString(), "Circle @ (Dot . Dot / Down_Gate)");
    expect(family.pronunciation.length, 6);
    expect(family.pronunciation[0], Syllable(Cons.n, Vowel.a, Coda.n));
    expect(family.pronunciation[1], Syllable.vc(Vowel.a, Coda.k));
    expect(family.pronunciation[2], Syllable(Cons.h, Vowel.a));
    expect(family.pronunciation[3], Syllable(Cons.h, Vowel.a, Coda.s));
    expect(family.pronunciation[4], Syllable(Cons.d, Vowel.u, Coda.k));
    expect(family.pronunciation[5], Syllable.v(Vowel.a));
    expect(family.pronunciation.toString(), 'nɑːŋ.ɑːk.hɑː.hɑːs.duːʧ.ɑː');
  });

  test('test SingleExpr equality and hashcode works', () {
    final table = GramTable();
    for (final m1 in Mono.values) {
      for (final f1 in Face.values) {
        final e1 = table.atMonoFace(m1, f1);
        for (final m2 in Mono.values) {
          for (final f2 in Face.values) {
            final e2 = table.atMonoFace(m2, f2);
            if (m1 == m2 && f1 == f2) {
              expect(e1, e2);
              expect(e1.hashCode, e2.hashCode);
            } else {
              expect(e1 == e2, isFalse);
            }
          }
        }
      }
    }
  });

  test('test MultiGramExpr equality and hashcode works', () {
    final dot = Mono.Dot.gram;
    final vLine = Quads.Line.up;
    final e1 = dot.over(vLine);
    final e11 = dot.over(vLine);
    final ce1 = ClusterExpr(e1);
    final ce11 = ClusterExpr(e11);
    final e2 = vLine.over(dot);

    expect(e1, e1);
    expect(e1, e11);
    expect(e1.hashCode, e11.hashCode);
    expect(e1 == e2, isFalse);
    expect(e1 == ce1, isFalse);
    expect(ce1, ce1);
    expect(ce1.hashCode, ce1.hashCode);
    expect(ce1, ce11);
    expect(ce1.hashCode, ce11.hashCode);
  });

  test('test BinaryExpr toClusterExpr', () {
    final dot = Mono.Dot.gram;
    final vLine = Quads.Line.up;
    final e = dot.over(vLine);
    final cluster = e.toClusterExpression();
    expect(e == cluster, isFalse);
    expect(cluster.subExpr, e);
    expect(cluster.pronunciation == e.pronunciation, isFalse);
    expect(cluster.renderPlan, e.renderPlan);
  });
}
