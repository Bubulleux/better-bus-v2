import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/error_handler/custom_error.dart';
import 'package:better_bus_v2/model/clean/route.dart';
import 'package:better_bus_v2/views/common/background.dart';
import 'package:better_bus_v2/views/common/custom_futur.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:better_bus_v2/views/common/fake_textfiel.dart';
import 'package:better_bus_v2/views/common/labeled_radio.dart';
import 'package:better_bus_v2/views/route_page/route_widget_item.dart';
import 'package:better_bus_v2/views/stops_search_page/place_searcher_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app_constante/AppString.dart';
import '../../model/clean/map_place.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({Key? key}) : super(key: key);

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  MapPlace? startPlace;
  MapPlace? endPlace;

  String timeType = "departure";

  TimeOfDay routeTimeOfDay = TimeOfDay.now();
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
    MapPlace? place = await Navigator.push(context, MaterialPageRoute(builder: (context) => const PlaceSearcherPage()));
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
    showTimePicker(
      context: context,
      initialTime: routeTimeOfDay,
    ).then((output) {
      if (output == null) {
        return;
      }
      setState(() {
        routeTimeOfDay = output;
        futureBuilderKey.currentState!.refresh();
      });
    });
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
    String date = DateFormat("dd-MM-yyyy").format(routeDateTime) + " ${routeTimeOfDay.hour}:${routeTimeOfDay.minute}";

    return await VitalisDataProvider.getVitalisRoute(
        startPlace!, endPlace!, DateFormat("dd-MM-yyyy HH:mm").parse(date), timeType);
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
                      Row(
                        children: [
                          Row(
                            children: [
                              LabeledRadio<String>(
                                value: "departure",
                                groupValue: timeType,
                                onChanged: setRouteTime,
                                label: AppString.departureAt,
                              ),
                              LabeledRadio<String>(
                                value: "arrival",
                                groupValue: timeType,
                                onChanged: setRouteTime,
                                label: AppString.arrivalAt,
                              ),
                            ],
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: ElevatedButton(
                              child: Row(
                                children: [
                                  Text(
                                    routeTimeOfDay.format(context),
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Icon(Icons.edit)
                                ],
                              ),
                              onPressed: setTime,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text(AppString.routeWhenDate),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              child: Row(
                                children: [
                                  Text(
                                    DateFormat("dd/MM/yy").format(routeDateTime),
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Icon(Icons.edit)
                                ],
                              ),
                              onPressed: setDate,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5,),
                Expanded(
                  child: Container(
                    decoration: CustomDecorations.of(context).boxBackground,
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: CustomFutureBuilder<List<VitalisRoute>?>(
                      key: futureBuilderKey,
                      future: getRoutes,
                      onData: (context, data, refresh) {
                        return ListView.builder(
                          itemBuilder: (context, index) => RouteItemWidget(data[index]),
                          itemCount: data!.length,
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
