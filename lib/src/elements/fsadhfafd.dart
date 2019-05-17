
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_cards/flutter_adaptive_cards.dart';
import 'package:provider/provider.dart';

mixin AdaptiveElementWidgetMixin on StatefulWidget {

  Map get adaptiveMap;
}


mixin AdaptiveElementMixin<T extends AdaptiveElementWidgetMixin> on State<T> {

  String id;

  RawAdaptiveCardState widgetState;

  Map get adaptiveMap => widget.adaptiveMap;

  @override
  void initState() {
    super.initState();

    widgetState = Provider.of<RawAdaptiveCardState>(context, listen: false);
    if (widget.adaptiveMap.containsKey("id")) {
      id = widget.adaptiveMap["id"];
    } else {
      id = widgetState.idGenerator.getId();
    }

  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AdaptiveElementMixin  &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

}



mixin AdaptiveActionMixin<T extends AdaptiveElementWidgetMixin> on State<T> implements AdaptiveElementMixin<T>{

  String get title => widget.adaptiveMap["title"];


  void onTapped();

}


mixin AdaptiveInputMixin<T extends AdaptiveElementWidgetMixin> on State<T> implements AdaptiveElementMixin<T>{

  String value;

  @override
  void initState() {
    super.initState();
    value = adaptiveMap["value"].toString() == "null"
        ? ""
        : adaptiveMap["value"].toString();
  }
  void appendInput(Map map);
}

mixin AdaptiveTextualInputMixin<T extends AdaptiveElementWidgetMixin> on State<T> implements AdaptiveInputMixin<T> {

  String placeholder;


  @override
  void initState() {
    super.initState();

    placeholder = widget.adaptiveMap["placeholder"] ?? "";

  }
}