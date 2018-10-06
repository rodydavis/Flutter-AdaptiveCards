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

  _AdaptiveElement _adaptiveElement;


  @override
  void initState() {
    super.initState();
    _referenceResolver = _ReferenceResolver(widget.hostConfig);
    /// TODO no need to pass atomicIdGenerator because it is not re constructed every time
    _adaptiveElement = getElement(widget.map, _referenceResolver, this, _AtomicIdGenerator());

  }


  void rebuild() {
    setState((){});
  }

  void submit() {

  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: _adaptiveElement.generateWidget(),
    );
  }
}




typedef void OnShowCard(_AdaptiveElement elementToShow);


/// Elements are *not* re constructed when setState is called.
///
abstract class _AdaptiveElement {
  _AdaptiveElement(this.adaptiveMap, this.resolver, this.widgetState, this.idGenerator) {
    loadTree();
  }


  final Map adaptiveMap;
  final _ReferenceResolver resolver;
  final _AtomicIdGenerator idGenerator;

  String id;

  /// Because some widgets (looking at you ShowCardAction) need to set the state
  /// all elements get a way to set the state.
  final AdaptiveCardState widgetState;

  Widget generateWidget();

  void loadId() {
    if(adaptiveMap.containsKey("id")) {
      id = adaptiveMap["id"];
    } else {
      id = idGenerator.getId();
    }
  }

  void loadTree() {
    loadId();
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
  _AdaptiveCardElement(Map adaptiveMap, _ReferenceResolver resolver, widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap, resolver, widgetState, idGenerator);

  _AdaptiveElement currentShowingCard;

  List<_AdaptiveElement> children;

  List<_AdaptiveAction> actions;

  @override
  void loadTree() {
    super.loadTree();
    children = List<Map>.from(adaptiveMap["body"])
        .map((map) => getElement(map, resolver, widgetState, idGenerator)).toList();

    if(adaptiveMap.containsKey("actions")) {
    actions =  List<Map>.from(adaptiveMap["actions"])
        .map((map) => getAction(map, resolver, widgetState, showCard, idGenerator)).toList();
    } else {
    actions =  [];
    }
  }

  @override
  Widget generateWidget() {
    List<Widget> widgetChildren = children.map((element) => element.generateWidget()).toList();
    widgetChildren.addAll(actions.map((action) => action.generateWidget()).toList());
    if(currentShowingCard != null) {
      widgetChildren.add(currentShowingCard.generateWidget());
    }
    return Column(
      children: widgetChildren,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }


  /// This is called when an [_AdaptiveActionShowCard] triggers it.
  void showCard(_AdaptiveElement element) {
    if(currentShowingCard == element) {
      currentShowingCard = null;
    } else {
      currentShowingCard = element;
    }
    widgetState.rebuild();
  }

}


class _AdaptiveTextBlock extends _AdaptiveElement {
  _AdaptiveTextBlock(Map adaptiveMap, _ReferenceResolver resolver, widgetState, _AtomicIdGenerator idGenerator) : super(adaptiveMap, resolver, widgetState, idGenerator);


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
      widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap, resolver, widgetState, idGenerator);


  List<_AdaptiveElement> children;

  @override
  void loadTree() {
    super.loadTree();
    children = List<Map>.from(adaptiveMap["items"]).map((child) => getElement(child, resolver, widgetState, idGenerator)).toList();

  }

  Widget generateWidget() {
    return Column(
      children: children.map((it) => it.generateWidget()).toList(),
    );
  }

}


class _AdaptiveColumnSet extends _AdaptiveElement {

  _AdaptiveColumnSet(Map adaptiveMap, _ReferenceResolver resolver, AdaptiveCardState widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap, resolver, widgetState, idGenerator);


  List<_AdaptiveColumn> columns;

  @override
  void loadTree() {
    super.loadTree();

    // TODO handle case where there are no children elegantly
    columns = List<Map>.from(adaptiveMap["columns"]).map((child) => _AdaptiveColumn(child, resolver, widgetState, idGenerator)).toList();

  }

  @override
  Widget generateWidget() {
   return Row(
      children: columns.map((it) => it.generateWidget()).toList(),
     mainAxisAlignment: MainAxisAlignment.start,
     crossAxisAlignment: CrossAxisAlignment.center,
   );
  }



}

class _AdaptiveColumn extends _AdaptiveElement {
  _AdaptiveColumn(Map adaptiveMap, _ReferenceResolver resolver, AdaptiveCardState widgetState, _AtomicIdGenerator idGenerator) : super(adaptiveMap, resolver, widgetState, idGenerator);


  List<_AdaptiveElement> items;


  @override
  void loadTree() {
    super.loadTree();
    items = List<Map>.from(adaptiveMap["items"]).map((child) => getElement(child, resolver, widgetState, idGenerator)).toList();
  }

