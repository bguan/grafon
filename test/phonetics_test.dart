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

import 'package:grafon/phonetics.dart';
import 'package:test/test.dart';

/// Unit Test for phonetics
void main() {
  test('ConsPair should cover all consonants', () {
    final consFromPairs = Set.of([
      ...ConsPair.values.map((cp) => cp.base),
      ...ConsPair.values.map((cp) => cp.head)
    ]);

    expect(consFromPairs, Set.of(Consonant.values));
  });

  test('Consonants should cover all ConsPair', () {
    final conspairFromCons = Set.of([
      ...Consonant.values.map((c) => c.pair),
    ]);

    expect(conspairFromCons, Set.of(ConsPair.values));
  });

  test('Consonants short names should all be unique', () {
    final shortNamesFromCons = Set.of([
      ...Consonant.values.map((c) => c.shortName),
    ]);

    expect(shortNamesFromCons.length, Consonant.values.length);
  });

  test('ConsPairs short names should all be unique', () {
    final shortNamesFromConspair = Set.of([
      ...ConsPair.values.map((cp) => cp.shortName),
    ]);

    expect(shortNamesFromConspair.length, ConsPair.values.length);
  });

  test('ConsPair base and head should not overlap', () {
    final baseFromPairs = Set.of([
      ...ConsPair.values.map((cp) => cp.base),
    ]);

    final headFromPairs = Set.of([
      ...ConsPair.values.map((cp) => cp.head),
    ]);

    expect(baseFromPairs.intersection(headFromPairs), Set.of([]));
  });
}
