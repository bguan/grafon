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
    if (r.widthRatio < MIN_WIDTH_RATIO || r.widthRatio > 2 * MIN_WIDTH_RATIO) {
      final s = (r.widthRatio < MIN_WIDTH_RATIO
              ? MIN_WIDTH_RATIO
              : sqrt(r.widthRatio)) /
          r.widthRatio;
      r = r.remap(
          (isFixed, v) => isFixed ? v * min(s, 1) : Vector2(v.x * s, v.y));

      if (r.widthRatio < MIN_WIDTH_RATIO) {
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

final w = WordGroup(
    'Edge Cases',
    CoreWord(Mono.X.over(Mono.X.gram).merge(Quads.Line.up)),
    'Random tricky edge cases for rendering.', [
  CoreWord(Quads.Angle.up.over(Quads.Arc.down)),
  CoreWord(ClusterExpr(Quads.Arc.up.next(Quads.Arc.up)).over(Quads.Angle.down)),
  CoreWord(Mono.Dot.up().merge(Quads.Step.left)),
  CoreWord(Mono.Dot.left().over(Quads.Corner.up)),
  CoreWord(Mono.Circle.wrap(Mono.Dot.gram)
      .next(Quads.Arc.left)
      .next(Quads.Flow.right)),
]);

final testGroup = WordGroup(
  'Test',
  CoreWord(Mono.Circle.next(Mono.Square.gram)
      .overCluster(Quads.Triangle.up.next(Mono.Diamond.gram))),
  'Test expression rendering...',
  [
    CoreWord(Mono.Circle.wrap(Mono.Dot.gram)
        .next(Quads.Arc.left)
        .next(Quads.Flow.right)),
    CoreWord(Mono.Dot.shrink()),
    CoreWord(Mono.Dot.shrink().over(Mono.Square.gram)),
    CoreWord(Mono.Dot.up()),
    CoreWord(Mono.Dot.up().over(Mono.Square.gram)),
    CoreWord(Mono.Dot.down()),
    CoreWord(Mono.Dot.down().over(Mono.Square.gram)),
    CoreWord(Mono.Dot.left()),
    CoreWord(Mono.Dot.left().over(Mono.Square.gram)),
    CoreWord(Mono.Dot.right()),
    CoreWord(Mono.Dot.right().over(Mono.Square.gram)),
    CoreWord(Mono.Circle.next(Quads.Angle.up)),
    CoreWord(Mono.Circle.next(Quads.Angle.up)),
    CoreWord(Mono.Circle.over(Quads.Angle.up)),
    CoreWord(Mono.Circle.merge(Quads.Angle.up)),
    CoreWord(Mono.Circle.merge(Quads.Angle.up.shrink())),
    CoreWord(Mono.Circle.merge(Quads.Angle.up.up())),
    CoreWord(Mono.Circle.merge(Quads.Angle.up.down())),
    CoreWord(Mono.Circle.merge(Quads.Angle.up.left())),
    CoreWord(Mono.Circle.merge(Quads.Angle.up.right())),
    CoreWord(Mono.Circle.wrap(Quads.Angle.up)),
    CoreWord(Mono.Circle.wrap(Quads.Angle.up.up())),
    CoreWord(Mono.Circle.wrap(Quads.Angle.up.down())),
    CoreWord(Mono.Circle.wrap(Quads.Angle.up.left())),
    CoreWord(Mono.Circle.wrap(Quads.Angle.up.right())),
    CoreWord(Mono.Circle.wrap(Quads.Angle.up.shrink())),
    CoreWord(Mono.Circle.wrapCluster(
        Quads.Angle.up.next(Quads.Angle.up).next(Quads.Angle.up))),
  ],
);

final numericGroup = WordGroup(
  'Numeric',
  CoreWord(Mono.X.over(Mono.X.gram).merge(Quads.Line.up)),
  'Numbers and counting...',
  [
    CoreWord(Mono.Circle.gram, "Zero"),
    CoreWord(Quads.Line.up, "One"),
    CoreWord(Quads.Corner.right, "Two"),
    CoreWord(Quads.Gate.up, "Three"),
    CoreWord(Mono.Square.gram, "Four"),
    CoreWord(Mono.Diamond.merge(Quads.Line.down), "Five"),
    CoreWord(Mono.X.merge(Quads.Line.down), "Six"),
    CoreWord(Mono.Square.merge(Quads.Angle.down), "Seven"),
    CoreWord(Mono.Diamond.merge(Mono.Cross.gram), "Eight"),
    CoreWord(Quads.Triangle.up.wrap(Quads.Triangle.down), "Nine"),
    CoreWord(Quads.Line.down.over(Mono.Circle.gram), "Ten",
        "Ten(s), ten to the power of 1."),
    CoreWord(Quads.Corner.right.over(Mono.Circle.gram), "Hundred",
        "Hundred(s), ten to the power of 2."),
    CoreWord(Quads.Gate.up.over(Mono.Circle.gram), "Thousand",
        "Thousand(s), ten to the power of 3."),
  ],
);

final interpersonalGroup = WordGroup(
  'Interpersonal',
  CoreWord(Mono.Dot.next(Mono.Dot.gram).over(Quads.Gate.down),
      "Interpersonal-Relationship"),
  'People, pronoun...',
  [
    CoreWord(Mono.Circle.over(Quads.Line.up), "Person", "Person, Adult."),
    CoreWord(Mono.Dot.over(Quads.Line.up), "Child"),
    CoreWord(Quads.Angle.up.up().merge(Quads.Line.up).over(Mono.Circle.gram),
        "Man", "Man, adult male."),
    CoreWord(
        Mono.Circle.over(Mono.Cross.gram), "Woman", "Woman, adult female."),
    CoreWord(Mono.Dot.up().merge(Quads.Step.left), "I",
        "I, first person singular pronoun."),
    CoreWord(Mono.Dot.left().over(Quads.Corner.up), "You",
        "You, second person singular pronoun."),
    CoreWord(Mono.Dot.right().over(Quads.Corner.right), "Ze",
        "He or she, third person singular pronoun."),
    CompoundWord([
      CoreWord(Mono.Dot.up().merge(Quads.Step.left)),
      CoreWord(Mono.Dot.down().over(Mono.Dot.gram))
    ], "We", "We, first person plural pronoun."),
    CompoundWord([
      CoreWord(Mono.Dot.left().over(Quads.Corner.up)),
      CoreWord(Mono.Dot.down().over(Mono.Dot.gram))
    ], "Yous", "You, second person plural pronoun."),
    CompoundWord([
      CoreWord(Mono.Dot.right().over(Quads.Corner.right)),
      CoreWord(Mono.Dot.down().over(Mono.Dot.gram))
    ], "They", "They, third person plural pronoun."),
    CoreWord(Mono.Dot.next(Mono.Dot.gram).over(Quads.Gate.up), "Couple"),
    CoreWord(
        Mono.Circle.wrapCluster(
            Mono.Dot.next(Mono.Dot.gram).over(Quads.Gate.down)),
        "Family"),
  ],
);

final demoGroup = WordGroup(
  'Demo',
  CompoundWord([
    CoreWord(Mono.Circle.wrap(Mono.Dot.gram)),
    CoreWord(Quads.Arc.left.next(Quads.Flow.right)),
  ]),
  'This group is a collection of words that demonstrates the Grafon ' +
      'system of logo-graphic and phonetic writing to showcase its strength.',
  [
    CoreWord(Quads.Angle.up.over(Quads.Gate.down), "House",
        "House, dwelling, building."),
    CoreWord(
        Mono.Sun.gram.over(Quads.Line.down), "Day", "Sun over land, day time."),
    CoreWord(Quads.Flow.right.over(Quads.Flow.right), "Water"),
    CoreWord(Quads.Flow.down.next(Quads.Flow.down), "Rain"),
    CoreWord(Quads.Arc.left.next(Quads.Flow.right), "Talk", "Talk, speech."),
    CoreWord(Quads.Arc.left.next(Quads.Arc.right), "Leaf"),
    CoreWord(Quads.Angle.down.shrink().merge(Quads.Line.up), "Wood"),
    CoreWord(Quads.Angle.up.over(Quads.Arc.down), "Drip"),
    CoreWord(Mono.Light.wrap(Quads.Zap.down), "White",
        "White, light from lightning."),
    CoreWord(Mono.Light.wrap(Mono.Sun.gram), "Red", "Red, light from Sun."),
    CoreWord(Mono.Light.wrap(Mono.Flower.gram), "Yellow",
        "Yellow, light from flower."),
    CoreWord(Mono.Light.wrapCluster(Quads.Arc.left.next(Quads.Arc.right)),
        "Green", "Green, light from leaf."),
    CoreWord(
        Mono.Light.wrapCluster(Quads.Angle.down.shrink().merge(Quads.Line.up)),
        "Brown",
        "Brown, Color of wood."),
    CoreWord(Mono.Light.wrapCluster(Quads.Flow.right.over(Quads.Flow.right)),
        "Blue", "Blue, light from water."),
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
