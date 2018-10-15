

import 'package:example/loading_adaptive_card.dart';
import 'package:flutter/material.dart';

class ContainerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Container"),
      ),
      body: ListView(
        children: <Widget>[
          LoadingAdaptiveCard("lib/container/example1",),
          LoadingAdaptiveCard("lib/container/example2",),
          LoadingAdaptiveCard("lib/container/example3",),
          LoadingAdaptiveCard("lib/container/example4",),
          LoadingAdaptiveCard("lib/container/example5",),
        ],
      ),
    );
  }
}
