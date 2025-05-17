import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/data_provider/radar_provider.dart';
import 'package:better_bus_v2/model/bus_line_color.dart';
import 'package:better_bus_v2/data_provider/app_provider.dart';
import 'package:better_bus_v2/views/common/close_cross.dart';
import 'package:better_bus_v2/views/common/directed_line.dart';
import 'package:better_bus_v2/views/common/report_infobox.dart';
import 'package:better_bus_v2/views/route_page/line_step_detail.dart';
import 'package:better_bus_v2/views/route_page/route_search.dart';
import 'package:better_bus_v2/views/stop_info/trip_view.dart';
import 'package:flutter/material.dart';
import 'package:format/format.dart';
import 'package:intl/intl.dart';

import '../../app_constant/app_string.dart';

class RouteDetail extends StatefulWidget {
  RouteDetail(
      {required this.route, required this.parameter, required this.onClose})
      : super(key: ObjectKey(route));

  final VitalisRoute route;
  final RouteSearchParameter parameter;
  final VoidCallback onClose;

  @override
  State<RouteDetail> createState() => RouteDetailState();
}

class RouteDetailState extends State<RouteDetail> {
  Map<Station, Timetable?> timeTable = {};
  Map<String, Station>? stations;
  Map<Station, Report> reports = {};
  late AppProvider provider;

  @override
  void initState() {
    super.initState();
    provider = AppProvider.of(context);
    getMoreDetails().onError((e, s) {
      print("Fuck error");
      print(e);
      print(s);
      return false;
    });
  }

  Future<bool> getMoreDetails() async {
    assert(provider.isAvailable());

    if (stations == null) await loadStation();
    assert(stations != null);
    print("Start geting more detail");

    for (var e in widget.route.itinerary) {
      if (e.lines == null) continue;
      final station = stations![e.startPlace];
      print(e.startPlace);
      print("Station $station");
      if (station == null) continue;
      timeTable[station] = null;
      print("Start getting timetable");
      provider.getTimetable(station, time: e.startTime).then((v) {
        print("Sucess get timetable");
        if (!mounted) return;
        setState(() {
          timeTable[station] = v;
        });
      },
      onError: (Object? e, st) {
        print("Failed to retrive timetable of $station");
        print(e);
        print(st);
      });
    }
    final r = await AppRadarProvider.of(context).getReports();
    reports.addEntries(r
        .where((e) => timeTable.containsKey(e.station))
        .map((e) => MapEntry(e.station, e)));
    if (mounted) setState(() {});

    return true;
  }

  Future loadStation() async {
    assert(stations == null);
    final rawStation = await provider.getStations();

    stations = {for (var e in rawStation) e.name: e};
  }

  Widget buildWalkStep(RoutePassage item) {
    assert(item.lines == null);
    // if (index == busRoute.itinerary.length -1) {
    //   title = Text("${AppString.walkToPlace} ${item.endPlace}", style: Theme.of(context).textTheme.titleLarge,);
    // } else {
    // }

    // final title = Text("${AppString.walkToStop} ${item.endPlace}", style: Theme.of(context).textTheme.titleLarge,);
    final title =
        "${item == widget.route.itinerary.last ? AppString.walkToPlace : AppString.walkToStop} "
        "${item.endPlace}";
    return buildRow(
      marge: const Icon(Icons.directions_walk),
      title: Text(title),
    );
  }

  static Widget timeWidget(String text, DateTime time) {
    return Text(text.format(DateFormat("Hm").format(time.toLocal())));
  }

  Widget buildLineStep(RoutePassage item) {
    assert(item.lines != null);
    final station = stations?[item.startPlace];
    final endStation = stations?[item.endPlace];
    List<StopTime>? times;
    if (station != null && endStation != null) {
      final next = timeTable[station]
          ?.getNext(from: item.startTime);
      print("Next lenght ${next?.length}");
      times = next?.where((e) =>
              e.trip != null &&
              e.trip!.followDirection(station, endStation) &&
              e.trip!.isPassingBy(station) &&
              e.trip!.isPassingBy(endStation) &&
              e.trip!.line.id == item.lines!.id)
          .toList();
    }
    print("Times lenght: ${times?.length}");
    final trip = times?.firstOrNull;
    final color = item.lines!.color;

    buildStop(String name) => Container(
          decoration: BoxDecoration(
              border: Border.all(color: color, width: 3),
              color: color.withAlpha(50),
              borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 3),
          child: Text(name),
        );

    final line = Expanded(
        child: Container(
      width: double.infinity,
      height: 3,
      color: color,
    ));

    Widget schema = Row(children: [
      buildStop(item.startPlace),
      line,
      buildStop(item.endPlace),
    ]);

    if (trip != null && trip.trip != null) {
      schema = TripView.fromRoute(item, trip.trip!, trip.delay);
    }


    return buildRow(
      marge: const Icon(Icons.directions_bus),
      title: LabeledLine(
        line: item.lines!,
        label: trip?.destination ?? item.endPlace,
      ),
      subTitle: RichText(text:TextSpan(
        style: TextStyle(color: Colors.black),
        children: [
          TextSpan(text: AppString.stopYouTo),
          TextSpan(text: item.endPlace,
          style: TextStyle(fontWeight: FontWeight.bold))
        ]
      )),
      body: Column(
        children: [
          station != null
              ? ReportInfobox(
                  station: station,
                  report: reports[station],
                )
              : Container(),
          schema,
          const SizedBox(
            height: 5,
          ),
          LineStepDetail(routeStep: item, times: times),
        ],
      ),
    );
  }

  Widget buildRow(
      {required Widget marge,
      required Widget title,
      Widget? subTitle,
      Widget? body,
      bool closeBtn = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 40,
                child: Center(child: marge),
              ),
              const SizedBox(width: 5),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle.merge(
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 15),
                    child: title,
                  ),
                  subTitle ?? Container(),
                ],
              )),
              if (closeBtn)
                CloseCross(
                  onTap: widget.onClose,
                )
              else
                Container()
            ],
          ),
          body ?? Container()
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, int i) {
    if (i == 0) return buildStart();
    i -= 1;
    if (i == widget.route.itinerary.length) return buildEnd();

    final item = widget.route.itinerary[i];
    if (item.lines == null) {
      return buildWalkStep(item);
    }
    return buildLineStep(item);
  }

  Widget buildStart() {
    final time = widget.route.itinerary.first.startTime;
    final from = widget.parameter.start!.name;
    return buildRow(
        marge: const Icon(Icons.flag, color: Colors.green),
        title: Text(from),
        subTitle: timeWidget(AppString.startAt, time),
        closeBtn: true);
  }

  Widget buildEnd() {
    final time = widget.route.itinerary.last.endTime;
    final to = widget.parameter.stop!.name;
    return buildRow(
      marge: const Icon(Icons.flag, color: Colors.red),
      title: timeWidget(AppString.endAt, time),
      subTitle: Text(to),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.parameter.valid);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.separated(
        itemBuilder: buildItem,
        separatorBuilder: (_, __) => const Divider(
          height: 5,
          color: Colors.black54,
        ),
        itemCount: widget.route.itinerary.length + 2,
      ),
    );
  }
}
