import 'dart:math';

import 'package:better_bus_v2/core/models/station.dart';
import 'package:better_bus_v2/views/stop_info/next_passage_view.dart';
import 'package:better_bus_v2/views/stops_search_page/stops_search_page.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';


class StopFocusWidget extends StatefulWidget {
  const StopFocusWidget({this.station, this.stop, this.position, this.openFocus, super.key});
  final Station? station;
  final int? stop;
  final LatLng? position;
  final VoidCallback? openFocus;


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
    if (detail.localPosition.dy.isNegative && detail.velocity.pixelsPerSecond.dy < -60) {
      setState(() {
        _height = 300;
      });
      widget.openFocus?.call();
    }
  }

  Widget buildDragBar() {
    // TODO: Check distance with sub stop
   String? distance =
    widget.position != null ?
       "${(getDistanceInKMeter(widget.station!, widget.position!) * 100).roundToDouble() / 100} km":
        null;

    return GestureDetector(
          onVerticalDragUpdate: handleVerticalDrag,
          onVerticalDragEnd: handleEndVerticalDrag,
          child: Material(
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 10, top: 8),
                  child: Container(
                    width: 100,
                    height: 4,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Colors.black.withAlpha(30)
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Row(
                    children: [
                      Text(
                        widget.station!.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                        const Spacer(),
                        ...(distance != null ? [
                      const Icon(Icons.directions_walk),
                      Text(distance)
                    ] : [])],
                  ),
                ),
              ],
            ),
          )
      );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.station == null) {
      return Container();
    }
    // TODO: Re implement filter
    //final lines = GTFSDataProvider.getStopLines(widget.stop?.id ?? widget.station!.id);

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
          buildDragBar(),
          Expanded(
              child: NextPassagePage(
                widget.station!,
                //lines: widget.stop != null ? lines : null,
                minimal: true,
                key: Key(widget.station!.name + (widget.stop.toString())),
              )
          ),
        ],
      ),
    );
  }
}
