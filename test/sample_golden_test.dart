
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils/test_utils.dart';


Widget getSampleForGoldenTest(Key key, String sampleName) {
  Widget sample = getWidthDefaultHostConfig(sampleName);

  return MaterialApp(
    home: RepaintBoundary(
      key: key,
      child: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: sample,
        ),
      ),
    ),
  );
}

void main() {

  // Deliver actual images
  setUp(() {
    HttpOverrides.global = MyTestHttpOverrides();
    WidgetsBinding.instance.renderView.configuration =
        TestViewConfiguration(size: const Size(500, 700));
  });

  testWidgets('Golden Sample 1', (tester) async {

    final binding = tester.binding as AutomatedTestWidgetsFlutterBinding;
    binding.addTime(Duration(seconds: 4));

    ValueKey key = ValueKey('paint');
    Widget sample1 = getSampleForGoldenTest(key, 'example1');

    //await tester.pumpWidget(SizedBox(width:100,height:100,child: Center(child: RepaintBoundary(child: SizedBox(width:500, height: 1200,child: sample1), key: key,))));
    await tester.pumpWidget(sample1);
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(key),
      matchesGoldenFile('gold_files/sample1-base.png')
    );

    expect(find.widgetWithText(RaisedButton, 'Set due date'), findsOneWidget);

    await tester.tap(find.widgetWithText(RaisedButton, 'Set due date'));
    await tester.pump();

    await expectLater(
      find.byKey(key),
      matchesGoldenFile('gold_files/sample1_set_due_date.png')
    );

    expect(find.widgetWithText(RaisedButton, "OK"), findsOneWidget);

    await tester.tap(find.widgetWithText(RaisedButton, "Comment"));
    await tester.pump();


    await expectLater(
        find.byKey(key),
        matchesGoldenFile('gold_files/sample1_comment.png')
    );

  });
  testWidgets('Golden Sample 2', (tester) async {

    final binding = tester.binding as AutomatedTestWidgetsFlutterBinding;
    binding.addTime(Duration(seconds: 4));

    ValueKey key = ValueKey('paint');
    Widget sample1 = getSampleForGoldenTest(key, 'example2');

    //await tester.pumpWidget(SizedBox(width:100,height:100,child: Center(child: RepaintBoundary(child: SizedBox(width:500, height: 1200,child: sample1), key: key,))));
    await tester.pumpWidget(sample1);
    await tester.pumpAndSettle();

    await expectLater(
        find.byKey(key),
        matchesGoldenFile('gold_files/sample2-base.png')
    );


    expect(find.widgetWithText(RaisedButton, "I'll be late"), findsOneWidget);

    await tester.tap(find.widgetWithText(RaisedButton, "I'll be late"));
    await tester.pumpAndSettle();


    await expectLater(
        find.byKey(key),
        matchesGoldenFile('gold_files/sample2_ill_be_late.png')
    );

    expect(find.widgetWithText(RaisedButton, 'Snooze'), findsOneWidget);

    await tester.tap(find.widgetWithText(RaisedButton, 'Snooze'));
    await tester.pumpAndSettle();

    await expectLater(
        find.byKey(key),
        matchesGoldenFile('gold_files/sample2_snooze.png')
    );

  });

  testWidgets('Golden Sample 3', (tester) async {

    final binding = tester.binding as AutomatedTestWidgetsFlutterBinding;
    binding.addTime(Duration(seconds: 4));

    ValueKey key = ValueKey('paint');
    Widget sample1 = getSampleForGoldenTest(key, 'example3');

    await tester.pumpWidget(sample1);
    await tester.pumpAndSettle();

    await expectLater(
        find.byKey(key),
        matchesGoldenFile('gold_files/sample3-base.png')
    );
    await tester.pump(Duration(seconds: 1));

  });

  testWidgets('Golden Sample 4', (tester) async {

    final binding = tester.binding as AutomatedTestWidgetsFlutterBinding;
    binding.addTime(Duration(seconds: 4));

    ValueKey key = ValueKey('paint');
    Widget sample1 = getSampleForGoldenTest(key, 'example4');

    await tester.pumpWidget(sample1);
    await tester.pumpAndSettle();

    await expectLater(
        find.byKey(key),
        matchesGoldenFile('gold_files/sample4-base.png')
    );

  });


  testWidgets('Golden Sample 5', (tester) async {

    final binding = tester.binding as AutomatedTestWidgetsFlutterBinding;
    binding.addTime(Duration(seconds: 4));

    ValueKey key = ValueKey('paint');
    Widget sample1 = getSampleForGoldenTest(key, 'example5');

    await tester.pumpWidget(sample1);
    await tester.pumpAndSettle();

    await expectLater(
        find.byKey(key),
        matchesGoldenFile('gold_files/sample5-base.png')
    );

    expect(find.widgetWithText(RaisedButton, "Steak"), findsOneWidget);
    expect(find.widgetWithText(RaisedButton, "Chicken"), findsOneWidget);
    expect(find.widgetWithText(RaisedButton, "Tofu"), findsOneWidget);


    await tester.tap(find.widgetWithText(RaisedButton, 'Steak'));
    await tester.pump();

    await expectLater(
        find.byKey(key),
        matchesGoldenFile('gold_files/sample5-steak.png')
    );

    await tester.tap(find.widgetWithText(RaisedButton, 'Chicken'));
    await tester.pump();


    await expectLater(
        find.byKey(key),
        matchesGoldenFile('gold_files/sample5-chicken.png')
    );


    await tester.tap(find.widgetWithText(RaisedButton, 'Tofu'));
    await tester.pump();


    await expectLater(
        find.byKey(key),
        matchesGoldenFile('gold_files/sample5-tofu.png')
    );
  });
 // TODO add other tests
  testWidgets('Golden Sample 14', (tester) async {

    final binding = tester.binding as AutomatedTestWidgetsFlutterBinding;
    binding.addTime(Duration(seconds: 4));

    ValueKey key = ValueKey('paint');
    Widget sample1 = getSampleForGoldenTest(key, 'example14');

    await tester.pumpWidget(sample1);
    await tester.pumpAndSettle();

    await expectLater(
        find.byKey(key),
        matchesGoldenFile('gold_files/sample14-base.png')
    );

    await tester.pump(Duration(seconds: 1));
  });

}