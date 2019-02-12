import 'package:flutter/material.dart';
import 'package:flutter_adaptive_cards/src/elements/basics.dart';
import 'package:flutter_adaptive_cards/src/elements/actions.dart';
import 'package:flutter_adaptive_cards/src/elements/input.dart';
import 'package:flutter_adaptive_cards/src/flutter_adaptive_cards.dart';

typedef ElementCreator = AdaptiveElement Function(
    Map<String, dynamic> map, RawAdaptiveCardState widgetState);

typedef ActionCreator = AdaptiveAction Function(Map<String, dynamic> map,
    RawAdaptiveCardState widgetState, AdaptiveCardElement cardElement);

/// Entry point for registering adaptive cards
///
/// 1. Providing custom elements
/// Add the element to [addedElements]. It takes the name of the element
/// as its key and it takes a function which generates an [AdaptiveElement] with
/// a given map and a widgetState
///
/// 2. Overwriting custom elements
/// Just use the same name as the element you want to override
///
/// 3. Deleting existing elements
///
/// Delete an element even if you have provided it yourself via the [addedElements]
///
class CardRegistry {
  const CardRegistry(
      {this.removedElements = const [],
      this.addedElements = const {},
      this.addedActions = const {}});

  /// Provide custom elements to use.
  /// When providing an element which is already defined, it is overwritten
  final Map<String, ElementCreator> addedElements;

  final Map<String, ActionCreator> addedActions;

  /// Remove specific elements from the list
  final List<String> removedElements;

  AdaptiveElement getElement(
      Map<String, dynamic> map, RawAdaptiveCardState widgetState) {
    String stringType = map["type"];

    if (removedElements.contains(stringType))
      return AdaptiveUnknown(map, widgetState, stringType);

    if (addedElements.containsKey(stringType)) {
      return addedElements[stringType](map, widgetState);
    } else {
      return _getBaseElement(map, widgetState);
    }
  }

  AdaptiveAction getAction(
      Map<String, dynamic> map,
      RawAdaptiveCardState widgetState,
      AdaptiveCardElement adaptiveCardElement) {
    String stringType = map["type"];

    if (removedElements.contains(stringType))
      return AdaptiveActionUnknown(map, widgetState, stringType);

    if (addedActions.containsKey(stringType)) {
      return addedActions[stringType](map, widgetState, adaptiveCardElement);
    } else {
      return _getBaseAction(map, widgetState, adaptiveCardElement);
    }
  }

  /// This returns an [AdaptiveElement] with the correct type.
  ///
  /// It looks at the [type] property and decides which object to construct
  AdaptiveElement _getBaseElement(
      Map<String, dynamic> map, RawAdaptiveCardState widgetState) {
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
    return AdaptiveUnknown(map, widgetState, stringType);
  }

  AdaptiveAction _getBaseAction(
      Map<String, dynamic> map,
      RawAdaptiveCardState widgetState,
      AdaptiveCardElement adaptiveCardElement) {
    String stringType = map["type"];

    switch (stringType) {
      case "Action.ShowCard":
        return AdaptiveActionShowCard(map, widgetState, adaptiveCardElement);
      case "Action.OpenUrl":
        return AdaptiveActionOpenUrl(map, widgetState);
      case "Action.Submit":
        return AdaptiveActionSubmit(map, widgetState);
    }
    return AdaptiveActionUnknown(map, widgetState, stringType);
  }
}

class DefaultCardRegistry extends InheritedWidget {
  DefaultCardRegistry({
    Key key,
    @required this.cardRegistry,
    @required Widget child,
  }) : super(key: key, child: child);

  final CardRegistry cardRegistry;

  static CardRegistry of(BuildContext context) {
    DefaultCardRegistry cardRegistry = context.inheritFromWidgetOfExactType(DefaultCardRegistry);
    if(cardRegistry == null) return null;
    return cardRegistry.cardRegistry;
  }
  @override
  bool updateShouldNotify(DefaultCardRegistry oldWidget) => oldWidget != this;
}
