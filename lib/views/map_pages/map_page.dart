import 'dart:async';

import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/custom_home_widget.dart';
import 'package:better_bus_v2/views/root/loader.dart';
import 'package:better_bus_v2/model/view_shortcut.dart';
import 'package:better_bus_v2/views/common/fake_text_field.dart';
import 'package:better_bus_v2/views/map/controller.dart';
import 'package:better_bus_v2/views/map/map_layout.dart';
import 'package:better_bus_v2/views/map_pages/focus_place.dart';
import 'package:better_bus_v2/views/map_pages/focus_stop.dart';
import 'package:better_bus_v2/views/map_pages/home_drawer.dart';
import 'package:better_bus_v2/views/map_pages/home_drawer_btn.dart';
import 'package:better_bus_v2/views/map_pages/map_home.dart';
import 'package:better_bus_v2/views/stop_info/stop_info_page.dart';
import 'package:better_bus_v2/views/stops_search_page/place_searcher_page.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../data_provider/local_data_handler.dart';
import '../stops_search_page/stops_search_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({this.initialShortcut, this.openClosest = false, super.key});

  static const String routeName = "/";
  final ViewShortcut? initialShortcut;
  final bool openClosest;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late NetworkMapController controller;
  ViewShortcut? selectedShortcut;

  @override
  void initState() {
    super.initState();
    if (widget.initialShortcut != null) {

      openShortcut(widget.initialShortcut!);
    }
    controller = NetworkMapController(context);
    controller.loadStation().then((_) => print("Map load finish"),
        onError: (Object e, s) {
      throw e;
    });

    controller.stateChange.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant MapPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialShortcut != widget.initialShortcut && widget.initialShortcut != null) {
        openShortcut(widget.initialShortcut!);
    }
    if (oldWidget.openClosest != widget.openClosest  && widget.openClosest) {
      openClosest();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void openClosest() async {
    final pos = await Geolocator.getCurrentPosition();
    final coord = LatLng(pos.latitude, pos.longitude);
    controller.focus((await controller.provider.getClosestStation(coord, max: 1)).first);
  }


  void handlePop(bool didPop, Object? result) async {
    if (didPop) return;
    if (controller.focused != null) {
      controller.focused = null;
      return;
    }
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
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
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
      controller: controller,
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
      drawer: HomeDrawer(),
      body: Loader(
        child: SafeArea(
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: handlePop,
            child: Column(
              children: [
                Expanded(
                  child: MapLayout(
                    controller: controller,
                    topBarHeight: 80,
                    topBar: Row(
                      children: [
                        HomeDrawerBtn(),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
