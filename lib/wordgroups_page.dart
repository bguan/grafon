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

library word_groups_page;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:grafon/word_group_widget.dart';

import 'grafon_word.dart';

/// Widget to render multiple word groups on a page as expandable sections
class WordGroupsPage extends StatefulWidget {
  final String title;
  final List<WordGroup> groups;

  WordGroupsPage(this.title, this.groups, {Key? key}) : super(key: key);

  @override
  _WordGroupsPageState createState() =>
      _WordGroupsPageState(this.title, this.groups);
}

class _WordGroupsPageState extends State<WordGroupsPage> {
  final String title;
  final List<WordGroup> groups;
  late final List<bool> _expandedFlag;

  _WordGroupsPageState(this.title, this.groups) {
    _expandedFlag = [
      for (var g in groups) g == groups.first,
    ];
  }

  @override
  Widget build(BuildContext ctx) {
    final scheme = Theme.of(ctx).colorScheme;
    final titleStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.normal,
      height: 1.5,
      color: scheme.primaryVariant,
      fontSize: 20,
    );
    final sectionStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.normal,
      height: 1,
      color: scheme.primaryVariant,
      fontSize: 17,
    );
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text(title, style: titleStyle),
            padding: EdgeInsets.only(top: 10, left: 10, bottom: 20),
          ),
          ExpansionPanelList(
            expandedHeaderPadding: EdgeInsets.all(0),
            elevation: 0,
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                _expandedFlag[index] = !isExpanded;
              });
            },
            children: [
              for (int i = 0; i < groups.length; i++)
                ExpansionPanel(
                  canTapOnHeader: true,
                  headerBuilder: (BuildContext context, bool isExpanded) =>
                      Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(groups[i].title, style: sectionStyle),
                  ),
                  body: WordGroupWidget(groups[i]),
                  isExpanded: _expandedFlag[i],
                )
            ],
          ),
          Container(height: 50),
        ],
      ),
    );
  }
}
