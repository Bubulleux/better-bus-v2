import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/error_handler/custom_error.dart';
import 'package:better_bus_v2/model/clean/route.dart';
import 'package:better_bus_v2/views/common/background.dart';
import 'package:better_bus_v2/views/common/custom_future.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:better_bus_v2/views/common/fake_text_field.dart';
import 'package:better_bus_v2/views/common/labeled_radio.dart';
import 'package:better_bus_v2/views/common/segmentedChoices.dart';
import 'package:better_bus_v2/views/route_page/route_time_picker.dart';
import 'package:better_bus_v2/views/route_page/route_widget_item.dart';
import 'package:better_bus_v2/views/stops_search_page/place_searcher_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app_constant/app_string.dart';
import '../../model/clean/map_place.dart';

enum RouteTimeType{
  departure,
  arival
}

class RouteTimeParameter {
  RouteTimeType timeType;
  DateTime time;

  RouteTimeParameter(this.timeType, this.time);
}

class RoutePage extends StatefulWidget {
  const RoutePage({Key? key}) : super(key: key);
  static const String routeName = "/RouteFinder";

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  MapPlace? startPlace;
  MapPlace? endPlace;

  RouteTimeParameter timeParameter = RouteTimeParameter(RouteTimeType.departure,
    DateTime.now());

  GlobalKey<CustomFutureBuilderState<List<VitalisRoute>?>> futureBuilderKey =
      GlobalKey<CustomFutureBuilderState<List<VitalisRoute>?>>();

  void getStartPlace() {
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

  void getStopPlace() {
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


  Future<List<VitalisRoute>?> getRoutes() async {
    if (startPlace == null || endPlace == null) {
      return null;
    }

    return await VitalisDataProvider.getVitalisRoute(
        startPlace!, endPlace!, timeParameter.time, timeParameter.timeType.name);
  }

  void setTime() async {
    RouteTimeParameter newParameter = 
      await showDialog(context: context, builder: (ctx) => RouteTimePicker(timeParameter));

    setState(() {
          timeParameter = newParameter;
          futureBuilderKey.currentState!.refresh();
        });

  }

  String getTimeString() {
    String timeTypeText = timeParameter.timeType == RouteTimeType.departure ?
      AppString.departureAt : AppString.arrivalAt;

    Duration diffNow = timeParameter.time.difference(DateTime.now());
    
    if (diffNow.inMinutes < 1) {
      return timeTypeText + " " + AppString.now;
    }

    String dateText = DateFormat("EE d MMM", "fr").format(timeParameter.time);

    String timeText = DateFormat("HH:mm").format(timeParameter.time);
    return timeTypeText + " " + dateText + " à " + timeText;
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
