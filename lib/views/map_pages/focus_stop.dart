import 'dart:math';

import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/views/stop_info/next_passage_view.dart';
import 'package:flutter/material.dart';


class StopFocusWidget extends StatefulWidget {
  StopFocusWidget(this.stop, {key}) : super(key: key);
  BusStop? stop;

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

  @override
  Widget build(BuildContext context) {
    if (widget.stop == null) {
      return Container();
    }
    return Container(
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
            onVerticalDragUpdate: (detail) {
              setState(() {
                _height -= detail.delta.dy;
                _height = max(_height, 100);
              });
            },
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
              child:NextPassagePage(widget.stop!, key: Key(widget.stop!.name),
              )
          ),
        ],
      ),
    );
  }
}
