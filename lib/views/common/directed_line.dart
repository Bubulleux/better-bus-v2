import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/model/bus_line_color.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:flutter/material.dart';

class LabeledLine extends StatelessWidget {
  const LabeledLine(
      {required this.line, this.label, this.size = 18, super.key});

  LabeledLine.fromDirection({required LineDirection direction})
      : this(line: direction.line, label: direction.destination);

  final BusLine line;
  final String? label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorAverage =
        (line.color.r + line.color.g + line.color.b) / (3 * 255);
    final textColor = colorAverage < 0.5 ? Colors.white : Colors.black;

    final radius = BorderRadius.circular(size);
    return DefaultTextStyle.merge(
      style: TextStyle(fontSize: size),
      child: Container(
        padding: EdgeInsets.only(right: 5),
        decoration: BoxDecoration(
          border: Border.all(color: line.color, width: 3),
          borderRadius: radius,
        ),
        clipBehavior: Clip.hardEdge,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: line.color,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              margin: const EdgeInsets.only(right: 5),
              child: Text(
                line.id,
                style: TextStyle(color: textColor),
              ),
            ),
            label != null ? Text(label!) : Container()
          ],
        ),
      ),
    );
  }
}
