import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/data_provider/gps_data_provider.dart';
import 'package:better_bus_v2/views/map/controller.dart';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

import '../stops_search_page/stops_search_page.dart';

class NearStations extends StatefulWidget {
  const NearStations({required this.controller, super.key});

  final NetworkMapController controller;

  @override
  State<NearStations> createState() => _NearStationsState();
}

class _NearStationsState extends State<NearStations> {
  List<Station>? nearStation;

  @override
  void initState() {
    super.initState();
    update();
    Geolocator.getPositionStream().listen((data) {
      update();
    });
  }

  Future update() async {
    final provider = widget.controller.provider;
    await provider.awaitInit();
    if (widget.controller.posCoord == null) return;
    final station = await provider.getStations();
    final pos = widget.controller.posCoord!;

    station.sort((a, b) =>
        getDistanceInKMeter(a, pos).compareTo(getDistanceInKMeter(b, pos)));

    if (!mounted) return;

    setState(() {
      nearStation = station.take(4).toList();
    });
  }

  void itemClick(Station station) {
    widget.controller.focus(station);
  }

  Widget buildItem(Station station) {
    return Expanded(child: InkWell(
      onTap: () => itemClick(station),
      child: Container(
        margin: EdgeInsets.all(3),
        padding: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black12
        ),
          child: Row(
            children: [
              Text(station.name),
              Spacer(),
            ],
          ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (nearStation == null) {
      return Container(
      );
    }
    return Column(
      children: nearStation!
          .slices(2)
          .map((e) => Row(
                children: e.map(buildItem).toList(),
              ))
          .toList(),
    );
  }
}
