library flutter_adaptive_cards;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdaptiveCard extends StatefulWidget {


 /* AdaptiveCard.fromAsset(String assetName):
  _adaptiveCardReader = _AdaptiveCardReader.fromAsset(assetName);
*/
  AdaptiveCard.fromMap(this.map, this.hostConfig);



  final Map map;
  final Map hostConfig;

  @override
  AdaptiveCardState createState() => AdaptiveCardState();
}

class AdaptiveCardState extends State<AdaptiveCard> {



  _ReferenceResolver _referenceResolver;


  @override
  void initState() {
    super.initState();
    _referenceResolver = _ReferenceResolver(widget.hostConfig);
    /// TODO no need to pass atomicIdGenerator because it is not re constructed every time

  }


  void stateSetter() {
    setState((){});
  }
  @override
  Widget build(BuildContext context) {
    return getElement(widget.map, _referenceResolver, stateSetter, _AtomicIdGenerator()).generateWidget();
  }
}



typedef void OnShowCard(_AdaptiveElement elementToShow);


/// Elements are *not* rebuilt when setState is called.
///
abstract class _AdaptiveElement {
  _AdaptiveElement(this.adaptiveMap, this.resolver, this.stateSetter, this.idGenerator) {
    loadId();
  }


  final Map adaptiveMap;
  final _ReferenceResolver resolver;
  final _AtomicIdGenerator idGenerator;

  String id;

  /// Because some widgets (looking at you ShowCardAction) need to set the state
  /// all elements get a way to set the state.
  final VoidCallback stateSetter;

  Widget generateWidget();

  void loadId() {
    if(adaptiveMap.containsKey("id")) {
      id = adaptiveMap["id"];
    } else {
      id = idGenerator.getId();
    }
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is _AdaptiveElement &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

}

/// This element also takes actions
class _AdaptiveCardElement extends _AdaptiveElement{
  _AdaptiveCardElement(Map adaptiveMap, _ReferenceResolver resolver, stateSetter, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap, resolver, stateSetter, idGenerator) {
    state = _stateStore.getState(id);
    if(state == null) {
      state = _AdaptiveCardState();
    }
  }
  _AdaptiveCardState state;

  @override
  Widget generateWidget() {
    List<Widget> widgetChildren = children.map((element) => element.generateWidget()).toList();
    widgetChildren.addAll(actions.map((action) => action.generateWidget()).toList());
    if(state.currentShowingCard != null) {
      widgetChildren.add(state.currentShowingCard.generateWidget());
    }
    return Column(
      children: widgetChildren,
    );
  }


  /// This is called when an [_AdaptiveActionShowCard] triggers it.
  void showCard(_AdaptiveElement element) {
    if(state.currentShowingCard == element) {
      state.currentShowingCard = null;
    } else {
      state.currentShowingCard = element;
    }
    _stateStore.saveState(id, state);
    stateSetter();
  }

  List<_AdaptiveElement> get children => List<Map>.from(adaptiveMap["body"])
      .map((map) => getElement(map, resolver, stateSetter, idGenerator)).toList();

  List<_AdaptiveAction> get actions {
    if(adaptiveMap.containsKey("actions")) {
      return List<Map>.from(adaptiveMap["actions"])
        .map((map) => getAction(map, resolver, stateSetter, showCard, idGenerator)).toList();
    } else {
      return [];
    }
  }

}

class _AdaptiveCardState extends _ElementState {
  _AdaptiveElement currentShowingCard;

}

class _AdaptiveTextBlock extends _AdaptiveElement {
  _AdaptiveTextBlock(Map adaptiveMap, _ReferenceResolver resolver, stateSetter, _AtomicIdGenerator idGenerator) : super(adaptiveMap, resolver, stateSetter, idGenerator);





  Widget generateWidget() {
    return Text(text, style: TextStyle(fontWeight: fontWeight, fontSize:fontSize),);
  }

  String get text => adaptiveMap["text"];

  double get fontSize {
    int size = resolver.resolve("fontSizes", adaptiveMap["size"]);
    return size.toDouble();
  }

  FontWeight get fontWeight {
    int weight = resolver.resolve("fontWeights", adaptiveMap["weight"]) ;
    return FontWeight.values.firstWhere((possibleWeight) => possibleWeight.toString() == "FontWeight.w$weight");
  }


}

class _AdaptiveContainer extends _AdaptiveElement {
  _AdaptiveContainer(Map adaptiveMap, _ReferenceResolver resolver,
      stateSetter, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap, resolver, stateSetter, idGenerator);



  Widget generateWidget() {
    return Column(
      children: children.map((child) => getElement(child, resolver, stateSetter, idGenerator).generateWidget()).toList(),
    );
  }

  List<Map> get children => List<Map>.from(adaptiveMap["items"]);

}


/// Text input elements

abstract class _AdaptiveInput extends _AdaptiveElement {
  _AdaptiveInput(Map adaptiveMap, _ReferenceResolver resolver, stateSetter, _AtomicIdGenerator idGenerator) : super(adaptiveMap, resolver, stateSetter, idGenerator);
}

class _AdaptiveTextInput extends _AdaptiveInput {
  _AdaptiveTextInput(Map adaptiveMap, _ReferenceResolver resolver, stateSetter, _AtomicIdGenerator idGenerator) : super(adaptiveMap, resolver, stateSetter, idGenerator);




