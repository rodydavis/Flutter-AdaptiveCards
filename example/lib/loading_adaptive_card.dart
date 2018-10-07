import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_adaptive_cards/flutter_adaptive_cards.dart';


class LoadingAdaptiveCard extends StatefulWidget {

  final String assetPath;

  const LoadingAdaptiveCard(this.assetPath);


  @override
  _LoadingAdaptiveCardState createState() => new _LoadingAdaptiveCardState();
}

class _LoadingAdaptiveCardState extends State<LoadingAdaptiveCard> {


  Map adaptiveMap;
  Map hostConfig;


  @override
  void initState() {
    super.initState();
    rootBundle.loadString(widget.assetPath).then((string) {
      setState(() {
        adaptiveMap = json.decode(string);
      });
    });
    rootBundle.loadString("lib/host_config").then((string) {
      setState(() {
        hostConfig = json.decode(string);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return adaptiveMap == null || hostConfig == null ? Container(
      width: 100.0, height: 100.0, color: Colors.red,) : Padding(
      padding: const EdgeInsets.all(8.0),
      child: AdaptiveCard
          .fromMap(adaptiveMap, hostConfig),
    );
  }
}
