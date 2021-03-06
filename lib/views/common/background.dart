import 'dart:ui';

import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  const Background({this.child, Key? key}) : super(key: key);
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bg_map.jpg"),
              repeat: ImageRepeat.repeat,
              fit: BoxFit.contain,
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
