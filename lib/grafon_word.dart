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

library grafon_word;

import 'dart:math';

import 'package:vector_math/vector_math.dart';

import 'expr_render.dart';
import 'grafon_expr.dart';
import 'gram_infra.dart';
import 'gram_table.dart';
import 'phonetics.dart';

/// Word has meaning but not all gram expr is a valid word so it needs a class.
abstract class GrafonWord {
  final String key;
  final String description;

  Pronunciation get pronunciation;

  RenderPlan get renderPlan;

  GrafonWord(this.key, [String? description])
      : this.description = description ?? '';

  double flexRenderWidth(double devHeight) =>
      renderPlan.flexRenderWidth(devHeight);
}

/// Core Word
class CoreWord extends GrafonWord {
  final GrafonExpr expr;
  final Pronunciation pronunciation;
  late final RenderPlan renderPlan;

  CoreWord(this.expr, [String? key, String? description])
      : this.pronunciation = expr.pronunciation,
        super(key ?? expr.toString(), description) {
    var r = expr.renderPlan;

    /// Make sure word rendering is not too narrow or too wide
    if (r.widthRatio < .75 || r.widthRatio > 1.75) {
      final wScale =
          (r.widthRatio < .75 ? .75 : sqrt(r.widthRatio)) / r.widthRatio;

      r = RenderPlan(r.lines.where((l) => l is! InvisiDot).map((l) {
        if (l.isFixedAspect) {
          final dx = l.center.x * (wScale - 1);
          return l.diffPoints(l.vectors.map((v) => Vector2(v.x + dx, v.y)));
        } else {
          return l.diffPoints(l.vectors.map((v) => Vector2(v.x * wScale, v.y)));
        }
      }));
    }
    renderPlan = r;
  }

  @override
  String toString() => '$runtimeType($expr)';
}

