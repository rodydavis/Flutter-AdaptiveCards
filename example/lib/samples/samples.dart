

import 'package:example/loading_adaptive_card.dart';
import 'package:flutter/material.dart';

class SamplesPage extends StatelessWidget {

  /*var items = [
    Text("Example1"),
    DemoAdaptiveCard("lib/samples/example1",),
    Text("Example2"),
    DemoAdaptiveCard("lib/samples/example2",),
    Text("Example3"),
    DemoAdaptiveCard("lib/samples/example3",),
    Text("Example4"),
    DemoAdaptiveCard("lib/samples/example4",),
    Text("Example5"),
    DemoAdaptiveCard("lib/samples/example5",),
    Text("Example6"),
    DemoAdaptiveCard("lib/samples/example6",),
    Text("Example7"),
    DemoAdaptiveCard("lib/samples/example7",),
    Text("Example8"),
    DemoAdaptiveCard("lib/samples/example8",),
    Text("Example9"),
    DemoAdaptiveCard("lib/samples/example9",),
    Text("Example10"),
    DemoAdaptiveCard("lib/samples/example10",),
    Text("Example11"),
    DemoAdaptiveCard("lib/samples/example11",),
    Text("Example12"),
    DemoAdaptiveCard("lib/samples/example12",),
    Text("Example13"),
    DemoAdaptiveCard("lib/samples/example13",),
    Text("Example14"),
    DemoAdaptiveCard("lib/samples/example14",),
    Text("Example15"),
    DemoAdaptiveCard("lib/samples/example15",),
  ];*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Samples"),
      ),
      body: ListView.builder(
        itemCount: 15,
        itemBuilder: (context, index) {
          return DemoAdaptiveCard("lib/samples/example${index + 1}");
        },

      ),
    );
  }
}
