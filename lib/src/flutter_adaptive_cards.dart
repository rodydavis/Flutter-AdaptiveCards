library flutter_adaptive_cards;

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_adaptive_cards/src/elements/actions.dart';
import 'package:flutter_adaptive_cards/src/elements/basics.dart';
import 'package:flutter_adaptive_cards/src/elements/input.dart';
import 'package:flutter_adaptive_cards/src/utils.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:http/http.dart' as http;

abstract class AdaptiveCardContentProvider {
  AdaptiveCardContentProvider({@required this.hostConfigPath});

  final String hostConfigPath;

  Future<Map> loadHostConfig() async {
    String hostConfigString = await rootBundle.loadString(hostConfigPath);
    return json.decode(hostConfigString);
  }

  Future<Map> loadAdaptiveCardContent();
}

class MemoryAdaptiveCardContentProvider extends AdaptiveCardContentProvider {
  MemoryAdaptiveCardContentProvider(
      {@required this.content, @required String hostConfigPath})
      : super(hostConfigPath: hostConfigPath);

  Map content;

  @override
  Future<Map> loadAdaptiveCardContent() {
    return Future.value(content);
  }
}

class AssetAdaptiveCardContentProvider extends AdaptiveCardContentProvider {
  AssetAdaptiveCardContentProvider(
      {@required this.path, @required String hostConfigPath})
      : super(hostConfigPath: hostConfigPath);

  String path;

  @override
  Future<Map> loadAdaptiveCardContent() async {
    return json.decode(await rootBundle.loadString(path));
  }
}

class NetworkAdaptiveCardContentProvider extends AdaptiveCardContentProvider {
  NetworkAdaptiveCardContentProvider(
      {@required this.url, @required String hostConfigPath})
      : super(hostConfigPath: hostConfigPath);

  String url;

  @override
  Future<Map> loadAdaptiveCardContent() async {
    return json.decode((await http.get(url)).body);
  }
}

class AdaptiveCard extends StatefulWidget {

  AdaptiveCard(
      {Key key, @required this.adaptiveCardContentProvider, this.placeholder,
      this.cardRegistry = const CardRegistry()})
      : super(key: key);

  AdaptiveCard.network({
    Key key,
    this.placeholder,
    this.cardRegistry = const CardRegistry(),
    @required String url,
    @required String hostConfigPath,
  }) : adaptiveCardContentProvider = NetworkAdaptiveCardContentProvider(
            url: url, hostConfigPath: hostConfigPath);

  AdaptiveCard.asset({
    Key key,
    this.placeholder,
    this.cardRegistry = const CardRegistry(),
    @required String assetPath,
    @required String hostConfigPath,
  }) : adaptiveCardContentProvider = AssetAdaptiveCardContentProvider(
            path: assetPath, hostConfigPath: hostConfigPath);

  AdaptiveCard.memory({
    Key key,
    this.placeholder,
    this.cardRegistry = const CardRegistry(),
    @required Map content,
    @required String hostConfigPath,
  }) : adaptiveCardContentProvider = MemoryAdaptiveCardContentProvider(
            content: content, hostConfigPath: hostConfigPath);

  final AdaptiveCardContentProvider adaptiveCardContentProvider;

  final Widget placeholder;

  final CardRegistry cardRegistry;

  @override
  _AdaptiveCardState createState() => new _AdaptiveCardState();
}

class _AdaptiveCardState extends State<AdaptiveCard> {
  Map map;
  Map hostConfig;

  @override
  void initState() {
    super.initState();

    widget.adaptiveCardContentProvider.loadHostConfig().then((hostConfigMap) {
      setState(() {
        hostConfig = hostConfigMap;
      });
    });
    widget.adaptiveCardContentProvider
        .loadAdaptiveCardContent()
        .then((adaptiveMap) {
      setState(() {
        map = adaptiveMap;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (map == null || hostConfig == null) {
      return widget.placeholder ?? SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RawAdaptiveCard.fromMap(map, hostConfig, cardRegistry: widget.cardRegistry),
    );
  }
}

/// Main entry point to adaptive cards.
///
/// This widget takes a [map] (which usually is just a json decoded string) and
/// displays in natively. Additionally a host config needs to be provided for
/// styling.
class RawAdaptiveCard extends StatefulWidget {
  RawAdaptiveCard.fromMap(this.map, this.hostConfig, {this.cardRegistry = const CardRegistry()});

  final Map map;
  final Map hostConfig;
  final CardRegistry cardRegistry;

  @override
  RawAdaptiveCardState createState() => RawAdaptiveCardState();
}

class RawAdaptiveCardState extends State<RawAdaptiveCard> {
  // Wrapper around the host config
  ReferenceResolver resolver;
  AtomicIdGenerator idGenerator;
  CardRegistry cardRegistry;

  // The root element
  AdaptiveElement _adaptiveElement;

  List<VoidCallback> deactivateListeners = [];

  @override
  void initState() {
    super.initState();
    resolver = ReferenceResolver(widget.hostConfig);
    idGenerator = AtomicIdGenerator();
    cardRegistry = widget.cardRegistry;

    /// TODO no need to pass atomicIdGenerator because it is not re constructed every time
    _adaptiveElement =
        widget.cardRegistry.getElement(widget.map, this);
  }

  /// Every widget can access method of this class, meaning setting the state
  /// is possible from every element
  void rebuild() {
    setState(() {});
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
      if (element is AdaptiveInput) {
        element.appendInput(map);
      }
    });
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(map.toString())));
  }

