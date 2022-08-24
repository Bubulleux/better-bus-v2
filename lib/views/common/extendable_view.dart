import 'dart:math';

import 'package:flutter/material.dart';


class ExpandableWidgetController {
  late AnimationController animationController;
  late _ExpendableWidgetState expendableWidgetState;
  Duration? duration;

  bool expanded = false;

  ExpandableWidgetController({this.duration, required TickerProvider root}) {
    animationController = AnimationController(
        vsync: root,
        duration: duration ?? const Duration(milliseconds: 800)
    );
  }

  void dispose() {
    animationController.dispose();
  }

  void tickAnimation() {
    if (expanded) {
      expanded = false;
      animationController.reverse();
    } else {
      expanded = true;
      animationController.forward();
    }
  }
}

class ExpendableWidget extends StatefulWidget {
  const ExpendableWidget({
    required this.child,
    required this.controller,
    Key? key
  }) : super(key: key);

  final Widget child;
  final ExpandableWidgetController controller;

  @override
  State<ExpendableWidget> createState() => _ExpendableWidgetState();
}

class _ExpendableWidgetState extends State<ExpendableWidget>{
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    //widget.controller._setExpendableWidgetState(this);

    animation = CurvedAnimation(parent: widget.controller.animationController, curve: Curves.fastLinearToSlowEaseIn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: 1.0,
      child: widget.child,
    );
  }
}

class ExpendableWidgetButton extends StatefulWidget {
  const ExpendableWidgetButton(this.controller, {Key? key}) : super(key: key);

  final ExpandableWidgetController controller;

  @override
  State<ExpendableWidgetButton> createState() => _ExpendableWidgetButtonState();
}

class _ExpendableWidgetButtonState extends State<ExpendableWidgetButton> {
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animation = CurvedAnimation(parent: widget.controller.animationController, curve: Curves.elasticOut);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: widget.controller.tickAnimation,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, widget) => Transform.rotate(
            angle:  animation.value * pi,
            child: const Icon(Icons.keyboard_arrow_down),
          ),
        )
    );
  }
}

