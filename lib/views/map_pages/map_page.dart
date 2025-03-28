import 'dart:async';

import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/model/view_shortcut.dart';
import 'package:better_bus_v2/views/common/fake_text_field.dart';
import 'package:better_bus_v2/views/home_page/home_page.dart';
import 'package:better_bus_v2/views/home_page/shortcut_section.dart';
import 'package:better_bus_v2/views/map/controller.dart';
import 'package:better_bus_v2/views/map/map_layout.dart';
import 'package:better_bus_v2/views/map_pages/focus_place.dart';
import 'package:better_bus_v2/views/map_pages/focus_stop.dart';
import 'package:better_bus_v2/views/map_pages/map_home.dart';
import 'package:better_bus_v2/views/stop_info/stop_info_page.dart';
import 'package:better_bus_v2/views/stops_search_page/place_searcher_page.dart';
import 'package:flutter/material.dart';

import '../stops_search_page/stops_search_page.dart';

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
  ViewShortcut? selectedShortcut;

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
    final arg = ModalRoute.of(context)!.settings.arguments as MapPageArg?;
    if (true) {
      // TODO: Do it
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void handlePop(bool didPop, Object? result) async {
    if (didPop) return;
    if (controller.focused != null) {
      controller.focused = null;
      return;
    }
    Navigator.of(context).pop();
  }

  void openShortcut(ViewShortcut newShortcut) {
    selectedShortcut = newShortcut;
    controller.focus(selectedShortcut!.stop);
    setState(() {});
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

  void camToFocus() {
    if (controller.focused == null) return;
    controller.animateCamTo(controller.focused!.position);
  }

  Widget buildOverlayTitle() {
    return Material(
      child: InkWell(
        onTap: camToFocus,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
          child: Row(
            children: [
              Text(
                controller.focusedStation!.name,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
              ),
              const Spacer(),
              buildDist(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDist() {
    final pos = controller.posCoord;
    if (pos == null) return Container();

    String? distance =
        "${(getDistanceInKMeter(controller.focusedStation!, pos!) * 100).roundToDouble() / 100} km";

    return Wrap(
      children: [
        const Icon(Icons.directions_walk, size: 20),
        Text(distance.toString())
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    Widget? overlayTitle;
    Widget? overlay = MapHome(
      onClicked: openShortcut,
    );

    if (controller.focusedStation != null) {
      overlayTitle = buildOverlayTitle();
      overlay = StopFocusWidget(
        controller: controller,
        shortcut: controller.focusedStation == selectedShortcut?.stop
            ? selectedShortcut
            : null,
      );
    }

    if (controller.focusedPlace != null) {
      overlayTitle = FocusPlace(controller: controller);
    }

    return Scaffold(
      body: SafeArea(
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: handlePop,
          child: MapLayout(
            controller: controller,
            topBarHeight: 100,
            topBar: Row(
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
            overlayTitle: overlayTitle,
            body: overlay,
            overlaySizable: controller.focusedPlace == null,
          ),
        ),
      ),
    );
  }
}
