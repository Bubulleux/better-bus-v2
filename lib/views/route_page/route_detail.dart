import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/model/provider.dart';
import 'package:better_bus_v2/views/common/close_cross.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
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
  State<RouteDetail> createState() => _RouteDetailState();
}

class _RouteDetailState extends State<RouteDetail> {
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
      final station = stations![e.startPlace]!;
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
      children: [Text(title)],
    );
  }

  Widget buildLineStep(RoutePassage item) {
    assert(item.lines != null);
    final station = stations?[item.startPlace]!;
    final endStation = stations?[item.endPlace]!;
    const arrow = Expanded(child: Icon(Icons.keyboard_double_arrow_right));
    List<StopTime>? times;
    if (station != null && endStation != null) {
      times = timeTable[station]
          ?.getNext(from: item.startTime)
          .where((e) => e.trip != null && e.trip!.isPassingBy(station) && e.trip!.isPassingBy(endStation)
      && e.trip!.line.id == item.lines!.id)
          .toList();
    }

    Widget timeWidget(String text, DateTime time) {
      return Text(text.format(DateFormat("Hm").format(time.toLocal())));
    }

    return buildRow(
      marge: LineWidget(item.lines!, 35),
      children: [
        Row(
          children: [
            Text(item.startPlace),
            const Spacer(),
            Text(item.endPlace)
          ],
        ),
        Material(
          textStyle: TextStyle(
            color: Colors.black.withAlpha(170),
          ),
          child: Row(
            children: [
              timeWidget(AppString.aimedAt, item.startTime),
              arrow,
              timeWidget(AppString.arrivalAimedAt, item.endTime),
            ],
          ),
        ),
        station != null
            ? Row(
                children:
                    times?.map((e) => timeWidget("{}, ", e.time)).toList() ??
                        [],
              )
            : CircularProgressIndicator()
      ],
    );
  }

  Widget buildRow({required Widget marge, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Center(child: marge),
          ),
          const SizedBox(width: 5),
          Expanded(
              child: Material(
            textStyle: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          )),
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
    final time =
        DateFormat("Hm").format(widget.route.itinerary.first.startTime);
    final from = widget.parameter.start!.name;
    return buildRow(
      marge: const Icon(Icons.flag, color: Colors.green),
      children: [Text(from), Text(AppString.startAt.format(time))],
    );
  }

  Widget buildEnd() {
    final time =
        DateFormat("Hm").format(widget.route.itinerary.first.startTime);
    final to = widget.parameter.stop!.name;
    return buildRow(
      marge: const Icon(Icons.flag, color: Colors.red),
      children: [Text(AppString.endAt.format(time))],
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
