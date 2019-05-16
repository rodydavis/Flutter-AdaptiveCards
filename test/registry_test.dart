import 'package:flutter/material.dart';
import 'package:flutter_adaptive_cards/flutter_adaptive_cards.dart';
import 'package:flutter_adaptive_cards/src/elements/basics.dart';
import 'package:flutter_adaptive_cards/src/registry.dart';
import 'package:flutter_adaptive_cards/src/utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'utils/test_utils.dart';

class MockAdaptiveCardState extends Mock implements RawAdaptiveCardState {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug}) {
    return "";
  }
}

void main() {
  RawAdaptiveCardState state;
  setUp(() {
    state = MockAdaptiveCardState();
    when(state.resolver).thenReturn(ReferenceResolver(getDefaultHostConfig()));
    when(state.idGenerator).thenReturn(UUIDGenerator());
  });

  testWidgets('Basic types return', (tester) async {
    CardRegistry cardRegistry = CardRegistry();
    AdaptiveElement adaptiveElement = cardRegistry.getElement({
      "type": "TextBlock",
      "text": "Adaptive Card design session",
      "size": "large",
      "weight": "bolder"
    }, state);

    expect(adaptiveElement.runtimeType, equals(AdaptiveTextBlock));

    AdaptiveElement second = cardRegistry.getElement({
      "type": "Media",
      "poster":
          "https://docs.microsoft.com/en-us/adaptive-cards/content/videoposter.png",
      "sources": [
        {
          "mimeType": "video/mp4",
          "url":
              "https://adaptivecardsblob.blob.core.windows.net/assets/AdaptiveCardsOverviewVideo.mp4"
        }
      ]
    }, state);

    expect(second.runtimeType, equals(AdaptiveMedia));
  });


  testWidgets('Unknown element', (tester) async {
    CardRegistry cardRegistry = CardRegistry();

    AdaptiveElement adaptiveElement = cardRegistry.getElement({
      'type': "NoType"
    }, state);

    expect(adaptiveElement.runtimeType, equals(AdaptiveUnknown));


    AdaptiveUnknown unknown = adaptiveElement as AdaptiveUnknown;

    expect(unknown.type, equals('NoType'));
  });

  testWidgets('Removed element', (tester) async {
    CardRegistry cardRegistry = CardRegistry(
      removedElements: ['TextBlock']
    );

    AdaptiveElement adaptiveElement = cardRegistry.getElement({
      "type": "TextBlock",
      "text": "Adaptive Card design session",
      "size": "large",
      "weight": "bolder"
    }, state);

    expect(adaptiveElement.runtimeType, equals(AdaptiveUnknown));

    AdaptiveUnknown unknown = adaptiveElement as AdaptiveUnknown;

    expect(unknown.type, equals('TextBlock'));

  });


  testWidgets('Add element', (tester) async {
    CardRegistry cardRegistry = CardRegistry(
      addedElements: {
        'Test': (map, state) => _AdaptiveTest(map, state)
      }
    );

   var element = cardRegistry.getElement({
     'type': "Test"
   }, state);

   expect(element.runtimeType, equals(_AdaptiveTest));

   await tester.pumpWidget(element.build());

   expect(find.text('Test'), findsOneWidget);
  });
}
class _AdaptiveTest extends AdaptiveElement
    with SeparatorElementMixin, TappableElementMixin, ChildStylerMixin {
  _AdaptiveTest(Map adaptiveMap, widgetState)
      : super(adaptiveMap: adaptiveMap, widgetState: widgetState,);


  Widget build() => MaterialApp(
    home: Text("Test"),
  );

}
