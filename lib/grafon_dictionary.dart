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

import 'constants.dart';
import 'grafon_word.dart';
import 'gram_table.dart';
import 'localized_string.dart';

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
  LocStr({EN: 'Demo', ZH: '示范'}),
  CompoundWord(
    [
      CoreWord(
        Mono.Eye.gram,
        LocStrs({
          EN: ["Eye"],
          ZH: ["眼"],
        }),
      ),
      CoreWord(
          Quads.Arc.left.next(Quads.Wave.right),
          LocStrs({
            EN: ["Speech"],
            ZH: ["语"],
          })),
    ],
    LocStrs({
      EN: ["Graphical Language"],
      ZH: ["形声语"]
    }),
  ),
  LocStr({
    EN: "Words demonstrating logo-graphic & phonetic writing of Grafon.",
    ZH: "一组示范形声语的象形象声文字。",
  }),
  [
    CoreWord(
        Quads.Angle.up.over(Quads.Gate.down),
        LocStrs({
          EN: ["House", "Dwelling, building."],
          ZH: ["屋", "房子，建筑物。"],
        })),
    CoreWord(
        Mono.Sun.gram.over(Quads.Line.down),
        LocStrs({
          EN: ["Day", "Sun over land, day time."],
          ZH: ["白天", "日照大地，白天。"],
        })),
    CoreWord(
        Quads.Curve.left.next(Quads.Line.up).next(Quads.Curve.right),
        LocStrs({
          EN: ["Grass"],
          ZH: ["草"],
        })),
    CoreWord(
        Quads.Wave.right.over(Quads.Wave.right),
        LocStrs({
          EN: ["Water"],
          ZH: ["水"],
        })),
    CoreWord(
        Quads.Wave.down.next(Quads.Wave.down),
        LocStrs({
          EN: ["Rain"],
          ZH: ["雨"],
        })),
    CoreWord(
        Quads.Arc.left.next(Quads.Wave.right),
        LocStrs({
          EN: ["Talk", "Speech, language."],
          ZH: ["言", "说话，语言。"],
        })),
    CoreWord(
        Quads.Curve.right.mix(Quads.Curve.up),
        LocStrs({
          EN: ["Leaf"],
          ZH: ["叶"],
        })),
    CoreWord(
        Quads.Branch.up,
        LocStrs({
          EN: ["Wood"],
          ZH: ["木"],
        })),
    CoreWord(
        Quads.Drop.down,
        LocStrs({
          EN: ["Droplet"],
          ZH: ["滴"],
        })),
    CoreWord(
        Mono.Light.gram,
        LocStrs({
          EN: ["Light", "Light, color."],
          ZH: ["光", "光，色。"],
        })),
    CoreWord(
        Mono.Light.wrap(Mono.Atom.gram),
        LocStrs({
          EN: ["Radiation", "Light from atom."],
          ZH: ["辐射", "原子光。"],
        })),
    CoreWord(
        Mono.Light.wrap(Quads.Zap.down),
        LocStrs({
          EN: ["White", "Color of lightning."],
          ZH: ["白", "闪电的光色。"],
        })),
    CoreWord(
        Mono.Light.wrap(Mono.Sun.gram),
        LocStrs({
          EN: ["Red", "Light/Color of Sun."],
          ZH: ["红", "日的光色。"],
        })),
    CoreWord(
        Mono.Light.wrap(Mono.Flower.gram),
        LocStrs({
          EN: ["Yellow", "Color of flower."],
          ZH: ["黄", "花色。"],
        })),
    CoreWord(
        Mono.Light.wrap(Quads.Curve.right.mix(Quads.Curve.up)),
        LocStrs({
          EN: ["Green", "Color of leaf."],
          ZH: ["绿", "叶色。"],
        })),
    CoreWord(
        Mono.Light.wrap(Quads.Branch.up),
        LocStrs({
          EN: ["Brown", "Color of wood."],
          ZH: ["褐", "木色。"],
        })),
    CoreWord(
        Mono.Light.wrap(Quads.Wave.right.over(Quads.Wave.right)),
        LocStrs({
          EN: ["Blue", "Color of water."],
          ZH: ["蓝", "水色。"],
        })),
    CoreWord(
        Mono.Light.wrap(Mono.Dot.gram),
        LocStrs({
          EN: ["Black", "Black."],
          ZH: ["黑", "无光。"],
        })),
    CoreWord(
        Quads.Bow.up.over(Quads.Angle.down),
        LocStrs({
          EN: ["Heart", "The organ, symbol of emotion and love."],
          ZH: ["心", "心脏，感情的象征。"],
        })),
    CompoundWord(
        [
          CoreWord.def(Mono.Sun.gram),
          CoreWord.def(Mono.Circle.over(Quads.Line.up))
        ],
        LocStrs({
          EN: ["Star-being", "Alien, god?"],
          ZH: ["星人", "外星人，神？"],
        })),
  ],
);