  void openUrl(String url) {
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text("Open url: $url")));
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
        firstDate: min ?? DateTime.now().subtract(Duration(days: 10000)),
        lastDate: max ?? DateTime.now().add(Duration(days: 10000)));
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
typedef AdaptiveElementVisitor = void Function(AdaptiveElement element);

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
abstract class AdaptiveElement {
  AdaptiveElement(
      {@required this.adaptiveMap,
      @required this.widgetState}) {
    loadTree();
  }

  final Map adaptiveMap;

  String id;

  // TODO abstract
  /// Because some widgets (looking at you ShowCardAction) need to set the state
  /// all elements get a way to set the state.
  final RawAdaptiveCardState widgetState;

  /// This method should be implemented by the actual elements to return
  /// their Flutter representation.
  Widget build();

  /// Use this method to obtain the widget tree of the adaptive card.
  ///
  /// Each mixin has the opportunity to add something to the widget hierarchy.
  ///
  /// An example:
  /// @override
  /// Widget generateWidget() {
  ///  assert(separator != null, "Did you forget to call loadSeperator in this class?");
  ///  return Column(
  ///    children: <Widget>[
  ///      separator? Divider(height: topSpacing,): SizedBox(height: topSpacing,),
  ///      super.generateWidget(),
  ///    ],
  ///  );
  ///}
  ///
  /// This works because each mixin calls [generateWidget] in its generateWidget
  /// and adds the returned value into the widget tree. Eventually the base
  /// implementation (this) will be called and the elements actual build method is
  /// included.
  @mustCallSuper
  Widget generateWidget() {
    return build();
  }

  void loadId() {
    if (adaptiveMap.containsKey("id")) {
      id = adaptiveMap["id"];
    } else {
      id = widgetState.idGenerator.getId();
    }
  }

  @mustCallSuper
  void loadTree() {
    loadId();
  }

