import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/core/full_provider.dart';
import 'package:better_bus_v2/core/models/bus_line.dart';
import 'package:better_bus_v2/core/models/bus_trip.dart';
import 'package:better_bus_v2/core/models/station.dart';
import 'package:better_bus_v2/core/models/stop_time.dart';
import 'package:better_bus_v2/core/models/timetable.dart';
import 'package:better_bus_v2/error_handler/custom_error.dart';
import 'package:better_bus_v2/helper.dart';
import 'package:better_bus_v2/views/common/custom_future.dart';
import 'package:better_bus_v2/views/common/extendable_view.dart';
import 'package:better_bus_v2/views/common/informative_box.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:flutter/material.dart';
import 'package:format/format.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class NextPassagePage extends StatefulWidget {
  const NextPassagePage(this.stop, {this.lines, this.minimal = false, super.key});

  final Station stop;
  final List<BusLine>? lines;
  final bool minimal;

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
    if (widget.lines == null || widget.minimal) {
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
                seeAll && !widget.minimal ? null : widget.lines,
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
  const NextPassageListWidget(this.stop, this.lines, {super.key});

  final Station stop;
  final List<BusLine>? lines;

  @override
  State<NextPassageListWidget> createState() => NextPassageListWidgetState();
}

class NextPassageListWidgetState extends State<NextPassageListWidget> {
  final GlobalKey<CustomFutureBuilderState<List<StopTime>>>
      futureBuilderKey =
      GlobalKey<CustomFutureBuilderState<List<StopTime>>>();

  void refresh() {
    futureBuilderKey.currentState!.refresh();
  }

  Future<List<StopTime>> getData() async {
    Timetable timetable =
        await FullProvider.of(context).getTimetable(widget.stop);
    List<StopTime> result = timetable.getNext().toList();
    // TODO: Re implement filter
    // if (widget.lines != null) {
    //   result.removeWhere((element) {
    //     for (BusLine line in widget.lines!) {
    //       if (line.id == element.line.id &&
    //           (line.goDirection.contains(element.destination) ||
    //               line.backDirection.contains(element.destination))) {
    //         return false;
    //       }
    //     }
    //     return true;
    //   });
    // }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return CustomFutureBuilder<List<StopTime>>(
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
  const NextPassageWidget(this.nextPassage, {super.key});

  final StopTime nextPassage;

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
    print("Trip: ${widget.nextPassage.trip}");
  }

  Widget buildNextPassageDetail(Duration delay) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          delay.abs().inMinutes >= 1
              ? InfoBox(
                  width: double.infinity,
                  color: delay.isNegative ? Colors.red : Colors.orange,
                  margin: const EdgeInsets.all(5),
                  icon: Icons.warning_amber,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        delay.isNegative
                            ? AppString.advanceOf.format(delay.abs().inMinutes)
                            : AppString.lateOf.format(delay.abs().inMinutes),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                          AppString.initialTime.format(DateFormat.Hm().format(widget.nextPassage.aimedTime)),
                        textScaler: const TextScaler.linear(0.8),
                      )
                    ],
                  ),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: (widget.nextPassage.trip?.stopTimes.length ?? -1) + 1,
                itemBuilder: (_, i) =>
                    ((widget.nextPassage.trip?.stopTimes.length ?? 0) == i)
                        ? buildLineEnd()
                        : buildWayItem(i, delay),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildLineEnd() {
    return const SizedBox(
      width: 70,
      height: double.infinity,
    );
  }

  Widget buildWayItem(int index, Duration delay) {
    BusTrip? trip = widget.nextPassage.trip;
    if (trip == null) return Container();
    TripStop stopTime = trip.stopTimes[index];
    String stopName = stopTime.station.name;
    DateTime arrivalTime = stopTime.time.add(delay);

    return SizedBox(
      width: 50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 40,
            child: OverflowBox(
              maxHeight: 65,
              maxWidth: 30,
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: 70,
                child: Transform.rotate(
                  angle:  pi * .30,
                  alignment: Alignment.bottomCenter,
                  child: RotatedBox(
                    quarterTurns: -1,
                    child: FittedBox(
                      //alignment: Alignment.centerRight,
                      fit: BoxFit.scaleDown,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 120),
                          child: Text(stopName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              )),
                        )),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SizedBox(
              height: 20,
              child: Row(
                //alignment: Alignment.center,
                children: [
                  Expanded(
                    child: Container(
                      height: 5,
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        color: widget.nextPassage.line.color,
                      ),
                    ),
                  ),
                  Container(
                      height: 20,
                      padding: const EdgeInsets.all(3),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: widget.nextPassage.line.color.withAlpha(80),
                        borderRadius: BorderRadiusDirectional.circular(10),
                        border: Border.all(
                            width: 2, color: widget.nextPassage.line.color),
                      ),
                      child: Text(DateFormat.Hm().format(arrivalTime.toLocal()),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ))
                      // child: RichText(
                      //     text: TextSpan(
                      //   style: DefaultTextStyle.of(context).style,
                      //   children: [
                      //     TextSpan(
                      //       text: arrivalTime.hour.toString().padLeft(2, '0') + ":",
                      //       style: const TextStyle(
                      //         fontSize: 8,
                      //         fontWeight: FontWeight.w700,
                      //       ),
                      //     ),
                      //     TextSpan(
                      //       text: arrivalTime.minute.toString().padLeft(2, '0'),
                      //       ),
                      //     )
                      //   ],
                      // )),
                      ),
                ],
              ),
            ),
          ),
          // const SizedBox(
          //   width: 10,
          // ),
          // ClipRect(
          // )
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
        DateFormat.Hm().format(widget.nextPassage.time.toLocal());
    Duration arrivalDuration =
        widget.nextPassage.time.difference(DateTime.now());
    String minuteToWait = (arrivalDuration.inHours >= 1
            ? "${arrivalDuration.inHours} h "
            : "") +
        "${widget.nextPassage.time.difference(DateTime.now()).inMinutes % 60} min";
    Duration delay =
        widget.nextPassage.time.difference(widget.nextPassage.aimedTime);
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
                  child: widget.nextPassage.isRealTime
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
