

import 'package:example/loading_adaptive_card.dart';
import 'package:flutter/material.dart';

class ImageSetPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ImageSet"),
      ),
      body: ListView(
        children: <Widget>[
          LoadingAdaptiveCard("lib/image_set/example1",),
          LoadingAdaptiveCard("lib/image_set/example2",),
        ],
      ),
    );
  }
}
