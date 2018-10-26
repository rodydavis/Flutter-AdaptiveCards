

import 'package:example/loading_adaptive_card.dart';
import 'package:flutter/material.dart';

class InputChoiceSetPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Input.ChoiceSet"),
      ),
      body: ListView(
        children: <Widget>[
          DemoAdaptiveCard("lib/inputs/input_choice_set/example1",),
        ],
      ),
    );
  }
}
