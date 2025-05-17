import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/data_provider/gps_data_provider.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:better_bus_v2/views/map/controller.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
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
  final Map<Station, List<BusLine>> lines = {};

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
    final stations =
        await provider.getClosestStation(widget.controller.posCoord!, max: 4, maxDist: 10);

    for (var e in stations) {
      if (lines.containsKey(e)) continue;
      lines[e] = [];

      provider.getPassingLines(e).then((value) {
        if (!mounted) return;
        lines[e] = value;
      });
    }

    if (!mounted) return;
    setState(() {
      nearStation = stations;
    });
  }

  void itemClick(Station station) {
    widget.controller.focus(station);
  }

  Widget buildItem(Station station) {
    final dst = widget.controller.posCoord!.distance(station.position);
    return Expanded(
        child: InkWell(
      onTap: () => itemClick(station),
      child: Container(
        margin: EdgeInsets.all(3),
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorLight,
          boxShadow: CustomDecorations.simpleShadow,
          borderRadius: BorderRadius.circular(10)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Row(
              children: [
                Text(
                  station.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                      fontSize: 14
                  ),
                ),
                const Spacer(),
                Text(
                  "$dst km",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColorDark),
                ),
              ],
            ),
            Wrap(
              children: lines[station]!.map((e) => LineWidget(e, 15)).toList(),
            ),
          ],
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (nearStation == null) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        children: nearStation!
            .slices(2)
            .map((e) => Row(
                  children: e.map(buildItem).toList(),
                ))
            .toList(),
      ),
    );
  }
}
