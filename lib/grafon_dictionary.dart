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
final coreWords = [_demoGroup, _numericGroup, _interpersonalGroup, _spiritual];

/// Test Words in dictionary
final testWords = [_circleGroup, _circleDotGroup, _circleSquareGroup];

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
        Quads.Curve.down.next(Quads.Line.up).next(Quads.Curve.right), "Grass"),
    CoreWord(Quads.Flow.right.over(Quads.Flow.right), "Water"),
    CoreWord(Quads.Flow.down.next(Quads.Flow.down), "Rain"),
    CoreWord(Quads.Arc.left.next(Quads.Flow.right), "Talk"),
    CoreWord(Quads.Curve.right.merge(Quads.Curve.left), "Leaf"),
    CoreWord(Quads.Branch.up, "Wood"),
    CoreWord(Quads.Drop.down, "Droplet"),
    CoreWord(Mono.Light.wrap(Mono.Atom.gram), "Radiation", "Light from Atom."),
    CoreWord(Mono.Light.wrap(Quads.Zap.down), "White", "Light from lightning."),
    CoreWord(Mono.Light.wrap(Mono.Sun.gram), "Red", "Light from Sun."),
    CoreWord(Mono.Light.wrap(Mono.Flower.gram), "Yellow", "Color of flower."),
    CoreWord(Mono.Light.wrap(Quads.Curve.right.merge(Quads.Curve.left)),
        "Green", "Color of leaf."),
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
  CompoundWord([CoreWord(Mono.Grid.gram), CoreWord(Quads.Step.up)]),
  'Numbers and counting...',
  [
    CoreWord(Mono.Circle.gram, "Zero"),
    CoreWord(Quads.Line.up, "One"),
    CoreWord(Quads.Angle.down, "Two"),
    CoreWord(Quads.Triangle.up, "Three"),
    CoreWord(Mono.Square.gram, "Four"),
    CoreWord(Mono.Diamond.merge(Quads.Line.down), "Five"),
    CoreWord(Mono.X.merge(Quads.Line.up), "Six"),
    CoreWord(Quads.Gate.down.merge(Mono.X.gram), "Seven"),
    CoreWord(Mono.Diamond.merge(Mono.Cross.gram), "Eight"),
    CoreWord(Quads.Triangle.up.wrap(Quads.Triangle.down), "Nine"),
    CoreWord(Mono.Circle.wrap(Quads.Line.up), "Ten",
        "Ten(s), ten to the power of 1."),
    CoreWord(Mono.Circle.wrap(Quads.Angle.down), "Hundred",
        "Hundred(s), ten squared."),
    CoreWord(Mono.Circle.wrap(Quads.Triangle.up), "Thousand",
        "Thousand(s), ten cubed."),
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
    CoreWord(Mono.Circle.over(Quads.Branch.up), "I",
        "First person singular pronoun."),
    CoreWord(Mono.Circle.left().over(Quads.Corner.up), "You",
        "Second person singular pronoun."),
    CoreWord(Mono.Circle.right().over(Quads.Corner.right), "He or She",
        "Third person singular pronoun."),
    CompoundWord([
      CoreWord(Mono.Circle.over(Quads.Branch.up)),
      CoreWord(Quads.Dots.down.shrink()),
    ], "We", "First person plural pronoun."),
    CompoundWord([
      CoreWord(Mono.Circle.left().over(Quads.Corner.up)),
      CoreWord(Quads.Dots.down.shrink()),
    ], "You(s)", "Second person plural pronoun."),
    CompoundWord([
      CoreWord(Mono.Circle.right().over(Quads.Corner.right)),
      CoreWord(Quads.Dots.down.shrink()),
    ], "They", "Third person plural pronoun."),
    CoreWord(Quads.Dots.down.over(Quads.Gate.up), "Couple"),
    CoreWord(Mono.Circle.wrap(Quads.Dots.down.over(Quads.Gate.down)), "Family"),
  ],
);

final _spiritual = WordGroup(
    'Religious', CoreWord(Mono.Sun.over(Quads.Arc.up)), 'Religious.', [
  CoreWord(Mono.Cross.over(Quads.Arc.up)),
  CoreWord(Quads.Triangle.up.merge(Quads.Triangle.down).over(Quads.Arc.up)),
  CoreWord(Quads.Step.up.merge(Quads.Step.right).over(Quads.Arc.up)),
  CoreWord(Quads.Arc.left.next(Mono.Star.gram).over(Quads.Arc.up)),
  CoreWord(Mono.Circle.merge(Quads.Flow.down).over(Quads.Arc.up)),
  CoreWord(Mono.Square.merge(Mono.Diamond.gram)
      .wrap(Mono.Sun.gram)
      .over(Quads.Arc.up)),
  CoreWord(Mono.Dot.merge(Quads.Arc.down.shrink())
      .over(Quads.Humps.right.next(Quads.Flow.left))),
]);

final _circleGroup = WordGroup(
  'Test',
  CoreWord(Mono.Circle.gram),
  'Test expression rendering...',
  [
    CoreWord(Mono.Circle.right(), "right shift O by Unary"),
    CoreWord(Mono.Empty.next(Mono.Circle.gram), "right shift O by Empty"),
    CoreWord(Mono.Circle.left(), "left shift O by Unary"),
    CoreWord(Mono.Circle.next(Mono.Empty.gram), "left shift O by Empty"),
    CoreWord(Mono.Circle.up(), "up shift O by Unary"),
    CoreWord(Mono.Circle.over(Mono.Empty.gram), "up shift O by Empty"),
    CoreWord(Mono.Circle.down(), "down shift O by Unary"),
    CoreWord(Mono.Empty.over(Mono.Circle.gram), "down shift O by Empty"),
    CoreWord(Mono.Circle.shrink(), "shrink O by Unary"),
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
