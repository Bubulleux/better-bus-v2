import 'dart:math';

import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/views/common/report_infobox.dart';
import 'package:better_bus_v2/views/map/controller.dart';
import 'package:better_bus_v2/views/stop_info/next_passage_view.dart';
import 'package:better_bus_v2/views/stops_search_page/stops_search_page.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../model/provider.dart';

class StopFocusWidget extends StatefulWidget {
  const StopFocusWidget({
    required this.controller,
    this.openFocus,
    super.key,
  });

  final NetworkMapController controller;
  final VoidCallback? openFocus;

  @override
  State<StopFocusWidget> createState() => _StopFocusWidgetState();
}

class _StopFocusWidgetState extends State<StopFocusWidget> {

  LatLng? get position => widget.controller.posCoord;

  Station get station => widget.controller.focusedStation!;

  int? get stop => null;

  Report? get report => widget.controller.report;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }


  Widget buildTitle() {
    String? distance = position != null
        ? "${(getDistanceInKMeter(station, position!) * 100).roundToDouble() / 100} km"
        : null;

    return Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: Row(
              children: [
                Text(
                  station.name,
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
    );
  }



  @override
  Widget build(BuildContext context) {
    List<LineDirection>? direction;
    final provider = FullProvider.of(context).gtfs;
    final stop = widget.controller.focusedStop;
    if (stop != null && provider.isAvailable()) {
      direction = provider.getStopDirections(stop);
    }

    return Column(
      key: Key(station.name + (stop.toString())),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        buildTitle(),
        ReportInfobox(
          updatable: widget.controller.canSentReport(station),
          report: report,
          station: station,
          reportUpdate: widget.controller.updateReport,
        ),
        SizedBox(
          height: 300,
          child: NextPassagePage(
                    station,
                    direction: direction,
                    minimal: true,
                    stopTimeSelected: widget.controller.setStopTime,
                  ),
        ),
      ],
    );
  }
}
