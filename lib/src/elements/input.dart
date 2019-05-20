import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_adaptive_cards/flutter_adaptive_cards.dart';
import 'package:flutter_adaptive_cards/src/elements/basics.dart';

import 'fsadhfafd.dart';

// TODO add separator for each

class AdaptiveTextInput extends StatefulWidget with AdaptiveElementWidgetMixin {

  AdaptiveTextInput({Key key, this.adaptiveMap}) : super(key: key);

  final Map adaptiveMap;
  @override
  _AdaptiveTextInputState createState() => _AdaptiveTextInputState();
}

class _AdaptiveTextInputState extends State<AdaptiveTextInput> with AdaptiveTextualInputMixin,
    AdaptiveInputMixin, AdaptiveElementMixin{


  TextEditingController controller = TextEditingController();
  bool isMultiline;
  int maxLength;
  TextInputType style;



  @override
  void initState() {
    super.initState();
    isMultiline = adaptiveMap["isMultiline"] ?? false;
    maxLength = adaptiveMap["maxLength"];
    style = loadTextInputType();
    controller.text = value;

  }
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      keyboardType: style,
      maxLines: isMultiline ? null : 1,
      decoration: InputDecoration(
        labelText: placeholder,
      ),
    );
  }


  @override
  void appendInput(Map map) {
    map[id] = controller.text;
  }

  TextInputType loadTextInputType() {
    /// Can be one of the following:
    /// - "text"
    /// - "tel"
    /// - "url"
    /// - "email"
    String style = adaptiveMap["style"] ?? "text";
    switch (style) {
      case "text":
        return TextInputType.text;
      case "tel":
        return TextInputType.phone;
      case "url":
        return TextInputType.url;
      case "email":
        return TextInputType.emailAddress;
      default:
        return null;
    }
  }
}



class AdaptiveNumberInput extends StatefulWidget with AdaptiveElementWidgetMixin {

  AdaptiveNumberInput({Key key, this.adaptiveMap}) : super(key: key);

  final Map adaptiveMap;
  @override
  _AdaptiveNumberInputState createState() => _AdaptiveNumberInputState();
}

class _AdaptiveNumberInputState extends State<AdaptiveNumberInput> with AdaptiveTextualInputMixin, AdaptiveInputMixin, AdaptiveElementMixin{


  TextEditingController controller = TextEditingController();

  int min;
  int max;


  @override
  void initState() {
    super.initState();

    controller.text = value;
    min = adaptiveMap["min"];
    max = adaptiveMap["max"];
  }
  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.number,
      inputFormatters: [
        TextInputFormatter.withFunction((oldVal, newVal) {
          if (newVal.text == "") return newVal;
          int newNumber = int.parse(newVal.text);
          if (newNumber >= min && newNumber <= max) return newVal;
          return oldVal;
        })
      ],
      controller: controller,
      decoration: InputDecoration(
        labelText: placeholder,
      ),
    );
  }



  @override
  void appendInput(Map map) {
    map[id] = controller.text;
  }
}


class AdaptiveDateInput extends StatefulWidget with AdaptiveElementWidgetMixin {

  AdaptiveDateInput({Key key, this.adaptiveMap}) : super(key: key);

  final Map adaptiveMap;
  @override
  _AdaptiveDateInputState createState() => _AdaptiveDateInputState();
}

class _AdaptiveDateInputState extends State<AdaptiveDateInput> with AdaptiveTextualInputMixin,
    AdaptiveElementMixin, AdaptiveInputMixin{



  DateTime selectedDateTime;
  DateTime min;
  DateTime max;


  @override
  void initState() {
    super.initState();

   try {
      selectedDateTime = DateTime.parse(value);
      min = DateTime.parse(adaptiveMap["min"]);
      max = DateTime.parse(adaptiveMap["max"]);
    } catch (formatException) {}
  }
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () async {
        selectedDateTime = await widgetState.pickDate(min, max);
        widgetState.rebuild();
      },
      child: Text(selectedDateTime == null
          ? placeholder
          : selectedDateTime.toIso8601String()),
    );
  }


  @override
  void appendInput(Map map) {
    map[id] = selectedDateTime.toIso8601String();
  }
}


class AdaptiveTimeInput extends StatefulWidget with AdaptiveElementWidgetMixin {

  AdaptiveTimeInput({Key key, this.adaptiveMap}) : super(key: key);

  final Map adaptiveMap;
  @override
  _AdaptiveTimeInputState createState() => _AdaptiveTimeInputState();
}

