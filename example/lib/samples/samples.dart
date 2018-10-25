

import 'package:example/loading_adaptive_card.dart';
import 'package:flutter/material.dart';

class SamplesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Samples"),
      ),
      body: ListView(
        children: <Widget>[
          LoadingAdaptiveCard("lib/samples/example1",),
          LoadingAdaptiveCard("lib/samples/example2",),
          LoadingAdaptiveCard("lib/samples/example3",),
          LoadingAdaptiveCard("lib/samples/example4",),
          LoadingAdaptiveCard("lib/samples/example5",),
          LoadingAdaptiveCard("lib/samples/example6",),
          LoadingAdaptiveCard("lib/samples/example7",),
          LoadingAdaptiveCard("lib/samples/example8",),
          LoadingAdaptiveCard("lib/samples/example9",),
          LoadingAdaptiveCard("lib/samples/example10",),
          LoadingAdaptiveCard("lib/samples/example11",),
          LoadingAdaptiveCard("lib/samples/example12",),
          LoadingAdaptiveCard("lib/samples/example13",),
          LoadingAdaptiveCard("lib/samples/example14",),
          LoadingAdaptiveCard("lib/samples/example15",),
        ],
      ),
    );
  }
}
