

import 'package:example/loading_adaptive_card.dart';
import 'package:flutter/material.dart';

class ColumnPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Column"),
      ),
      body: ListView(
        children: <Widget>[
          LoadingAdaptiveCard("lib/column/example1",),
          LoadingAdaptiveCard("lib/column/example2",),
          LoadingAdaptiveCard("lib/column/example3",),
          LoadingAdaptiveCard("lib/column/example4",),
          LoadingAdaptiveCard("lib/column/example5",),
        ],
      ),
    );
  }
}
