import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../flutter_adaptive_cards.dart';
import 'base.dart';
import 'basics.dart';

class IconButtonAction extends StatefulWidget with AdaptiveElementWidgetMixin {
  IconButtonAction({
    Key key,
    this.adaptiveMap,
    this.onTapped,
    this.adaptiveOS = true,
  }) : super(key: key);

  final Map adaptiveMap;

  final VoidCallback onTapped;

  final bool adaptiveOS;

  @override
  _IconButtonActionState createState() => _IconButtonActionState();
}

class _IconButtonActionState extends State<IconButtonAction>
    with AdaptiveActionMixin, AdaptiveElementMixin {
  String iconUrl;
  @override
  void initState() {
    super.initState();
    iconUrl = adaptiveMap["iconUrl"];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.adaptiveOS) {
      if (Platform.isIOS || Platform.isMacOS) {
        Widget result = CupertinoButton(
          padding: EdgeInsets.all(4.0),
          onPressed: onTapped,
          child: Text(title),
        );

        if (iconUrl != null) {
          result = CupertinoButton(
            padding: EdgeInsets.all(4.0),
            onPressed: onTapped,
            child: Row(
              children: <Widget>[
                Image.network(
                  iconUrl,
                  height: 36.0,
                ),
                Text(title),
              ],
            ),
          );
        }
        return result;
      }
    }
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

class AdaptiveActionShowCard extends StatefulWidget
    with AdaptiveElementWidgetMixin {
  AdaptiveActionShowCard({
    Key key,
    this.adaptiveMap,
    this.adaptiveOS = true,
  }) : super(key: key);

  final Map adaptiveMap;

  final bool adaptiveOS;

  @override
  _AdaptiveActionShowCardState createState() => _AdaptiveActionShowCardState();
}

class _AdaptiveActionShowCardState extends State<AdaptiveActionShowCard>
    with AdaptiveActionMixin, AdaptiveElementMixin {
  @override
  void initState() {
    super.initState();

    Widget card = widgetState.cardRegistry.getElement(adaptiveMap["card"]);

    var _adaptiveCardElement = AdaptiveCardElementState.of(context);
    if (_adaptiveCardElement != null) {
      _adaptiveCardElement.registerCard(id, card);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.adaptiveOS) {
      if (Platform.isIOS || Platform.isMacOS) {
        return CupertinoButton(
          padding: EdgeInsets.all(4.0),
          onPressed: onTapped,
          child: Row(
            children: <Widget>[
              Text(title),
              AdaptiveCardElementState.of(context).currentCardId == id
                  ? Icon(Icons.keyboard_arrow_up)
                  : Icon(Icons.keyboard_arrow_down),
            ],
          ),
        );
      }
    }
    return RaisedButton(
      onPressed: onTapped,
      child: Row(
        children: <Widget>[
          Text(title),
          AdaptiveCardElementState.of(context).currentCardId == id
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
      _adaptiveCardElement.showCard(id);
    }
  }
}

class AdaptiveActionSubmit extends StatefulWidget
    with AdaptiveElementWidgetMixin {
  AdaptiveActionSubmit({
    Key key,
    this.adaptiveMap,
    this.color,
    this.adaptiveOS = true,
  }) : super(key: key);

  final Map adaptiveMap;

  // Native styling
  final Color color;

  final bool adaptiveOS;

  @override
  _AdaptiveActionSubmitState createState() => _AdaptiveActionSubmitState();
}

class _AdaptiveActionSubmitState extends State<AdaptiveActionSubmit>
    with AdaptiveActionMixin, AdaptiveElementMixin {
  GenericSubmitAction action;

  @override
  void initState() {
    super.initState();
    action = GenericSubmitAction(adaptiveMap, widgetState);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.adaptiveOS) {
      if (Platform.isIOS || Platform.isMacOS) {
        return CupertinoButton(
          padding: EdgeInsets.all(4.0),
          color: widget.color,
          onPressed: onTapped,
          child: Text(title),
        );
      }
    }
    return RaisedButton(
      color: widget.color,
      onPressed: onTapped,
      child: Text(title),
    );
  }

  @override
  void onTapped() {
    action.tap();
  }
}

class AdaptiveActionOpenUrl extends StatefulWidget
    with AdaptiveElementWidgetMixin {
  AdaptiveActionOpenUrl({Key key, this.adaptiveMap}) : super(key: key);

  final Map adaptiveMap;
  @override
  _AdaptiveActionOpenUrlState createState() => _AdaptiveActionOpenUrlState();
}

class _AdaptiveActionOpenUrlState extends State<AdaptiveActionOpenUrl>
    with AdaptiveActionMixin, AdaptiveElementMixin {
  GenericActionOpenUrl action;
  String iconUrl;

  @override
  void initState() {
    super.initState();

    action = GenericActionOpenUrl(adaptiveMap, widgetState);
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
    action.tap();
  }
}