  @override
  Widget generateWidget() {
    return TextField();
  }

}


/// Actions

abstract class _AdaptiveAction extends _AdaptiveElement {
  _AdaptiveAction(Map adaptiveMap, _ReferenceResolver resolver, stateSetter, _AtomicIdGenerator idGenerator) : super(adaptiveMap, resolver, stateSetter, idGenerator);


  String get title => adaptiveMap["title"];

}

class _AdaptiveActionShowCard extends _AdaptiveAction {




  _AdaptiveActionShowCard(Map adaptiveMap, _ReferenceResolver resolver, stateSetter,
      _AtomicIdGenerator idGenerator, this.onShowCard) : super(adaptiveMap, resolver, stateSetter, idGenerator);

  final OnShowCard onShowCard;

  @override
  Widget generateWidget() {
    // Event if not displayed, build to have stable ids
    _AdaptiveElement it = card;
    return MaterialButton(
      onPressed: () {
        onShowCard(card);
      },
      child: Text(title),
    );
  }

  _AdaptiveElement get card {
    return getElement(adaptiveMap["card"], resolver, stateSetter, idGenerator);
  }

}

class _AdaptiveActionSubmit extends _AdaptiveAction {
  _AdaptiveActionSubmit(Map adaptiveMap, _ReferenceResolver resolver, stateSetter, _AtomicIdGenerator idGenerator) : super(adaptiveMap, resolver, stateSetter, idGenerator);



  @override
  Widget generateWidget() {
    // TODO: implement generateWidget
  }

}

/// This returns an [_AdaptiveElement] with the correct type.
///
/// It looks at the [type] property and decides which object to construct
_AdaptiveElement getElement(Map<String, dynamic> map, _ReferenceResolver resolver,
    VoidCallback stateSetter, _AtomicIdGenerator idGenerator) {

  String stringType = map["type"];
  // Because enum dont allow ".", we have to remove them to make a nice match.
  String cleanedType = stringType.replaceAll(".", "");
  // TODO optimize, probably do not want to iterate over all enums every time, probably store them in
  // TODO a map and acess them in O(1)
  _AdaptiveCardType type = _AdaptiveCardType.values.firstWhere((it) => it.toString() == "$_AdaptiveCardType.$cleanedType");
  switch(type) {
    case _AdaptiveCardType.Container:
      return _AdaptiveContainer(map, resolver, stateSetter, idGenerator);
    case _AdaptiveCardType.TextBlock:
      return _AdaptiveTextBlock(map, resolver, stateSetter, idGenerator);
    case _AdaptiveCardType.InputText:
      return _AdaptiveTextInput(map, resolver, stateSetter, idGenerator);
    case _AdaptiveCardType.AdaptiveCard:
      return _AdaptiveCardElement(map, resolver, stateSetter, idGenerator);
  }
  return null;
}

// TODO this is code duplication, maybe better way to do this
_AdaptiveAction getAction(Map<String, dynamic> map, _ReferenceResolver resolver,
    VoidCallback stateSetter, OnShowCard onShowCard, _AtomicIdGenerator idGenerator) {
  String stringType = map["type"];
  // Because enum dont allow ".", we have to remove them to make a nice match.
  String cleanedType = stringType.replaceAll(".", "");
  // TODO optimize, probably do not want to iterate over all enums every time, probably store them in
  // TODO a map and acess them in O(1)
  _AdaptiveActionType type = _AdaptiveActionType.values.firstWhere((it) => it.toString() == "$_AdaptiveActionType.$cleanedType");
  switch(type) {
    case _AdaptiveActionType.ActionShowCard:
      return _AdaptiveActionShowCard(map, resolver, stateSetter, idGenerator, onShowCard);
    case _AdaptiveActionType.ActionSubmit:
      return null;
    case _AdaptiveActionType.ActionOpenUrl:
      return null;
  }
  return null;
}



enum _AdaptiveCardType {
  TextBlock,
  Container,
  InputText,
  AdaptiveCard,
}

enum _AdaptiveActionType {
  ActionShowCard,
  ActionSubmit,
  ActionOpenUrl,
}


class _ReferenceResolver {


  _ReferenceResolver(this.hostConfig);

  final Map hostConfig;

  dynamic resolve(String key, String value) {
    return hostConfig[key][value];
  }

}

/// Some elements always need an id to function
/// (Looking at you [_AdaptiveActionShowCard]) because the objects are rebuilt
/// every build time using a UUID generator wouldn't work (different ids for
/// the same objects). But the elements are traversed the same way every time.
///
/// A new instance of this class is used every build time to ensure that all ids
/// are different but same objects maintain their ids.
class _AtomicIdGenerator {

  int index = 0;

  String _idPrefix = "pleaseDontUseThisIdAnywhereElse";


  String getId() {
    String id =  "$_idPrefix.$index";
    index++;
    return id;
  }

}


abstract class _ElementState {

}
_StateStore _stateStore = _StateStore();

class _StateStore {

  Map<String, _ElementState> states = {};

  _ElementState getState(String id) {
    return states[id];
  }

  void saveState(String id, _ElementState state) {
    states[id] = state;
  }
}