import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:better_bus_v2/views/common/extendable_view.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:better_bus_v2/views/common/separator.dart';
import 'package:better_bus_v2/views/route_page/route_detail.dart';
import 'package:better_bus_v2/views/stop_info/delay_infobox.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import '../../app_constant/app_string.dart';

class LineStepDetail extends StatefulWidget {
  const LineStepDetail({required this.routeStep, this.times, super.key});

  final RoutePassage routeStep;
  final List<StopTime>? times;

  // final Map<String, Station>? stations;
  // final Timetable? timetable;

  @override
  State<LineStepDetail> createState() => _LineStepDetailState();
}

class _LineStepDetailState extends State<LineStepDetail>
    with SingleTickerProviderStateMixin {
  late final ExpandableWidgetController controller;

  @override
  void initState() {
    super.initState();
    controller = ExpandableWidgetController(root: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget buildTimeRow(StopTime? stopTime) {
    final line = stopTime?.line ?? widget.routeStep.lines!;
    final startTime = stopTime?.time ?? widget.routeStep.startTime;
    final delay = stopTime?.delay ?? Duration.zero;
    final endTime = widget.routeStep.endTime
        .add(stopTime?.time.difference(startTime) ?? Duration.zero);
    format(DateTime time) => Text(DateFormat("Hm").format(time.toLocal()));
    const arrow = Expanded(child: Icon(Icons.keyboard_arrow_right));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              format(startTime),
              arrow,
              LineWidget(line, 20),
              arrow,
              format(endTime)
            ],
          ),
          DelayInfobox(stopTime: stopTime, height: 30,),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.routeStep;
    assert(item.lines != null);
    final times = widget.times;
    List<Widget>? timesWidget = times?.map(buildTimeRow).toList();
    if (timesWidget == null || timesWidget.isEmpty) {
      timesWidget = [buildTimeRow(null)];
    }

    return InkWell(
      onTap: controller.tickAnimation,
      child: Column(
        children: [
          Row(
            children: [
              Text(item.startPlace),
              const Spacer(),
              Text(item.endPlace)
            ],
          ),
          Material(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black12,
              ),
              child: Column(
                children: [
                  timesWidget.first,
                  Material(
                    color: Colors.transparent,
                    child: ExpandableWidget(
                      controller: controller,
                      child: Column(
                        children: times != null
                            ? timesWidget
                                .skip(1)
                                .separate(const Divider(thickness: 2),
                                    before: true)
                                .toList()
                            : [],
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
