import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/data_provider/gps_data_provider.dart';
import 'package:better_bus_v2/data_provider/maps_router.dart';
import 'package:better_bus_v2/views/common/back_arrow.dart';
import 'package:better_bus_v2/views/common/fake_text_field.dart';
import 'package:better_bus_v2/views/map_pages/map_test_page.dart';
import 'package:better_bus_v2/views/stops_search_page/stops_search_page.dart';
import 'package:better_bus_v2/views/stop_info/timetable_view.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../model/clean/bus_line.dart';
import '../../model/clean/bus_stop.dart';
import 'next_passage_view.dart';

class StopInfoPageArgument {
  final BusStop stop;
  final List<BusLine>? lines;
  final bool fromMap;

  const StopInfoPageArgument(this.stop, this.lines,  {this.fromMap = false});
}

class StopInfoPage extends StatefulWidget {
  const StopInfoPage({Key? key}) : super(key: key);
  static const String routeName = "/stopInfo";

  @override
  State<StopInfoPage> createState() => _StopInfoPageState();
}

class _StopInfoPageState extends State<StopInfoPage>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;
  BusStop? stop;
  List<BusLine>? lines;
  late bool fromMap = false;
  double? busStopDistance;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    StopInfoPageArgument argument =
        ModalRoute.of(context)!.settings.arguments as StopInfoPageArgument;
    if (stop == null) {
      setState(() {
        stop = argument.stop;
        lines = argument.lines;
        fromMap = argument.fromMap;
        getBusStopDistance();
      });
    }
  }

  void getBusStopDistance() async {
    LatLng? location = await GpsDataProvider.getLocation();
    if (location == null || stop == null) return;

    double distance = GpsDataProvider.calculateDistance(
        location.latitude, location.longitude, stop!.latitude, stop!.longitude);

      busStopDistance = (distance * 10).roundToDouble() / 10;
  }

  void changeBusStop() {
    Navigator.of(context).pushNamed(SearchPage.routeName).then((value) {
      print("Stop changed");
      print(value);
      if (value == null) {
        return;
      }
      setState(() {
        stop = value as BusStop;
        lines = null;
      });
    });
  }

  void mapButtonClick() {
    Navigator.of(context).pop(stop as BusStop);
    if (!fromMap) {
      Navigator.of(context).pushNamed(MapPage.routeName, arguments: MapPageArg(
        station: stop
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (stop == null) return Placeholder();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Material(
              elevation: 2,
              child: Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: Row(
                        children: [
                          const BackArrow(),
                          Expanded(
                            child: FakeTextField(
                              onPress: changeBusStop,
                              value: stop!.name,
                              icon: Icons.search,
                            ),
                          ),
                          Column(
                            children: [
                              TextButton(
                                onPressed: mapButtonClick,
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Icon(
                                    Icons.map,
                                    size: 40,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              busStopDistance != null
                                  ? Text(
                                      "$busStopDistance km",
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ],
                      )),
                  TabBar(
                    indicatorColor: Theme.of(context).primaryColor,
                    tabs: const [
                      Tab(
                        text: AppString.nextPassage,
                      ),
                      Tab(
                        text: AppString.allSchedule,
                      )
                    ],
                    controller: tabController,
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  NextPassagePage(stop!, lines: lines),
                  TimeTableView(stop!),
                ],
                controller: tabController,
                key: ObjectKey(stop),
              ),
            )
          ],
        ),
      ),
    );
  }
}
