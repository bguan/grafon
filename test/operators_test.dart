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
import 'package:grafon/operators.dart';

/// Unit Tests for Operators
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
      ...Binary.values.map((b) => b.ending),
    ]);
    expect(endingsFromBinary.length, Binary.values.length);
  });
}
