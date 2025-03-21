import 'dart:async';

import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/views/common/fake_text_field.dart';
import 'package:better_bus_v2/views/map/controller.dart';
import 'package:better_bus_v2/views/map/map_view.dart';
import 'package:better_bus_v2/views/map/map_view_port.dart';
import 'package:better_bus_v2/views/map_pages/focus_place.dart';
import 'package:better_bus_v2/views/map_pages/focus_stop.dart';
import 'package:better_bus_v2/views/stop_info/stop_info_page.dart';
import 'package:better_bus_v2/views/stops_search_page/place_searcher_page.dart';
import 'package:flutter/material.dart';

class MapPageArg {
  const MapPageArg({this.station, this.stop});

  final Station? station;
  final int? stop;
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  static const String routeName = "/map";

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late NetworkMapController controller;

  @override
  void initState() {
    super.initState();
    controller = NetworkMapController(context);
    controller.loadStation().then((_) => print("Map load finish"));
    controller.stateChange.addListener(() {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute
        .of(context)!
        .settings
        .arguments as MapPageArg?;
    if (true) {
      // TODO: Do it
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future goToSearch() async {
    Place? place = await (Navigator.of(context)
        .pushNamed(PlaceSearcherPage.routeName) as Future<dynamic>);
    if (place == null) return;

    controller.focus(place);
  }

  void onFocusOpen() {
    final station = controller.focusedStation;
    if (station == null) return;
    Navigator.of(context)
        .pushNamed(StopInfoPage.routeName,
        arguments: StopInfoPageArgument(station, null, fromMap: true))
        .then((value) => controller.focus(value));
  }

  @override
  Widget build(BuildContext context) {
    Widget? overlay;
    if (controller.focusedStation != null) {
      overlay = StopFocusWidget(
        controller: controller,
        openFocus: onFocusOpen,
      );
    }

    if (controller.focusedPlace != null) {
      overlay = FocusPlace(controller: controller);
    }

    return Scaffold(
      body: SafeArea(
        child: NetworkMap(
          controller: controller,
          input: Row(
            children: [
              const BackButton(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FakeTextField(
                    onPress: goToSearch,
                    icon: Icons.search,
                    value: controller.focusedName,
                    hint: AppString.searchLabel,
                  ),
                ),
              ),
            ],
          ),
          overlayAsDrawer: controller.focusedStation != null,
          overlay: overlay,
        ),
      ),
    );
  }
}
