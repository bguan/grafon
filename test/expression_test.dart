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
        expect(qg.toString(),
            "${m.quadPeer.shortName} ${f.shortName.toLowerCase()}");
      }
    }
  });

  test('SingleGram pronunciation matches gram equivalent', () {
    for (final cp in ConsPair.values) {
      for (final v in Vowel.values) {
        final g = GramTable.atConsPairVowel(cp, v);
        expect(
            g.pronunciation,
            (cp == ConsPair.aHa ? '' : cp.base.shortName) +
                (cp == ConsPair.aHa ? v.shortName : v.shortName.toLowerCase()));
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
    expect(sun.pronunciation, "Za");

    final house = Quads.Angle.up.merge(Quads.Gate.down);
    expect(house.toString(), "Angle up * Gate down");
    expect(house.pronunciation, "GiDu");

    final person = Mono.Dot.gram.over(Quads.Line.up);
    expect(person.toString(), "Dot / Line up");
    expect(person.pronunciation, "ArI");

    final rain = Quads.Flow.down.before(Quads.Flow.down);
    expect(rain.toString(), "Flow down | Flow down");
    expect(rain.pronunciation, "VuzVu");

    final speech = Quads.Gate.left.around(Quads.Flow.right);
    expect(speech.toString(), "Gate left @ Flow right");
    expect(speech.pronunciation, "DonVe");

    final starMan = sun.compound(person); // God? Alien?
    expect(starMan.toString(), "Sun : Dot / Line up");
    expect(starMan.pronunciation, "ZangArI");

    // Red is the light from a Flower
    final red = Mono.Light.gram.around(Mono.Flower.gram);
    expect(red.toString(), "Light @ Flower");
    expect(red.pronunciation, "JanVa");
  });
}
