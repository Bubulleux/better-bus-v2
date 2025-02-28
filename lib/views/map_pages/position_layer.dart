import 'dart:async';

import 'package:better_bus_v2/data_provider/gps_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class PositionLayer extends StatefulWidget {
  const PositionLayer({super.key});

  @override
  State<PositionLayer> createState() => _PositionLayerState();
}

class _PositionLayerState extends State<PositionLayer>
    with SingleTickerProviderStateMixin {
  Position? position;
  LatLngTween? posAnimation;
  Tween<double>? angleAnimation;
  late AnimationController controller;
  late Animation<double> animation;
  StreamSubscription? listener;

  LatLng? get posPoint {
    if (position == null) return null;
    return LatLng(position!.latitude, position!.longitude);
  }

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.linear);
    animation.addListener(() {
      setState(() {});
      });
    updatePosition();
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    listener?.cancel();
    controller.dispose();
    super.dispose();
  }

  void updatePosition() async {
    const setttings = LocationSettings(
      accuracy: LocationAccuracy.medium,
    );
    if (!(await GpsDataProvider.available())) {
      return;
    }
    listener = Geolocator.getPositionStream(locationSettings: setttings)
        .listen((Position newPos) {
      setState(() {
        final newLatLng = LatLng(newPos.latitude, newPos.longitude);
        LatLng start = posAnimation?.evaluate(animation) ?? newLatLng;
        posAnimation = LatLngTween(begin: start, end: newLatLng);
        angleAnimation = Tween(begin: position?.heading ?? newPos.heading, end: newPos.heading);
        position = newPos;
        controller.duration = position != null ?
          newPos.timestamp.difference(position!.timestamp) : const Duration(seconds: 1);
        controller.duration = const Duration(milliseconds: 500);
        controller.forward(from: 0);
      });
    });
  }

  Widget buildMarker(LatLng pos, double angle) {
    // final cam = MapCamera.of(context);
    // final realPos = cam.project(pos) - cam.pixelOrigin;
    return MarkerLayer(
      markers: [
        Marker(
          point: pos,
            width: 28,
            height: 28,
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(offset: Offset(1, 1),
                  blurRadius: 3,
                  color: Colors.black54)
                ]
              ),
              child: Transform.rotate(
                angle: angle / 180 * 3.141592,
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: position != null
            ? [
                buildMarker(
                    posAnimation!.evaluate(animation), angleAnimation!.evaluate(animation))
              ]
            : []);
  }
}
