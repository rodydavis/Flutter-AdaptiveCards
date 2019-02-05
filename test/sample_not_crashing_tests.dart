import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_adaptive_cards/flutter_adaptive_cards.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    HttpOverrides.global = MyTestHttpOverrides();
  });
  for(int i = 1; i <= 15; i++) {
    testWidgets('sample$i', (tester) async {
      final binding = tester.binding as AutomatedTestWidgetsFlutterBinding;
      binding.addTime(Duration(seconds: 10));
      Widget widget = getWidget('example$i', 'host_config');
      await tester.pumpWidget(widget);
    });
  }
}

class MyTestHttpOverrides extends HttpOverrides{
}

Widget getWidget(String path, String hostConfigPath){
  var file = File('test/samples/$path');
  var hostConfigFile = File('test/host_configs/$hostConfigPath');
  var map = json.decode(file.readAsStringSync());
  var hostConfig = json.decode(hostConfigFile.readAsStringSync());
  Widget adaptiveCard = RawAdaptiveCard.fromMap(map, hostConfig);

  return MaterialApp(
    home: adaptiveCard,
  );
}