/// Compound Words combines CoreWords into another word.
class CompoundWord extends GrafonWord {
  static const SEPARATOR_SYMBOL = ':';
  static const PRONUNCIATION_LINK = EndConsonant.ng;

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
      if (r == null) {
        r = w.renderPlan;
        continue;
      }
      r = r.byBinary(Binary.Next, w.renderPlan);
    }
    renderPlan = r!;

    List<Syllable> syllables = [];
    for (var w in words.take(words.length - 1)) {
      final wsl = w.pronunciation.syllables;
      syllables.addAll(wsl.take(wsl.length - 1));
      final last = wsl.last;
      syllables.add(
          Syllable(last.consonant, last.vowel, last.endVowel, EndConsonant.ng));
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

final testGroup = WordGroup(
  'Test',
  CoreWord(Quads.Line.up.over(Mono.Dot.shrink())),
  'Test expression rendering...',
  [
    CoreWord(Quads.Angle.up.shrink()),
    CoreWord(Mono.Circle.next(Quads.Angle.up)),
    CoreWord(Mono.Circle.over(Quads.Angle.up)),
    CoreWord(Mono.Circle.wrap(Quads.Angle.up)),
    CoreWord(Mono.Circle.merge(Quads.Angle.up)),
    CoreWord(Mono.Circle.merge(Quads.Angle.up.shrink())),
    CoreWord(Mono.Circle.merge(Quads.Angle.up.up())),
    CoreWord(Mono.Circle.merge(Quads.Angle.up.down())),
    CoreWord(Mono.Circle.merge(Quads.Angle.up.left())),
    CoreWord(Mono.Circle.merge(Quads.Angle.up.right())),
    CoreWord(Mono.Circle.wrap(Quads.Angle.up.up())),
    CoreWord(Mono.Circle.wrap(Quads.Angle.up.down())),
    CoreWord(Mono.Circle.wrap(Quads.Angle.up.left())),
    CoreWord(Mono.Circle.wrap(Quads.Angle.up.right())),
    CoreWord(Mono.Circle.wrap(Quads.Angle.up.shrink())),
  ],
);

final numericGroup = WordGroup(
  'Numeric',
  CoreWord(Quads.Step.up),
  'Numbers and counting...',
  [
    CoreWord(Mono.Circle.gram, "Zero"),
    CoreWord(Quads.Line.up, "One"),
    CoreWord(Quads.Corner.right, "Two"),
    CoreWord(Quads.Gate.right, "Three"),
    CoreWord(Mono.Square.gram, "Four"),
    CoreWord(Mono.Square.gram.merge(Quads.Line.left), "Five"),
    CoreWord(Quads.Gate.right.merge(Quads.Angle.right), "Six"),
    CoreWord(Mono.Square.merge(Quads.Angle.right), "Seven"),
    CoreWord(Mono.Square.merge(Mono.X.gram), "Eight"),
    CoreWord(Mono.Square.merge(Quads.Zap.down), "Nine"),
    CoreWord(Mono.Circle.next(Quads.Line.up.up()), "Ten",
        "Ten(s), ten to the power of 1."),
    CoreWord(Mono.Circle.next(Quads.Corner.right.up()), "Hundred",
        "Hundred(s), ten to the power of 2."),
    CoreWord(Mono.Circle.next(Quads.Gate.right.up()), "Thousand",
        "Thousand(s), ten to the power of 3."),
  ],
);

final interpersonalGroup = WordGroup(
  'Interpersonal',
  CoreWord(
      Mono.Dot.next(Mono.Dot.gram).over(Quads.Gate.down).wrap(Quads.Flow.right),
      "Interpersonal-Relationship"),
  'People, pronoun...',
  [
    CoreWord(Quads.Step.right.merge(Mono.Circle.up()), "I",
        "I, first person singular pronoun."),
    CoreWord(Mono.Circle.left().over(Quads.Corner.up), "You",
        "You, second person singular pronoun."),
    CoreWord(Mono.Circle.right().over(Quads.Corner.right), "Ze",
        "He or she, third person singular pronoun."),
    CoreWord(
        Quads.Step.right.merge(Mono.Circle.up()).next(Quads.Flow.right.down()),
        "We",
        "We, first person plural pronoun."),
    CoreWord(
        Mono.Circle.left().over(Quads.Corner.up).next(Quads.Flow.right.down()),
        "Yous",
        "You, second person plural pronoun."),
    CoreWord(
        Mono.Circle.right()
            .over(Quads.Corner.right)
            .next(Quads.Flow.right.down()),
        "They",
        "They, third person plural pronoun."),
    CoreWord(Mono.Dot.next(Mono.Dot.gram).over(Quads.Gate.up), "Couple"),
    CoreWord(
        Quads.Angle.up.overCluster(
            Mono.Dot.over(Quads.Line.up).next(Quads.Flow.right.down())),
        "Family"),
  ],
);

final demoGroup = WordGroup(
  'Demo',
  CompoundWord([
    CoreWord(Mono.Circle.wrap(Mono.Dot.gram)),
    CoreWord(Quads.Arc.left.next(Quads.Flow.right)),
  ]),
  'The Demo word group is a collection of words that demonstrates ' +
      'the Grafon system of logo phonetic writing to showcase its strength.',
  [
    CoreWord(Quads.Angle.up.over(Quads.Gate.down), "House",
        "House, dwelling, building."),
    CoreWord(Mono.Sun.gram.over(Quads.Line.down), "Day", "Day time, day."),
    CoreWord(Quads.Flow.right.over(Quads.Flow.right), "Water"),
    CoreWord(Quads.Flow.down.next(Quads.Flow.down), "Rain"),
    CoreWord(Quads.Arc.left.next(Quads.Flow.right), "Talk", "Talk, speech."),
    CoreWord(Quads.Arc.left.next(Quads.Arc.right), "Leaf"),
    CoreWord(Quads.Angle.up.over(Quads.Arc.down), "Drip"),
    CoreWord(Mono.Light.wrap(Quads.Zap.down), "White",
        "White, light from lightning."),
    CoreWord(
        Mono.Light.wrap(Mono.Flower.gram), "Red", "Red, light from flower."),
    CoreWord(Mono.Light.wrapCluster(Quads.Arc.left.next(Quads.Arc.right)),
        "Green", "Green, light from leaf."),
    CoreWord(
        Mono.Light.wrap(Quads.Flow.right), "Blue", "Blue, light from water."),
    CoreWord(Mono.Light.wrap(Mono.X.gram), "Black", "Black, no light."),
    CoreWord(
        ClusterExpr(Quads.Arc.up.next(Quads.Arc.up)).over(Quads.Angle.down),
        "Heart",
        "Heart, Love."),
    CompoundWord(
        [CoreWord(Mono.Sun.gram), CoreWord(Mono.Circle.over(Quads.Line.up))],
        "Star-being",
        "Alien, god?"),
  ],
);
