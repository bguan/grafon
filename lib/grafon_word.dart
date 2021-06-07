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

/// Library to deal with words
library grafon_word;

import 'dart:math';

import 'package:vector_math/vector_math.dart';

import 'expr_render.dart';
import 'grafon_expr.dart';
import 'gram_infra.dart';
import 'phonetics.dart';

/// Word has meaning but not all gram expr is a valid word so it needs a class.
abstract class GrafonWord {
  final String key;
  final String description;

  Pronunciation get pronunciation;

  RenderPlan get renderPlan;

  GrafonWord(this.key, [String? description])
      : this.description = description ?? '';

  double widthAtHeight(double devHeight) =>
      renderPlan.calcWidthByHeight(devHeight);
}

/// Core Word
class CoreWord extends GrafonWord {
  static const MIN_WIDTH_RATIO = 2 / 3;
  final GrafonExpr expr;
  final Pronunciation pronunciation;
  late final RenderPlan renderPlan;

  CoreWord(this.expr, [String? key, String? description])
      : this.pronunciation = expr.pronunciation,
        super(key ?? expr.toString(), description) {
    var r = expr.renderPlan;

    /// Make sure word rendering is not too narrow or too wide
    if ((MIN_WIDTH_RATIO - r.widthRatio) > 0.1 ||
        r.widthRatio > 2 * MIN_WIDTH_RATIO) {
      final s = (r.widthRatio < MIN_WIDTH_RATIO
              ? MIN_WIDTH_RATIO
              : min(MIN_WIDTH_RATIO * r.widthRatio, sqrt(r.widthRatio))) /
          r.widthRatio;
      r = r
          .remap(
              (isFixed, v) => isFixed ? v * min(s, 1) : Vector2(v.x * s, v.y))
          .reCenter();

      if ((MIN_WIDTH_RATIO - r.widthRatio) > 0.1) {
        final w = MIN_WIDTH_RATIO * r.height;
        r = RenderPlan([
          ...r.lines,
          InvisiDot([Vector2(-w / 2, 0), Vector2(w / 2, 0)]),
        ]);
      }
    }
    renderPlan = r;
  }

  @override
  String toString() => '$runtimeType($expr)';
}

/// Compound Words combines CoreWords into another word.
class CompoundWord extends GrafonWord {
  static const SEPARATOR_SYMBOL = ':';
  static const PRONUNCIATION_LINK = Coda.ng;

  final Iterable<CoreWord> words;
  late final Pronunciation pronunciation;
  late final RenderPlan renderPlan;

  CompoundWord(this.words, [String? key, String? description])
      : super(
          key ?? words.map((w) => w.toString()).join("$SEPARATOR_SYMBOL"),
          description,
        ) {
    if (words.length < 2)
      throw ArgumentError('Minimum 2 words; only ${words.length} given.');

    RenderPlan? r;
    for (var w in words) {
      final wr = w.renderPlan;
      if (r == null) {
        r = wr;
        continue;
      }
      r = r.byBinary(Binary.Next, wr);
    }
    renderPlan = r!;

    List<Syllable> syllables = [];
    for (var w in words.take(words.length - 1)) {
      final wsl = w.pronunciation.syllables;
      syllables.addAll(wsl.take(wsl.length - 1));
      final last = wsl.last;
      syllables.add(Syllable(last.cons, last.vowel, last.endVowel, Coda.ng));
    }
    syllables.addAll(words.last.pronunciation.syllables);
    pronunciation = Pronunciation(syllables);
  }

  @override
  String toString() =>
      '$runtimeType(' +
      words.map((w) => w.toString()).join("$SEPARATOR_SYMBOL") +
      ')';
}

/// Entry of a Word in WordGroup
class WordGroupEntry {
  final String key;
  final GrafonWord word;
  final String description;

  WordGroupEntry(this.word, [String? key, String? description])
      : this.key = key ?? word.toString(),
        this.description = description ?? '';
}

/// A Group of Related Words
class WordGroup {
  String title;
  String description;
  GrafonWord logo;
  Map<String, GrafonWord> _key2word;

  WordGroup(
      this.title, this.logo, this.description, Iterable<GrafonWord> entries)
      : this._key2word = {
          for (var e in entries) e.key: e,
        };

  Iterable<String> get keys => _key2word.keys;

  Iterable<GrafonWord> get values => _key2word.values;

  bool contains(String key) => _key2word.containsKey(key);

  GrafonWord? operator [](String key) => _key2word[key];
}
