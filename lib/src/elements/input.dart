import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_adaptive_cards/flutter_adaptive_cards.dart';
import 'package:flutter_adaptive_cards/src/elements/basics.dart';

/// Text input elements

abstract class AdaptiveInput extends AdaptiveElement {
  AdaptiveInput({Map adaptiveMap, widgetState,})
      : super(adaptiveMap: adaptiveMap, widgetState: widgetState,);

  String value;

  void appendInput(Map map);

  @override
  void loadTree() {
    super.loadTree();
    value = adaptiveMap["value"].toString() == "null"
        ? ""
        : adaptiveMap["value"].toString();
  }
}

abstract class AdaptiveTextualInput extends AdaptiveInput
    with SeparatorElementMixin {
  AdaptiveTextualInput({Map adaptiveMap, widgetState,})
      : super(adaptiveMap: adaptiveMap, widgetState: widgetState,);

  String placeholder;
  @override
  void loadTree() {
    super.loadTree();
    placeholder = adaptiveMap["placeholder"] ?? "";
  }
}

class AdaptiveTextInput extends AdaptiveTextualInput {
  AdaptiveTextInput(Map adaptiveMap, widgetState,)
      : super(adaptiveMap: adaptiveMap, widgetState: widgetState,);

  TextEditingController controller = TextEditingController();
  bool isMultiline;
  int maxLength;
  TextInputType style;

  @override
  void loadTree() {
    super.loadTree();
    isMultiline = adaptiveMap["isMultiline"] ?? false;
    maxLength = adaptiveMap["maxLength"];
    style = loadTextInputType();
    controller.text = value;
  }

  @override
  Widget build() {
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

class AdaptiveNumberInput extends AdaptiveTextualInput {
  AdaptiveNumberInput(Map adaptiveMap, widgetState)
      : super(adaptiveMap: adaptiveMap, widgetState: widgetState,);

  TextEditingController controller = TextEditingController();

  int min;
  int max;

  @override
  void loadTree() {
    super.loadTree();
    controller.text = value;
    min = adaptiveMap["min"];
    max = adaptiveMap["max"];
  }

  @override
  Widget build() {
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

class AdaptiveDateInput extends AdaptiveTextualInput {
  AdaptiveDateInput(Map adaptiveMap, widgetState)
      : super(adaptiveMap: adaptiveMap, widgetState: widgetState,);

  DateTime selectedDateTime;
  DateTime min;
  DateTime max;

  @override
  void loadTree() {
    super.loadTree();
    try {
      selectedDateTime = DateTime.parse(value);
      min = DateTime.parse(adaptiveMap["min"]);
      max = DateTime.parse(adaptiveMap["max"]);
    } catch (formatException) {}
  }

  @override
  Widget build() {
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

class AdaptiveTimeInput extends AdaptiveTextualInput {
  AdaptiveTimeInput(Map adaptiveMap, widgetState)
      : super(adaptiveMap: adaptiveMap, widgetState: widgetState,);

  TimeOfDay selectedTime;
  TimeOfDay min;
  TimeOfDay max;

  @override
  void loadTree() {
    super.loadTree();
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
  Widget build() {
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

class AdaptiveToggle extends AdaptiveInput {
  AdaptiveToggle(Map adaptiveMap, widgetState)
      : super(adaptiveMap: adaptiveMap, widgetState: widgetState,);

  bool boolValue = false;

  String valueOff;
  String valueOn;

  String title;

  @override
  void loadTree() {
    super.loadTree();
    valueOff = adaptiveMap["valueOff"] ?? "false";
    valueOn = adaptiveMap["valueOn"] ?? "true";
    boolValue = value == valueOn;
    title = adaptiveMap["title"] ?? "";
  }

  @override
  Widget build() {
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

class AdaptiveChoiceSet extends AdaptiveInput {
  AdaptiveChoiceSet(Map adaptiveMap, widgetState,)
      : super(adaptiveMap: adaptiveMap, widgetState: widgetState);

  // Map from title to value
  Map<String, String> choices;

  // Contains the values (the things to send as request)
  Set<String> _selectedChoice = Set();

  bool isCompact;
  bool isMultiSelect;

  @override
  void loadTree() {
    super.loadTree();
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
  Widget build() {
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

///