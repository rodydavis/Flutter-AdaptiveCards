

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
          DemoAdaptiveCard("lib/samples/example1",),
          DemoAdaptiveCard("lib/samples/example2",),
          DemoAdaptiveCard("lib/samples/example3",),
          DemoAdaptiveCard("lib/samples/example4",),
          DemoAdaptiveCard("lib/samples/example5",),
          DemoAdaptiveCard("lib/samples/example6",),
          DemoAdaptiveCard("lib/samples/example7",),
          DemoAdaptiveCard("lib/samples/example8",),
          DemoAdaptiveCard("lib/samples/example9",),
          DemoAdaptiveCard("lib/samples/example10",), // TODO crashes because of the Image stretch property
          DemoAdaptiveCard("lib/samples/example11",),
       //   DemoAdaptiveCard("lib/samples/example12",),
          DemoAdaptiveCard("lib/samples/example13",),
          //DemoAdaptiveCard("lib/samples/example14",),
          DemoAdaptiveCard("lib/samples/example15",),
        ],
      ),
    );
  }
}
