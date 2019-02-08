
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
      ),
    ),
  );
}

void main() {

  // Deliver actual images
  setUp(() {
    HttpOverrides.global = MyTestHttpOverrides();
  });

  testWidgets('Golden test 1', (tester) async {


    final binding = tester.binding as AutomatedTestWidgetsFlutterBinding;
    binding.addTime(Duration(seconds: 4));

    ValueKey key = ValueKey('paint');
    Widget sample1 = getWidthDefaultHostConfig('example1');

    //await tester.pumpWidget(SizedBox(width:100,height:100,child: Center(child: RepaintBoundary(child: SizedBox(width:500, height: 1200,child: sample1), key: key,))));
    await tester.pumpWidget(MaterialApp(
      home: RepaintBoundary(
        key: key,
        child: Scaffold(
          appBar: AppBar(
            title: Text("hi"),
          ),
          body: Center(
            child: sample1,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(key),
      matchesGoldenFile('gold_files/sample1-golden.png')
    );
  });


}