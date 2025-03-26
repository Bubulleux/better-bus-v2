import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/views/common/report_infobox.dart';
import 'package:better_bus_v2/views/map/controller.dart';
import 'package:better_bus_v2/views/stop_info/next_passage_view.dart';
import 'package:better_bus_v2/views/stop_info/timetable_view.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../model/provider.dart';

class StopFocusWidget extends StatefulWidget {
  const StopFocusWidget({
    required this.controller,
    required this.goToRoute,
    super.key,
  });

  final NetworkMapController controller;
  final VoidCallback goToRoute;

  @override
  State<StopFocusWidget> createState() => _StopFocusWidgetState();
}

class _StopFocusWidgetState extends State<StopFocusWidget> {
  LatLng? get position => widget.controller.posCoord;

  Station get station => widget.controller.focusedStation!;

  int? get stop => null;

  Report? get report => widget.controller.report;

  Widget? body;

  List<BusLine>? passingLines = null;

  @override
  void initState() {
    super.initState();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  Widget buildClose()  {
    return CloseButton(onPressed: () => setState(() {
      body = null;
    }),);
  }

  void showTimetable() {
    body = Column(
      children: [
        buildClose(),
        Expanded(child: TimeTableView(station))
      ],
    );
    setState(() {});
  }
  

  Widget buildHeader() {

    Widget btn(String content, VoidCallback onPressed) {
      return ElevatedButton(onPressed: onPressed, child: Text(content));
    }

    final buttons = [
      btn("Itineraire", widget.goToRoute),
      btn("TimeTable", showTimetable),
      //report == null ? ReportInfobox(station: station) : Container(),
      // btn("InfTraif", () {}),
    ];

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 5,
              children: buttons,
            ),
          ],
        ),
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
        buildHeader(),
        ReportInfobox(
          updatable: widget.controller.canSentReport(station),
          report: report,
          station: station,
          reportUpdate: widget.controller.updateReport,
        ),
        Expanded(
          child: Material(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: body ?? NextPassagePage(
                station,
                direction: direction,
                minimal: true,
                stopTimeSelected: widget.controller.setStopTime,
              ),
            )
    
    ))

      ],
    );
  }
}
