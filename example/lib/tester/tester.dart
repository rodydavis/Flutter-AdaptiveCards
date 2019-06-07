

import 'package:example/loading_adaptive_card.dart';
import 'package:flutter/material.dart';

class TesterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test"),
      ),
      body: ListView(
        children: <Widget>[
          DemoAdaptiveCard("lib/samples/example1",),
        ],
      ),
    );
  }
}
