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