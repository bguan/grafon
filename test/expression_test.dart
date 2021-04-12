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
import 'package:grafon/gram_infra.dart';
import 'package:grafon/gram_table.dart';
import 'package:grafon/operators.dart';
import 'package:grafon/phonetics.dart';

/// Unit Tests for Expressions
void main() {
  test('SingleGram to String matches gram equivalent', () {
    for (final m in Mono.values) {
      final mg = GramTable.atMonoFace(m, Face.Center);
      expect(mg.toString(), m.shortName);
      for (final f in FaceHelper.directionals) {
        final qg = GramTable.atMonoFace(m, f);
        expect(qg.toString(), "${m.quadPeer.shortName}.${f.shortName}");
      }
    }
  });

  test('SingleGram pronunciation matches gram equivalent', () {
    for (final cp in ConsPair.values) {
      for (final v in Vowel.values) {
        final g = GramTable.atConsPairVowel(cp, v);
        expect(
            g.pronunciation,
            (cp == ConsPair.AHA ? '' : cp.base.shortName) +
                (cp == ConsPair.AHA ? v.shortName : v.shortName.toLowerCase()));
      }
    }
  });

  test('UnaryExpr to String is correct', () {
    for (final m in Mono.values) {
      for (final f in Face.values) {
        final g = GramTable.atMonoFace(m, f);
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
        final g = GramTable.atMonoFace(m, f);
        expect(g.shrink().pronunciation,
            g.pronunciation + Unary.Shrink.ending.shortName.toLowerCase());
        expect(
          g.up().pronunciation,
          g.pronunciation + Unary.Up.ending.shortName.toLowerCase(),
        );
        expect(
          g.down().pronunciation,
          g.pronunciation + Unary.Down.ending.shortName.toLowerCase(),
        );
        expect(
          g.left().pronunciation,
          g.pronunciation + Unary.Left.ending.shortName.toLowerCase(),
        );
        expect(
          g.right().pronunciation,
          g.pronunciation + Unary.Right.ending.shortName.toLowerCase(),
        );
      }
    }
  });

  test('BinaryExpr toString and pronunciation is correct', () {
    final sun = Mono.Sun.gram; // or star
    expect(sun.toString(), "Sun");
    expect(sun.pronunciation, "Je");

    final house = Quad.Angle.up.over(Quad.Gate.up);
    expect(house.toString(), "Angle.Up / Gate.Up");
    expect(house.pronunciation, "GisDi");

    final person = Mono.Dot.gram.over(Quad.Line.up);
    expect(person.toString(), "Dot / Line.Up");
    expect(person.pronunciation, "SesI");

    final day = sun.over(Quad.Line.down);
    expect(day.toString(), "Sun / Line.Down");
    expect(day.pronunciation, "JesU");

    final rain = Quad.Flow.down.before(Quad.Flow.down);
    expect(rain.toString(), "Flow.Down | Flow.Down");
    expect(rain.pronunciation, "VuVu");

    final speech = Quad.Arc.right.around(Quad.Flow.right);
    expect(speech.toString(), "Arc.Right @ Flow.Right");
    expect(speech.pronunciation, "MamVa");

    final nine = Mono.Square.gram.merge(Quad.Line.up);
    expect(nine.toString(), "Square * Line.Up");
    expect(nine.pronunciation, "DelI");

    final starMan = sun.compound(person); // God? Alien?
    expect(starMan.toString(), "Sun : Dot / Line.Up");
    expect(starMan.pronunciation, "JengSesI");
  });
}
