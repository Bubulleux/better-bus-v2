import 'package:flutter/material.dart';

class InfoBox extends StatelessWidget {
  const InfoBox(
      {this.icon,
      required this.color,
      required this.child,
      this.margin = EdgeInsets.zero,
      this.width = double.infinity,
      super.key});

  final IconData? icon;
  final MaterialColor color;
  final EdgeInsets margin;
  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Container(
        width: width,
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color.shade100,
            border: Border.all(
                color: color.shade700,
                width: 2,
            )),
        child: Row(
          children: [
            Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(
                  icon,
                  color: color,
                  size: 30,
                )),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
