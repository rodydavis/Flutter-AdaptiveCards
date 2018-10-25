import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_adaptive_cards/src/flutter_adaptive_cards.dart';

class LoadingAdaptiveCard extends StatefulWidget {

  final String assetPath;

  const LoadingAdaptiveCard(this.assetPath, {Key key}) : super(key: key);



  @override
  _LoadingAdaptiveCardState createState() => new _LoadingAdaptiveCardState();
}

class _LoadingAdaptiveCardState extends State<LoadingAdaptiveCard> with AutomaticKeepAliveClientMixin<LoadingAdaptiveCard>{


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
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    if(adaptiveMap == null || hostConfig == null) {
      return SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AdaptiveCard
          .fromMap(adaptiveMap, hostConfig),
    );
  }


}
