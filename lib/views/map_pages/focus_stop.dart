import 'dart:math';

import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/data_provider/radar_provider.dart';
import 'package:better_bus_v2/views/common/informative_box.dart';
import 'package:better_bus_v2/views/common/report_infobox.dart';
import 'package:better_bus_v2/views/stop_info/next_passage_view.dart';
import 'package:better_bus_v2/views/stops_search_page/stops_search_page.dart';
import 'package:flutter/material.dart';
import 'package:format/format.dart';
import 'package:latlong2/latlong.dart';

import '../../model/provider.dart';

class StopFocusWidget extends StatefulWidget {
  const StopFocusWidget({
    this.station,
    this.stop,
    this.position,
    this.openFocus,
    this.report,
    this.reportUpdate,
    super.key,
  });

  final Station? station;
  final int? stop;
  final Report? report;
  final LatLng? position;
  final VoidCallback? openFocus;
  final ValueChanged<Report>? reportUpdate;

  @override
  State<StopFocusWidget> createState() => _StopFocusWidgetState();
}

class _StopFocusWidgetState extends State<StopFocusWidget> {
  double _height = 200;

  @override
  void initState() {
    super.initState();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  void handleVerticalDrag(DragUpdateDetails detail) {
    setState(() {
      _height -= detail.delta.dy;
      _height = max(_height, 100);
    });
  }

  void handleEndVerticalDrag(DragEndDetails detail) {
    if (detail.localPosition.dy.isNegative &&
        detail.velocity.pixelsPerSecond.dy < -60) {
      setState(() {
        _height = 300;
      });
      widget.openFocus?.call();
    }
  }

  Widget buildDragBar() {
    String? distance = widget.position != null
        ? "${(getDistanceInKMeter(widget.station!, widget.position!) * 100).roundToDouble() / 100} km"
        : null;

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
                      color: Colors.black.withAlpha(30)),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                child: Row(
                  children: [
                    Text(
                      widget.station!.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    ...(distance != null
                        ? [const Icon(Icons.directions_walk), Text(distance)]
                        : [])
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.station == null) {
      return Container();
    }

    List<LineDirection>? direction;
    final provider = FullProvider.of(context).gtfs;
    if (widget.stop != null && provider.isAvailable()) {
      direction = provider.getStopDirections(widget.stop!);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      height: _height,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      padding: const EdgeInsets.only(right: 5, left: 5),
      child: Column(
        key: Key(widget.station!.name + (widget.stop.toString())),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildDragBar(),
          ReportInfobox(
            report: widget.report,
            station: widget.station!,
            reportUpdate: widget.reportUpdate,
          ),
          Expanded(
              child: NextPassagePage(
            widget.station!,
            direction: direction,
            minimal: true,
          )),
        ],
      ),
    );
  }
}
