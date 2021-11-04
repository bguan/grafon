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

/// Core Words in dictionary
final coreWords = [_demoGroup, _numericGroup, _interpersonalGroup, _religious];

/// Test Words in dictionary
final testWords = [
  _randomGroup,
  _circleGroup,
  _circleDotGroup,
  _circleSquareGroup
];

final _demoGroup = WordGroup(
  'Demo',
  CompoundWord([
    CoreWord(Mono.Eye.gram),
    CoreWord(Quads.Arc.left.next(Quads.Flow.right)),
  ]),
  "A collection of words demonstrating Grafon's logo-graphic & phonetic writing.",
  [
    CoreWord(
        Quads.Angle.up.over(Quads.Gate.down), "House", "Dwelling, building."),
    CoreWord(
        Mono.Sun.gram.over(Quads.Line.down), "Day", "Sun over land, day time."),
    CoreWord(
        Quads.Curve.left.next(Quads.Line.up).next(Quads.Curve.right), "Grass"),
    CoreWord(Quads.Flow.right.over(Quads.Flow.right), "Water"),
    CoreWord(Quads.Flow.down.next(Quads.Flow.down), "Rain"),
    CoreWord(Quads.Arc.left.next(Quads.Flow.right), "Talk"),
    CoreWord(Quads.Curve.right.mix(Quads.Curve.up), "Leaf"),
    CoreWord(Quads.Branch.up, "Wood"),
    CoreWord(Quads.Drop.down, "Droplet"),
    CoreWord(Mono.Light.wrap(Mono.Atom.gram), "Radiation", "Light from Atom."),
    CoreWord(Mono.Light.wrap(Quads.Zap.down), "White", "Light from lightning."),
    CoreWord(Mono.Light.wrap(Mono.Sun.gram), "Red", "Light from Sun."),
    CoreWord(Mono.Light.wrap(Mono.Flower.gram), "Yellow", "Color of flower."),
    CoreWord(Mono.Light.wrap(Quads.Curve.right.mix(Quads.Curve.up)), "Green",
        "Color of leaf."),
    CoreWord(Mono.Light.wrap(Quads.Branch.up), "Brown", "Color of wood."),
    CoreWord(Mono.Light.wrap(Quads.Flow.right.over(Quads.Flow.right)), "Blue",
        "Color of water."),
    CoreWord(Mono.Light.wrap(Mono.Dot.gram), "Black", "Black."),
    CoreWord(Quads.Humps.up.over(Quads.Angle.down), "Heart", "Organ of Love."),
    CompoundWord(
        [CoreWord(Mono.Sun.gram), CoreWord(Mono.Circle.over(Quads.Line.up))],
        "Star-being",
        "Alien, god?"),
  ],
);

final _numericGroup = WordGroup(
  'Numeric',
  CoreWord(Mono.Grid.next(Quads.Step.up)),
  'Cardinal and Ordinal Numbers...',
  [
    CoreWord(Mono.Circle.gram, "Zero"),
    CoreWord(Quads.Line.up, "One"),
    CoreWord(Quads.Corner.left, "Two"),
    CoreWord(Quads.Triangle.up, "Three"),
    CoreWord(Mono.Square.gram, "Four"),
    CoreWord(Mono.Diamond.mix(Quads.Line.up), "Five"),
    CoreWord(Quads.Triangle.up.mix(Quads.Branch.down), "Six"),
    CoreWord(Mono.Square.mix(Quads.Angle.down), "Seven"),
    CoreWord(Mono.Diamond.mix(Mono.Cross.gram), "Eight"),
    CoreWord(Quads.Triangle.up.wrap(Quads.Triangle.down), "Nine"),
    CoreWord(Mono.Circle.wrap(Quads.Line.up), "Ten", "Ten to the power of 1."),
    CoreWord(Mono.Circle.wrap(Quads.Corner.left), "Hundred", "Ten squared."),
    CoreWord(Mono.Circle.wrap(Quads.Triangle.up), "Thousand", "Ten cubed."),
    CompoundWord(
      [
        CoreWord(Quads.Triangle.up),
        CoreWord(Quads.Line.right),
        CoreWord(Mono.Square.gram),
      ],
      "3/4",
      "3 part of 4, three quarter.",
    ),
    CompoundWord(
      [
        CoreWord(Mono.Dot.gram /*.down()*/),
        CoreWord(Mono.Square.mix(Quads.Angle.down)),
        CoreWord(Mono.Diamond.mix(Quads.Line.up)),
      ],
      ".75",
      "Decimal Point .75.",
    ),
  ],
);

