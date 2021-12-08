import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';

import 'constants.dart';

const DEF_LOCALE = Locale.fromSubtags(languageCode: DEF_LANG_TAG);

const EN = Locale.fromSubtags(languageCode: "en");

const EN_US = Locale.fromSubtags(
  languageCode: "en",
  countryCode: "US",
);

const ZH = Locale.fromSubtags(languageCode: "zh");

const ZH_CN = Locale.fromSubtags(
  languageCode: "zh",
  countryCode: "CN",
);

/// Extending Locale with fallback computation
extension LocaleHelper on Locale {
  Locale get fallback => this == EN_US
      ? EN
      : (this == ZH_CN
          ? ZH
          : Locale.fromSubtags(languageCode: this.languageCode));
}

class LocStr {
  late final Map<Locale, String> locale2String;

  LocStr.def(String txt) : locale2String = {EN: txt};

  LocStr(Map<Locale, String> loc2str) {
    if (!loc2str.containsKey(DEF_LOCALE))
      throw ArgumentError("Missing entry for $DEF_LOCALE.");

    locale2String = loc2str;
  }

  operator []=(Locale l, String txt) => locale2String[l] = txt;

  String operator [](Locale l) => locale2String.containsKey(l)
      ? locale2String[l]!
      : (locale2String.containsKey(l.fallback)
          ? locale2String[l.fallback]!
          : locale2String[DEF_LOCALE]!);

  @override
  bool operator ==(Object other) {
    if (other is! LocStr) return false;
    LocStr that = other;
    return DeepCollectionEquality()
        .equals(this.locale2String, that.locale2String);
  }

  @override
  int get hashCode => DeepCollectionEquality().hash(this.locale2String);
}

class LocStrs {
  late final Map<Locale, List<String>> locale2Strings;

  LocStrs.def(List<String> texts) : locale2Strings = {DEF_LOCALE: texts};

  LocStrs(Map<Locale, List<String>> loc2strings) {
    if (!loc2strings.containsKey(DEF_LOCALE))
      throw ArgumentError("Missing entry for $DEF_LOCALE.");

    locale2Strings = loc2strings;
  }

  operator []=(Locale l, List<String> texts) => locale2Strings[l] = texts;

  List<String> operator [](Locale l) => locale2Strings.containsKey(l)
      ? locale2Strings[l]!
      : locale2Strings[DEF_LOCALE]!;

  LocStr operator ^(int i) => LocStr(
        locale2Strings.map(
          (loc, texts) => MapEntry(loc, texts.length > i ? texts[i] : ''),
        ),
      );

  @override
  bool operator ==(Object other) {
    if (other is! LocStrs) return false;
    LocStrs that = other;
    return DeepCollectionEquality()
        .equals(this.locale2Strings, that.locale2Strings);
  }

  @override
  int get hashCode => DeepCollectionEquality().hash(this.locale2Strings);
}
