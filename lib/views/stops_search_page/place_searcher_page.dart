import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/views/common/background.dart';
import 'package:better_bus_v2/views/common/custom_text_field.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:better_bus_v2/views/stops_search_page/map_place_searcher_view.dart';
import 'package:better_bus_v2/views/stops_search_page/search_bus_stop_view.dart';
import 'package:flutter/material.dart';

import '../../app_constant/app_string.dart';

class PlaceSearcherPage extends StatefulWidget {
  const PlaceSearcherPage({super.key});
  static const String routeName = "/placeSearcher";

  @override
  State<PlaceSearcherPage> createState() => _PlaceSearcherPageState();
}

class _PlaceSearcherPageState extends State<PlaceSearcherPage> with TickerProviderStateMixin {
  late TextEditingController textEditingController;
  late TabController tabController;

  void stopCallback(Station stop) {
    Navigator.of(context).pop(stop);
  }

  void placeCallback(Place place){
    Navigator.of(context).pop(place);
  }

  void inputChange() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    textEditingController = TextEditingController();
    textEditingController.addListener(inputChange);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
            child: Column(
              children: [
                CustomTextField(
                  autofocus: true,
                  controller: textEditingController,
                  hint: AppString.searchLabel,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    decoration: CustomDecorations.of(context).boxBackground,
                    padding: const EdgeInsets.all(5),
                    child: TabBar(
                      tabs: const [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.directions_bus),
                              Text(AppString.busStation),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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
