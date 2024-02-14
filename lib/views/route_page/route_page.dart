import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/error_handler/custom_error.dart';
import 'package:better_bus_v2/model/clean/route.dart';
import 'package:better_bus_v2/views/common/background.dart';
import 'package:better_bus_v2/views/common/custom_future.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:better_bus_v2/views/common/fake_text_field.dart';
import 'package:better_bus_v2/views/common/labeled_radio.dart';
import 'package:better_bus_v2/views/route_page/route_widget_item.dart';
import 'package:better_bus_v2/views/stops_search_page/place_searcher_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app_constant/app_string.dart';
import '../../model/clean/map_place.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({Key? key}) : super(key: key);
  static const String routeName = "/RouteFinder";

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  MapPlace? startPlace;
  MapPlace? endPlace;

  String timeType = "departure";

  DateTime routeDateTime = DateTime.now();

  GlobalKey<CustomFutureBuilderState<List<VitalisRoute>?>> futureBuilderKey =
      GlobalKey<CustomFutureBuilderState<List<VitalisRoute>?>>();

  getStartPlace() {
    getPlace().then((place) {
      if (place == null) {
        return;
      }
      setState(() {
        startPlace = place;
        futureBuilderKey.currentState!.refresh();
      });
    });
  }

  getStopPlace() {
    getPlace().then((place) {
      if (place == null) {
        return;
      }
      setState(() {
        endPlace = place;
        futureBuilderKey.currentState!.refresh();
      });
    });
  }

  Future<MapPlace?> getPlace() async {
    // ignore: unnecessary_cast
    MapPlace? place = await (Navigator.of(context).pushNamed(PlaceSearcherPage.routeName) as Future<dynamic>);
    return place;
  }

  void setRouteTime(String? value) {
    if (value == null) {
      return;
    }
    setState(() {
      timeType = value;
      futureBuilderKey.currentState!.refresh();
    });
  }

  void setTime() {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          child: Row(
            children: [
              CupertinoSlidingSegmentedControl(
                children: {
                  "arival" : Text(AppString.departureAt),
                  "departure" : Text(AppString.arrivalAt)
                },
                onValueChanged: (newValue) {
                setState(() {
                    timeType = newValue as String;
                  });
                },
                groupValue: timeType,
              )
            ],
          ),
        );
      }
    );
  }

  void setDate() {
    showDatePicker(
            context: context,
            initialDate: routeDateTime,
            firstDate: DateTime.now().subtract(const Duration(days: 4)),
            lastDate: DateTime.now().add(const Duration(days: 4)))
        .then((date) {
      if (date == null) {
        return;
      }
      setState(() {
        routeDateTime = date;
        futureBuilderKey.currentState!.refresh();
      });
    });
  }

  Future<List<VitalisRoute>?> getRoutes() async {
    if (startPlace == null || endPlace == null) {
      return null;
    }

    return await VitalisDataProvider.getVitalisRoute(
        startPlace!, endPlace!, routeDateTime, timeType);
  }

  String getTimeString() {
    if (routeDateTime.difference(DateTime.now()).isNegative) {
      return "Now";
    }
    return "Nan";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Background(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            width: double.infinity,
            child: Column(
              children: [
                Container(
                  decoration: CustomDecorations.of(context).boxBackground.copyWith(boxShadow: [
                    const BoxShadow(
                      color: Colors.grey,
                      spreadRadius: 2,
                      blurRadius: 7,
                    )
                  ]),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      FakeTextField(
                        onPress: getStartPlace,
                        backgroundColor: Theme.of(context).backgroundColor,
                        hint: AppString.startLabel,
                        prefixIcon: const Icon(
                          Icons.flag,
                          color: Colors.green,
                        ),
                        icon: Icons.search,
                        value: startPlace?.title,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      FakeTextField(
                        onPress: getStopPlace,
                        backgroundColor: Theme.of(context).backgroundColor,
                        hint: AppString.endLabel,
                        prefixIcon: const Icon(Icons.flag, color: Colors.red),
                        icon: Icons.search,
                        value: endPlace?.title,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      FakeTextField(
                        value: getTimeString(),
                        onPress: setTime,
                        prefixIcon: const Icon(Icons.access_time),
                        backgroundColor: Theme.of(context).backgroundColor,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 5,),
                Expanded(
                  child: Container(
                    decoration: CustomDecorations.of(context).boxBackground,
                    // padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: CustomFutureBuilder<List<VitalisRoute>?>(
                      key: futureBuilderKey,
                      future: getRoutes,
                      onData: (context, data, refresh) {
                        return ClipRRect(
                          borderRadius: CustomDecorations.borderRadius,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            itemBuilder: (context, index) => RouteItemWidget(data[index]),
                            itemCount: data!.length,
                          ),
                        );
                      },
                      errorTest: (data) {
                        if (data == null) {
                          return CustomErrors.routeInputError;
                        } else if (data!.isEmpty) {
                          return CustomErrors.routeResultEmpty;
                        }
                        return null;
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
