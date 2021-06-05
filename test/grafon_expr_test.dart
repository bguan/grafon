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
  test('Unary symbol should all be unique', () {
    final symbolsFromUnary = Set.of([
      ...Unary.values.map((u) => u.symbol),
    ]);
    expect(symbolsFromUnary.length, Unary.values.length);
  });

  test('Binary symbol should all be unique', () {
    final symbolsFromBinary = Set.of([
      ...Binary.values.map((b) => b.symbol),
    ]);
    expect(symbolsFromBinary.length, Binary.values.length);
  });

  test('Unary ending should all be unique', () {
    final endingsFromUnary = Set.of([
      ...Unary.values.map((u) => u.ending),
    ]);
    expect(endingsFromUnary.length, Unary.values.length);
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

  test('SingleGram pronunciation matches gram equivalent', () {
    for (final cp in ConsPair.values) {
      for (final v in Vowel.values.where((e) => e != Vowel.NIL)) {
        final g = GramTable().atConsPairVowel(cp, v);
        expect(
          g.pronunciation.first,
          Syllable(cp.base, v, Vowel.NIL, Coda.NIL),
        );
      }
    }
  });

  test('UnaryExpr to String is correct', () {
    for (final m in Mono.values) {
      for (final f in Face.values) {
        final g = GramTable().atMonoFace(m, f);
        expect(g.shrink().toString(), Unary.Shrink.symbol + g.toString());
        expect(g.up().toString(), Unary.Up.symbol + g.toString());
        expect(g.down().toString(), Unary.Down.symbol + g.toString());
        expect(g.left().toString(), Unary.Left.symbol + g.toString());
        expect(g.right().toString(), Unary.Right.symbol + g.toString());
      }
    }
  });

  test('UnaryExpr pronunciation is correct', () {
    for (final m in Mono.values) {
      for (final f in Face.values) {
        final g = GramTable().atMonoFace(m, f);
        expect(
          g.shrink().pronunciation.first,
          g.pronunciation.first.diffEndVowel(Unary.Shrink.ending),
        );
        expect(
          g.up().pronunciation.first,
          g.pronunciation.first.diffEndVowel(Unary.Up.ending),
        );
        expect(
          g.down().pronunciation.first,
          g.pronunciation.first.diffEndVowel(Unary.Down.ending),
        );
        expect(
          g.left().pronunciation.first,
          g.pronunciation.first.diffEndVowel(Unary.Left.ending),
        );
        expect(
          g.right().pronunciation.first,
          g.pronunciation.first.diffEndVowel(Unary.Right.ending),
        );
      }
    }
  });

  test('SingleGram toString and pronunciation is correct', () {
    final sun = Mono.Sun.gram;
    expect(sun.toString(), "Sun");
    expect(sun.pronunciation.length, 1);
    expect(sun.pronunciation.first, Syllable(Cons.sh, Vowel.a));

    final sunTiny = sun.shrink();
    expect(sunTiny.toString(), "!Sun");
    expect(sunTiny.pronunciation.length, 1);
    expect(sunTiny.pronunciation.first, Syllable(Cons.sh, Vowel.a, Vowel.a));

    final sunUp = sun.up();
    expect(sunUp.toString(), "+Sun");
    expect(sunUp.pronunciation.length, 1);
    expect(sunUp.pronunciation.first, Syllable(Cons.sh, Vowel.a, Vowel.i));

    final sunDown = sun.down();
    expect(sunDown.toString(), "-Sun");
    expect(sunDown.pronunciation.length, 1);
    expect(sunDown.pronunciation.first, Syllable(Cons.sh, Vowel.a, Vowel.u));

    final sunLeft = sun.left();
    expect(sunLeft.toString(), "<Sun");
    expect(sunLeft.pronunciation.length, 1);
    expect(sunLeft.pronunciation.first, Syllable(Cons.sh, Vowel.a, Vowel.o));

    final sunRight = sun.right();
    expect(sunRight.toString(), ">Sun");
    expect(sunRight.pronunciation.length, 1);
    expect(sunRight.pronunciation.first, Syllable(Cons.sh, Vowel.a, Vowel.e));
  });

  test('merge() and mergeCluster() toString and pronunciation is correct', () {
    final x = Mono.X.gram;
    final hline = Quads.Line.down;
    final six = x.merge(hline);

    expect(six.toString(), "X * Down_Line");
    expect(six.pronunciation.length, 2);
    expect(six.pronunciation.first, Syllable.cvc(Cons.g, Vowel.a, Coda.k));
    expect(six.pronunciation.last, Syllable.v(Vowel.u));

    final vline = Quads.Line.up;
    final hash = vline.next(vline).mergeCluster(hline.next(hline));
    expect(hash.toString(), "Up_Line . Up_Line * (Down_Line . Down_Line)");
    expect(hash.pronunciation.length, 4);
    expect(hash.pronunciation[0], Syllable.vc(Vowel.i, Coda.th));
    expect(hash.pronunciation[1], Syllable.vc(Vowel.i, Coda.k));
    expect(hash.pronunciation[2], Syllable.cvc(Cons.h, Vowel.u, Coda.h));
    expect(hash.pronunciation[3], Syllable.v(Vowel.u));
  });

  test('over() and overCluster() toString and pronunciation is correct', () {
    final dot = Mono.Dot.gram;
    final vline = Quads.Line.up;
    final child = dot.over(vline);

    expect(child.toString(), "Dot / Up_Line");
    expect(child.pronunciation.length, 2);
    expect(child.pronunciation.first, Syllable.vc(Vowel.a, Coda.s));
    expect(child.pronunciation.last, Syllable.v(Vowel.i));
    expect(child.pronunciation.toString(), 'asi');

    final cornerDown = Quads.Corner.down;
    final cornerLeft = Quads.Corner.left;
    final feet = dot.overCluster(cornerDown.next(cornerLeft));
    expect(feet.toString(), "Dot / (Down_Corner . Left_Corner)");
    expect(feet.pronunciation.length, 3);
    expect(feet.pronunciation[0], Syllable.vc(Vowel.a, Coda.s));
    expect(feet.pronunciation[1], Syllable.cvc(Cons.p, Vowel.u, Coda.h));
    expect(feet.pronunciation[2], Syllable(Cons.b, Vowel.o));
    expect(feet.pronunciation.toString(), 'aspuhbo');
  });

  test('next() and nextCluster() toString and pronunciation is correct', () {
    final lArc = Quads.Arc.left;
    final rFlow = Quads.Flow.right;
    final talk = lArc.next(rFlow);

    expect(talk.toString(), "Left_Arc . Right_Flow");
    expect(talk.pronunciation.length, 2);
    expect(talk.pronunciation.first, Syllable(Cons.m, Vowel.o));
    expect(talk.pronunciation.last, Syllable(Cons.f, Vowel.e));
    expect(talk.pronunciation.toString(), 'mofe');

    final rSlash = Quads.Line.right;
    final bSlash = Quads.Line.left;
    final shout = lArc.nextCluster(rSlash.over(bSlash));
    expect(shout.toString(), "Left_Arc . (Right_Line / Left_Line)");
    expect(shout.pronunciation.length, 3);
    expect(shout.pronunciation[0], Syllable(Cons.m, Vowel.o));
    expect(shout.pronunciation[1], Syllable.cvc(Cons.h, Vowel.e, Coda.z));
    expect(shout.pronunciation[2], Syllable.v(Vowel.o));
    expect(shout.pronunciation.toString(), 'mohezo');
  });

  test('wrap() and wrapCluster() toString and pronunciation is correct', () {
    final circle = Mono.Circle.gram;
    final dot = Mono.Dot.gram;
    final eye = circle.wrap(dot);

    expect(eye.toString(), "Circle @ Dot");
    expect(eye.pronunciation.length, 2);
    expect(eye.pronunciation.first, Syllable.cvc(Cons.m, Vowel.a, Coda.n));
    expect(eye.pronunciation.last, Syllable.v(Vowel.a));
    expect(eye.pronunciation.toString(), 'mana');

    final gateDown = Quads.Gate.down;
    final family = circle.wrapCluster(dot.next(dot).over(gateDown));
    expect(family.toString(), "Circle @ (Dot . Dot / Down_Gate)");
    expect(family.pronunciation.length, 4);
    expect(family.pronunciation[0], Syllable.cvc(Cons.m, Vowel.a, Coda.n));
    expect(family.pronunciation[1], Syllable.cvc(Cons.h, Vowel.a, Coda.th));
    expect(family.pronunciation[2], Syllable.vc(Vowel.a, Coda.z));
    expect(family.pronunciation[3], Syllable(Cons.d, Vowel.u));
    expect(family.pronunciation.toString(), 'manhathazdu');
  });
}
