import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_adaptive_cards/src/flutter_adaptive_cards.dart';

class LabAdaptiveCard extends StatelessWidget {
  const LabAdaptiveCard({Key key, this.payload}) : super(key: key);

  final String payload;

  @override
  Widget build(BuildContext context) {
    return AdaptiveCard.memory(
      hostConfigPath: "lib/host_config",
      content: json.decode(payload),
      showDebugJson: true,
    );
  }
}



class DemoAdaptiveCard extends StatefulWidget {
  final String assetPath;

  const DemoAdaptiveCard(this.assetPath, {Key key}) : super(key: key);

  @override
  _DemoAdaptiveCardState createState() => new _DemoAdaptiveCardState();
}

class _DemoAdaptiveCardState extends State<DemoAdaptiveCard> with AutomaticKeepAliveClientMixin{
  String jsonFile;

  @override
  void initState() {
    super.initState();
    rootBundle.loadString(widget.assetPath).then((string) {
      jsonFile = string;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          AdaptiveCard.asset(
            assetPath: widget.assetPath,
            hostConfigPath: "lib/host_config",
            showDebugJson: false,
          ),
          FlatButton(
            textColor: Colors.indigo,
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
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

  @override
  bool get wantKeepAlive => true;
}
