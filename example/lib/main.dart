import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_adaptive_cards/flutter_adaptive_cards.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  Map adaptiveMap;
  Map hostConfig;


  @override
  void initState() {
    super.initState();
    rootBundle.loadString("lib/easy_card").then((string) {
      setState(() {
        adaptiveMap = json.decode(string);
      });
    });
    rootBundle.loadString("lib/host_config").then((string) {
      setState(() {
        hostConfig = json.decode(string);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Example"),
      ),
      body: new Center(
        child: adaptiveMap == null || hostConfig == null ? Container(
          width: 100.0, height: 100.0, color: Colors.red,) : AdaptiveCard
            .fromMap(adaptiveMap, hostConfig),
      ),
    );
  }
}
