import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  const Background({this.child, Key? key}) : super(key: key);
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/bg_map.jpg"),
              fit: BoxFit.cover,
              colorFilter:
                  ColorFilter.mode(Color(0xffbbbbbb), BlendMode.multiply))),
      child: child,
    );
  }
}
