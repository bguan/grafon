// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
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
  String get localeName => 'zh';

  static String m0(face) => "${Intl.select(face, {
            'Center': '中',
            'Right': '右',
            'Up': '上',
            'Left': '左',
            'Down': '下',
            'other': '???',
          })}";

  static String m1(mono) => "${Intl.select(mono, {
            'Empty': '空',
            'Dot': '点',
            'Cross': '十字',
            'Flake': '雪花',
            'Square': '方',
            'Grid': '格',
            'X': '交叉',
            'Diamond': '钻石',
            'Light': '光',
            'Sun': '日',
            'Blob': '泥团',
            'Circle': '园',
            'Eye': '目',
            'Star': '星',
            'Flower': '花',
            'Atom': '原子',
            'Infinity': '无限',
            'Octo': '八角',
            'other': '???',
          })}";

  static String m2(op) => "${Intl.select(op, {
            'Next': '侧',
            'Mix': '掺',
            'Over': '盖',
            'Wrap': '包',
            'other': '???',
          })}";

  static String m3(quad) => "${Intl.select(quad, {
            'Line': '线',
            'Dots': '双点',
            'Corner': '拐角',
            'Branch': '叉',
            'Gate': '门',
            'Step': '梯',
            'Angle': '尖',
            'Triangle': '三角',
            'Zap': '电',
            'Arrow': '箭',
            'Bow': '弓',
            'Arc': '弯',
            'Swirl': '卷',
            'Curve': '拐弯',
            'Drop': '滴',
            'Wave': '波',
            'Knot': '结',
            'Cover': '盖',
            'other': '???',
          })}";

  static String m4(opName, opSymbol, codas) => "${opName} ${opSymbol} ${codas}";

  static String m5(monoName, quadName, consonant) =>
      "${monoName}, ${quadName} (${consonant}...)";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "app_TTS_enabled_msg":
            MessageLookupByLibrary.simpleMessage("云端发音系统已启动."),
        "app_login_tooltip": MessageLookupByLibrary.simpleMessage("登录"),
        "app_logout_tooltip": MessageLookupByLibrary.simpleMessage("退出"),
        "app_title": MessageLookupByLibrary.simpleMessage("形声语"),
        "common_face_name": m0,
        "common_mono_name": m1,
        "common_op_name": m2,
        "common_quad_name": m3,
        "page_core_words_title": MessageLookupByLibrary.simpleMessage("核心词"),
        "page_gram_table_op_label": m4,
        "page_gram_table_operators": MessageLookupByLibrary.simpleMessage("组合"),
        "page_gram_table_row_header": m5,
        "page_random_words_title":
            MessageLookupByLibrary.simpleMessage("随意词（用于测试）")
      };
}
