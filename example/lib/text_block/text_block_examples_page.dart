

import 'package:example/loading_adaptive_card.dart';
import 'package:flutter/material.dart';

class TextBlockPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TextBlock"),
      ),
      body: ListView(
        children: <Widget>[
          DemoAdaptiveCard("lib/text_block/example1",),
          DemoAdaptiveCard("lib/text_block/example2",),
          DemoAdaptiveCard("lib/text_block/example3",),
          DemoAdaptiveCard("lib/text_block/example4",),
          DemoAdaptiveCard("lib/text_block/example5",),
          DemoAdaptiveCard("lib/text_block/example6",),
          DemoAdaptiveCard("lib/text_block/example7",),
          DemoAdaptiveCard("lib/text_block/example8",),
          DemoAdaptiveCard("lib/text_block/example9",),
          DemoAdaptiveCard("lib/text_block/example10",),
        ],
      ),
    );
  }
}
