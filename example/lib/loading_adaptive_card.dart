import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_adaptive_cards/src/flutter_adaptive_cards.dart';

class DemoAdaptiveCard extends StatefulWidget {

  final String assetPath;

  const DemoAdaptiveCard(this.assetPath, {Key key}) : super(key: key);



  @override
  _DemoAdaptiveCardState createState() => new _DemoAdaptiveCardState();
}

class _DemoAdaptiveCardState extends State<DemoAdaptiveCard> with AutomaticKeepAliveClientMixin<DemoAdaptiveCard>{


  Map adaptiveMap;
  Map hostConfig;

  String jsonFile;

  @override
  void initState() {
    super.initState();
    rootBundle.loadString(widget.assetPath).then((string) {
      jsonFile = string;
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
      child: Column(
        children: <Widget>[
          AdaptiveCard
              .fromMap(adaptiveMap, hostConfig),
          FlatButton(
            textColor: Colors.indigo,
            onPressed: () {
              showDialog(context: context, builder: (context) {
                return AlertDialog(
                  title: Text("JSON"),
                  content: SingleChildScrollView(child: Text(jsonFile)),
                  actions: <Widget>[
                    Center(
                      child: FlatButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Thanks"),
                      ),
                    )
                  ],
                  contentPadding: EdgeInsets.all(8.0),
                );
              });
            },
            child: Text("Show the JSON"),
          ),
        ],
      ),
    );
  }


}
