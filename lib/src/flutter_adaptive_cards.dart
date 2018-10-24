library flutter_adaptive_cards;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_adaptive_cards/src/utils.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';


/// Main entry point to adaptive cards.
///
/// This widget takes a [map] (which usually is just a json decoded string) and
/// displays in natively. Additionally a host config needs to be provided for
/// styling.
class AdaptiveCard extends StatefulWidget {

  AdaptiveCard.fromMap(this.map, this.hostConfig);

  final Map map;
  final Map hostConfig;

  @override
  AdaptiveCardState createState() => AdaptiveCardState();
}

class AdaptiveCardState extends State<AdaptiveCard> {

  // Wrapper around the host config
  _ReferenceResolver _referenceResolver;

  // The root element
  _AdaptiveElement _adaptiveElement;

  List<VoidCallback> deactivateListeners = [];

  @override
  void initState() {
    super.initState();
    _referenceResolver = _ReferenceResolver(widget.hostConfig);
    /// TODO no need to pass atomicIdGenerator because it is not re constructed every time
    _adaptiveElement = getElement(widget.map, _referenceResolver, this, _AtomicIdGenerator());

  }

  /// Every widget can access method of this class, meaning setting the state
  /// is possible from every element
  void rebuild() {
    setState((){});
  }


  void addDeactivateListener(VoidCallback callback) {
    deactivateListeners.add(callback);
  }

  @override
  void deactivate() {
    super.deactivate();
    deactivateListeners.forEach((it) => it());
  }


  //TODO abstract these methods to an interface
  /// Submits all the inputs of this adaptive card, does it by recursively
  /// visiting the elements in the tree
  void submit(Map map) {
    _adaptiveElement.visitChildren((element) {
      print("visiting ${element.runtimeType}");
      if(element is _AdaptiveInput) {
        element.appendInput(map);
      }
    });
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(map.toString())));
  }

  void openUrl(String url) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text("Open url: $url")));
  }

  void showError(String message) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// min and max dates may be null, in this case no constraint is made in that direction
  Future<DateTime> pickDate(DateTime min, DateTime max) {
    DateTime initialDate = DateTime.now();
    return showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: min?? DateTime.now().subtract(Duration(days: 10000)),
        lastDate: max?? DateTime.now().add(Duration(days: 10000))
    );
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


/// The visitor, the function is called once for every element in the tree
typedef _AdaptiveElementVisitor = void Function(_AdaptiveElement element);



/// The base class for every element (widget) drawn on the screen.
///
/// The lifecycle is as follows:
/// - [loadTree()] is called, all the initialization should be done here
/// - [generateWidget()] is called every time the elements needs to render
/// this method should be as lightweight as possible because it could possibly
/// be called many times (for example in an animation). The method should also be
/// idempotent meaning calling it multiple times without changing anything should
/// return the same result
///
/// This class also holds some references every element needs.
/// --------------------------------------------------------------------
/// The [adaptiveMap] is the map associated with that element
///
/// root
/// |
/// currentElement <-- ([adaptiveMap] contains the subtree from there)
/// |       |
/// child 1 child2
/// --------------------------------------------------------------------
///
/// The [resolver] is a handy wrapper around the hostConfig, which makes accessing
/// it easier.
///
/// //TODO refactor
/// The [widgetState] provides access to flutter specific implementations.
///
/// If the element has children (you don't need to do this if the element is a
/// leaf):
/// implement the method [visitChildren] and call visitor(this) in addition call
/// [visitChildren] on each child with the passed visitor.
abstract class _AdaptiveElement {
  _AdaptiveElement({@required this.adaptiveMap, @required this.resolver, @required this.widgetState, @required this.idGenerator}) {
    loadTree();
  }

  final Map adaptiveMap;
  final _ReferenceResolver resolver;
  final _AtomicIdGenerator idGenerator;

  String id;

  // TODO abstract
  /// Because some widgets (looking at you ShowCardAction) need to set the state
  /// all elements get a way to set the state.
  final AdaptiveCardState widgetState;



  /// Overwrite this method to return a Flutter widget. If this element has children, call their generateWidget instead of build.
  Widget build();

  /// The default implementation of generateWidget only calls build. But some classes (for example those with a separator) use this method to add
  /// additional things into the tree.
  /// This method always needs to call build() in some way or another.
  Widget generateWidget() {
    return build();
  }

