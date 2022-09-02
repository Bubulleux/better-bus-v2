import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/model/clean/route.dart';
import 'package:better_bus_v2/views/common/background.dart';
import 'package:better_bus_v2/views/common/custom_futur.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:better_bus_v2/views/common/fake_textfiel.dart';
import 'package:better_bus_v2/views/place_search_page/place_search_page.dart';
import 'package:better_bus_v2/views/route_page/route_widget_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/clean/map_place.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({Key? key}) : super(key: key);

  @override
  State<RoutePage> createState() => _RoutePageState();
}

enum RouteTime { startAt, ArriveAt }

class _RoutePageState extends State<RoutePage> {

  MapPlace? startPlace;
  MapPlace? endPlace;

  RouteTime? routeTime;

  TimeOfDay routeTimeOfDay = TimeOfDay.now();
  DateTime routeDateTime = DateTime.now();

  GlobalKey<CustomFutureBuilderState<List<VitalisRoute>?>> futureBuilderKey = GlobalKey<CustomFutureBuilderState<List<VitalisRoute>?>>();

  getStartPlace() {
    getPlace().then((place) {
      if (place == null) {
        return;
      }
      setState(() {
        startPlace = place;
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
      });
    });
  }


  Future<MapPlace?> getPlace() async {
    MapPlace? place = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => PlaceSearchPage())
    );
    return place;
  }

  void setRouteTime(RouteTime? value) {
    setState(() {
      routeTime = value;
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
      });
    }
    );
  }

  void setDate() {
    showDatePicker(context: context,
        initialDate: routeDateTime,
        firstDate: DateTime.now().subtract(const Duration(days: 4)),
        lastDate: DateTime.now().add(const Duration(days: 4))
    ).then((date) {
      if (date == null) {
        return;
      }
      setState(() {
        routeDateTime = date;
      });
    });
  }

  Future<List<VitalisRoute>?> getRoutes() async {
    if (startPlace == null || endPlace == null || routeTime == null) {
      return null;
    }
    String date = DateFormat("dd-MM-yyyy").format(routeDateTime) + " ${routeTimeOfDay.hour}:${routeTimeOfDay.minute}";

    return await VitalisDataProvider.getVitalisRoute(
        startPlace!, endPlace!, DateFormat("dd-MM-yyyy HH:mm").parse(date), routeTime == RouteTime.ArriveAt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Background(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            width: double.infinity,
            child: Column(
              children: [
                FakeTextField(
                  onPress: getStartPlace,
                  backgroundColor: Theme
                      .of(context)
                      .backgroundColor,
                  hint: "! Depart",
                  prefixIcon: Icon(Icons.flag, color: Colors.green,),
                  icon: Icons.search,
                  value: startPlace?.title,
                ),
                SizedBox(height: 5,),
                FakeTextField(
                  onPress: getStopPlace,
                  backgroundColor: Theme
                      .of(context)
                      .backgroundColor,
                  hint: "! Arivée",
                  prefixIcon: Icon(Icons.flag, color: Colors.red),
                  icon: Icons.search,
                  value: endPlace?.title,
                ),
                Row(
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            Radio<RouteTime>(
                              value: RouteTime.startAt,
                              groupValue: routeTime,
                              onChanged: setRouteTime,
                            ),
                            const Text("! Partir à"),
                          ],
                        ),
                        Row(
                          children: [
                            Radio<RouteTime>(
                              value: RouteTime.ArriveAt,
                              groupValue: routeTime,
                              onChanged: setRouteTime,
                            ),
                            const Text("! Arriver à"),
                          ],
                        ),
                      ],
                    ),
                    Spacer(),
                    Text(routeTimeOfDay.format(context)),
                    TextButton(onPressed: setTime, child: Icon(Icons.access_time_filled))
                  ],
                ),
                Row(
                  children: [
                    Text("! Quand?"),
                    Spacer(),
                    Text(DateFormat("dd/MM/yy").format(routeDateTime)),
                    TextButton(onPressed: setDate, child: Icon(Icons.change_circle))
                  ],
                ),
                TextButton(onPressed: () {
                  futureBuilderKey.currentState!.refresh();
                  getRoutes().then((value) {
                    if (value == null) {return;}
                    print(value.length);
                  }
                  );
                }, child: Text("Refresh")),
                Expanded(
                  child: CustomFutureBuilder<List<VitalisRoute>?>(
                    key: futureBuilderKey,
                    future: getRoutes,
                    onData: (context, data, refresh) {
                      if (data == null){
                        return Container();
                      }
                      print("Route Found: ${data.length}");
                      return ListView.builder(
                        itemBuilder: (context, index) => RouteItemWidget(data[index]),
                        itemCount: data!.length,
                      );
                    },
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
