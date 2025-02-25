import 'package:better_bus_v2/core/models/bus_line.dart';
import 'package:better_bus_v2/core/models/line_direction.dart';
import 'package:flutter/material.dart';

class DirectionSelector extends StatefulWidget {
  const DirectionSelector(this.line, {super.key});

  final BusLine line;

  @override
  State<DirectionSelector> createState() => _DirectionSelectorState();
}

class _DirectionSelectorState extends State<DirectionSelector> {
  @override
  Widget build(BuildContext context) {
    List<Direction> top = widget.line.directions.where((e) => e.directionId == 0).toList();
    List<Direction> bot = widget.line.directions.where((e) => e.directionId == 1).toList();
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: top.map((e) => Text(e.destination)).toList(),
          ),
          Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: bot.map((e) => Text(e.destination)).toList(),
          )
        ],
      ),
    );
  }
}
