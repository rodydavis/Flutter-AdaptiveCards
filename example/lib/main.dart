import 'dart:convert';

import 'package:example/action_open_url/action_open_url_examples_page.dart';
import 'package:example/action_submit/action_submit_examples_page.dart';
import 'package:example/column/column_examples_page.dart';
import 'package:example/column_set/column_set_examples_page.dart';
import 'package:example/container/container_examples_page.dart';
import 'package:example/fact_set/fact_set_examples_page.dart';
import 'package:example/image/image_examples_page.dart';
import 'package:example/image_set/image_set_examples_page.dart';
import 'package:example/text_block/text_block_examples_page.dart';
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
      routes: {
        "TextBlock": (context) => TextBlockPage(),
        "Image": (context) => ImagePage(),
        "Container": (context) => ContainerPage(),
        "ColumnSet": (context) => ColumnSetPage(),
        "Column": (context) => ColumnPage(),
        "FactSet": (context) => FactSetPage(),
        "ImageSet": (context) => ImageSetPage(),
        "Action.OpenUrl": (context) => ActionOpenUrlPage(),
        "Action.Submit": (context) => ActionSubmitPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Example"),
      ),
      body: ListView(
        children: <Widget>[
          RaisedButton(onPressed: () {
            Navigator.pushNamed(context, "TextBlock");
          },
          child: Text("TextBlock"),
          ),
          RaisedButton(onPressed: () {
            Navigator.pushNamed(context, "Image");
          },
            child: Text("Image"),
          ),
          RaisedButton(onPressed: () {
            Navigator.pushNamed(context, "Container");
          },
            child: Text("Container"),
          ),
          RaisedButton(onPressed: () {
            Navigator.pushNamed(context, "ColumnSet");
          },
            child: Text("ColumnSet"),
          ),
          RaisedButton(onPressed: () {
            Navigator.pushNamed(context, "Column");
          },
            child: Text("Column"),
          ),
          RaisedButton(onPressed: () {
            Navigator.pushNamed(context, "FactSet");
          },
            child: Text("FactSet"),
          ),
          RaisedButton(onPressed: () {
            Navigator.pushNamed(context, "ImageSet");
          },
            child: Text("ImageSet"),
          ),
          RaisedButton(onPressed: () {
            Navigator.pushNamed(context, "Action.OpenUrl");
          },
            child: Text("Action.OpenUrl"),
          ),
          RaisedButton(onPressed: () {
            Navigator.pushNamed(context, "Action.Submit");
          },
            child: Text("Action.Submit"),
          ),
        ],
      ),
    );
  }
}
