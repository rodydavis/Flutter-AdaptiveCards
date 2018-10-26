

import 'package:example/loading_adaptive_card.dart';
import 'package:flutter/material.dart';

class ActionShowCardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Action.ShowCard"),
      ),
      body: ListView(
        children: <Widget>[
          DemoAdaptiveCard("lib/action_show_card/example1",),
        ],
      ),
    );
  }
}
