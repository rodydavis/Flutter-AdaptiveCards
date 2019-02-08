import 'package:flutter/material.dart';

class FadeAnimation extends StatefulWidget {
  FadeAnimation(
      {this.child, this.duration = const Duration(milliseconds: 500)});

  final Widget child;
  final Duration duration;

  @override
  _FadeAnimationState createState() => _FadeAnimationState();
}

class _FadeAnimationState extends State<FadeAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: widget.duration, vsync: this);
    animationController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    animationController.forward(from: 0.0);
  }

  @override
  void deactivate() {
    animationController.stop();
    super.deactivate();
  }

  @override
  void didUpdateWidget(FadeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {
      animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return animationController.isAnimating
        ? Opacity(
      opacity: 1.0 - animationController.value,
      child: widget.child,
    )
        : Container();
  }
}

String firstCharacterToLowerCase(String s) => s.isNotEmpty? s[0].toLowerCase() + s.substring(1): "";


class Tuple<A, B> {
  final A a;
  final B b;

  Tuple(this.a, this.b);
}

class FullCircleClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0.0, 0.0, size.width, size.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => false;
}

Color parseColor(String colorValue) {
  // No alpha
  if (colorValue.length == 7) {
    return Color(int.parse(colorValue.substring(1, 7), radix: 16) + 0xFF000000);
  } else if (colorValue.length == 9) {
    return Color(int.parse(colorValue.substring(1, 9), radix: 16));
  } else {
    throw StateError("$colorValue is not a valid color");
  }
}


String _weekDayToString(int weekday, bool short) {

  switch(weekday) {
    case 1: return short? "Mon" : "Monday";
    case 2: return short? "Tue" : "Tuesday";
    case 3: return short? "Wed" : "Wednesday";
    case 4: return short? "Thu" : "Thursday";
    case 5: return short? "Fri" : "Friday";
    case 6: return short? "Sat" : "Saturday";
    case 7: return short? "Sun" : "Sunday";
    default: throw StateError("Weekday $weekday is not valid");
  }
}

String _monthToString(int month, bool short) {

  switch(month) {
    case 1: return short? "Jan" : "January";
    case 2: return short? "Feb" : "February";
    case 3: return short? "Mar" : "March";
    case 4: return short? "Apr" : "April";
    case 5: return short? "May" : "May";
    case 6: return short? "Jun" : "June";
    case 7: return short? "Jul" : "July";
    case 8: return short? "Aug" : "August";
    case 9: return short? "Sept" : "September";
    case 10: return short? "Oct" : "October";
    case 11: return short? "Nov" : "November";
    case 12: return short? "Dec" : "December";
    default: throw StateError("Moneth $month is not valid");
  }
}

String _numberToText(int number) {
  switch(number) {
    case 1: return "1st";
    case 2: return "2nd";
    case 3: return "3rd";
    default: return "${number}th";

  }
}

/// Parses a given text string to property handle DATE() and TIME()
/// TODO this needs a bunch of tests
String parseTextString(String text) {
  text.replaceAllMapped(RegExp(r'{{.*}}'), (match) {
    String res = match.group(0);
    String input = res.substring(2, res.length -2);
    input = input.replaceAll(" ", "");

    String type = input.substring(0, 4);
    if(type == "DATE") {
      String dateFunction = input.substring(5, input.length - 1);
      List<String> items = dateFunction.split(",");
      if(items.length == 1) {
        items.add("COMPACT");
      }
      if(items.length != 2) throw StateError("$dateFunction is not valid");

      DateTime dateTime = DateTime.parse(items[0]);
      if(items[1] == "COMPACT") {
        return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
      } else if(items[1] == "SHORT") {
        return "${_weekDayToString(dateTime.weekday, true)}, ${_monthToString(dateTime.month, true)} "
            "${_numberToText(dateTime.day)}, ${dateTime.year}";
      } else if(items[1] == "LONG") {
        return "${_weekDayToString(dateTime.weekday, false)}, ${_monthToString(dateTime.month, false)} "
            "${_numberToText(dateTime.day)}, ${dateTime.year}";
      } else {
        throw StateError("${items[1]} is not a valid format");
      }


    } else if(type == "TIME") {

    } else {
      throw StateError("Function $type not found");
    }

    print("Match: ${type}");
  });
  return text;

}