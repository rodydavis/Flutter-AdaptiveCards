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

  Future<DateTime> pickDate() {
    DateTime initialDate = DateTime.now();
    return showDatePicker(context: context, initialDate: initialDate, firstDate: initialDate, lastDate: DateTime.now().add(Duration(days: 365)));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: _adaptiveElement.generateWidget(),
    );
  }
}






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

  _AdaptiveActionShowCard currentlyActiveShowCardAction;

  List<_AdaptiveElement> children;

  List<_AdaptiveAction> allActions;

  List<_AdaptiveActionShowCard> showCardActions;

  Axis actionsOrientation;

  @override
  void loadTree() {
    super.loadTree();

    if(adaptiveMap.containsKey("actions")) {
      allActions =  List<Map>.from(adaptiveMap["actions"]).map((map) => getAction(map, resolver, widgetState, this, idGenerator)).toList();
      showCardActions = List<_AdaptiveActionShowCard>.from(allActions.where((action) => action is _AdaptiveActionShowCard).toList());
    } else {
      allActions =  [];
      showCardActions = [];
    }

    String stringAxis = resolver.resolve("actions", "actionsOrientation");
    if(stringAxis == "Horizontal") actionsOrientation = Axis.horizontal;
    else if(stringAxis == "Vertical") actionsOrientation = Axis.vertical;


    children = List<Map>.from(adaptiveMap["body"]).map((map) => getElement(map, resolver, widgetState, idGenerator)).toList();

  }

  @override
  Widget generateWidget() {
    List<Widget> widgetChildren = children.map((element) => element.generateWidget()).toList();

    // Adds the actions
    List<Widget> actionWidgets = allActions.map((action) => action.generateWidget()).toList();
    Widget actionWidget;
    if(actionsOrientation == Axis.vertical) {
      actionWidget = Column(
        children: actionWidgets,
        mainAxisAlignment: MainAxisAlignment.start,
      );
    } else {
      actionWidget = Row(
        children: actionWidgets,
        crossAxisAlignment: CrossAxisAlignment.start,
      );
    }
    widgetChildren.add(actionWidget);

    if(currentlyActiveShowCardAction != null) {
      widgetChildren.add(currentlyActiveShowCardAction.card.generateWidget());
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: widgetChildren,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }


  /// This is called when an [_AdaptiveActionShowCard] triggers it.
  void showCard(_AdaptiveActionShowCard showCardAction) {
    if(currentlyActiveShowCardAction == showCardAction) {
      currentlyActiveShowCardAction = null;
    } else {
      currentlyActiveShowCardAction = showCardAction;
    }
    showCardAction.expanded = !showCardAction.expanded;
    showCardActions.where((it) =>  it != showCardAction).forEach((it) => (){it.expanded = false;}());
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
    int size = resolver.resolve("fontSizes", adaptiveMap["size"]?? "default");
    return size.toDouble();
  }

  FontWeight get fontWeight {
    int weight = resolver.resolve("fontWeights", adaptiveMap["weight"]?? "default") ;
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: children.map((it) => it.generateWidget()).toList(),
      ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

}


class _AdaptiveFactSet extends _AdaptiveElement {
  _AdaptiveFactSet(Map adaptiveMap, _ReferenceResolver resolver, AdaptiveCardState widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap, resolver, widgetState, idGenerator);


  List<_AdaptiveFact> facts;


  @override
  void loadTree() {
    super.loadTree();
    facts = List<Map>.from(adaptiveMap["facts"]).map((child) => _AdaptiveFact(child, resolver, widgetState, idGenerator)).toList();
  }

  @override
  Widget generateWidget() {
    return Row(
      children: [
        Column(
          children: facts.map((fact) => Text(fact.title, style: TextStyle(fontWeight: FontWeight.bold),)).toList(),
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        SizedBox(width: 8.0,),
        Column(
          children: facts.map((fact) => Text(fact.value)).toList(),
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

}

class _AdaptiveFact extends _AdaptiveElement {
  _AdaptiveFact(Map adaptiveMap, _ReferenceResolver resolver, AdaptiveCardState widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap, resolver, widgetState, idGenerator);


  String title;
  String value;


  @override
  void loadTree() {
    super.loadTree();
    title = adaptiveMap["title"];
    value = adaptiveMap["value"];
  }

  @override
  Widget generateWidget() {
    throw StateError("The widget should be built by _AdaptiveFactSet");
  }

}


class _AdaptiveImage extends _AdaptiveElement {
  _AdaptiveImage(Map adaptiveMap, _ReferenceResolver resolver, AdaptiveCardState widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap, resolver, widgetState, idGenerator);

  @override
  Widget generateWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(backgroundImage: NetworkImage(url), radius: size / 2,),
    );
  }


  String get url => adaptiveMap["url"];

  double get size {
    String sizeDescription = adaptiveMap["size"];
    if(sizeDescription == null) sizeDescription = "auto";

    int size = resolver.resolve("imageSizes", sizeDescription?? "default");
    return size.toDouble();
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

class _AdaptiveDateInput extends _AdaptiveInput {
  _AdaptiveDateInput(Map adaptiveMap, _ReferenceResolver resolver, widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap, resolver, widgetState, idGenerator);


  DateTime selectedDateTime;

  @override
  Widget generateWidget() {
    return RaisedButton(
      onPressed: () async {
        selectedDateTime = await widgetState.pickDate();
        widgetState.rebuild();
      },
      child: Text(selectedDateTime == null ? "Pick a date" : selectedDateTime.toIso8601String()),
    );
  }

  @override
  void appendInput(Map map) {
    map[id] = selectedDateTime.toIso8601String();
  }


}












/// Actions

abstract class _AdaptiveAction extends _AdaptiveElement {
  _AdaptiveAction(Map adaptiveMap, _ReferenceResolver resolver, widgetState, _AtomicIdGenerator idGenerator) : super(adaptiveMap, resolver, widgetState, idGenerator);


  String get title => adaptiveMap["title"];

}

class _AdaptiveActionShowCard extends _AdaptiveAction {

  _AdaptiveActionShowCard(Map adaptiveMap, _ReferenceResolver resolver, widgetState,
      _AtomicIdGenerator idGenerator, this._adaptiveCardElement) : super(adaptiveMap, resolver, widgetState, idGenerator);



  _AdaptiveElement card;

  final _AdaptiveCardElement _adaptiveCardElement;

  bool expanded = false;

  @override
  void loadTree() {
    super.loadTree();
    card = getElement(adaptiveMap["card"], resolver, widgetState, idGenerator);

  }


  @override
  Widget generateWidget() {
    return RaisedButton(
      onPressed: () {
        _adaptiveCardElement.showCard(this);
      },
      child: Row(
        children: <Widget>[
          Text(title),
          expanded? Icon(Icons.keyboard_arrow_up): Icon(Icons.keyboard_arrow_down),
        ],
      ),

    );
  }



}

class _AdaptiveActionSubmit extends _AdaptiveAction {

  _AdaptiveActionSubmit(Map adaptiveMap, _ReferenceResolver resolver, widgetState, _AtomicIdGenerator idGenerator) : super(adaptiveMap, resolver, widgetState, idGenerator);



  @override
  Widget generateWidget() {
    return RaisedButton(
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

  switch(stringType) {
    case "Container":
      return _AdaptiveContainer(map, resolver, widgetState, idGenerator);
    case "TextBlock":
      return _AdaptiveTextBlock(map, resolver, widgetState, idGenerator);
    case "Input.Text":
      return _AdaptiveTextInput(map, resolver, widgetState, idGenerator);
    case "AdaptiveCard":
      return _AdaptiveCardElement(map, resolver, widgetState, idGenerator);
    case "ColumnSet":
      return _AdaptiveColumnSet(map, resolver, widgetState, idGenerator);
    case "Image":
      return _AdaptiveImage(map, resolver, widgetState, idGenerator);
    case "Input.Date":
      return _AdaptiveDateInput(map, resolver, widgetState, idGenerator);
    case "FactSet":
      return _AdaptiveFactSet(map, resolver, widgetState, idGenerator);
  }
  throw StateError("Could not find: $stringType");
}

_AdaptiveAction getAction(Map<String, dynamic> map, _ReferenceResolver resolver,
    AdaptiveCardState widgetState, _AdaptiveCardElement adaptiveCardElement, _AtomicIdGenerator idGenerator) {

  String stringType = map["type"];

  switch(stringType) {
    case "Action.ShowCard":
      return _AdaptiveActionShowCard(map, resolver, widgetState, idGenerator, adaptiveCardElement);
    case "Action.OpenUrl":
      return null;
    case "Action.Submit":
      return _AdaptiveActionSubmit(map, resolver, widgetState, idGenerator);
  }
  return null;
}




class _ReferenceResolver {


  _ReferenceResolver(this.hostConfig);

  final Map hostConfig;

  dynamic resolve(String key, String value) {
    return hostConfig[key][value];
  }

  dynamic get(String key) {
    return hostConfig[key];
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