class _AdaptiveTimeInputState extends State<AdaptiveTimeInput> with AdaptiveTextualInputMixin,
    AdaptiveElementMixin, AdaptiveInputMixin{


  TimeOfDay selectedTime;
  TimeOfDay min;
  TimeOfDay max;


  @override
  void initState() {
    super.initState();

    selectedTime = parseTime(value) ?? TimeOfDay.now();
    min = parseTime(adaptiveMap["min"]) ?? TimeOfDay(minute: 0, hour: 0);
    max = parseTime(adaptiveMap["max"]) ?? TimeOfDay(minute: 59, hour: 23);
  }


  TimeOfDay parseTime(String time) {
    if (time == null) return null;
    List<String> times = time.split(":");
    assert(times.length == 2, "Invalid TimeOfDay format");
    return TimeOfDay(
      hour: int.parse(times[0]),
      minute: int.parse(times[1]),
    );
  }
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () async {
        TimeOfDay result = await widgetState.pickTime();
        if (result.hour >= min.hour && result.hour <= max.hour) {
          widgetState
              .showError("Time must be after ${min.format(widgetState.context)}"
              " and before ${max.format(widgetState.context)}");
        } else {
          selectedTime = result;
          widgetState.rebuild();
        }
      },
      child: Text(selectedTime == null
          ? placeholder
          : selectedTime.format(widgetState.context)),
    );
  }


  @override
  void appendInput(Map map) {
    map[id] = selectedTime.toString();
  }
}


class AdaptiveToggle extends StatefulWidget with AdaptiveElementWidgetMixin {

  AdaptiveToggle({Key key, this.adaptiveMap}) : super(key: key);

  final Map adaptiveMap;
  @override
  _AdaptiveToggleState createState() => _AdaptiveToggleState();
}

class _AdaptiveToggleState extends State<AdaptiveToggle> with AdaptiveInputMixin,AdaptiveElementMixin{



  bool boolValue = false;

  String valueOff;
  String valueOn;

  String title;


  @override
  void initState() {
    super.initState();

    valueOff = adaptiveMap["valueOff"] ?? "false";
    valueOn = adaptiveMap["valueOn"] ?? "true";
    boolValue = value == valueOn;
    title = adaptiveMap["title"] ?? "";
  }



  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Switch(
          value: boolValue,
          onChanged: (newValue) {
            boolValue = newValue;
            widgetState.rebuild();
          },
        ),
        Expanded(
          child: Text(title),
        ),
      ],
    );
  }



  @override
  void appendInput(Map map) {
    map[id] = boolValue ? valueOn : valueOff;
  }
}



class AdaptiveChoiceSet extends StatefulWidget with AdaptiveElementWidgetMixin {

  AdaptiveChoiceSet({Key key, this.adaptiveMap}) : super(key: key);

  final Map adaptiveMap;
  @override
  _AdaptiveChoiceSetState createState() => _AdaptiveChoiceSetState();
}

class _AdaptiveChoiceSetState extends State<AdaptiveChoiceSet> with AdaptiveInputMixin,AdaptiveElementMixin{


  // Map from title to value
  Map<String, String> choices;

  // Contains the values (the things to send as request)
  Set<String> _selectedChoice = Set();

  bool isCompact;
  bool isMultiSelect;


  @override
  void initState() {
    super.initState();
    choices = Map();
    for (Map map in adaptiveMap["choices"]) {
      choices[map["title"]] = map["value"].toString();
    }
    isCompact = loadCompact();
    isMultiSelect = adaptiveMap["isMultiSelect"] ?? false;
    _selectedChoice.addAll(value.split(","));

  }



  @override
  void appendInput(Map map) {
    map[id] = _selectedChoice;
  }

  @override
  Widget build(BuildContext context) {
    return isCompact
        ? isMultiSelect ? _buildExpanded() : _buildCompact()
        : _buildExpanded();
  }


  /// This is built when multiSelect is false and isCompact is true
  Widget _buildCompact() {
    return DropdownButton<String>(
      items: choices.keys
          .map((choice) => DropdownMenuItem<String>(
        value: choices[choice],
        child: Text(choice),
      ))
          .toList(),
      onChanged: select,
      value: _selectedChoice.single,
    );
  }

  Widget _buildExpanded() {
    return Column(
      children: choices.keys.map((key) {
        return RadioListTile<String>(
            value: choices[key],
            groupValue:
            _selectedChoice.contains(choices[key]) ? choices[key] : null,
            title: Text(key),
            onChanged: select);
      }).toList(),
    );
  }

  void select(String choice) {
    if (!isMultiSelect) {
      _selectedChoice.clear();
      _selectedChoice.add(choice);
    } else {
      if (_selectedChoice.contains(choice)) {
        _selectedChoice.remove(choice);
      } else {
        _selectedChoice.add(choice);
      }
    }
    widgetState.rebuild();
  }

  bool loadCompact() {
    if (!adaptiveMap.containsKey("style")) return false;
    if (adaptiveMap["style"] == "compact") return true;
    if (adaptiveMap["style"] == "expanded") return false;
    throw StateError(
        "The style of the ChoiceSet needs to be either compact or expanded");
  }
}

