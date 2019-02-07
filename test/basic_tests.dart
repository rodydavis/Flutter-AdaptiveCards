import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_adaptive_cards/flutter_adaptive_cards.dart';
import 'package:flutter_test/flutter_test.dart';
import 'utils/test_utils.dart';



void main() {


  // Deliver actual images
  setUp(() {
    HttpOverrides.global = MyTestHttpOverrides();
  });


  testWidgets('Activity Update test', (tester) async {
    final binding = tester.binding as AutomatedTestWidgetsFlutterBinding;
    binding.addTime(Duration(seconds: 10));

    Widget widget = getWidthDefaultHostConfig('example1');

    await tester.pumpWidget(widget);

    // At the top and at assigned to:
    expect(find.text('Matt Hidinger'), findsNWidgets(2));

    expect(find.text('Now that we have defined the main rules and features of'
        ' the format, we need to produce a schema and publish it to GitHub. '
        'The schema will be the starting point of our reference documentation.'),
        findsOneWidget);

    expect(find.byType(Image), findsOneWidget);

    // The two buttons "Set due date" and "Comment"
    expect(find.byType(RaisedButton), findsNWidgets(2));

    expect(find.widgetWithText(RaisedButton, 'Set due date'), findsOneWidget);

    await tester.tap(find.widgetWithText(RaisedButton, 'Set due date'));
    await tester.pump();


    expect(find.widgetWithText(RaisedButton, "OK"), findsOneWidget);


    Widget button = tester.firstWidget(find.widgetWithText(RaisedButton, "OK"));
    
    await tester.tap(find.widgetWithText(RaisedButton, "Comment"));
    await tester.pump();

    expect(find.byType(RaisedButton), findsNWidgets(3));

    expect(find.widgetWithText(RaisedButton, "OK"), findsOneWidget);


    // Also has OK widget but it's a different instance

    expect(find.byWidget(button), findsNothing);
  });

}


