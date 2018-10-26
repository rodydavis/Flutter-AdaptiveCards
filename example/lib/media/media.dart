

import 'package:example/loading_adaptive_card.dart';
import 'package:flutter/material.dart';

class MediaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Media"),
      ),
      body: ListView(
        children: <Widget>[
          DemoAdaptiveCard("lib/media/example1",),
        ],
      ),
    );
  }
}
