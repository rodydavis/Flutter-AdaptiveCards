

import 'package:example/loading_adaptive_card.dart';
import 'package:flutter/material.dart';

class ColumnSetPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ColumnSet"),
      ),
      body: ListView(
        children: <Widget>[
          LoadingAdaptiveCard("lib/column_set/example1",),
          LoadingAdaptiveCard("lib/column_set/example2",),
          LoadingAdaptiveCard("lib/column_set/example3",),
        ],
      ),
    );
  }
}
