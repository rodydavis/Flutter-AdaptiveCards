

import 'package:example/loading_adaptive_card.dart';
import 'package:flutter/material.dart';

class FactSetPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FactSet"),
      ),
      body: ListView(
        children: <Widget>[
          DemoAdaptiveCard("lib/fact_set/example1",),
        ],
      ),
    );
  }
}
