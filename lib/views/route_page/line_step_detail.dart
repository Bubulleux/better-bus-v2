import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/views/common/directed_line.dart';
import 'package:better_bus_v2/views/common/extendable_view.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:better_bus_v2/views/common/report_infobox.dart';
import 'package:better_bus_v2/views/common/separator.dart';
import 'package:better_bus_v2/views/stop_info/delay_infobox.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


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
    final direction = stopTime?.destination ?? widget.routeStep.endPlace;
    final startTime = stopTime?.time ?? widget.routeStep.startTime;
    final delay = stopTime?.delay ?? Duration.zero;
    final endTime = widget.routeStep.endTime
        .add(stopTime?.time.difference(startTime) ?? Duration.zero);
    format(DateTime time) => Text(DateFormat("Hm").format(time.toLocal()));
    const arrow = Expanded(child: Icon(Icons.keyboard_arrow_right));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 5),
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: const BoxDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              format(startTime),
              arrow,
              LabeledLine(line: line, label: direction, size: 14,),
              arrow,
              format(endTime)
            ],
          ),
          DelayInfobox(
            stopTime: stopTime,
            fontSize: 14,
            //height: 30,
          ),
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

    return Material(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          // color: const Color(0xffeeeeee),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 1,
              spreadRadius: 2,
              offset: Offset(1, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: controller.tickAnimation,
          child: Column(
            children: [
              // TODO : To it this wey Every where !!!!
              DefaultTextStyle.merge(
                style: const TextStyle(fontWeight: FontWeight.bold),
                child: timesWidget.first,
              ),
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
      ),
    );
  }
}
