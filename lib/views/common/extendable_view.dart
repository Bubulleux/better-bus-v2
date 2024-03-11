import 'dart:math';

import 'package:flutter/material.dart';


class ExpandableWidgetController {
  late AnimationController animationController;
  late _ExpandableWidgetState expendableWidgetState;
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

class ExpandableWidget extends StatefulWidget {
  const ExpandableWidget({
    required this.child,
    required this.controller,
    Key? key
  }) : super(key: key);

  final Widget child;
  final ExpandableWidgetController controller;

  @override
  State<ExpandableWidget> createState() => _ExpandableWidgetState();
}

class _ExpandableWidgetState extends State<ExpandableWidget>{
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
  const ExpendableWidgetButton(this.controller, {this.height, this.width, Key? key}) : super(key: key);

  final ExpandableWidgetController controller;
  final double? height;
  final double? width;

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
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: TextButton(
        onPressed: widget.controller.tickAnimation,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, widget) => Transform.rotate(
            angle:  animation.value * pi,
            child: const FittedBox(
              fit: BoxFit.fill,
              child: Icon(Icons.keyboard_arrow_down,)
            ),
          ),
        )
      ),
    );
  }
}

