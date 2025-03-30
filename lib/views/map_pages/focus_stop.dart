import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/model/view_shortcut.dart';
import 'package:better_bus_v2/views/common/report_infobox.dart';
import 'package:better_bus_v2/views/map/controller.dart';
import 'package:better_bus_v2/views/route_page/route_page.dart';
import 'package:better_bus_v2/views/route_page/route_search.dart';
import 'package:better_bus_v2/views/stop_info/next_passage_view.dart';
import 'package:better_bus_v2/views/stop_info/timetable_view.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../app_constant/app_string.dart';
import '../../model/provider.dart';

class StopFocusWidget extends StatefulWidget {
  const StopFocusWidget({
    required this.controller,
    this.shortcut,
    super.key,
  });

  final NetworkMapController controller;
  final ViewShortcut? shortcut;

  @override
  State<StopFocusWidget> createState() => _StopFocusWidgetState();
}

class _StopFocusWidgetState extends State<StopFocusWidget> {
  LatLng? get position => widget.controller.posCoord;

  Station get station => widget.controller.focusedStation!;

  int? get stop => null;

  Report? get report => widget.controller.report;

  Widget? body;

  List<BusLine>? passingLines;

  ViewShortcut? actualFilter;

  @override
  void initState() {
    super.initState();
    actualFilter ??= widget.shortcut;
    widget.controller.stateChange.addListener(() {
      if (widget.controller.focusedStation != actualFilter?.stop) {
        actualFilter = null;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }


  void showTimetable() {
    body = TimeTableView(station);
    setState(() {});
  }
  void removeFilter() {
    setState(() {
      actualFilter = null;
    });
  }

  void goToRoute() {
    assert(position != null);
    final arg = RouteSearchParameter(
      Place(AppString.myPosition, position: position!),
      station,
      RouteTimeType.departure,
      DateTime.now(),
    );
    Navigator.of(context).pushNamed(RoutePage.routeName, arguments: arg);
  }

  Widget buildReport() {
    return ReportInfobox(
      updatable: widget.controller.canSentReport(station),
      report: report,
      station: station,
      reportUpdate: widget.controller.updateReport,
    );
  }

  Widget buildHeader() {
    final menuBtn = body == null
        ? ElevatedButton.icon(
            onPressed: showTimetable,
            icon: Icon(Icons.calendar_month),
            label: const Text(AppString.allSchedule),
          )
        : ElevatedButton.icon(
            onPressed: () => setState(() {
              body = null;
            }),
            icon: Icon(Icons.share_arrival_time),
            label: const Text(AppString.nextPassage),
          );

    final seeAll = actualFilter != null ?
        ElevatedButton.icon(
          onPressed: removeFilter,
          icon: Icon(Icons.filter_alt_off),
          label: Text(AppString.seeAllLabel),
        ) : Container();

    final buttons = [
      seeAll,
      menuBtn,
      // btn(AppString.allSchedule, showTimetable),
      ElevatedButton.icon(
        onPressed: position != null ? goToRoute : null,
        icon: Icon(Icons.route),
        label: const Text(AppString.routeLabel),
      ),
      report == null ? buildReport() : Container(),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 5),
            blurRadius: 3,
            spreadRadius: -1
          )
        ]
      ),
      child: DefaultTextStyle.merge(
        child: Wrap(
          spacing: 5,
          verticalDirection: VerticalDirection.up,
          children: buttons,
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
        report != null ? buildReport() : Container(),
        buildHeader(),
        Expanded(
            child: Material(
                child: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: body ??
              NextPassageListWidget(
                station,
                actualFilter?.direction ?? direction,
                stopTimeSelected: widget.controller.setStopTime,
              ),
        )))
      ],
    );
  }
}
