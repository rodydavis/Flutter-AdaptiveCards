

import 'package:example/loading_adaptive_card.dart';
import 'package:flutter/material.dart';

class ImagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image"),
      ),
      body: ListView(
        children: <Widget>[
          LoadingAdaptiveCard("lib/image/example1",),
          LoadingAdaptiveCard("lib/image/example2",),
          LoadingAdaptiveCard("lib/image/example3",),
          LoadingAdaptiveCard("lib/image/example4",),
          LoadingAdaptiveCard("lib/image/example5",),
          LoadingAdaptiveCard("lib/image/example6",),
        ],
      ),
    );
  }
}
