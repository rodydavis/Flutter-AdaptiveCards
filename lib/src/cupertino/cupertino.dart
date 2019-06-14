// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CupertinoWidgets {
  CupertinoWidgets._();

  static const double _kPickerSheetHeight = 216.0;
  static const double _kPickerItemHeight = 32.0;

  static Widget buildBottomPicker(Widget picker) {
    return Container(
      height: _kPickerSheetHeight,
      padding: const EdgeInsets.only(top: 6.0),
      color: CupertinoColors.white,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: CupertinoColors.black,
          fontSize: 22.0,
        ),
        child: GestureDetector(
          // Blocks taps from propagating to the modal sheet and popping.
          onTap: () {},
          child: SafeArea(
            top: false,
            child: picker,
          ),
        ),
      ),
    );
  }

  static Widget buildPicker(
    BuildContext context, {
    @required String placeholder,
    @required Map<String, String> items,
    ValueChanged<String> onChanged,
    bool trySegmentedControl = false,
    int selectedIndex = 0,
    bool multiSelect = false,
  }) {

    final _selected =
        selectedIndex == -1 ? null : _getKeyByIndex(items, selectedIndex);

    if (trySegmentedControl && items.keys.length < 5) {
      final _items = <int, Widget>{};
      for (int i = 0; i < items.keys.length; i++) {
        _items[i] = Container(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(_getKeyByIndex(items, i)),
        );
      }

      return CupertinoSegmentedControl<int>(
        children: _items,
        onValueChanged: (val) => onChanged(_getKeyByIndex(items, val)),
        groupValue: selectedIndex == -1 ? 0 : selectedIndex,
      );
    }

    return GestureDetector(
      onTap: () async {
        await showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) {
            return buildBottomPicker(
              CupertinoPicker(
                scrollController:
                    FixedExtentScrollController(initialItem: selectedIndex),
                itemExtent: _kPickerItemHeight,
                backgroundColor: CupertinoColors.white,
                onSelectedItemChanged: (int index) {
                  final _item = items.keys.toList()[index];
                  onChanged(_item);
                },
                children: List<Widget>.generate(
                  items.keys.length,
                  (int index) {
                    final _item = items.keys.toList()[index];
                    return Center(child: Text(_item));
                  },
                ),
              ),
            );
          },
        );
      },
      child: buildMenu(
        context,
        children: <Widget>[
          Text(placeholder),
          Text(
            _selected ?? 'Not Selected',
            style: const TextStyle(color: CupertinoColors.inactiveGray),
          ),
        ],
      ),
    );
  }

  static String _getKeyByIndex(Map<String, String> items, int index) {
    return items.keys.toList()[index];
  }

  static Widget buildMenu(BuildContext context,
      {@required List<Widget> children}) {
    return Container(
      decoration: decoration(context),
      height: 44.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: children,
          ),
        ),
      ),
    );
  }

  static BoxDecoration decoration(BuildContext context) => BoxDecoration(
        border: Border(
            bottom: BorderSide(
          width: 0.0,
          color: CupertinoColors.inactiveGray,
        )),
        color: CupertinoTheme.of(context).scaffoldBackgroundColor,
      );
}

///
/// ```
/// final _phoneNumberFormatter = UsNumberTextInputFormatter();
/// ```
///
/// Setup [inputFormatters]:
///
/// ```
/// inputFormatters: <TextInputFormatter> [
///   WhitelistingTextInputFormatter.digitsOnly,
///   _phoneNumberFormatter,
/// ],
/// ```
///
/// Format incoming numeric text to fit the format of (###) ###-#### ##...
class UsNumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final int newTextLength = newValue.text.length;
    int selectionIndex = newValue.selection.end;
    int usedSubstringIndex = 0;
    final StringBuffer newText = StringBuffer();
    if (newTextLength >= 1) {
      newText.write('(');
      if (newValue.selection.end >= 1) selectionIndex++;
    }
    if (newTextLength >= 4) {
      newText.write(newValue.text.substring(0, usedSubstringIndex = 3) + ') ');
      if (newValue.selection.end >= 3) selectionIndex += 2;
    }
    if (newTextLength >= 7) {
      newText.write(newValue.text.substring(3, usedSubstringIndex = 6) + '-');
      if (newValue.selection.end >= 6) selectionIndex++;
    }
    if (newTextLength >= 11) {
      newText.write(newValue.text.substring(6, usedSubstringIndex = 10) + ' ');
      if (newValue.selection.end >= 10) selectionIndex++;
    }
    // Dump the rest.
    if (newTextLength >= usedSubstringIndex)
      newText.write(newValue.text.substring(usedSubstringIndex));
    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