final _numericGroup = WordGroup(
  LocStr({EN: 'Numeric', ZH: '数码'}),
  CoreWord(
      Mono.Grid.next(Quads.Step.up),
      LocStrs({
        EN: ["Numbers"],
        ZH: ["数"]
      })),
  LocStr({EN: 'Cardinal and Ordinal Numbers...', ZH: '基数和序数'}),
  [
    CoreWord(
        Mono.Circle.gram,
        LocStrs({
          EN: ["Zero"],
          ZH: ["零"]
        })),
    CoreWord(
        Quads.Line.up,
        LocStrs({
          EN: ["One"],
          ZH: ["一"]
        })),
    CoreWord(
        Quads.Corner.left,
        LocStrs({
          EN: ["Two"],
          ZH: ["二"]
        })),
    CoreWord(
        Quads.Triangle.up,
        LocStrs({
          EN: ["Three"],
          ZH: ["三"]
        })),
    CoreWord(
        Mono.Square.gram,
        LocStrs({
          EN: ["Four"],
          ZH: ["四"]
        })),
    CoreWord(
        Mono.Diamond.mix(Quads.Line.up),
        LocStrs({
          EN: ["Five"],
          ZH: ["五"]
        })),
    CoreWord(
        Quads.Triangle.down.mix(Quads.Branch.up),
        LocStrs({
          EN: ["Six"],
          ZH: ["六"]
        })),
    CoreWord(
        Quads.Gate.down.mix(Mono.X.gram),
        LocStrs({
          EN: ["Seven"],
          ZH: ["七"]
        })),
    CoreWord(
        Mono.Square.mix(Mono.X.gram),
        LocStrs({
          EN: ["Eight"],
          ZH: ["八"]
        })),
    CoreWord(
        Quads.Triangle.up.wrap(Quads.Triangle.down),
        LocStrs({
          EN: ["Nine"],
          ZH: ["九"]
        })),
    CoreWord(
        Mono.Circle.wrap(Quads.Line.up),
        LocStrs({
          EN: ["Ten", "Ten, single zero after a number."],
          ZH: ["十", "十，数字后一个零。"]
        })),
    CoreWord(
        Mono.Circle.wrap(Quads.Corner.left),
        LocStrs({
          EN: [
            "Hundred",
            "Hundred, ten squared, number with 2 trailing zeros."
          ],
          ZH: ["百", "十的二次方，数尾有双零。"]
        })),
    CoreWord(
        Mono.Circle.wrap(Quads.Triangle.up),
        LocStrs({
          EN: ["Thousand", "Thousand, ten cubed, triple zeros after a number."],
          ZH: ["千", "十的三次方，数尾有三零。"]
        })),
    CompoundWord(
        [
          CoreWord.def(Quads.Triangle.up),
          CoreWord.def(Quads.Line.right),
          CoreWord.def(Mono.Square.gram),
        ],
        LocStrs({
          EN: ["3/4", "3 part of 4, three quarter."],
          ZH: ["3/4", "四分之三。"]
        })),
    CompoundWord(
      [
        CoreWord.def(Mono.Dot.gram),
        CoreWord.def(Quads.Gate.down.mix(Mono.X.gram)),
        CoreWord.def(Mono.Diamond.mix(Quads.Line.up)),
      ],
      LocStrs({
        EN: [".75", "Decimal Point 0.75."],
        ZH: [".75", "小数点 0.75。"]
      }),
    ),
  ],
);

