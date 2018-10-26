

import 'package:example/loading_adaptive_card.dart';
import 'package:flutter/material.dart';

class ActionSubmitPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Action.Submit"),
      ),
      body: ListView(
        children: <Widget>[
          DemoAdaptiveCard("lib/action_submit/example1",),
        ],
      ),
    );
  }
}
