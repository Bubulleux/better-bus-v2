import 'package:better_bus_v2/model/clean/bus_line.dart';
import 'package:flutter/material.dart';

class LineWidget extends StatelessWidget {
  const LineWidget(this.line, this.size, {this.dynamicWidth = false, Key? key})
      : super(key: key);

  final BusLine line;
  final double size;
  final bool dynamicWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: size,
      ),
      width: dynamicWidth ? null : size,
      height: size,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: FittedBox(
          child: Text(
            line.id,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
          fit: dynamicWidth ? BoxFit.fitHeight : BoxFit.contain,
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: line.color,
      ),
    );
  }
}
