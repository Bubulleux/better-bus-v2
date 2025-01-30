import 'dart:math';

import 'package:better_bus_v2/data_provider/gtfs_data_provider.dart';
import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/views/stop_info/next_passage_view.dart';
import 'package:flutter/material.dart';


class StopFocusWidget extends StatefulWidget {
  StopFocusWidget({this.station, this.stop, this.distance, super.key});
  final BusStop? station;
  final SubBusStop? stop;
  final double? distance;


  @override
  State<StopFocusWidget> createState() => _StopFocusWidgetState();
}

class _StopFocusWidgetState extends State<StopFocusWidget> {

  double _height = 200;

  @override
  void didChangeDependencies() {
    setState(() {
    });
    super.didChangeDependencies();
  }

  void handleVerticalDrag(DragUpdateDetails detail) {
    setState(() {
      _height -= detail.delta.dy;
      _height = max(_height, 100);
    });
  }

  void handleEndVerticalDrag(DragEndDetails detail) {
    print(detail.velocity.pixelsPerSecond.dy);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.station == null) {
      return Container();
    }

    final lines = GTFSDataProvider.getStopLines(widget.stop?.id ?? widget.station?.id ?? 0);
    print(lines);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      height: _height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
      padding: const EdgeInsets.only(right: 5, left: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onVerticalDragUpdate: handleVerticalDrag,
            onVerticalDragEnd: handleEndVerticalDrag,
            child: Material(
              color: Colors.transparent,
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                padding: EdgeInsets.only(bottom: 10, top: 20),
                child: Container(
                  width: 200,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Colors.black.withAlpha(30)
                  ),
                ),
              ),
            )
          ),
          Row(
            children: [
              Icon(Icons.directions_walk),
            ],
          ),
          Expanded(
              child: NextPassagePage(
                widget.station!,
                lines: lines,
                key: Key(widget.station!.name + (widget.stop?.id.toString() ?? " ")),
              )
          ),
        ],
      ),
    );
  }
}
