import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/model/provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app_constant/app_string.dart';
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

  RouteSearchParameter.nowToPlace(Place place)
      : this(null, place, RouteTimeType.departure, DateTime.now());

  RouteSearchParameter copyWidth(
      {Place? start, Place? stop, RouteTimeType? timeType, DateTime? time}) {
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
  const RouteSearch({required this.onSearch, this.parameter, super.key});

  final ValueChanged<RouteSearchParameter> onSearch;
  final RouteSearchParameter? parameter;

  @override
  State<RouteSearch> createState() => _RouteSearchState();
}

class _RouteSearchState extends State<RouteSearch> {
  late ValueNotifier<RouteSearchParameter> search;

  @override
  void initState() {
    super.initState();
    newNotifier(RouteSearchParameter(
        null, null, RouteTimeType.departure, DateTime.now()));
  }

  void newNotifier(RouteSearchParameter value) {
    search = ValueNotifier(value);
    search.addListener(() {
      if (mounted) {
        widget.onSearch(search.value);
        setState(() {});
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.parameter != null) {
      newNotifier(widget.parameter!);
    }
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
    if (!v.valid) return;
    search.value = v.copyWidth(start: v.stop, stop: v.start);
  }

  void setTime() async {
    RouteSearchParameter newParameter = await showDialog(
        context: context, builder: (ctx) => RouteTimePicker(search.value));

    search.value = newParameter;
  }

  String getTimeString() {
    final timeParameter = search.value;
    String timeTypeText = timeParameter.timeType == RouteTimeType.departure
        ? AppString.departureAt
        : AppString.arrivalAt;

    Duration diffNow = timeParameter.time.difference(DateTime.now());

    if (diffNow.inMinutes < 1 && !diffNow.isNegative) {
      return "$timeTypeText ${AppString.now}";
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
    return "$timeTypeText $dateText à $timeText";
  }

  @override
  Widget build(BuildContext context) {
    final v = search.value;
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Flexible(
            flex: 5,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: FakeTextField(
                        onPress: getStartPlace,
                        hint: AppString.startLabel,
                        prefixIcon: const Icon(
                          Icons.flag,
                          color: Colors.green,
                        ),
                        icon: Icons.search,
                        value: v.start?.name,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Expanded(
                      child: FakeTextField(
                        onPress: getStopPlace,
                        hint: AppString.endLabel,
                        prefixIcon: const Icon(Icons.flag, color: Colors.red),
                        icon: Icons.search,
                        value: v.stop?.name,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: swapDirection,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(0)),
                  child: const Icon(Icons.swap_vert, size: 20),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Flexible(
            flex: 2,
            child: FakeTextField(
              value: getTimeString(),
              onPress: setTime,
              prefixIcon: const Icon(Icons.access_time),
              icon: Icons.autorenew,
              small : true,
            ),
          )
        ],
      ),
    );
  }
}
