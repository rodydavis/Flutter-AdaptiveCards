

import 'package:example/loading_adaptive_card.dart';
import 'package:flutter/material.dart';

class InputText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Input.Text"),
      ),
      body: ListView(
        children: <Widget>[
          LoadingAdaptiveCard("lib/inputs/input_text/example1",),
          LoadingAdaptiveCard("lib/inputs/input_text/example2",),
        ],
      ),
    );
  }
}