  void loadId() {
    if(adaptiveMap.containsKey("id")) {
      id = adaptiveMap["id"];
    } else {
      id = idGenerator.getId();
    }
  }


  @mustCallSuper
  void loadTree() {
    loadId();
  }

  /// Visits the children
  void visitChildren(_AdaptiveElementVisitor visitor) {
    visitor(this);
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

/// Usually the root element of every adaptive card.
///
/// This container behaves like a Column/ a Container
class _AdaptiveCardElement extends _AdaptiveElement{
  _AdaptiveCardElement(Map adaptiveMap, _ReferenceResolver resolver, widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap: adaptiveMap, resolver: resolver, widgetState: widgetState, idGenerator: idGenerator);

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
  Widget build() {
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
      widgetChildren.add(currentlyActiveShowCardAction.card.build());
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

  @override
  void visitChildren(_AdaptiveElementVisitor visitor) {
    visitor(this);
    children.forEach((it) => it.visitChildren(visitor));
    allActions.forEach((it) => it.visitChildren(visitor));
    showCardActions.forEach((it) => it.visitChildren(visitor));
  }


}

abstract class _SeparatorElementMixin extends _AdaptiveElement{

  double topSpacing;
  bool separator;

  void loadSeparator() {
    topSpacing = resolver.resolveSpacing(adaptiveMap["spacing"]);
    separator = adaptiveMap["separator"]?? false;
  }


  // TODO potential bug, because this mixin overrites this method
  // others might not be able to do so meaning only one mixing will generate its
  // widget
  @override
  Widget generateWidget() {
    assert(separator != null, "Did you forget to call loadSeperator in this class?");
    return Column(
      children: <Widget>[
        separator? Divider(height: topSpacing,): SizedBox(height: topSpacing,),
        build(),
      ],
    );
  }


}

abstract class _TappableElementMixin extends _AdaptiveElement{

  _AdaptiveAction action;

  void loadTappable() {
    if(adaptiveMap.containsKey("selectAction")) {
      action = getAction(adaptiveMap["selectAction"],
          resolver, widgetState, null, idGenerator);

    }
  }

  Widget wrapInTappable(Widget child) {
    return InkWell(
      onTap: action?.onTapped,
      child: child,
    );
  }
}
abstract class _ChildStylerMixin extends _AdaptiveElement{
  void styleChild() {
    // The container needs to set the style in every iteration
    if(adaptiveMap.containsKey("style")) {
      resolver.setContainerStyle(adaptiveMap["style"]);
    }
  }
}

class _AdaptiveTextBlock extends _AdaptiveElement with _SeparatorElementMixin {
  _AdaptiveTextBlock(Map adaptiveMap, _ReferenceResolver resolver, widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap: adaptiveMap, resolver: resolver, widgetState: widgetState, idGenerator: idGenerator);


  FontWeight fontWeight;
  double fontSize;
  Color color;
  Alignment horizontalAlignment;
  int maxLines;
  MarkdownStyleSheet markdownStyleSheet;

  @override
  void loadTree() {
    super.loadTree();
    fontSize = resolver.resolveFontSize(adaptiveMap["size"]);
    fontWeight = resolver.resolveFontWeight(adaptiveMap["weight"]);
    color = resolver.resolveColor(adaptiveMap["color"], adaptiveMap["isSubtle"]);
    horizontalAlignment = loadAlignment();
    maxLines = loadMaxLines();
    markdownStyleSheet = loadMarkdownStyleSheet();
    loadSeparator();
  }

  // TODO create own widget that parses _basic_ markdown. This might help: https://docs.flutter.io/flutter/widgets/Wrap-class.html
  Widget build() {
    return Align(
        alignment: horizontalAlignment,
        child: Text(text, style: TextStyle(fontWeight: fontWeight, fontSize:fontSize, color: color), maxLines: maxLines,)
      /* child: MarkdownBody(
        data: text,
        styleSheet: markdownStyleSheet,
      )*/
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

// TODO implement verticalContentAlignment
class _AdaptiveContainer extends _AdaptiveElement with _SeparatorElementMixin,
    _TappableElementMixin, _ChildStylerMixin{
  _AdaptiveContainer(Map adaptiveMap, _ReferenceResolver resolver,
      widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap: adaptiveMap, resolver: resolver, widgetState: widgetState, idGenerator: idGenerator);


  List<_AdaptiveElement> children;


  Color backgroundColor;

  @override
  void loadTree() {
    super.loadTree();
    children = List<Map>.from(adaptiveMap["items"]).map((child) {
      styleChild();
      return getElement(child, resolver, widgetState, idGenerator);
    }).toList();


    String colorString = resolver.hostConfig["containerStyles"]
    [adaptiveMap["style"]?? "default"]["backgroundColor"];
    backgroundColor = _parseColor(colorString);

    loadSeparator();
    loadTappable();

  }

  Widget build() {
    return Container(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: wrapInTappable(Column(
          children: children.map((it) => it.generateWidget()).toList(),
        )),
      ),
    );
  }

  @override
  void visitChildren(_AdaptiveElementVisitor visitor) {
    visitor(this);
    children.forEach((it) => it.visitChildren(visitor));
    action.visitChildren(visitor);
  }


}


class _AdaptiveColumnSet extends _AdaptiveElement with _TappableElementMixin{
  _AdaptiveColumnSet(Map adaptiveMap, _ReferenceResolver resolver, AdaptiveCardState widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap: adaptiveMap, resolver: resolver, widgetState: widgetState, idGenerator: idGenerator);

  List<_AdaptiveColumn> columns;


  @override
  void loadTree() {
    super.loadTree();
    // TODO handle case where there are no children elegantly
    columns = List<Map>.from(adaptiveMap["columns"])
        .map((child) => _AdaptiveColumn(child, resolver, widgetState, idGenerator))
        .toList();
    loadTappable();

  }

  @override
  Widget build() {
   return wrapInTappable(
       Row(
         children: columns.map((it) => Flexible(child: it.generateWidget())).toList(),
         mainAxisAlignment: MainAxisAlignment.start,
         crossAxisAlignment: CrossAxisAlignment.center,
       )
   );
  }

  @override
  void visitChildren(_AdaptiveElementVisitor visitor) {
    visitor(this);
    columns.forEach((it) => it.visitChildren(visitor));
    action.visitChildren(visitor);
  }


}

class _AdaptiveColumn extends _AdaptiveElement with _SeparatorElementMixin,
    _TappableElementMixin, _ChildStylerMixin{
  _AdaptiveColumn(Map adaptiveMap, _ReferenceResolver resolver, AdaptiveCardState widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap: adaptiveMap, resolver: resolver, widgetState: widgetState, idGenerator: idGenerator);


  List<_AdaptiveElement> items;
  //TODO implement
  double width;

  //TODO fix style (column/example3)
  @override
  void loadTree() {
    super.loadTree();
    items = List<Map>.from(adaptiveMap["items"]).map((child) {
      styleChild();
      return getElement(child, resolver, widgetState, idGenerator);
    }).toList();
    loadSeparator();
    loadTappable();
  }

  @override
  Widget build() {
    return wrapInTappable(
        Column(
          children: items.map((it) => it.generateWidget()).toList(),
          crossAxisAlignment: CrossAxisAlignment.start,
        )
    );
  }

  @override
  void visitChildren(_AdaptiveElementVisitor visitor) {
    visitor(this);
    items.forEach((it) => it.visitChildren(visitor));
  }


}


class _AdaptiveFactSet extends _AdaptiveElement with _SeparatorElementMixin{
  _AdaptiveFactSet(Map adaptiveMap, _ReferenceResolver resolver, AdaptiveCardState widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap: adaptiveMap, resolver: resolver, widgetState: widgetState, idGenerator: idGenerator);


  List<Map> facts;


  @override
  void loadTree() {
    super.loadTree();
    facts = List<Map>.from(adaptiveMap["facts"]).toList();
    loadSeparator();
  }

  @override
  Widget build() {
    return Row(
      children: [
        Column(
          children: facts.map((fact) => Text(fact["title"], style: TextStyle(fontWeight: FontWeight.bold),)).toList(),
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        SizedBox(width: 8.0,),
        Column(
          children: facts.map((fact) => Text(fact["value"])).toList(),
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  @override
  void visitChildren(_AdaptiveElementVisitor visitor) {
    visitor(this);
  }
}



class _AdaptiveImage extends _AdaptiveElement with _SeparatorElementMixin{
  _AdaptiveImage(Map adaptiveMap, _ReferenceResolver resolver, AdaptiveCardState widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap: adaptiveMap, resolver: resolver, widgetState: widgetState, idGenerator: idGenerator);


  Alignment horizontalAlignment;
  bool isPerson;
  Tuple<double, double> size;


  @override
  void loadTree() {
    super.loadTree();
    horizontalAlignment = loadAlignment();
    isPerson = loadIsPerson();
    size = loadSize();
    loadSeparator();
  }

  @override
  Widget build() {

    //TODO alt text
    Widget image = ConstrainedBox(
      constraints: BoxConstraints(
          minWidth: size.a,
          minHeight: size.a,
          maxHeight: size.b,
          maxWidth: size.b
      ),
      child: Image(image: NetworkImage(url)),
    );
    if(isPerson) {
      image = ClipOval(
        clipper: FullCircleClipper(),
        child: image,
      );
    }


    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: horizontalAlignment,
        child: image,
      ),
    );
  }

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

  bool loadIsPerson() {
    if(adaptiveMap["style"] == null || adaptiveMap["style"] == "default") return false;
    return true;
  }

  String get url => adaptiveMap["url"];

  Tuple<double, double> loadSize() {
    String sizeDescription = adaptiveMap["size"] ?? "auto";

    if(sizeDescription == "auto") return Tuple(0.0, double.infinity);
    if(sizeDescription == "stretch") return Tuple(double.infinity, double.infinity);
    int size = resolver.resolve("imageSizes", sizeDescription?? "default");

    return Tuple(size.toDouble(), size.toDouble());
  }

}

class _AdaptiveImageSet extends _AdaptiveElement with _SeparatorElementMixin{
  _AdaptiveImageSet(Map adaptiveMap, _ReferenceResolver resolver, AdaptiveCardState widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap: adaptiveMap, resolver: resolver, widgetState: widgetState, idGenerator: idGenerator);

  List<_AdaptiveImage> images;

  String imageSize;
  double maybeSize;


  @override
  void loadTree() {
    super.loadTree();
    images = List<Map>.from(adaptiveMap["images"])
        .map((child) => _AdaptiveImage(child, resolver, widgetState, idGenerator)).toList();

    loadSize();
    loadSeparator();

  }

  @override
  Widget build() {
    return LayoutBuilder(builder: (context, constraints) {
      return Wrap(
        //maxCrossAxisExtent: 200.0,
        children: images.map((img) => SizedBox(width: calculateSize(constraints), child: img.generateWidget())).toList(),
        //shrinkWrap: true,
      );
    });
  }

  double calculateSize(BoxConstraints constraints) {
    if(maybeSize != null) return maybeSize;
    if(imageSize == "stretch") return constraints.maxWidth;
    // Display a maximum of 5 children
    if(images.length >= 5) {
      return constraints.maxWidth / 5;
    } else if(images.length == 0){
      return 0.0;
    } else {
      return constraints.maxWidth / images.length;
    }
  }

  void loadSize() {
    String sizeDescription = adaptiveMap["imageSize"]?? "auto";
    if(sizeDescription == "auto") {
      imageSize = "auto";
      return;
    }
    if(sizeDescription == "stretch") {
      imageSize = "stretch";
      return;
    }
    int size = resolver.resolve("imageSizes", sizeDescription);
    maybeSize = size.toDouble();
  }

  @override
  void visitChildren(_AdaptiveElementVisitor visitor) {
    visitor(this);
    images.forEach((it) => it.visitChildren(visitor));
  }


}


class _AdaptiveMedia extends _AdaptiveElement with _SeparatorElementMixin {
  _AdaptiveMedia(Map adaptiveMap, _ReferenceResolver resolver, AdaptiveCardState widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap: adaptiveMap, resolver: resolver, widgetState: widgetState, idGenerator: idGenerator);


  VideoPlayerController controller;
  String sourceUrl;
  String postUrl;
  String altText;

  FadeAnimation imageFadeAnim = FadeAnimation(child: const Icon(Icons.play_arrow, size: 100.0));





  @override
  void loadTree() {
    super.loadTree();
    postUrl = adaptiveMap["poster"];
    sourceUrl = adaptiveMap["sources"][0]["url"];
    controller = VideoPlayerController.network(sourceUrl);
    controller.initialize().then((_){
      widgetState.rebuild();
    });
    controller.addListener((){
      widgetState.rebuild();
    });
    controller.setVolume(1.0);
    controller.play();
    loadSeparator();

    widgetState.addDeactivateListener(() {
      controller.dispose();
    });

  }

  @override
  Widget build() {
    final List<Widget> children = <Widget>[
      GestureDetector(
        child: controller.value.initialized? AspectRatio(
            child: VideoPlayer(controller),
          aspectRatio: controller.value.aspectRatio,
        ): Container(),
        onTap: () {
          if (!controller.value.initialized) {
            return;
          }
          if (controller.value.isPlaying) {
            imageFadeAnim =
                FadeAnimation(child: const Icon(Icons.pause, size: 100.0));
            controller.pause();
          } else {
            imageFadeAnim =
                FadeAnimation(child: const Icon(Icons.play_arrow, size: 100.0));
            controller.play();
          }
        },
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: VideoProgressIndicator(
          controller,
          allowScrubbing: true,
        ),
      ),
      Center(child: imageFadeAnim),
      Center(
          child: controller.value.isBuffering
              ? const CircularProgressIndicator()
              : null),
    ];

    return Stack(
      fit: StackFit.passthrough,
      children: children,
    );
  }

}











/// Text input elements

abstract class _AdaptiveInput extends _AdaptiveElement {
  _AdaptiveInput({Map adaptiveMap, _ReferenceResolver resolver, widgetState, _AtomicIdGenerator idGenerator})
      : super(adaptiveMap: adaptiveMap, resolver: resolver, widgetState: widgetState, idGenerator: idGenerator);

  String value;


  void appendInput(Map map);

  @override
  void loadTree() {
    super.loadTree();
    value = adaptiveMap["value"].toString() == "null"? "": adaptiveMap["value"].toString();
  }


}

abstract class _AdaptiveTextualInput extends _AdaptiveInput with _SeparatorElementMixin{
  _AdaptiveTextualInput({Map adaptiveMap, _ReferenceResolver resolver, widgetState, _AtomicIdGenerator idGenerator})
      : super(adaptiveMap: adaptiveMap, resolver: resolver, widgetState: widgetState, idGenerator: idGenerator);


  String placeholder;


  @override
  void loadTree() {
    super.loadTree();
    loadSeparator();
    placeholder = adaptiveMap["placeholder"]?? "";
  }


}



class _AdaptiveTextInput extends _AdaptiveTextualInput {
  _AdaptiveTextInput(Map adaptiveMap, _ReferenceResolver resolver, widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap: adaptiveMap, resolver: resolver, widgetState: widgetState, idGenerator: idGenerator);


  TextEditingController controller = TextEditingController();
  bool isMultiline;
  int maxLength;
  TextInputType style;

  @override
  void loadTree() {
    super.loadTree();
    isMultiline = adaptiveMap["isMultiline"]?? false;
    maxLength = adaptiveMap["maxLength"];
    style = loadTextInputType();
    controller.text = value;
  }

  @override
  Widget build() {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      keyboardType: style,
      maxLines: isMultiline? null: 1,
      decoration: InputDecoration(
        labelText: placeholder,
      ),
    );
  }

  @override
  void appendInput(Map map) {
    map[id] = controller.text;
  }


  TextInputType loadTextInputType() {
    /// Can be one of the following:
    /// - "text"
    /// - "tel"
    /// - "url"
    /// - "email"
    String style = adaptiveMap["style"]?? "text";
    switch(style) {
      case "text": return TextInputType.text;
      case "tel": return TextInputType.phone;
      case "url": return TextInputType.url;
      case "email": return TextInputType.emailAddress;
      default: return null;
    }

  }
}

class _AdaptiveNumberInput extends _AdaptiveTextualInput {
  _AdaptiveNumberInput(Map adaptiveMap, _ReferenceResolver resolver, widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap: adaptiveMap, resolver: resolver, widgetState: widgetState, idGenerator: idGenerator);

  TextEditingController controller = TextEditingController();

  int min;
  int max;

  @override
  void loadTree() {
    super.loadTree();
    controller.text = value;
    min = adaptiveMap["min"];
    max = adaptiveMap["max"];
  }

  @override
  Widget build() {
    return TextField(
      keyboardType: TextInputType.number,
      inputFormatters: [TextInputFormatter.withFunction((oldVal, newVal) {
        if(newVal.text == "") return newVal;
        int newNumber = int.parse(newVal.text);
        if(newNumber >= min && newNumber <= max) return newVal;
        return oldVal;

      })],
      controller: controller,
      decoration: InputDecoration(
        labelText: placeholder,
      ),
    );
  }

  @override
  void appendInput(Map map) {
    map[id] = controller.text;
  }

}

class _AdaptiveDateInput extends _AdaptiveTextualInput {
  _AdaptiveDateInput(Map adaptiveMap, _ReferenceResolver resolver, widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap: adaptiveMap, resolver: resolver, widgetState: widgetState, idGenerator: idGenerator);


  DateTime selectedDateTime;
  DateTime min;
  DateTime max;

  @override
  void loadTree() {
    super.loadTree();
    try {
      selectedDateTime = DateTime.parse(value);
      min = DateTime.parse(adaptiveMap["min"]);
      max = DateTime.parse(adaptiveMap["max"]);
    } catch(formatException) {

    }
  }

  @override
  Widget build() {
    return RaisedButton(
      onPressed: () async {
        selectedDateTime = await widgetState.pickDate(min, max);
        widgetState.rebuild();
      },
      child: Text(selectedDateTime == null ? placeholder : selectedDateTime.toIso8601String()),
    );
  }

  @override
  void appendInput(Map map) {
    map[id] = selectedDateTime.toIso8601String();
  }

}

class _AdaptiveTimeInput extends _AdaptiveTextualInput {
  _AdaptiveTimeInput(Map adaptiveMap, _ReferenceResolver resolver, widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap: adaptiveMap, resolver: resolver, widgetState: widgetState, idGenerator: idGenerator);


  TimeOfDay selectedTime;
  TimeOfDay min;
  TimeOfDay max;


  @override
  void loadTree() {
    super.loadTree();
    selectedTime = parseTime(value);
    min = parseTime(adaptiveMap["min"]);
    max = parseTime(adaptiveMap["max"]);
  }

  TimeOfDay parseTime(String time) {
    List<String> times = time.split(":");
    assert(times.length == 2, "Invalid TimeOfDay format");
    return TimeOfDay(
      hour: int.parse(times[0]),
      minute: int.parse(times[1]),
    );
  }

  @override
  Widget build() {
    return RaisedButton(
      onPressed: () async {
        TimeOfDay result = await widgetState.pickTime();
        //TODO compare times
        if(result.hour >= min.hour && result.hour <= max.hour) {
          widgetState.showError("Time must be after ${min.format(widgetState.context)}"
              " and before ${max.format(widgetState.context)}");
        } else {
          selectedTime = result;
          widgetState.rebuild();
        }
      },
      child: Text(selectedTime == null ? placeholder : selectedTime.format(widgetState.context)),
    );
  }

  @override
  void appendInput(Map map) {
    map[id] = selectedTime.toString();
  }

}

class _AdaptiveToggle extends _AdaptiveInput {
  _AdaptiveToggle(Map adaptiveMap, _ReferenceResolver resolver, widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap: adaptiveMap, resolver: resolver, widgetState: widgetState, idGenerator: idGenerator);

  bool boolValue = false;

  String valueOff;
  String valueOn;


  @override
  void loadTree() {
    super.loadTree();
    valueOff = adaptiveMap["valueOff"]?? "false";
    valueOn = adaptiveMap["valueOn"]?? "true";
    boolValue = value == valueOn;
  }

  @override
  Widget build() {
    return Switch(
      value: boolValue,
      onChanged: (newValue) {
        boolValue = newValue;
        widgetState.rebuild();
      },
    );
  }

  @override
  void appendInput(Map map) {
    map[id] = boolValue? valueOn: valueOff;
  }

}

class _AdaptiveChoiceSet extends _AdaptiveInput {
  _AdaptiveChoiceSet(Map adaptiveMap, _ReferenceResolver resolver, widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap: adaptiveMap, resolver: resolver, widgetState: widgetState, idGenerator: idGenerator);


  // Map from title to value
  Map<String, String> choices;

  String _selectedChoice;

  @override
  void loadTree() {
    super.loadTree();
    choices = Map();
    for(Map map in adaptiveMap["choices"]) {
      choices[map["title"]] = map["value"];
    }
    //choices = List<Map>.from(adaptiveMap["choices"]);
  }

  @override
  void appendInput(Map map) {
    map[id] = _selectedChoice;
  }

  @override
  Widget build() {
    return isCompact? _buildCompact(): _buildExpanded();
  }

  Widget _buildCompact() {
    return PopupMenuButton<Map>(itemBuilder: (BuildContext context) {
      return choices.map((choice) => PopupMenuItem<Map>(
          child: Text(choice[]),
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

///





abstract class _IconButtonMixin extends _AdaptiveAction {

  String iconUrl;


  void loadSeparator() {
    iconUrl = adaptiveMap["iconUrl"];
  }

  Widget getButton() {
    Widget result =  RaisedButton(
      onPressed: onTapped,
      child: Text(title),
    );

    if(iconUrl != null) {
      result = RaisedButton.icon(
        onPressed: onTapped,
        icon: Image.network(iconUrl, height: 36.0,),
        label: Text(title),
      );
    }
    return result;
  }
}


/// Actions

abstract class _AdaptiveAction extends _AdaptiveElement {
  _AdaptiveAction({Map adaptiveMap, _ReferenceResolver resolver, widgetState, _AtomicIdGenerator idGenerator})
      : super(adaptiveMap: adaptiveMap, resolver: resolver, widgetState: widgetState, idGenerator: idGenerator);

  String get title => adaptiveMap["title"];

  void onTapped();

}

class _AdaptiveActionShowCard extends _AdaptiveAction {

  _AdaptiveActionShowCard(Map adaptiveMap, _ReferenceResolver resolver, widgetState,
      _AtomicIdGenerator idGenerator, this._adaptiveCardElement)
      : super(adaptiveMap: adaptiveMap, resolver: resolver, widgetState: widgetState, idGenerator: idGenerator);



  _AdaptiveElement card;

  final _AdaptiveCardElement _adaptiveCardElement;

  bool expanded = false;

  @override
  void loadTree() {
    super.loadTree();
    card = getElement(adaptiveMap["card"], resolver, widgetState, idGenerator);

  }


  @override
  Widget build() {
    return RaisedButton(
      onPressed: onTapped,
      child: Row(
        children: <Widget>[
          Text(title),
          expanded? Icon(Icons.keyboard_arrow_up): Icon(Icons.keyboard_arrow_down),
        ],
      ),

    );
  }

  @override
  void onTapped() {
    if(_adaptiveCardElement != null) {
      _adaptiveCardElement.showCard(this);
    }
  }

  @override
  void visitChildren(_AdaptiveElementVisitor visitor) {
    card.visitChildren(visitor);
  }


}

class _AdaptiveActionSubmit extends _AdaptiveAction {

  _AdaptiveActionSubmit(Map adaptiveMap, _ReferenceResolver resolver, widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap: adaptiveMap, resolver: resolver, widgetState: widgetState, idGenerator: idGenerator);


  Map data;


  @override
  void loadTree() {
    super.loadTree();
    data = adaptiveMap["data"]?? {};
  }

  @override
  Widget build() {
    return RaisedButton(
      onPressed: onTapped,
      child: Text(title),
    );
  }

  @override
  void onTapped() {
    widgetState.submit(data);
  }
}

class _AdaptiveActionOpenUrl extends _AdaptiveAction with _IconButtonMixin{
  _AdaptiveActionOpenUrl(Map adaptiveMap, _ReferenceResolver resolver, widgetState, _AtomicIdGenerator idGenerator)
      : super(adaptiveMap: adaptiveMap, resolver: resolver, widgetState: widgetState, idGenerator: idGenerator);

  String url;
  String iconUrl;

  @override
  void loadTree() {
    super.loadTree();
    url = adaptiveMap["url"];
    iconUrl = adaptiveMap["iconUrl"];
  }

  @override
  Widget build() {
    return getButton();
  }

  @override
  void onTapped() {
    widgetState.openUrl(url);
  }
}
















/// This returns an [_AdaptiveElement] with the correct type.
///
/// It looks at the [type] property and decides which object to construct
_AdaptiveElement getElement(Map<String, dynamic> map, _ReferenceResolver resolver,
    AdaptiveCardState widgetState, _AtomicIdGenerator idGenerator) {

  String stringType = map["type"];

  switch(stringType) {
    case "Media":
      return _AdaptiveMedia(map, resolver, widgetState, idGenerator);
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
    return _parseColor(colorValue);
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

Color _parseColor(String colorValue) {
  // No alpha
  if(colorValue.length == 7) {
    return Color(int.parse(colorValue.substring(1, 7), radix: 16) + 0xFF000000);
  } else if(colorValue.length == 9) {
    return Color(int.parse(colorValue.substring(1, 9), radix: 16));
  } else {
    throw StateError("$colorValue is not a valid color");
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

class Tuple<A, B> {

  final A a;
  final B b;

  Tuple(this.a, this.b);
}


class FullCircleClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0.0, 0.0, size.width, size.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => false;

}