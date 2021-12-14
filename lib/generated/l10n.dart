// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Login`
  String get app_login_tooltip {
    return Intl.message(
      'Login',
      name: 'app_login_tooltip',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get app_logout_tooltip {
    return Intl.message(
      'Logout',
      name: 'app_logout_tooltip',
      desc: '',
      args: [],
    );
  }

  /// `Grafon Language`
  String get app_title {
    return Intl.message(
      'Grafon Language',
      name: 'app_title',
      desc: '',
      args: [],
    );
  }

  /// `Cloud Text to Speech initialized.`
  String get app_TTS_enabled_msg {
    return Intl.message(
      'Cloud Text to Speech initialized.',
      name: 'app_TTS_enabled_msg',
      desc: '',
      args: [],
    );
  }

  /// `{face, select, Center {Center} Right {Right} Up {Up} Left {Left} Down {Down} other {???}}`
  String common_face_name(Object face) {
    return Intl.select(
      face,
      {
        'Center': 'Center',
        'Right': 'Right',
        'Up': 'Up',
        'Left': 'Left',
        'Down': 'Down',
        'other': '???',
      },
      name: 'common_face_name',
      desc: '',
      args: [face],
    );
  }

  /// `{grp, select, Base {Base} Head {Head} Tail {Tail} other {???}}`
  String common_grp_name(Object grp) {
    return Intl.select(
      grp,
      {
        'Base': 'Base',
        'Head': 'Head',
        'Tail': 'Tail',
        'other': '???',
      },
      name: 'common_grp_name',
      desc: '',
      args: [grp],
    );
  }

  /// `{mono, select, Empty {Empty} Dot {Dot} Cross {Cross} Hex {Hex} Square {Square} Grid {Grid} X {X} Diamond {Diamond} Light {Light} Sun {Sun} Blob {Blob} Circle {Circle} Eye {Eye} Star {Star} Flower {Flower} Atom {Atom} other {???}}`
  String common_mono_name(Object mono) {
    return Intl.select(
      mono,
      {
        'Empty': 'Empty',
        'Dot': 'Dot',
        'Cross': 'Cross',
        'Hex': 'Hex',
        'Square': 'Square',
        'Grid': 'Grid',
        'X': 'X',
        'Diamond': 'Diamond',
        'Light': 'Light',
        'Sun': 'Sun',
        'Blob': 'Blob',
        'Circle': 'Circle',
        'Eye': 'Eye',
        'Star': 'Star',
        'Flower': 'Flower',
        'Atom': 'Atom',
        'other': '???',
      },
      name: 'common_mono_name',
      desc: '',
      args: [mono],
    );
  }

  /// `{op, select, Next {Next} Mix {Mix} Over {Over} Wrap {Wrap} other {???}}`
  String common_op_name(Object op) {
    return Intl.select(
      op,
      {
        'Next': 'Next',
        'Mix': 'Mix',
        'Over': 'Over',
        'Wrap': 'Wrap',
        'other': '???',
      },
      name: 'common_op_name',
      desc: '',
      args: [op],
    );
  }

  /// `{quad, select, Line {Line} Dots {Dots} Corner {Corner} Branch {Branch} Gate {Gate} Step {Step} Angle {Angle} Triangle {Triangle} Zap {Zap} Arrow {Arrow} Bow {Bow} Arc {Arc} Swirl {Swirl} Curve {Curve} Drop {Drop} Wave {Wave} other {???}}`
  String common_quad_name(Object quad) {
    return Intl.select(
      quad,
      {
        'Line': 'Line',
        'Dots': 'Dots',
        'Corner': 'Corner',
        'Branch': 'Branch',
        'Gate': 'Gate',
        'Step': 'Step',
        'Angle': 'Angle',
        'Triangle': 'Triangle',
        'Zap': 'Zap',
        'Arrow': 'Arrow',
        'Bow': 'Bow',
        'Arc': 'Arc',
        'Swirl': 'Swirl',
        'Curve': 'Curve',
        'Drop': 'Drop',
        'Wave': 'Wave',
        'other': '???',
      },
      name: 'common_quad_name',
      desc: '',
      args: [quad],
    );
  }

  /// `Core Words`
  String get page_core_words_title {
    return Intl.message(
      'Core Words',
      name: 'page_core_words_title',
      desc: '',
      args: [],
    );
  }

  /// `Group`
  String get page_gram_table_grouping {
    return Intl.message(
      'Group',
      name: 'page_gram_table_grouping',
      desc: '',
      args: [],
    );
  }

  /// `Combo`
  String get page_gram_table_operators {
    return Intl.message(
      'Combo',
      name: 'page_gram_table_operators',
      desc: '',
      args: [],
    );
  }

  /// `{grpName} {grpSymbol} \n…{grpVoice}`
  String page_gram_table_grp_label(
      Object grpName, Object grpSymbol, Object grpVoice) {
    return Intl.message(
      '$grpName $grpSymbol \n…$grpVoice',
      name: 'page_gram_table_grp_label',
      desc: '',
      args: [grpName, grpSymbol, grpVoice],
    );
  }

  /// `{opName} {opSymbol}\n…{codas}`
  String page_gram_table_op_label(
      Object opName, Object opSymbol, Object codas) {
    return Intl.message(
      '$opName $opSymbol\n…$codas',
      name: 'page_gram_table_op_label',
      desc: '',
      args: [opName, opSymbol, codas],
    );
  }

  /// `{monoName}, {quadName} ({consonant}…)`
  String page_gram_table_row_header(
      Object monoName, Object quadName, Object consonant) {
    return Intl.message(
      '$monoName, $quadName ($consonant…)',
      name: 'page_gram_table_row_header',
      desc: '',
      args: [monoName, quadName, consonant],
    );
  }

  /// `Random Words (for Testing)`
  String get page_random_words_title {
    return Intl.message(
      'Random Words (for Testing)',
      name: 'page_random_words_title',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
