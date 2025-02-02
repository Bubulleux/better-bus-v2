import 'dart:ui';

import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  const Background({this.child, super.key});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bg_map.png"),
              repeat: ImageRepeat.repeat,
              fit: BoxFit.fitHeight,
              colorFilter:
                  ColorFilter.mode(Color(0xffbbbbbb), BlendMode.multiply),
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Material(
            type: MaterialType.transparency,
              child: child,
          ),
        ),
      ],
    );
  }
}
