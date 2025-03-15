import 'dart:math';

import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/model/provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app_constant/app_string.dart';
import '../common/decorations.dart';
import '../common/fake_text_field.dart';
import '../stops_search_page/place_searcher_page.dart';
import 'route_time_picker.dart';

enum RouteTimeType { departure, arrival }

class RouteSearchParameter {
  final Place? start;
  final Place? stop;
  final RouteTimeType timeType;
  final DateTime time;

  bool get valid => start != null && stop != null;

  const RouteSearchParameter(this.start, this.stop, this.timeType, this.time);

  RouteSearchParameter copyWidth(
      {Place? start, Place? stop, RouteTimeType? timeType, DateTime? time}) {
    print("Copy with stop ${stop?.name}");
    return RouteSearchParameter(
      start ?? this.start,
      stop ?? this.stop,
      timeType ?? this.timeType,
      time ?? this.time,
    );
  }

  @override
  int get hashCode =>
      start.hashCode ^ stop.hashCode * 2 ^ time.hashCode ^ timeType.hashCode;

  @override
  bool operator ==(Object other) {
    return other is RouteSearchParameter && hashCode == other.hashCode;
  }
}

class RouteSearch extends StatefulWidget {
  const RouteSearch({required this.onSearch, super.key});

  final ValueChanged<RouteSearchParameter> onSearch;

  @override
  State<RouteSearch> createState() => _RouteSearchState();
}

class _RouteSearchState extends State<RouteSearch> {
  final search = ValueNotifier(RouteSearchParameter(
      null, null, RouteTimeType.departure, DateTime.now()));

  @override
  void initState() {
    super.initState();
    search.addListener(() {
      print(mounted);
      if (mounted) {
        widget.onSearch(search.value);
        print("Search changed");
        setState(() {});
      }
    });
    showFarestStation();
  }

  void getStartPlace() {
    getPlace().then((place) {
      if (place == null) {
        return;
      }
      search.value = search.value.copyWidth(start: place);
    });
  }

  void getStopPlace() {
    getPlace().then((place) {
      if (place == null) {
        return;
      }
      search.value = search.value.copyWidth(stop: place);
    });
  }

  Future<Place?> getPlace() async {
    // ignore: unnecessary_cast
    Place? place = await (Navigator.of(context)
        .pushNamed(PlaceSearcherPage.routeName) as Future<dynamic>);
    return place;
  }

  void swapDirection() {
    final v = search.value;
    search.value = v.copyWidth(start: v.stop, stop: v.start);
    print(search.value.stop?.name);
    print(v.start?.name);
    print("Swap");
  }

  void setTime() async {
    RouteSearchParameter newParameter = await showDialog(
        context: context, builder: (ctx) => RouteTimePicker(search.value));

    search.value = newParameter;
  }

  Future showFarestStation() async {
    print("Start");
    final station = await FullProvider.of(context).getStations();
    print("HAHHA");
    var a = station.first;
    var b = station.first;
    var maxDst = 0.0;
    for (var curA in station) {
      for (var curB in station) {
        final dst = curA.position.distance(curB.position);
        if (dst > maxDst) {
          maxDst = dst;
          a = curA;
          b = curB;
        }
        if (maxDst > 40) break;
      }
    }
    print("Fearest Stations : $a, $b, $maxDst");
  }

  String getTimeString() {
    final timeParameter = search.value;
    String timeTypeText = timeParameter.timeType == RouteTimeType.departure
        ? AppString.departureAt
        : AppString.arrivalAt;

    Duration diffNow = timeParameter.time.difference(DateTime.now());

    if (diffNow.inMinutes < 1 && !diffNow.isNegative) {
      return timeTypeText + " " + AppString.now;
    }

    Duration dayDiff =
        timeParameter.time.difference(DateTime.now().atMidnight());
    String dateText = DateFormat("EE d MMM", "fr").format(timeParameter.time);

    if (dayDiff.inDays == 0) {
      dateText = AppString.today;
    }
    if (dayDiff.inDays == 1) {
      dateText = AppString.tomorrow;
    }

    String timeText = DateFormat("HH:mm").format(timeParameter.time);
    return timeTypeText + " " + dateText + " à " + timeText;
  }

  @override
  Widget build(BuildContext context) {
    final v = search.value;
    return Container(
      // decoration:
      //     CustomDecorations.of(context).boxBackground.copyWith(boxShadow: [
      //   const BoxShadow(
      //     color: Colors.grey,
      //     spreadRadius: 2,
      //     blurRadius: 7,
      //   )
      // ]),
      color: Colors.black12,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  FakeTextField(
                    onPress: getStartPlace,
                    backgroundColor: Theme.of(context).colorScheme.background,
                    hint: AppString.startLabel,
                    prefixIcon: const Icon(
                      Icons.flag,
                      color: Colors.green,
                    ),
                    icon: Icons.search,
                    value: v.start?.name,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  FakeTextField(
                    onPress: getStopPlace,
                    backgroundColor: Theme.of(context).colorScheme.background,
                    hint: AppString.endLabel,
                    prefixIcon: const Icon(Icons.flag, color: Colors.red),
                    icon: Icons.search,
                    value: v.stop?.name,
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: swapDirection,
                style:
                    ElevatedButton.styleFrom(padding: const EdgeInsets.all(0)),
                child: const Icon(Icons.swap_vert, size: 20),
              )
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          FakeTextField(
            value: getTimeString(),
            onPress: setTime,
            prefixIcon: const Icon(Icons.access_time),
            icon: Icons.autorenew,
            backgroundColor: Theme.of(context).colorScheme.background,
          )
        ],
      ),
    );
  }
}
