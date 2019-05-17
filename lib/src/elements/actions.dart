import 'package:flutter/material.dart';
import 'package:flutter_adaptive_cards/flutter_adaptive_cards.dart';
import 'package:flutter_adaptive_cards/src/elements/basics.dart';

import 'fsadhfafd.dart';



class IconButtonAction extends StatefulWidget with AdaptiveElementWidgetMixin {

  IconButtonAction({Key key, this.adaptiveMap, this.onTapped}) : super(key: key);

  final Map adaptiveMap;

  final VoidCallback onTapped;

  @override
  _IconButtonActionState createState() => _IconButtonActionState();
}

class _IconButtonActionState extends State<IconButtonAction> with AdaptiveActionMixin, AdaptiveElementMixin{


  String iconUrl;
  @override
  void initState() {
    super.initState();
    iconUrl = adaptiveMap["iconUrl"];

  }

  @override
  Widget build(BuildContext context) {
    Widget result = RaisedButton(
      onPressed: onTapped,
      child: Text(title),
    );

    if (iconUrl != null) {
      result = RaisedButton.icon(
        onPressed: onTapped,
        icon: Image.network(
          iconUrl,
          height: 36.0,
        ),
        label: Text(title),
      );
    }
    return result;
  }

  @override
  void onTapped() => widget.onTapped();
}




class AdaptiveActionShowCard extends StatefulWidget with AdaptiveElementWidgetMixin  {

  AdaptiveActionShowCard({Key key, this.adaptiveMap}) : super(key: key);

  final Map adaptiveMap;
  @override
  _AdaptiveActionShowCardState createState() => _AdaptiveActionShowCardState();
}

class _AdaptiveActionShowCardState extends State<AdaptiveActionShowCard> with
    AdaptiveActionMixin, AdaptiveElementMixin{

  Widget card;


  bool expanded = false;

  @override
  void initState() {
    super.initState();

    card = widgetState.cardRegistry.getElement(adaptiveMap["card"]);
  }

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: onTapped,
      child: Row(
        children: <Widget>[
          Text(title),
          expanded
              ? Icon(Icons.keyboard_arrow_up)
              : Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }


  @override
  void onTapped() {
    var _adaptiveCardElement = AdaptiveCardElementState.of(context);
    if (_adaptiveCardElement != null) {
      _adaptiveCardElement.showCard(this);
    }
  }
}


class AdaptiveActionSubmit extends StatefulWidget with AdaptiveElementWidgetMixin {

  AdaptiveActionSubmit({Key key, this.adaptiveMap}) : super(key: key);

  final Map adaptiveMap;
  @override
  _AdaptiveActionSubmitState createState() => _AdaptiveActionSubmitState();
}

class _AdaptiveActionSubmitState extends State<AdaptiveActionSubmit> with AdaptiveActionMixin, AdaptiveElementMixin{

  Map data;

  // Native styling
  final Color color;

  @override
  void initState() {
    super.initState();

    data = adaptiveMap["data"] ?? {};

  }
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: color,
      onPressed: onTapped,
      child: Text(title),
    );
  }


  @override
  void onTapped() {
    widgetState.submit(data);
  }
}




class AdaptiveActionOpenUrl extends StatefulWidget with AdaptiveElementWidgetMixin {

  AdaptiveActionOpenUrl({Key key, this.adaptiveMap}) : super(key: key);

  final Map adaptiveMap;
  @override
  _AdaptiveActionOpenUrlState createState() => _AdaptiveActionOpenUrlState();
}

class _AdaptiveActionOpenUrlState extends State<AdaptiveActionOpenUrl> with AdaptiveActionMixin, AdaptiveElementMixin{


  String url;
  String iconUrl;



  @override
  void initState() {
    super.initState();

    url = adaptiveMap["url"];
    iconUrl = adaptiveMap["iconUrl"];
  }
  @override
  Widget build(BuildContext context) {
    // TODO
    return IconButtonAction(
      adaptiveMap: adaptiveMap,
      onTapped: onTapped,
    );
  }


  @override
  void onTapped() {
    widgetState.openUrl(url);
  }
}

