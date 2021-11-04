// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(mono) => "${Intl.select(mono, {
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
          })}";

  static String m1(op) => "${Intl.select(op, {
            'Next': 'Next',
            'Mix': 'Mix',
            'Over': 'Over',
            'Wrap': 'Wrap',
            'other': '???',
          })}";

  static String m2(quad) => "${Intl.select(quad, {
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
            'Humps': 'Humps',
            'Arc': 'Arc',
            'Swirl': 'Swirl',
            'Curve': 'Curve',
            'Drop': 'Drop',
            'Flow': 'Flow',
            'other': '???',
          })}";

  static String m3(opName, opSymbol, codas) => "${opName} ${opSymbol} ${codas}";

  static String m4(monoName, quadName, consonant) =>
      "${monoName} & ${quadName} (${consonant}...)";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "app_TTS_enabled_msg": MessageLookupByLibrary.simpleMessage(
            "Cloud Text to Speech initialized."),
        "app_login_tooltip": MessageLookupByLibrary.simpleMessage("Login"),
        "app_logout_tooltip": MessageLookupByLibrary.simpleMessage("Logout"),
        "app_title": MessageLookupByLibrary.simpleMessage("Grafon Home"),
        "common_mono_name": m0,
        "common_op_name": m1,
        "common_quad_name": m2,
        "page_core_words_title":
            MessageLookupByLibrary.simpleMessage("Core Words"),
        "page_gram_table_op_label": m3,
        "page_gram_table_operators":
            MessageLookupByLibrary.simpleMessage("Operators"),
        "page_gram_table_row_header": m4,
        "page_random_words_title":
            MessageLookupByLibrary.simpleMessage("Random Words (for Testing)")
      };
}