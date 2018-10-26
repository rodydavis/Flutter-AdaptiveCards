

import 'package:example/loading_adaptive_card.dart';
import 'package:flutter/material.dart';

class InputNumber extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Input.Number"),
      ),
      body: ListView(
        children: <Widget>[
          DemoAdaptiveCard("lib/inputs/input_number/example1",),
        ],
      ),
    );
  }
}
