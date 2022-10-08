import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/model/clean/map_place.dart';
import 'package:better_bus_v2/views/common/background.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:better_bus_v2/views/stops_search_page/map_place_searcher_view.dart';
import 'package:better_bus_v2/views/stops_search_page/search_bus_stop_view.dart';
import 'package:flutter/material.dart';

import '../../app_constante/app_string.dart';

class PlaceSearcherPage extends StatefulWidget {
  const PlaceSearcherPage({Key? key}) : super(key: key);

  @override
  State<PlaceSearcherPage> createState() => _PlaceSearcherPageState();
}

class _PlaceSearcherPageState extends State<PlaceSearcherPage> with TickerProviderStateMixin {
  late TextEditingController textEditingController;
  late TabController tabController;

  void stopCallback(BusStop stop) {
    Navigator.of(context).pop(MapPlace(title: stop.name, type: "busStop", latitude: stop.latitude, longitude: stop.longitude));
  }

  void placeCallback(MapPlace place){
    Navigator.of(context).pop(place);
  }

  void inputChange() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    textEditingController.addListener(inputChange);

    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).backgroundColor,
                  ),
                  autofocus: true,
                  controller: textEditingController,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    decoration: CustomDecorations.of(context).boxBackground,
                    padding: const EdgeInsets.all(5),
                    child: TabBar(
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.directions_bus),
                              Text(AppString.busStation),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.location_on),
                              Text(AppString.place),
                            ],
                          ),
                        ),
                      ],
                      indicator: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      controller: tabController,
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      SearchBusStopView(
                        search: textEditingController.value.text,
                        stopCallback: stopCallback,
                      ),
                      MapPlaceSearcherView
                        (
                        search: textEditingController.value.text,
                        placeCallback: placeCallback,
                      ),
                    ],
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
