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
  @override
  Widget build(BuildContext context) {
    if (widget.stop != null) {
      return NextPassagePage(widget.stop!);
    }
    return Container();
  }
}
