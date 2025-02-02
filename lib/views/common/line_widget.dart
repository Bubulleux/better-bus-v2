import 'package:better_bus_v2/model/clean/bus_line.dart';
import 'package:better_bus_v2/model/clean/route.dart';
import 'package:flutter/material.dart';

class LineWidget extends StatelessWidget {
  const LineWidget(this.line, this.size, {this.dynamicWidth = false, super.key});

  LineWidget.fromRouteLine(RouteLine line, double size, {bool dynamicWidth = false, Key? key}): this(
    BusLine(line.name, "", line.color),
    size,
    dynamicWidth: dynamicWidth,
    key: key,
  );

  final BusLine line;
  final double size;
  final bool dynamicWidth;

  @override
  Widget build(BuildContext context) {
    double colorAverage = (line.color.red + line.color.green + line.color.blue) / (3 * 255);
    Color textColor = colorAverage < 0.5 ? Colors.white : Colors.black;

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
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.normal
            ),
          ),
          fit: dynamicWidth ? BoxFit.fitHeight : BoxFit.contain,
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: line.color,
      ),
    );
  }
}
