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

import 'package:collection/collection.dart';
import 'package:vector_math/vector_math.dart';

import 'constants.dart';
import 'expr_render.dart';
import 'generated/l10n.dart';
import 'grafon_expr.dart';
import 'gram_infra.dart';
import 'localized_string.dart';
import 'phonetics.dart';

/// Abstract base class for all Grafon Words to associate meaning to gram expr.
abstract class GrafonWord {
  final String key;
  final LocStr locTitle;
  final LocStr locDescription;

  Iterable<Pronunciation> get pronunciations;

  RenderPlan get renderPlan;

  GrafonWord.def(this.key, [String? title, String? description])
      : this.locTitle = LocStr.def(title ?? ''),
        this.locDescription = LocStr.def(description ?? '');

  GrafonWord(this.key, LocStrs loc2TitleDesc)
      : this.locTitle = loc2TitleDesc ^ 0,
        this.locDescription = loc2TitleDesc ^ 1;

  double widthAtHeight(double height) => renderPlan.calcWidthByHeight(height);

  double heightAtWidth(double width) => renderPlan.calcHeightByWidth(width);

  @override
  int get hashCode => key.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! GrafonWord) return false;
    GrafonWord that = other;
    return key == that.key;
  }

  String localizeExpr(S l10n);
}

/// Core Word has only 1 Grafon Expression.
class CoreWord extends GrafonWord {
  final GrafonExpr expr;
  final Iterable<Pronunciation> pronunciations;
  late final RenderPlan renderPlan;

  /// Make sure word rendering is not too narrow or too wide
  static RenderPlan normalize(RenderPlan r) {
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
    return r;
  }

  CoreWord.def(this.expr, [String? title, String? description])
      : this.pronunciations = [expr.pronunciation],
        renderPlan = normalize(expr.renderPlan),
        super.def(expr.toString(), title, description);

  CoreWord(this.expr, LocStrs loc2TitleDesc)
      : this.pronunciations = [expr.pronunciation],
        renderPlan = normalize(expr.renderPlan),
        super(expr.toString(), loc2TitleDesc);

  @override
  String toString() => '$expr';

  @override
  String localizeExpr(S l10n) => expr.localize(l10n);
}

/// Compound Words combines CoreWords into another word,
/// its meaning is made up from the base core words.
class CompoundWord extends GrafonWord {
  final Iterable<CoreWord> words;
  late final List<Pronunciation> pronunciations;
  late final RenderPlan renderPlan;

  static RenderPlan words2Plan(Iterable<CoreWord> words) {
    if (words.length < 2)
      throw ArgumentError('Minimum 2 words; only ${words.length} given.');

    RenderPlan? r;
    for (var w in words) {
      final wr = w.renderPlan;
      if (r == null) {
        r = wr;
        continue;
      }
      r = r.byBinary(Op.Next, wr, gap: COMPOUND_WORD_GAP);
    }

    return r!;
  }

  static List<Pronunciation> words2Voice(Iterable<CoreWord> words) =>
      List.unmodifiable(
        [
          for (var w in words) ...w.pronunciations,
        ],
      );

  CompoundWord.def(this.words, [String? title, String? description])
      : renderPlan = words2Plan(words),
        pronunciations = words2Voice(words),
        super.def(
          words.map((w) => w.toString()).join("$COMPOUND_SEP"),
          title,
          description,
        );

  CompoundWord(this.words, LocStrs loc2TitleDesc)
      : renderPlan = words2Plan(words),
        pronunciations = words2Voice(words),
        super(
          words.map((w) => w.toString()).join(" $COMPOUND_SEP "),
          loc2TitleDesc,
        );

  @override
  String toString() => words.map((w) => w.toString()).join(" $COMPOUND_SEP ");

  @override
  String localizeExpr(S l10n) =>
      words.map((w) => w.localizeExpr(l10n)).join(" $COMPOUND_SEP ");
}

/// A Group of Related Words in some ways.
class WordGroup {
  LocStr title;
  LocStr description;
  GrafonWord logo;
  Map<String, GrafonWord> _key2word;

  WordGroup(
    this.title,
    this.logo,
    this.description,
    Iterable<GrafonWord> entries,
  ) : this._key2word = {
          for (var e in entries) e.key: e,
        };

  WordGroup.def(
    String title,
    this.logo,
    String description,
    Iterable<GrafonWord> entries,
  )   : this.title = LocStr.def(title),
        this.description = LocStr.def(description),
        this._key2word = {
          for (var e in entries) e.key: e,
        };

  Iterable<String> get keys => _key2word.keys;

  Iterable<GrafonWord> get values => _key2word.values;

  bool contains(String key) => _key2word.containsKey(key);

  GrafonWord? operator [](String key) => _key2word[key];

  @override
  int get hashCode => _key2word.keys.fold(
        title.hashCode << 1 ^ logo.hashCode,
        (hash, key) => hash << 1 ^ key.hashCode,
      );

  @override
  bool operator ==(Object other) {
    if (other is! WordGroup) return false;
    WordGroup that = other;
    final ieq = IterableEquality<String>().equals;

    return title == that.title &&
        logo == that.logo &&
        ieq(_key2word.keys, that._key2word.keys);
  }
}
