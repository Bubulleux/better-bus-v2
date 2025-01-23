import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/error_handler/custom_error.dart';
import 'package:better_bus_v2/helper.dart';
import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/views/common/custom_future.dart';
import 'package:better_bus_v2/views/common/extendable_view.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:format/format.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import '../../model/clean/bus_line.dart';
import '../../model/clean/next_passage.dart';

class NextPassagePage extends StatefulWidget {
  const NextPassagePage(this.stop, {this.lines, Key? key}) : super(key: key);

  final BusStop stop;
  final List<BusLine>? lines;

  @override
  State<NextPassagePage> createState() => _NextPassagePageState();
}

class _NextPassagePageState extends State<NextPassagePage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  bool seeAll = false;
  late AnimationController seeAllAnimationController;
  late Animation<double> seeAllBtnAnimation;

  GlobalKey<NextPassageListWidgetState> nextPassageWidgetKey =
      GlobalKey<NextPassageListWidgetState>();

  @override
  void initState() {
    super.initState();
    if (widget.lines == null) {
      seeAll = true;
    }
    seeAllAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    seeAllBtnAnimation = CurvedAnimation(
        parent: seeAllAnimationController, curve: Curves.easeOut);
    seeAllAnimationController.value = seeAll ? 0 : 1;
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            SizeTransition(
              sizeFactor: seeAllBtnAnimation,
              axisAlignment: 1,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ElevatedButton(
                  onPressed: () {
                    seeAll = true;
                    seeAllAnimationController.reverse();
                    nextPassageWidgetKey.currentState!.refresh();
                    setState(() {});
                  },
                  child: const Text(AppString.seeAllLabel),
                ),
              ),
            ),
            Expanded(
              child: NextPassageListWidget(
                widget.stop,
                seeAll ? null : widget.lines,
                key: nextPassageWidgetKey,
              ),
            ),
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}

class NextPassageListWidget extends StatefulWidget {
  const NextPassageListWidget(this.stop, this.lines, {Key? key})
      : super(key: key);

  final BusStop stop;
  final List<BusLine>? lines;

  @override
  State<NextPassageListWidget> createState() => NextPassageListWidgetState();
}

class NextPassageListWidgetState extends State<NextPassageListWidget> {
  final GlobalKey<CustomFutureBuilderState<List<NextPassage>>>
      futureBuilderKey =
      GlobalKey<CustomFutureBuilderState<List<NextPassage>>>();

  void refresh() {
    futureBuilderKey.currentState!.refresh();
  }

  Future<List<NextPassage>> getData() async {
    List<NextPassage> result =
        await VitalisDataProvider.getNextPassage(widget.stop);
    if (widget.lines != null) {
      result.removeWhere((element) {
        for (BusLine line in widget.lines!) {
          if (line.id == element.line.id &&
              (line.goDirection.contains(element.destination) ||
                  line.backDirection.contains(element.destination))) {
            return false;
          }
        }
        return true;
      });
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return CustomFutureBuilder<List<NextPassage>>(
      future: getData,
      key: futureBuilderKey,
      onData: (context, data, refresh) {
        return ListView.separated(
          itemCount: data.length,
          itemBuilder: (context, index) => NextPassageWidget(data[index]),
          separatorBuilder: (ctx, index) =>
              const Divider(height: 3, color: Colors.black38),
        );
      },
      onError: (context, error, refresh) {
        return error.build(context, refresh);
      },
      refreshIndicator: (context, child, refresh) {
        return RefreshIndicator(child: child, onRefresh: refresh);
      },
      errorTest: (data) {
        if (data.isEmpty) {
          return CustomErrors.emptyNextPassage;
        }
        return null;
      },
      automaticRefresh: const Duration(seconds: 30),
    );
  }
}

class NextPassageWidget extends StatefulWidget {
  const NextPassageWidget(this.nextPassage, {Key? key}) : super(key: key);

  final NextPassage nextPassage;

  @override
  State<NextPassageWidget> createState() => _NextPassageWidgetState();
}

class _NextPassageWidgetState extends State<NextPassageWidget>
    with SingleTickerProviderStateMixin {
  late ExpandableWidgetController expandControler;

  @override
  void initState() {
    super.initState();
    expandControler = ExpandableWidgetController(
        duration: const Duration(milliseconds: 300), root: this);
  }

  Widget buildNextPassageDetail(Duration delay) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          delay.abs().inMinutes >= 2
              ? Text(delay.isNegative
                  ? AppString.advanceOf.format(delay.abs().inMinutes)
                  : AppString.lateOf.format(delay.abs().inMinutes))
              : Container(),
          // Text(widget.nextPassage.aimedTime.toLocal().toString()),
          // Text(widget.nextPassage.expectedTime.toLocal().toString()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 148,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.nextPassage.arrivingTimes.length,
                itemBuilder: (_, i) => buildWayItem(i, delay, i == widget.nextPassage.arrivingTimes.length - 1),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildWayItem(int index, Duration delay, bool last) {
    ArrivingTime arrival = widget.nextPassage.arrivingTimes[index];
    String stopName = arrival.stop;
    DateTime arrivalTime = DateTime.now().atMidnight().add(arrival.duration).add(delay);
    return SizedBox(
      width: last ? 70 : 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Transform.rotate(
              angle: pi * 0.25,
              alignment: Alignment.bottomCenter,
              child: RotatedBox(
                  quarterTurns: -1,
                  child: Container(
                    width: 100,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                          stopName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
              )
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SizedBox(
              height: 20,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 5,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: widget.nextPassage.line.color,
                    ),
                  ),
                  Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: widget.nextPassage.line.color,
                      borderRadius: BorderRadiusDirectional.circular(10),
                      border: Border.all(width: 1, color: Colors.black38),
                    ),
                  )
                ],
              ),
            ),
          ),
          // const SizedBox(
          //   width: 10,
          // ),
          RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: [
              TextSpan(
                text: arrivalTime.hour.toString().padLeft(2, '0') + ":",
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: arrivalTime.minute.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ))
          // const SizedBox(
          //   width: 10,
          // ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime =
        DateFormat.Hm().format(widget.nextPassage.expectedTime.toLocal());
    Duration arrivalDuration =
        widget.nextPassage.expectedTime.difference(DateTime.now());
    String minuteToWait = (arrivalDuration.inHours >= 1
            ? "${arrivalDuration.inHours} h "
            : "") +
        "${widget.nextPassage.expectedTime.difference(DateTime.now()).inMinutes % 60} min";
    Duration delay = widget.nextPassage.expectedTime
        .difference(widget.nextPassage.aimedTime);
    return InkWell(
      onTap: expandControler.tickAnimation,
      child: Container(
        // height: 55,
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
        child: Column(
          children: [
            Row(
              children: [
                LineWidget(widget.nextPassage.line, 45),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      widget.nextPassage.destination,
                      style: Theme.of(context).textTheme.headlineSmall,
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                ),
                Container(
                  child: widget.nextPassage.realTime
                      ? const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.wifi,
                            size: 20,
                          ),
                        )
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        minuteToWait,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formattedTime,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                )
              ],
            ),
            ExpandableWidget(
              controller: expandControler,
              child: buildNextPassageDetail(delay),
            )
          ],
        ),
      ),
    );
  }
}
