import 'package:flutter/material.dart';
import 'package:flutter_adaptive_cards/src/elements/fsadhfafd.dart';

/// TODO lokk which classe used this before
class SeparatorElement extends StatefulWidget with AdaptiveElementWidgetMixin {

  final Map adaptiveMap;
  final Widget child;

  SeparatorElement({Key key, this.adaptiveMap, this.child}) : super(key: key);

  @override
  _SeparatorElementState createState() => _SeparatorElementState();
}

class _SeparatorElementState extends State<SeparatorElement> with AdaptiveElementMixin{


  double topSpacing;
  bool separator;

  @override
  void initState() {
    super.initState();
    topSpacing = widgetState.resolver.resolveSpacing(adaptiveMap["spacing"]);
    separator = adaptiveMap["separator"] ?? false;

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        separator
            ? Divider(
          height: topSpacing,
        ) : SizedBox(
          height: topSpacing,
        ),
        widget.child
      ],
    );
  }
}

class AdaptiveTappable extends StatefulWidget with AdaptiveElementWidgetMixin{


  AdaptiveTappable({Key key, this.child, this.adaptiveMap}) : super(key: key);

  final Widget child;

  final Map adaptiveMap;

  @override
  _AdaptiveTappableState createState() => _AdaptiveTappableState();
}

class _AdaptiveTappableState extends State<AdaptiveTappable> with AdaptiveElementMixin{

  GenericAction action;

  @override
  void initState() {
    super.initState();
    if (adaptiveMap.containsKey("selectAction")) {
      action = widgetState.cardRegistry.getGenericAction(adaptiveMap["selectAction"], widgetState);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action?.tap,
      child: widget.child,
    );
  }
}

mixin ChildStylerMixin<T extends AdaptiveElementWidgetMixin> on AdaptiveElementMixin<T> {
  String style;
  @override
  void initState() {
    super.initState();
    style = adaptiveMap["style"];
  }

  void styleChild() {
    // The container needs to set the style in every iteration
    if (style != null) {
      widgetState.resolver.setContainerStyle(style);
    }
  }
}