  @override
  Widget generateWidget() {
    return Column(
      children: items.map((it) => it.generateWidget()).toList(),
    );
  }

}















/// Text input elements

abstract class _AdaptiveInput extends _AdaptiveElement {
  _AdaptiveInput(Map adaptiveMap, _ReferenceResolver resolver, widgetState, _AtomicIdGenerator idGenerator) : super(adaptiveMap, resolver, widgetState, idGenerator);


  void appendInput(Map map);



}

class _AdaptiveTextInput extends _AdaptiveInput {
  _AdaptiveTextInput(Map adaptiveMap, _ReferenceResolver resolver, widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap, resolver, widgetState, idGenerator);


  TextEditingController controller = TextEditingController();




  @override
  Widget generateWidget() {
    return TextField(
      controller: controller,
    );
  }

  @override
  void appendInput(Map map) {
    map[id] = controller.value;
  }

}












/// Actions

abstract class _AdaptiveAction extends _AdaptiveElement {
  _AdaptiveAction(Map adaptiveMap, _ReferenceResolver resolver, widgetState, _AtomicIdGenerator idGenerator) : super(adaptiveMap, resolver, widgetState, idGenerator);


  String get title => adaptiveMap["title"];

}

class _AdaptiveActionShowCard extends _AdaptiveAction {

  _AdaptiveActionShowCard(Map adaptiveMap, _ReferenceResolver resolver, widgetState,
      _AtomicIdGenerator idGenerator, this.onShowCard) : super(adaptiveMap, resolver, widgetState, idGenerator);



  _AdaptiveElement card;

  final OnShowCard onShowCard;


  @override
  void loadTree() {
    super.loadTree();
    card = getElement(adaptiveMap["card"], resolver, widgetState, idGenerator);

  }

  @override
  Widget generateWidget() {
    return MaterialButton(
      onPressed: () {
        onShowCard(card);
      },
      child: Text(title),
    );
  }



}

class _AdaptiveActionSubmit extends _AdaptiveAction {

  _AdaptiveActionSubmit(Map adaptiveMap, _ReferenceResolver resolver, widgetState, _AtomicIdGenerator idGenerator) : super(adaptiveMap, resolver, widgetState, idGenerator);



  @override
  Widget generateWidget() {
    return MaterialButton(
      onPressed: () {
        widgetState.submit();
      },
      child: Text(title),
    );
  }

}
















/// This returns an [_AdaptiveElement] with the correct type.
///
/// It looks at the [type] property and decides which object to construct
_AdaptiveElement getElement(Map<String, dynamic> map, _ReferenceResolver resolver,
    AdaptiveCardState widgetState, _AtomicIdGenerator idGenerator) {

  String stringType = map["type"];
  // Because enum dont allow ".", we have to remove them to make a nice match.
  String cleanedType = stringType.replaceAll(".", "");
  // TODO optimize, probably do not want to iterate over all enums every time, probably store them in
  // TODO a map and acess them in O(1)
  _AdaptiveCardType type = _AdaptiveCardType.values.firstWhere((it) => it.toString() == "$_AdaptiveCardType.$cleanedType");
  switch(type) {
    case _AdaptiveCardType.Container:
      return _AdaptiveContainer(map, resolver, widgetState, idGenerator);
    case _AdaptiveCardType.TextBlock:
      return _AdaptiveTextBlock(map, resolver, widgetState, idGenerator);
    case _AdaptiveCardType.InputText:
      return _AdaptiveTextInput(map, resolver, widgetState, idGenerator);
    case _AdaptiveCardType.AdaptiveCard:
      return _AdaptiveCardElement(map, resolver, widgetState, idGenerator);
    case _AdaptiveCardType.AdaptiveColumnSet:
      return _AdaptiveColumnSet(map, resolver, widgetState, idGenerator);
  }
  return null;
}

// TODO this is code duplication, maybe better way to do this
_AdaptiveAction getAction(Map<String, dynamic> map, _ReferenceResolver resolver,
    AdaptiveCardState widgetState, OnShowCard onShowCard, _AtomicIdGenerator idGenerator) {
  String stringType = map["type"];
  // Because enum dont allow ".", we have to remove them to make a nice match.
  String cleanedType = stringType.replaceAll(".", "");
  // TODO optimize, probably do not want to iterate over all enums every time, probably store them in
  // TODO a map and acess them in O(1)
  _AdaptiveActionType type = _AdaptiveActionType.values.firstWhere((it) => it.toString() == "$_AdaptiveActionType.$cleanedType");
  switch(type) {
    case _AdaptiveActionType.ActionShowCard:
      return _AdaptiveActionShowCard(map, resolver, widgetState, idGenerator, onShowCard);
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
  AdaptiveColumnSet,
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
///
/// TODO replace with UUID
class _AtomicIdGenerator {

  int index = 0;

  String _idPrefix = "pleaseDontUseThisIdAnywhereElse";


  String getId() {
    String id =  "$_idPrefix.$index";
    index++;
    return id;
  }

}

