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

import 'package:grafon/grafon_expr.dart';
import 'package:grafon/grafon_word_parser.dart';
import 'package:grafon/gram_table.dart';
import 'package:grafon/phonetics.dart';
import 'package:petitparser/reflection.dart';
import 'package:test/test.dart';

/// Unit Test for phonetics
void main() {
  test('detect parser common problems', () {
    final gp = GrafonParser();
    expect(linter(gp.parser), isEmpty);
  });

  test('parsing a specific simple Gram', () {
    final gp = GrafonParser();
    expect(
      gp.parse("mi"),
      Quads.Bow.up,
    );
  });

  test('parsing an invalid Gram', () {
    final gp = GrafonParser();
    expect(() => gp.parse("xy"), throwsA(isA<FormatException>()));
  });

  test('parsing all simple Grams in Gram Table', () {
    final gTab = GramTable();
    final gp = GrafonParser();
    for (var c in Cons.values) {
      for (var v in Vowel.values.where((v) => v.isBase)) {
        expect(
          gp.parse("${c.shortName}${v.shortName}"),
          gTab.atConsVowel(c, v),
        );
      }
    }
  });

  test('parsing expr: gichdu', () {
    final gp = GrafonParser();
    expect(
      gp.parse("gichdu"),
      Quads.Angle.up.mix(Quads.Gate.down),
    );
  });

  test('parsing expr: gidu', () {
    final gp = GrafonParser();
    expect(
      gp.parse("gidu"),
      Quads.Angle.up.next(Quads.Gate.down),
    );
  });

  test('parsing expr: gishdu', () {
    final gp = GrafonParser();
    expect(
      gp.parse("gishdu"),
      Quads.Angle.up.over(Quads.Gate.down),
    );
  });

  test('parsing expr: gingdu', () {
    final gp = GrafonParser();
    expect(
      gp.parse("gingdu"),
      Quads.Angle.up.wrap(Quads.Gate.down),
    );
  });

  test('parsing all grams all ops all grams', () {
    final gTab = GramTable();
    final gp = GrafonParser();
    for (var c1 in Cons.values) {
      for (var v1 in Vowel.values.where((v) => v.isBase)) {
        for (var o in Op.values) {
          for (var c2 in Cons.values) {
            for (var v2 in Vowel.values.where((v) => v.isBase)) {
              String os = o.coda.shortName;
              final c1n = c1.shortName;
              final v1n = v1.shortName;
              final c2n = c2.shortName;
              final v2n = v2.shortName;
              final input = "$c1n$v1n$os$c2n$v2n";
              expect(
                gp.parse(input),
                BinaryOpExpr(
                  gTab.atConsVowel(c1, v1),
                  o,
                  gTab.atConsVowel(c2, v2),
                ),
                reason: "Failed to parse '$input'.",
              );
            }
          }
        }
      }
    }
  });

  test('parsing expr: nolashni', () {
    final gp = GrafonParser();
    expect(
      gp.parse("nolashni"),
      Quads.Arc.left.next(Mono.Star.gram).over(Quads.Arc.up),
    );
  });

  test('parsing expr: nowanglay', () {
    final gp = GrafonParser();
    expect(
      gp.parse("nowanglay"),
      Quads.Arc.left.next(ClusterExpr(Mono.Empty.wrap(Mono.Star.gram))),
    );
  });

  test('parsing expr: pwanghayfe', () {
    final gp = GrafonParser();
    expect(
      gp.parse("pwanghayfe"),
      ClusterExpr(Mono.Hex.wrap(Mono.Dot.gram)).next(Quads.Wave.right),
    );
  });

  test('parsing expr: pwangochheyfe', () {
    final gp = GrafonParser();
    expect(
      gp.parse("pwangochheyfe"),
      ClusterExpr(Mono.Hex.wrap(Quads.Line.left.mix(Quads.Dots.right)))
          .next(Quads.Wave.right),
    );
  });
}
