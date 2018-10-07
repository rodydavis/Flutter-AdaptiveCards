

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
          LoadingAdaptiveCard("lib/text_block/example1",),
          LoadingAdaptiveCard("lib/text_block/example2",),
          LoadingAdaptiveCard("lib/text_block/example3",),
          LoadingAdaptiveCard("lib/text_block/example4",),
          LoadingAdaptiveCard("lib/text_block/example5",),
          LoadingAdaptiveCard("lib/text_block/example6",),
          LoadingAdaptiveCard("lib/text_block/example7",),
          LoadingAdaptiveCard("lib/text_block/example8",),
          LoadingAdaptiveCard("lib/text_block/example9",),
          LoadingAdaptiveCard("lib/text_block/example10",),
        ],
      ),
    );
  }
}