final _interpersonalGroup = WordGroup(
  LocStr({EN: 'Interpersonal', ZH: '人际关系'}),
  CoreWord.def(Quads.Dots.down.over(Quads.Gate.down)),
  LocStr({EN: 'People, pronoun...', ZH: '人际关系，代词。'}),
  [
    CoreWord(
      Mono.Circle.over(Quads.Line.up),
      LocStrs(
        {
          EN: ["Person", "Adult person."],
          ZH: ["人", "成人."],
        },
      ),
    ),
    CoreWord(
        Mono.Dot.over(Quads.Line.up),
        LocStrs({
          EN: ["Child"],
          ZH: ["小孩"]
        })),
    CoreWord(
        Quads.Arrow.up.over(Mono.Circle.gram),
        LocStrs({
          EN: ["Man", "Adult male."],
          ZH: ["男人"]
        })),
    CoreWord(
        Mono.Circle.over(Mono.Cross.gram),
        LocStrs({
          EN: ["Woman", "Adult female."],
          ZH: ["女人"]
        })),
    CoreWord(
        Mono.Dot.over(Quads.Branch.up),
        LocStrs({
          EN: ["I", "First person singular pronoun."],
          ZH: ["我", "第一人称代词。"]
        })),
    CoreWord(
        Mono.Dot.next(Mono.Empty.gram).over(Quads.Corner.right),
        LocStrs({
          EN: ["You", "Second person singular pronoun."],
          ZH: ["你", "第二人称代词。"]
        })),
    CoreWord(
        Mono.Empty.next(Mono.Dot.gram).over(Quads.Corner.left),
        LocStrs({
          EN: ["He or She", "Third person singular pronoun, gender neutral."],
          ZH: ["他", "第三人称代词，不分性别。"]
        })),
    CompoundWord(
      [
        CoreWord.def(Mono.Dot.over(Quads.Branch.up)),
        CoreWord.def(Quads.Dots.down),
      ],
      LocStrs({
        EN: ["We", "First person plural pronoun."],
        ZH: ["我们"]
      }),
    ),
    CompoundWord(
        [
          CoreWord.def(Mono.Dot.next(Mono.Empty.gram).over(Quads.Corner.right)),
          CoreWord.def(Quads.Dots.down),
        ],
        LocStrs({
          EN: ["You(s)", "Second person plural pronoun."],
          ZH: ["你们"]
        })),
    CompoundWord(
      [
        CoreWord.def(Mono.Empty.next(Mono.Dot.gram).over(Quads.Corner.left)),
        CoreWord.def(Quads.Dots.down),
      ],
      LocStrs({
        EN: ["They", "Third person plural pronoun."],
        ZH: ["他们"]
      }),
    ),
    CoreWord(
        Quads.Dots.down.over(Quads.Gate.up),
        LocStrs({
          EN: ["Couple", "Pair of lovers."],
          ZH: ["伴侣", "一对情侣。"]
        })),
    CoreWord(
      Mono.Circle.wrap(Quads.Dots.down.over(Quads.Gate.down)),
      LocStrs({
        EN: ["Family"],
        ZH: ["家人"]
      }),
    )
  ],
);

final _religious = WordGroup(
  LocStr({EN: 'Religious', ZH: '宗教'}),
  CoreWord.def(Mono.Sun.over(Quads.Arc.up)),
  LocStr({EN: 'Religious.', ZH: '宗教'}),
  [
    CoreWord(
        Mono.Cross.over(Quads.Arc.up),
        LocStrs({
          EN: ["Christianity"],
          ZH: ["基督教"]
        })),
    CoreWord(
        Quads.Triangle.up.mix(Quads.Triangle.down).over(Quads.Arc.up),
        LocStrs({
          EN: ["Judaism"],
          ZH: ["犹太教"]
        })),
    CoreWord(
        Quads.Step.up.mix(Quads.Step.left).over(Quads.Arc.up),
        LocStrs({
          EN: ["Buddhism"],
          ZH: ["佛教"]
        })),
    CoreWord(
        Quads.Arc.left.next(Mono.Empty.wrap(Mono.Star.gram)).over(Quads.Arc.up),
        LocStrs({
          EN: ["Islam"],
          ZH: ["伊斯兰教"]
        })),
    CoreWord(
        Mono.Circle.mix(Quads.Wave.down).over(Quads.Arc.up),
        LocStrs({
          EN: ["Taoism"],
          ZH: ["道教"]
        })),
    CoreWord(
        Mono.Square.mix(Mono.Diamond.gram)
            .wrap(Mono.Sun.gram)
            .over(Quads.Arc.up),
        LocStrs({
          EN: ["Hinduism"],
          ZH: ["印度教"]
        })),
    CoreWord(
        Mono.Dot.over(Quads.Arc.down)
            .over(Quads.Bow.right.next(Quads.Wave.left)),
        LocStrs({
          EN: ["Om", "Hindu spiritual symbol."],
          ZH: ["唵", "印度教的精神象征。"]
        })),
  ],
);

final _randomGroup = WordGroup(
  LocStr({EN: 'Test Mix', ZH: '测试随意凑'}),
  CoreWord.def(Mono.Square.mix(Quads.Angle.down)),
  LocStr({EN: 'Test expression rendering...', ZH: '测试方程绘图。'}),
  [
    CoreWord(
      Quads.Triangle.up.mix(Quads.Branch.down),
      LocStrs.def(["6"]),
    ),
    CompoundWord(
      [
        CoreWord.def(Mono.Dot.gram),
        CoreWord.def(Quads.Gate.down.mix(Mono.X.gram)),
        CoreWord.def(Mono.Diamond.mix(Quads.Line.up)),
      ],
      LocStrs.def(["0.75"]),
    ),
    CompoundWord(
      [
        CoreWord.def(Mono.Circle.gram),
        CoreWord.def(Quads.Line.up),
        CoreWord.def(Quads.Corner.left),
        CoreWord.def(Quads.Triangle.up),
        CoreWord.def(Mono.Square.gram),
        CoreWord.def(Mono.Diamond.mix(Quads.Line.up)),
        CoreWord.def(Quads.Triangle.down.mix(Quads.Branch.up)),
        CoreWord.def(Quads.Gate.down.mix(Mono.X.gram)),
        CoreWord.def(Mono.Square.mix(Mono.X.gram)),
        CoreWord.def(Quads.Triangle.up.wrap(Quads.Triangle.down)),
      ],
      LocStrs.def(["0,1,2,3,4,5,6,7,8,9"]),
    )
  ],
);

