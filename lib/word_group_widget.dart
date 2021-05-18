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

library word_group_widget;

import 'package:charcode/html_entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'grafon_widget.dart';
import 'grafon_word.dart';

/// Widget to render a word group as a page
class WordGroupPage extends StatelessWidget {
  final WordGroup wordGroup;

  WordGroupPage(this.wordGroup);

  @override
  Widget build(BuildContext ctx) {
    final scheme = Theme.of(ctx).colorScheme;
    final titleStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.normal,
      height: 1.5,
      color: scheme.primary,
      fontSize: 20,
      fontFamily: "Arial",
    );
    final groupDescStyle = TextStyle(
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.1,
      color: scheme.primary,
      fontSize: 14,
      fontFamily: "Times",
    );
    final wordDescStyle = groupDescStyle.copyWith(fontSize: 12);
    final voicingStyle = TextStyle(
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.italic,
      height: 1.2,
      color: scheme.primary,
      fontSize: 12,
      fontFamily: "Courier",
    );

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.topLeft,
                      child: Text(wordGroup.title,
                          textAlign: TextAlign.left, style: titleStyle),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.topLeft,
                      child: Text(wordGroup.description,
                          textAlign: TextAlign.left, style: groupDescStyle),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      height: 80,
                      width: wordGroup.logo.flexRenderWidth(80),
                      child: GrafonTile(wordGroup.logo.renderPlan, height: 80),
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      child: Text('"${wordGroup.logo.pronunciation}"',
                          textAlign: TextAlign.right, style: voicingStyle),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10, width: 10),
          Table(
            border: TableBorder(),
            columnWidths: const <int, TableColumnWidth>{
              0: IntrinsicColumnWidth(),
              1: IntrinsicColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: <TableRow>[
              for (GrafonWord w in wordGroup.values)
                TableRow(
                  children: <Widget>[
                    Container(
                      constraints:
                          BoxConstraints.tight(Size(w.flexRenderWidth(70), 70)),
                      padding: EdgeInsets.all(10),
                      child:
                          GrafonTile(w.renderPlan, height: 50, flexFit: true),
                    ),
                    RichText(
                      text: TextSpan(
                        text: '"${w.pronunciation}"',
                        style: voicingStyle,
                        children: <TextSpan>[
                          TextSpan(
                              text: ' ${String.fromCharCode($mdash)} ',
                              style: wordDescStyle),
                          if (w.description.isEmpty)
                            TextSpan(text: '${w.key}.', style: wordDescStyle),
                          if (w.description.isNotEmpty)
                            TextSpan(
                                text: '${w.description}.',
                                style: wordDescStyle),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
