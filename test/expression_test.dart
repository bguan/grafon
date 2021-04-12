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
import 'package:grafon/expression.dart';
import 'package:grafon/gram_infra.dart';
import 'package:grafon/gram_table.dart';
import 'package:grafon/operators.dart';
import 'package:grafon/phonetics.dart';

/// Unit Tests for Expressions
void main() {
  test('SingleGram to String matches gram equivalent', () {
    for (final m in Mono.values) {
      final mg = GramTable.atMonoFace(m, Face.Center);
      final sm = SingleGram(mg);
      expect(sm.toString(), m.shortName);
      for (final f in FaceHelper.directionals) {
        final q = GramTable.atMonoFace(m, f);
        final sq = SingleGram(q);
        expect(sq.toString(), "${m.quadPeer.shortName}.${f.shortName}");
      }
    }
  });

  test('SingleGram pronunciation matches gram equivalent', () {
    for (final cp in ConsPair.values) {
      for (final v in Vowel.values) {
        final g = GramTable.atConsPairVowel(cp, v);
        final single = SingleGram(g);
        expect(
            single.pronunciation,
            (cp == ConsPair.AHA ? '' : cp.base.shortName) +
                v.shortName.toLowerCase());
      }
    }
  });

  test('UnaryExpr to String is correct', () {
    for (final m in Mono.values) {
      for (final f in Face.values) {
        final g = GramTable.atMonoFace(m, f);
        final sg = SingleGram(g);
        expect(sg.shrink().toString(), Unary.Shrink.symbol + sg.toString());
        expect(sg.up().toString(), Unary.Up.symbol + sg.toString());
        expect(sg.down().toString(), Unary.Down.symbol + sg.toString());
        expect(sg.left().toString(), Unary.Left.symbol + sg.toString());
        expect(sg.right().toString(), Unary.Right.symbol + sg.toString());
      }
    }
  });

  test('UnaryExpr pronunciation is correct', () {
    for (final m in Mono.values) {
      for (final f in Face.values) {
        final g = GramTable.atMonoFace(m, f);
        final sg = SingleGram(g);
        expect(sg.shrink().pronunciation,
            sg.pronunciation + Unary.Shrink.ending.shortName.toLowerCase());
        expect(
          sg.up().pronunciation,
          sg.pronunciation + Unary.Up.ending.shortName.toLowerCase(),
        );
        expect(
          sg.down().pronunciation,
          sg.pronunciation + Unary.Down.ending.shortName.toLowerCase(),
        );
        expect(
          sg.left().pronunciation,
          sg.pronunciation + Unary.Left.ending.shortName.toLowerCase(),
        );
        expect(
          sg.right().pronunciation,
          sg.pronunciation + Unary.Right.ending.shortName.toLowerCase(),
        );
      }
    }
  });
}