final _interpersonalGroup = WordGroup(
  'Interpersonal',
  CoreWord(Quads.Dots.down.over(Quads.Gate.down), "Interpersonal-Relationship"),
  'People, pronoun...',
  [
    CoreWord(Mono.Circle.over(Quads.Line.up), "Person", "Adult person."),
    CoreWord(Mono.Dot.over(Quads.Line.up), "Child"),
    CoreWord(Quads.Arrow.up.over(Mono.Circle.gram), "Man", "Adult male."),
    CoreWord(Mono.Circle.over(Mono.Cross.gram), "Woman", "Adult female."),
    CoreWord(
        Mono.Dot.over(Quads.Branch.up), "I", "First person singular pronoun."),
    CoreWord(Mono.Dot.next(Mono.Empty.gram).over(Quads.Corner.right), "You",
        "Second person singular pronoun."),
    CoreWord(Mono.Empty.next(Mono.Dot.gram).over(Quads.Corner.left),
        "He or She", "Third person singular pronoun."),
    CompoundWord([
      CoreWord(Mono.Dot.over(Quads.Branch.up)),
      CoreWord(Quads.Dots.down),
    ], "We", "First person plural pronoun."),
    CompoundWord([
      CoreWord(Mono.Dot.next(Mono.Empty.gram).over(Quads.Corner.right)),
      CoreWord(Quads.Dots.down),
    ], "You(s)", "Second person plural pronoun."),
    CompoundWord([
      CoreWord(Mono.Empty.next(Mono.Dot.gram).over(Quads.Corner.left)),
      CoreWord(Quads.Dots.down),
    ], "They", "Third person plural pronoun."),
    CoreWord(Quads.Dots.down.over(Quads.Gate.up), "Couple"),
    CoreWord(Mono.Circle.wrap(Quads.Dots.down.over(Quads.Gate.down)), "Family"),
  ],
);

final _religious = WordGroup(
    'Religious', CoreWord(Mono.Sun.over(Quads.Arc.up)), 'Religious.', [
  CoreWord(Mono.Cross.over(Quads.Arc.up)),
  CoreWord(Quads.Triangle.up.mix(Quads.Triangle.down).over(Quads.Arc.up)),
  CoreWord(Quads.Step.up.mix(Quads.Step.left).over(Quads.Arc.up)),
  CoreWord(Quads.Arc.left.next(Mono.Star.gram).over(Quads.Arc.up)),
  CoreWord(Mono.Circle.mix(Quads.Flow.down).over(Quads.Arc.up)),
  CoreWord(Mono.Square.mix(Mono.Diamond.gram)
      .wrap(Mono.Sun.gram)
      .over(Quads.Arc.up)),
  CoreWord(Mono.Dot.over(Quads.Arc.down)
      .over(Quads.Humps.right.next(Quads.Flow.left))),
]);

final _randomGroup = WordGroup(
  'Test Mix',
  CoreWord(Mono.Square.mix(Quads.Angle.down)),
  'Test expression rendering...',
  [
    CoreWord(Quads.Triangle.up.mix(Quads.Branch.down)),
    CompoundWord(
      [
        CoreWord(Mono.Dot.gram),
        CoreWord(Mono.Square.mix(Quads.Angle.up)),
        CoreWord(Mono.Diamond.mix(Quads.Line.up)),
      ],
    ),
    CompoundWord([
      CoreWord(Mono.Circle.gram, "Zero"),
      CoreWord(Quads.Line.up, "One"),
      CoreWord(Quads.Corner.left, "Two"),
      CoreWord(Quads.Triangle.up, "Three"),
      CoreWord(Mono.Square.gram, "Four"),
      CoreWord(Mono.Diamond.mix(Quads.Line.up), "Five"),
      CoreWord(Quads.Triangle.up.mix(Quads.Branch.down), "Six"),
      CoreWord(Mono.Square.mix(Quads.Angle.down), "Seven"),
      CoreWord(Mono.Diamond.mix(Mono.Cross.gram), "Eight"),
      CoreWord(Quads.Triangle.up.wrap(Quads.Triangle.down), "Nine"),
    ])
  ],
);

final _circleGroup = WordGroup(
  'Test',
  CoreWord(Mono.Circle.gram),
  'Test expression rendering...',
  [
    CoreWord(Mono.Empty.next(Mono.Circle.gram), "right shift O by Empty"),
    CoreWord(Mono.Circle.next(Mono.Empty.gram), "left shift O by Empty"),
    CoreWord(Mono.Circle.over(Mono.Empty.gram), "up shift O by Empty"),
    CoreWord(Mono.Empty.over(Mono.Circle.gram), "down shift O by Empty"),
    CoreWord(Mono.Empty.wrap(Mono.Circle.gram), "shrink O by Empty"),
  ],
);

final _circleDotGroup = WordGroup(
  'Test',
  CoreWord(Mono.Dot.wrap(Mono.Circle.gram)),
  'Test expression rendering...',
  [
    CoreWord(Mono.Circle.next(Mono.Dot.gram), "Circle next Dot"),
    CoreWord(Mono.Dot.next(Mono.Circle.gram), "Dot next Circle"),
    CoreWord(Mono.Dot.over(Mono.Circle.gram), "Dot over Circle"),
    CoreWord(Mono.Circle.over(Mono.Dot.gram), "Circle over Dot"),
    CoreWord(Mono.Circle.wrap(Mono.Dot.gram), "Circle wrap Dot"),
    CoreWord(Mono.Dot.wrap(Mono.Circle.gram), "Dot wrap Circle"),
  ],
);

final _circleSquareGroup = WordGroup(
  'Test',
  CoreWord(Mono.Circle.wrap(Mono.Square.gram)),
  'Test expression rendering...',
  [
    CoreWord(Mono.Circle.next(Mono.Square.gram), "Circle next Square"),
    CoreWord(Mono.Square.next(Mono.Circle.gram), "Square next Circle"),
    CoreWord(Mono.Square.over(Mono.Circle.gram), "Square over Circle"),
    CoreWord(Mono.Circle.over(Mono.Square.gram), "Circle over Square"),
    CoreWord(Mono.Circle.wrap(Mono.Square.gram), "Circle wrap Square"),
    CoreWord(Mono.Square.wrap(Mono.Circle.gram), "Square wrap Circle"),
  ],
);
