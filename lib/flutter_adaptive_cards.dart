library flutter_adaptive_cards;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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

  void openUrl() {

  }

  Future<DateTime> pickDate() {
    DateTime initialDate = DateTime.now();
    return showDatePicker(context: context, initialDate: initialDate, firstDate: initialDate, lastDate: DateTime.now().add(Duration(days: 365)));
  }

  Future<TimeOfDay> pickTime() {
    TimeOfDay initialTimeOfDay = TimeOfDay.now();
    return showTimePicker(context: context, initialTime: initialTimeOfDay);
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


  FontWeight fontWeight;
  double fontSize;
  Color color;
  Alignment horizontalAlignment;
  int maxLines;
  double topSpacing;
  bool separator;
  MarkdownStyleSheet markdownStyleSheet;

  @override
  void loadTree() {
    super.loadTree();
    fontSize = resolver.resolveFontSize(adaptiveMap["size"]);
    fontWeight = resolver.resolveFontWeight(adaptiveMap["weight"]);
    color = resolver.resolveColor(adaptiveMap["color"], adaptiveMap["isSubtle"]);
    horizontalAlignment = loadAlignment();
    maxLines = loadMaxLines();
    topSpacing = resolver.resolveSpacing(adaptiveMap["spacing"]);
    separator = adaptiveMap["separator"]?? false;
    markdownStyleSheet = loadMarkdownStyleSheet();
  }

  Widget generateWidget() {
    return Column(
      children: <Widget>[
        separator? Divider(height: topSpacing,): SizedBox(height: topSpacing,),
        Align(
          alignment: horizontalAlignment,
          child: Text(text, style: TextStyle(fontWeight: fontWeight, fontSize:fontSize, color: color), maxLines: maxLines,)
         /* child: MarkdownBody(
            data: text,
            styleSheet: markdownStyleSheet,
          )*/
        ),
      ],
    );
  }

  String get text => adaptiveMap["text"];

  Alignment loadAlignment() {
    String alignmentString = adaptiveMap["horizontalAlignment"]?? "left";
    switch(alignmentString) {
      case "left":
        return Alignment.centerLeft;
      case "center":
        return Alignment.center;
      case "right":
        return Alignment.centerRight;
      default:
        return Alignment.centerLeft;
    }
  }

  /// This also takes care of the wrap property, because maxLines = 1 => no wrap
  int loadMaxLines() {
    bool wrap = adaptiveMap["wrap"] ?? true;
    if(!wrap) return 1;
    // can be null, but that's okay for the text widget.
    return adaptiveMap["maxLines"];
  }

  /// TODO Markdown still has some problems
  MarkdownStyleSheet loadMarkdownStyleSheet() {
    TextStyle style = TextStyle(fontWeight: fontWeight, fontSize:fontSize, color: color);
    return MarkdownStyleSheet(
      a: style,
      blockquote: style,
      code: style,
      em: style,
      strong: style.copyWith(fontWeight: FontWeight.bold),
      p: style,
    );
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
    children = List<Map>.from(adaptiveMap["items"]).map((child) {
      // The container needs to set the style in every iteration
      resolver.setContainerStyle(adaptiveMap["style"]);
      return getElement(child, resolver, widgetState, idGenerator);
    }).toList();

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
    //TODO can facts be stand alone?
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

class _AdaptiveImageSet extends _AdaptiveElement {
  _AdaptiveImageSet(Map adaptiveMap, _ReferenceResolver resolver, AdaptiveCardState widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap, resolver, widgetState, idGenerator);

  List<_AdaptiveImage> images;


  @override
  void loadTree() {
    super.loadTree();
    images = List<Map>.from(adaptiveMap["images"])
        .map((child) => _AdaptiveImage(child, resolver, widgetState, idGenerator)).toList();

  }

  @override
  Widget generateWidget() {
    return GridView.extent(
      maxCrossAxisExtent: 200.0,
      children: images.map((img) => img.generateWidget()).toList(),
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

class _AdaptiveNumberInput extends _AdaptiveInput {
  _AdaptiveNumberInput(Map adaptiveMap, _ReferenceResolver resolver, widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap, resolver, widgetState, idGenerator);

  TextEditingController controller = TextEditingController();

  @override
  Widget generateWidget() {
    return TextField(
      keyboardType: TextInputType.number,
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

class _AdaptiveTimeInput extends _AdaptiveInput {
  _AdaptiveTimeInput(Map adaptiveMap, _ReferenceResolver resolver, widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap, resolver, widgetState, idGenerator);


  TimeOfDay selectedTime;

  @override
  Widget generateWidget() {
    return RaisedButton(
      onPressed: () async {
        selectedTime = await widgetState.pickTime();
        widgetState.rebuild();
      },
      child: Text(selectedTime == null ? "Pick a date" : selectedTime.toString()),
    );
  }

  @override
  void appendInput(Map map) {
    map[id] = selectedTime.toString();
  }

}

class _AdaptiveToggle extends _AdaptiveInput {
  _AdaptiveToggle(Map adaptiveMap, _ReferenceResolver resolver, widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap, resolver, widgetState, idGenerator);

  bool value = false;

  @override
  Widget generateWidget() {
    return Switch(
      value: value,
      onChanged: (newValue) {
        value = newValue;
        widgetState.rebuild();
      },
    );
  }

  @override
  void appendInput(Map map) {
    map[id] = value;
  }

}

class _AdaptiveChoiceSet extends _AdaptiveInput {
  _AdaptiveChoiceSet(Map adaptiveMap, _ReferenceResolver resolver, widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap, resolver, widgetState, idGenerator);


  List<_AdaptiveChoice> choices;

  _AdaptiveChoice _selectedChoice;
  @override
  void loadTree() {
    super.loadTree();
    choices = List<Map>.from(adaptiveMap["choices"])
        .map((child) => _AdaptiveChoice(child, resolver, widgetState, idGenerator)).toList();
  }

  @override
  void appendInput(Map map) {
    map[id] = _selectedChoice.id;
  }

  @override
  Widget generateWidget() {
    return isCompact? _buildCompact(): _buildExpanded();
  }

  Widget _buildCompact() {
    return PopupMenuButton<_AdaptiveChoice>(itemBuilder: (BuildContext context) {
      return choices.map((choice) => PopupMenuItem<_AdaptiveChoice>(
          child: Text(choice.title),
      )).toList();
    },
    onSelected: (choice){
      _selectedChoice = choice;
    },
    );
  }

  Widget _buildExpanded() {

  }

  bool get isCompact {
    if(!adaptiveMap.containsKey("style")) return false;
    if(adaptiveMap["style"] == "compact") return true;
    if(adaptiveMap["style"] == "expanded") return false;
    throw StateError("The style of the ChoiceSet needs to be either compact or expanded");
  }

}

class _AdaptiveChoice extends _AdaptiveInput {
  _AdaptiveChoice(Map adaptiveMap, _ReferenceResolver resolver, widgetState, _AtomicIdGenerator idGenerator)
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
    //TODO can facts be stand alone?
    throw StateError("The widget should be built by _AdaptiveFactSet");
  }

  @override
  void appendInput(Map map) {
    // TODO: implement appendInput
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

class _AdaptiveActionOpenUrl extends _AdaptiveAction {
  _AdaptiveActionOpenUrl(Map adaptiveMap, _ReferenceResolver resolver, widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap, resolver, widgetState, idGenerator);

  @override
  Widget generateWidget() {
    return RaisedButton(
      onPressed: () {
        widgetState.openUrl();
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
    case "AdaptiveCard":
      return _AdaptiveCardElement(map, resolver, widgetState, idGenerator);
    case "ColumnSet":
      return _AdaptiveColumnSet(map, resolver, widgetState, idGenerator);
    case "Image":
      return _AdaptiveImage(map, resolver, widgetState, idGenerator);
    case "FactSet":
      return _AdaptiveFactSet(map, resolver, widgetState, idGenerator);
    case "ImageSet":
      return _AdaptiveImageSet(map, resolver, widgetState, idGenerator);
    case "Input.Text":
      return _AdaptiveTextInput(map, resolver, widgetState, idGenerator);
    case "Input.Number":
      return _AdaptiveNumberInput(map, resolver, widgetState, idGenerator);
    case "Input.Date":
      return _AdaptiveDateInput(map, resolver, widgetState, idGenerator);
    case "Input.Time":
      return _AdaptiveTimeInput(map, resolver, widgetState, idGenerator);
    case "Input.Toggle":
      return _AdaptiveToggle(map, resolver, widgetState, idGenerator);
    case "Input.ChoiceSet":
      return _AdaptiveChoiceSet(map, resolver, widgetState, idGenerator);
    case "Input.Choice":
      return _AdaptiveChoice(map, resolver, widgetState, idGenerator);
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
      return _AdaptiveActionOpenUrl(map, resolver, widgetState, idGenerator);
    case "Action.Submit":
      return _AdaptiveActionSubmit(map, resolver, widgetState, idGenerator);
  }
  throw StateError("Could not find: $stringType");
}



/// Resolves values based on the host config.
///
/// All values can also be null, in that case the default is used
class _ReferenceResolver {


  _ReferenceResolver(this.hostConfig);

  final Map hostConfig;
  
  String _currentStyle;

  dynamic resolve(String key, String value) {
    return hostConfig[key][value];
  }

  dynamic get(String key) {
    return hostConfig[key];
  }

  FontWeight resolveFontWeight(String value) {
    int weight = resolve("fontWeights", value?? "default") ;
    return FontWeight.values.firstWhere((possibleWeight) => possibleWeight.toString() == "FontWeight.w$weight");
  }

  double resolveFontSize(String value) {
    int size = resolve("fontSizes", value?? "default");
    return size.toDouble();
  }

  /// Resolves a color from the host config
  ///
  /// Typically one of the following colors:
  /// - default
  /// - dark
  /// - light
  /// - accent
  /// - good
  /// - warning
  /// - attention
  Color resolveColor(String color, bool isSubtle) {
    String myColor = color?? "default";
    String subtleOrDefault = isSubtle ?? false? "subtle" : "default";
    _currentStyle = _currentStyle ?? "default";
    String colorValue = hostConfig["containerStyles"][_currentStyle]["foregroundColors"][myColor][subtleOrDefault];
    return new Color(int.parse(colorValue.substring(1, 7), radix: 16) + 0xFF000000);
  }

  /// This is to correctly resolve corresponding styles in a container
  /// 
  /// Before a container loads its children it first needs to set its style here
  /// IMPORTANT, is needs to be called after every child iteration because a container down the tree might have 
  /// overwritten it for its portion
  void setContainerStyle(String style) {
    assert(style == null ||style == "default" || style == "emphasis");
    String myStyle = style?? "default";
    _currentStyle = myStyle;
  }

  double resolveSpacing(String spacing) {
    String mySpacing = spacing?? "default";
    if(mySpacing == "none") return 0.0;
    int intSpacing = hostConfig["spacing"][mySpacing];
    return intSpacing.toDouble();
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

