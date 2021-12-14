// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(face) => "${Intl.select(face, {
            'Center': 'Center',
            'Right': 'Right',
            'Up': 'Up',
            'Left': 'Left',
            'Down': 'Down',
            'other': '???',
          })}";

  static String m1(grp) => "${Intl.select(grp, {
            'Base': 'Base',
            'Head': 'Head',
            'Tail': 'Tail',
            'other': '???',
          })}";

  static String m2(mono) => "${Intl.select(mono, {
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

  static String m3(op) => "${Intl.select(op, {
            'Next': 'Next',
            'Mix': 'Mix',
            'Over': 'Over',
            'Wrap': 'Wrap',
            'other': '???',
          })}";

  static String m4(quad) => "${Intl.select(quad, {
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
          })}";

  static String m5(grpName, grpSymbol, grpVoice) =>
      "${grpName} ${grpSymbol} \n…${grpVoice}";

  static String m6(opName, opSymbol, codas) =>
      "${opName} ${opSymbol}\n…${codas}";

  static String m7(monoName, quadName, consonant) =>
      "${monoName}, ${quadName} (${consonant}…)";

  final messages = _notInlinedMessages(_notInlinedMessages);

  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "app_TTS_enabled_msg": MessageLookupByLibrary.simpleMessage(
            "Cloud Text to Speech initialized."),
        "app_login_tooltip": MessageLookupByLibrary.simpleMessage("Login"),
        "app_logout_tooltip": MessageLookupByLibrary.simpleMessage("Logout"),
        "app_title": MessageLookupByLibrary.simpleMessage("Grafon Language"),
        "common_face_name": m0,
        "common_grp_name": m1,
        "common_mono_name": m2,
        "common_op_name": m3,
        "common_quad_name": m4,
        "page_core_words_title":
            MessageLookupByLibrary.simpleMessage("Core Words"),
        "page_gram_table_grouping":
            MessageLookupByLibrary.simpleMessage("Group"),
        "page_gram_table_grp_label": m5,
        "page_gram_table_op_label": m6,
        "page_gram_table_operators":
            MessageLookupByLibrary.simpleMessage("Combo"),
        "page_gram_table_row_header": m7,
        "page_random_words_title":
            MessageLookupByLibrary.simpleMessage("Random Words (for Testing)")
      };
}
