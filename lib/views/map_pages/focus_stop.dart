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
    if (widget.stop == null) {
      return Container();
    }
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
      padding: const EdgeInsets.only(top: 10, right: 5, left: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.stop!.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Row(
            children: [
              Icon(Icons.directions_walk),
            ],
          ),
          Expanded(child:NextPassagePage(widget.stop!)),
        ],
      ),
    );
  }
}
