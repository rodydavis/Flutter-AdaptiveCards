import 'dart:convert';

import 'package:example/action_open_url/action_open_url_examples_page.dart';
import 'package:example/action_show_card/action_show_card_examples_page.dart';
import 'package:example/action_submit/action_submit_examples_page.dart';
import 'package:example/column/column_examples_page.dart';
import 'package:example/column_set/column_set_examples_page.dart';
import 'package:example/container/container_examples_page.dart';
import 'package:example/fact_set/fact_set_examples_page.dart';
import 'package:example/image/image_examples_page.dart';
import 'package:example/image_set/image_set_examples_page.dart';
import 'package:example/inputs/input_choice_set/input_choice_set.dart';
import 'package:example/inputs/input_date/input_date.dart';
import 'package:example/inputs/input_number/input_number.dart';
import 'package:example/inputs/input_text/input_text.dart';
import 'package:example/inputs/input_time/input_time.dart';
import 'package:example/inputs/input_toggle/input_toggle.dart';
import 'package:example/media/media.dart';
import 'package:example/samples/samples.dart';
import 'package:example/text_block/text_block_examples_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_adaptive_cards/src/flutter_adaptive_cards.dart';

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
        "Samples": (context) => SamplesPage(),
        "TextBlock": (context) => TextBlockPage(),
        "Image": (context) => ImagePage(),
        "Container": (context) => ContainerPage(),
        "ColumnSet": (context) => ColumnSetPage(),
        "Column": (context) => ColumnPage(),
        "FactSet": (context) => FactSetPage(),
        "ImageSet": (context) => ImageSetPage(),
        "Action.OpenUrl": (context) => ActionOpenUrlPage(),
        "Action.Submit": (context) => ActionSubmitPage(),
        "Action.ShowCard": (context) => ActionShowCardPage(),
        "Input.Text": (context) => InputText(),
        "Input.Number": (context) => InputNumber(),
        "Media": (context) => MediaPage(),
        "Input.Date": (context) => InputDatePage(),
        "Input.Time": (context) => InputTimePage(),
        "Input.Toggle": (context) => InputTogglePage(),
        "Input.ChoiceSet": (context) => InputChoiceSetPage(),
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
        title: new Text("Flutter Adaptive Cards"),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  FlutterLogo(
                    size: 50.0,
                  ),
                  Text("Flutter - Adaptive Cards \nby Neohelden", style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600), textAlign: TextAlign.center,),
                  SizedBox(height: 8.0,),
                  Text("The animations are not part of the library, check out flutter_villains for that ", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300), textAlign: TextAlign.center,),
                ],
              ),
            ),
          ),
          getButton("Samples"),
          getRow(["Image", "ImageSet"]),
          getButton("Media"),
          Divider(),
          getRow(["Action.OpenUrl", "Action.Submit", "Action.ShowCard"]),
          Divider(),
          getButton("Container"),
          getButton("FactSet"),
          getButton("TextBlock"),
          getRow(["Column", "ColumnSet"]),
          Divider(),
          getRow(["Input.Text", "Input.Number", "Input.Date"]),
          getRow(["Input.Time", "Input.Toggle", "Input.ChoiceSet"]),
        ],
      ),
    );
  }


  Widget getRow(List<String> element) {
    return Row(
      children: element.map((it) => Expanded(child: getButton(it)),).toList(),
    );
  }

  Widget getButton(String element) {
    return Card(
      child: InkWell(
        onTap: () => pushNamed(element),
        child: SizedBox(
          height: 64.0,
          child: Center(child: Text(element)),
        )
      ),
    );
  }

  void pushNamed(String element) {
    Navigator.pushNamed(context, element);
  }
}
