import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/model/bus_line_color.dart';
import 'package:better_bus_v2/model/provider.dart';
import 'package:better_bus_v2/views/common/close_cross.dart';
import 'package:better_bus_v2/views/common/directed_line.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:better_bus_v2/views/route_page/line_step_detail.dart';
import 'package:better_bus_v2/views/route_page/route_search.dart';
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
  late FullProvider provider;

  @override
  void initState() {
    super.initState();
    provider = FullProvider.of(context);
    getRealtimes().then((v) => print("Realtimes : $v"));
  }

  Future<bool> getRealtimes() async {
    assert(provider.isAvailable());

    if (!provider.api.isAvailable()) return false;
    if (stations == null) await loadStation();
    assert(stations != null);

    for (var e in widget.route.itinerary) {
      if (e.lines == null) continue;
      final station = stations![e.startPlace];
      if (station == null) continue;
      timeTable[station] = null;

      provider.getTimetable(station).then((v) {
        if (!mounted) return;
        setState(() {
          timeTable[station] = v;
        });
      });
    }
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
      marge: Icon(Icons.directions_walk),
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
      times = timeTable[station]
          ?.getNext(from: item.startTime)
          .where((e) =>
              e.trip != null &&
              e.trip!.isPassingBy(station) &&
              e.trip!.isPassingBy(endStation) &&
              e.trip!.line.id == item.lines!.id &&
              e.isRealTime)
          .toList();
    }
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

    final schema = Row(children: [
      buildStop(item.startPlace),
      line,
      buildStop(item.endPlace),
    ]);

    final instruction = item.instruction;

    return buildRow(
      marge: Icon(Icons.directions_bus),
      title: LabeledLine(line: item.lines!, label: trip?.destination ?? item.endPlace,),
      subTitle: Text(instruction),
      body: Column(
        children: [
          schema,
          SizedBox(height: 5,),
          LineStepDetail(routeStep: item, times: times),
        ],
      ),
    );
  }

  Widget buildRow(
      {required Widget marge, required Widget title, Widget? subTitle, Widget? body}) {
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
    );
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: CloseCross(onTap: widget.onClose),
          ),
          Expanded(
            child: ListView.separated(
              itemBuilder: buildItem,
              separatorBuilder: (_, __) => const Divider(
                height: 5,
                color: Colors.black54,
              ),
              itemCount: widget.route.itinerary.length + 2,
            ),
          ),
        ],
      ),
    );
  }
}
