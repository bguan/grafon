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

/// Library where dictionary is populated
library grafon_dictionary;

import 'grafon_word.dart';
import 'gram_table.dart';

final w = WordGroup(
    'Edge Cases',
    CoreWord(Mono.Circle.up().merge(Quads.Step.left)),
    'Random tricky edge cases for rendering.', [
  CoreWord(Quads.Curve.up.merge(Quads.Curve.down)),
  CoreWord(Quads.Line.up.merge(Quads.Angle.up.up())),
  CoreWord(Quads.Arc.left.next(Quads.Flow.right)),
  CoreWord(Quads.Triangle.up.wrap(Quads.Triangle.down)),
  CoreWord(Quads.Arc.left.next(Quads.Arc.right)),
  CoreWord(Quads.Angle.up.over(Quads.Arc.down)),
  CoreWord(Quads.Arc.up.next(Quads.Arc.up).over(Quads.Angle.down)),
  CoreWord(Mono.Dot.up().merge(Quads.Step.left)),
  CoreWord(Mono.Dot.left().over(Quads.Corner.up)),
  CoreWord(Mono.Circle.wrap(Mono.Dot.gram)
      .next(Quads.Arc.left)
      .next(Quads.Flow.right)),
]);

final testGroup = WordGroup(
  'Test',
  CoreWord(Mono.Circle.wrap(Mono.Dot.gram)
      .next(Quads.Arc.left)
      .next(Quads.Flow.right)),
  'Test expression rendering...',
  [
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
  CoreWord(Quads.Line.right.over(Quads.Line.right).merge(Quads.Line.up)),
  'Numbers and counting...',
  [
    CoreWord(Mono.Circle.gram, "Zero"),
    CoreWord(Quads.Line.up, "One"),
    CoreWord(Quads.Corner.right, "Two"),
    CoreWord(Quads.Gate.down, "Three"),
    CoreWord(Mono.Square.gram, "Four"),
    CoreWord(Mono.Diamond.merge(Quads.Line.down), "Five"),
    CoreWord(Mono.X.merge(Quads.Line.up), "Six"),
    CoreWord(Quads.Gate.up.merge(Mono.X.gram), "Seven"),
    CoreWord(Mono.Diamond.merge(Mono.Cross.gram), "Eight"),
    CoreWord(Quads.Triangle.down.wrap(Quads.Triangle.up), "Nine"),
    CoreWord(Mono.Circle.wrap(Quads.Line.up), "Ten",
        "Ten(s), ten to the power of 1."),
    CoreWord(Mono.Circle.wrap(Quads.Corner.right), "Hundred",
        "Hundred(s), ten to the power of 2."),
    CoreWord(Mono.Circle.wrap(Quads.Gate.up), "Thousand",
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
    CoreWord(Mono.Circle.up().merge(Quads.Step.left), "I",
        "I, first person singular pronoun."),
    CoreWord(Mono.Circle.left().over(Quads.Corner.up), "You",
        "You, second person singular pronoun."),
    CoreWord(Mono.Circle.right().over(Quads.Corner.right), "Ze",
        "He or she, third person singular pronoun."),
    CoreWord(
        Mono.Circle.up()
            .merge(Quads.Step.left)
            .next(Mono.Dot.gram)
            .next(Mono.Dot.gram),
        "We",
        "We, first person plural pronoun."),
    CoreWord(
        Mono.Circle.left()
            .over(Quads.Corner.up)
            .next(Mono.Dot.gram)
            .next(Mono.Dot.gram),
        "Yous",
        "You, second person plural pronoun."),
    CoreWord(
        Mono.Circle.right()
            .over(Quads.Corner.right)
            .next(Mono.Dot.gram)
            .next(Mono.Dot.gram),
        "They",
        "They, third person plural pronoun."),
    CoreWord(Mono.Dot.next(Mono.Dot.gram).over(Quads.Gate.up), "Couple"),
    CoreWord(
        Mono.Circle.wrapCluster(
            Mono.Dot.next(Mono.Dot.gram).over(Quads.Gate.down)),
        "Family"),
  ],
);

final spiritual = WordGroup(
    'Spiritual', CoreWord(Mono.Sun.over(Quads.Arc.up)), 'Spiritual.', [
  CoreWord(Mono.Cross.over(Quads.Arc.up)),
  CoreWord(Quads.Triangle.up.merge(Quads.Triangle.down).over(Quads.Arc.up)),
  CoreWord(Quads.Step.up.merge(Quads.Step.right).over(Quads.Arc.up)),
  CoreWord(Quads.Arc.left.next(Mono.Light.shrink()).over(Quads.Arc.up)),
  CoreWord(Mono.Circle.merge(Quads.Flow.down).over(Quads.Arc.up)),
  CoreWord(Mono.Square.merge(Mono.Diamond.gram)
      .wrap(Mono.Sun.gram)
      .over(Quads.Arc.up)),
  CoreWord(Mono.Dot.merge(Quads.Arc.down.shrink()).overCluster(
      Quads.Arc.right.over(Quads.Arc.right).next(Quads.Flow.left))),
]);

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
    CoreWord(Quads.Curve.right.next(Quads.Curve.up), "Grass"),
    CoreWord(Quads.Flow.right.over(Quads.Flow.right), "Water"),
    CoreWord(Quads.Flow.down.next(Quads.Flow.down), "Rain"),
    CoreWord(Quads.Arc.left.next(Quads.Flow.right), "Talk", "Talk, speech."),
    // CoreWord(Quads.Arc.left.next(Quads.Arc.right), "Leaf"),
    CoreWord(Quads.Curve.up.merge(Quads.Curve.down), "Leaf"),
    CoreWord(Quads.Angle.down.shrink().merge(Quads.Line.up), "Wood"),
    CoreWord(Quads.Corner.left.shrink().merge(Quads.Line.right), "Wood 2"),
    CoreWord(Quads.Angle.up.over(Quads.Arc.down), "Drip"),
    CoreWord(Mono.Light.wrap(Quads.Zap.down), "White",
        "White, light from lightning."),
    CoreWord(Mono.Light.wrap(Mono.Sun.gram), "Red", "Red, light from Sun."),
    CoreWord(Mono.Light.wrap(Mono.Flower.gram), "Yellow",
        "Yellow, light from flower."),
    CoreWord(Mono.Light.wrapCluster(Quads.Curve.up.merge(Quads.Curve.down)),
        "Green", "Green, light from leaf."),
    CoreWord(
        Mono.Light.wrapCluster(
            Quads.Corner.left.shrink().merge(Quads.Line.right)),
        "Brown",
        "Brown, Color of wood."),
    CoreWord(Mono.Light.wrapCluster(Quads.Flow.right.over(Quads.Flow.right)),
        "Blue", "Blue, light from water."),
    CoreWord(Mono.Light.wrap(Mono.X.gram), "Black", "Black, no light."),
    CoreWord(Quads.Arc.up.next(Quads.Arc.up).over(Quads.Angle.down), "Heart",
        "Heart, Love."),
    CompoundWord(
        [CoreWord(Mono.Sun.gram), CoreWord(Mono.Circle.over(Quads.Line.up))],
        "Star-being",
        "Alien, god?"),
  ],
);
