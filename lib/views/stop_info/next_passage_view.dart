import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/error_handler/custom_error.dart';
import 'package:better_bus_v2/views/common/custom_future.dart';
import 'package:better_bus_v2/views/common/extendable_view.dart';
import 'package:better_bus_v2/views/common/informative_box.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:better_bus_v2/views/stop_info/delay_infobox.dart';
import 'package:better_bus_v2/views/stop_info/trip_view.dart';
import 'package:flutter/material.dart';
import 'package:format/format.dart';
import 'package:intl/intl.dart';
import '../../model/provider.dart';

class NextPassagePage extends StatefulWidget {
  const NextPassagePage(this.stop,
      {this.direction, this.minimal = false, this.stopTimeSelected, super.key});

  final Station stop;
  final List<LineDirection>? direction;
  final bool minimal;
  // TODO: There is a better way
  final ValueChanged<StopTime>? stopTimeSelected;

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
    if (widget.direction == null || widget.minimal) {
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
                seeAll && !widget.minimal ? null : widget.direction,
                key: nextPassageWidgetKey,
                stopTimeSelected: widget.stopTimeSelected,
              ),
            ),
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}

class NextPassageListWidget extends StatefulWidget {
  const NextPassageListWidget(this.stop, this.direction,
      {this.stopTimeSelected, super.key});

  final Station stop;
  final List<Direction>? direction;
  final ValueChanged<StopTime>? stopTimeSelected;

  @override
  State<NextPassageListWidget> createState() => NextPassageListWidgetState();
}

class NextPassageListWidgetState extends State<NextPassageListWidget> {
  final GlobalKey<CustomFutureBuilderState<List<StopTime>>> futureBuilderKey =
      GlobalKey<CustomFutureBuilderState<List<StopTime>>>();

  late final FullProvider provider;

  @override
  void initState() {
    super.initState();
    provider = FullProvider.of(context);
  }

  void refresh() {
    futureBuilderKey.currentState!.refresh();
  }

  Future<List<StopTime>> getData() async {
    Timetable timetable = await provider.getTimetable(widget.stop);
    List<StopTime> result = timetable.getNext().toList();
    if (widget.direction != null) {
      result.retainWhere((e) => widget.direction!.contains(e.direction));
    }

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
          itemBuilder: (context, index) => NextPassageWidget(
            data[index],
            onOpen: () => widget.stopTimeSelected?.call(data[index]),
          ),
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
        print("Error test");
        print(data);
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
  const NextPassageWidget(this.nextPassage, {this.onOpen, super.key});

  final StopTime nextPassage;
  final VoidCallback? onOpen;

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
          DelayInfobox(stopTime: widget.nextPassage),
          widget.nextPassage.trip != null
              ? TripView(widget.nextPassage.trip!, delay: delay)
              : Container()
        ],
      ),
    );
  }

  void handleTap() {
    if (!expandControler.expanded) {
      widget.onOpen?.call();
    }
    expandControler.tickAnimation();
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
      onTap: handleTap,
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
