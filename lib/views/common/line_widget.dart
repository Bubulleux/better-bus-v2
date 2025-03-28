import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/model/bus_line_color.dart';
import 'package:flutter/material.dart';

class LineWidget extends StatelessWidget {
  const LineWidget(this.line, this.size, {this.dynamicWidth = false, this.rounded = false, super.key});

  // TODO: Maybe Needed
  // LineWidget.fromRouteLine(RouteLine line, double size, {bool dynamicWidth = false, Key? key}): this(
  //   BusLine(line.name, "", line.color),
  //   size,
  //   dynamicWidth: dynamicWidth,
  //   key: key,
  // );

  final BusLine line;
  final double size;
  final bool dynamicWidth;
  final bool rounded;

  @override
  Widget build(BuildContext context) {
    double colorAverage = (line.color.red + line.color.green + line.color.blue) / (3 * 255);
    Color textColor = colorAverage < 0.5 ? Colors.white : Colors.black;
    final rad = rounded ? BorderRadius.circular(size * 0.4) : BorderRadius.circular(5);

    return Container(
      constraints: BoxConstraints(
        minWidth: size,
      ),
      width: dynamicWidth ? null : size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: rad,
        color: line.color,
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: FittedBox(
          fit: dynamicWidth ? BoxFit.fitHeight : BoxFit.contain,
          child: Text(
            line.id,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontWeight: size < 20 ? FontWeight.w600 : FontWeight.normal
            ),
          ),
        ),
      ),
    );
  }
}