  /// Visits the children
  void visitChildren(AdaptiveElementVisitor visitor) {
    visitor(this);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdaptiveElement &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}



mixin SeparatorElementMixin on AdaptiveElement {
  double topSpacing;
  bool separator;

  @override
  void loadTree() {
    super.loadTree();
    topSpacing = widgetState.resolver.resolveSpacing(adaptiveMap["spacing"]);
    separator = adaptiveMap["separator"] ?? false;
  }

  @override
  Widget generateWidget() {
    assert(separator != null,
        "Did you forget to call loadSeperator in this class?");
    return Column(
      children: <Widget>[
        separator
            ? Divider(
                height: topSpacing,
              )
            : SizedBox(
                height: topSpacing,
              ),
        super.generateWidget(),
      ],
    );
  }
}

mixin TappableElementMixin on AdaptiveElement {
  AdaptiveAction action;

  @override
  void loadTree() {
    super.loadTree();
    if (adaptiveMap.containsKey("selectAction")) {
      action = widgetState.cardRegistry.getAction(adaptiveMap["selectAction"], widgetState,null);
    }
  }

  @override
  Widget generateWidget() {
    return InkWell(
      onTap: action?.onTapped,
      child: super.generateWidget(),
    );
  }
}
mixin ChildStylerMixin on AdaptiveElement {
  String style;

  @override
  void loadTree() {
    super.loadTree();
    style = adaptiveMap["style"];
  }

  void styleChild() {
    // The container needs to set the style in every iteration
    if (style != null) {
      widgetState.resolver.setContainerStyle(style);
    }
  }
}





mixin IconButtonMixin on AdaptiveAction {
  String iconUrl;

  void loadSeparator() {
    iconUrl = adaptiveMap["iconUrl"];
  }

  Widget getButton() {
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
}






class CardRegistry {

  const CardRegistry({this.addedElements = const {}, this.removedElements = const []});

  /// Provide custom elements to use.
  /// When providing an element which is already defined, it is overwritten
  final Map<String, AdaptiveElement> addedElements;

  /// Remove specific elements fomr the list
  final List<String> removedElements;

  // TODO implement

/// This returns an [AdaptiveElement] with the correct type.
///
/// It looks at the [type] property and decides which object to construct
AdaptiveElement getElement(
    Map<String, dynamic> map,
    RawAdaptiveCardState widgetState) {
  String stringType = map["type"];

  switch (stringType) {
    case "Media":
      return AdaptiveMedia(map, widgetState);
    case "Container":
      return AdaptiveContainer(map, widgetState);
    case "TextBlock":
      return AdaptiveTextBlock(map, widgetState);
    case "AdaptiveCard":
      return AdaptiveCardElement(map, widgetState);
    case "ColumnSet":
      return AdaptiveColumnSet(map, widgetState);
    case "Image":
      return AdaptiveImage(map, widgetState);
    case "FactSet":
      return AdaptiveFactSet(map, widgetState);
    case "ImageSet":
      return AdaptiveImageSet(map, widgetState);
    case "Input.Text":
      return AdaptiveTextInput(map, widgetState);
    case "Input.Number":
      return AdaptiveNumberInput(map, widgetState);
    case "Input.Date":
      return AdaptiveDateInput(map, widgetState);
    case "Input.Time":
      return AdaptiveTimeInput(map, widgetState);
    case "Input.Toggle":
      return AdaptiveToggle(map, widgetState);
    case "Input.ChoiceSet":
      return AdaptiveChoiceSet(map, widgetState);
  }
  throw StateError("Could not find: $stringType");
}

AdaptiveAction getAction(
    Map<String, dynamic> map,
    RawAdaptiveCardState widgetState,
    AdaptiveCardElement adaptiveCardElement) {
  String stringType = map["type"];

  switch (stringType) {
    case "Action.ShowCard":
      return AdaptiveActionShowCard(
          map, widgetState, adaptiveCardElement);
    case "Action.OpenUrl":
      return AdaptiveActionOpenUrl(map, widgetState);
    case "Action.Submit":
      return AdaptiveActionSubmit(map, widgetState);
  }
  throw StateError("Could not find: $stringType");
}

}


/// Resolves values based on the host config.
///
/// All values can also be null, in that case the default is used
class ReferenceResolver {
  ReferenceResolver(this.hostConfig);

  final Map hostConfig;

  String _currentStyle;

  dynamic resolve(String key, String value) {
    // Make it case insensitive
    return hostConfig[key][firstCharacterToLowerCase(value)];
  }

  dynamic get(String key) {
    return hostConfig[key];
  }

  FontWeight resolveFontWeight(String value) {
    int weight = resolve("fontWeights", value ?? "default");
    assert(
        weight != null,
        "\n"
        "FontWeight '${value ?? "default"}' was not found in the host_config. \n\n"
        "The available font weights were: \n\n"
        "${(hostConfig["fontWeights"] as Map).entries.map((entry) => "${entry.key}: ${entry.value}\n").toList()}");
    FontWeight fontWeight = FontWeight.values.firstWhere(
        (possibleWeight) => possibleWeight.toString() == "FontWeight.w$weight");
    assert(fontWeight != null, "There is no FontWight.w$weight");
    return fontWeight;
  }

  double resolveFontSize(String value) {
    int size = resolve("fontSizes", value ?? "default");
    assert(
        size != null,
        "\n"
        "Fontsize '${value ?? "default"}' was not found in the host_config. \n\n"
        "The available font sizes were: \n\n"
        "${(hostConfig["fontSizes"] as Map).entries.map((entry) => "${entry.key}: ${entry.value}\n").toList()}");
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
    String myColor = color ?? "default";
    String subtleOrDefault = isSubtle ?? false ? "subtle" : "default";
    _currentStyle = _currentStyle ?? "default";
    // Make it case insensitive
    String colorValue = hostConfig["containerStyles"][_currentStyle]
            ["foregroundColors"][firstCharacterToLowerCase(myColor)]
        [subtleOrDefault];
    return parseColor(colorValue);
  }

  /// This is to correctly resolve corresponding styles in a container
  ///
  /// Before a container loads its children it first needs to set its style here
  /// IMPORTANT, is needs to be called after every child iteration because a container down the tree might have
  /// overwritten it for its portion
  void setContainerStyle(String style) {
    assert(style == null || style == "default" || style == "emphasis");
    String myStyle = style ?? "default";
    _currentStyle = myStyle;
  }

  double resolveSpacing(String spacing) {
    String mySpacing = spacing ?? "default";
    if (mySpacing == "none") return 0.0;
    int intSpacing = hostConfig["spacing"][mySpacing];
    return intSpacing.toDouble();
  }
}


/// Some elements always need an id to function
/// (Looking at you [AdaptiveActionShowCard]) because the objects are rebuilt
/// every build time using a UUID generator wouldn't work (different ids for
/// the same objects). But the elements are traversed the same way every time.
///
/// A new instance of this class is used every build time to ensure that all ids
/// are different but same objects maintain their ids.
///
/// TODO replace with UUID
class AtomicIdGenerator {
  int index = 0;

  String _idPrefix = "pleaseDontUseThisIdAnywhereElse";

  String getId() {
    String id = "$_idPrefix.$index";
    index++;
    return id;
  }
}


