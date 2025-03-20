
import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/views/map/bus_marker.dart';
import 'package:better_bus_v2/views/map/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';

class BusLayer extends StatefulWidget {
  const BusLayer({required this.stopTime, required this.controller, super.key});

  final StopTime stopTime;
  final NetworkMapController controller;

  @override
  State<BusLayer> createState() => _BusLayerState();
}

class _BusLayerState extends State<BusLayer>
    with SingleTickerProviderStateMixin {
  StopTime get stopTime => widget.stopTime;

  BusTrip get trip => stopTime.trip!;
  late final Ticker ticker;
  late BusMarker marker;

  @override
  void initState() {
    super.initState();
    marker = BusMarker(stopTime: stopTime);
    ticker = createTicker((time) {
      if (mounted) setState(() {});
    });

    ticker.start();
  }

  @override
  void dispose() {
    ticker.stop();
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO : Make it more robust
    final now = DateTime.now();
    marker.build(now, context);
    //widget.controller.animateCamTo(marker.busPos, zoom: 15);

    return MarkerLayer(markers: [
      marker.build(now, context),
    ]);
  }
}