final _circleGroup = WordGroup(
  LocStr({EN: 'Test with Circles', ZH: '测试园形方程'}),
  CoreWord.def(Mono.Circle.gram),
  LocStr({EN: 'Test expressions with Circles rendering...', ZH: '测试圆形方程绘图。'}),
  [
    CoreWord(
        Mono.Empty.next(Mono.Circle.gram),
        LocStrs({
          EN: ["Right shift O by Empty"],
          ZH: ["用空白把园圈右移"]
        })),
    CoreWord(
        Mono.Circle.next(Mono.Empty.gram),
        LocStrs({
          EN: ["Left shift O by Empty"],
          ZH: ["用空白把园圈左移"]
        })),
    CoreWord(
        Mono.Circle.over(Mono.Empty.gram),
        LocStrs({
          EN: ["Up shift O by Empty"],
          ZH: ["用空白把园圈上移"]
        })),
    CoreWord(
        Mono.Empty.over(Mono.Circle.gram),
        LocStrs({
          EN: ["Down shift O by Empty"],
          ZH: ["用空白把园圈下移"]
        })),
    CoreWord(
        Mono.Empty.wrap(Mono.Circle.gram),
        LocStrs({
          EN: ["Shrink O by shifting inward with Empty"],
          ZH: ["用空白把园圈缩小内移"]
        })),
  ],
);

final _circleDotGroup = WordGroup(
  LocStr({EN: 'Test Circles and Dots.', ZH: '测试圆形与点'}),
  CoreWord.def(Mono.Dot.wrap(Mono.Circle.gram)),
  LocStr({
    EN: 'Test expressions with Circles and Dots rendering...',
    ZH: '测试圆形与点的方程绘图。'
  }),
  [
    CoreWord(
        Mono.Circle.next(Mono.Dot.gram),
        LocStrs({
          EN: ["Circle next Dot"],
          ZH: ["圆侧点"]
        })),
    CoreWord(
        Mono.Dot.next(Mono.Circle.gram),
        LocStrs({
          EN: ["Dot next Circle"],
          ZH: ["点侧园"]
        })),
    CoreWord(
        Mono.Dot.over(Mono.Circle.gram),
        LocStrs({
          EN: ["Dot over Circle"],
          ZH: ["点压园"]
        })),
    CoreWord(
        Mono.Circle.over(Mono.Dot.gram),
        LocStrs({
          EN: ["Circle over Dot"],
          ZH: ["园压点"]
        })),
    CoreWord(
        Mono.Circle.wrap(Mono.Dot.gram),
        LocStrs({
          EN: ["Circle wrap Dot"],
          ZH: ["园包点"]
        })),
    CoreWord(
        Mono.Dot.wrap(Mono.Circle.gram),
        LocStrs({
          EN: ["Dot wrap Circle"],
          ZH: ["点包园"]
        })),
  ],
);

final _circleSquareGroup = WordGroup(
  LocStr({EN: 'Test Circles and Squares', ZH: '测试园形与方形'}),
  CoreWord.def(Mono.Circle.wrap(Mono.Square.gram)),
  LocStr({
    EN: 'Test expressions with Circles and Squares rendering...',
    ZH: '测试园形与方形的方程绘图。'
  }),
  [
    CoreWord(
        Mono.Circle.next(Mono.Square.gram),
        LocStrs({
          EN: ["Circle next Square"],
          ZH: ["园侧方"]
        })),
    CoreWord(
        Mono.Square.next(Mono.Circle.gram),
        LocStrs({
          EN: ["Square next Circle"],
          ZH: ["方侧园"]
        })),
    CoreWord(
        Mono.Square.over(Mono.Circle.gram),
        LocStrs({
          EN: ["Square over Circle"],
          ZH: ["园压方"]
        })),
    CoreWord(
        Mono.Circle.over(Mono.Square.gram),
        LocStrs({
          EN: ["Circle over Square"],
          ZH: ["方压园"]
        })),
    CoreWord(
        Mono.Circle.wrap(Mono.Square.gram),
        LocStrs({
          EN: ["Circle wrap Square"],
          ZH: ["园包方"]
        })),
    CoreWord(
        Mono.Square.wrap(Mono.Circle.gram),
        LocStrs({
          EN: ["Square wrap Circle"],
          ZH: ["方包园"]
        })),
  ],
);
