import 'dart:async';

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
    animation.addListener(() {setState(() {});});
    updatePosition();
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
    listener = Geolocator.getPositionStream(locationSettings: setttings)
        .listen((Position newPos) {
      setState(() {
        final newLatLng = LatLng(newPos.latitude, newPos.longitude);
        LatLng start = posAnimation?.evaluate(animation) ?? newLatLng;
        posAnimation = LatLngTween(begin: start, end: newLatLng);
        angleAnimation = Tween(begin: position?.heading, end: newPos.heading);
        position = newPos;
        controller.duration = position != null ?
          newPos.timestamp.difference(position!.timestamp) : const Duration(seconds: 1);
        controller.forward(from: 0);
      });
    });
  }

  Widget buildMarker(LatLng pos, double angle) {
    final cam = MapCamera.of(context);
    final realPos = cam.project(pos) - cam.pixelOrigin;
    return MobileLayerTransformer(
        child: Stack(
      children: [
        Positioned(
            left: realPos.x,
            top: realPos.y,
            child: Transform.rotate(
              angle: angle / 180 * 3.141592,
              child: const Icon(
                Icons.arrow_circle_up,
                size: 30,
              ),
            ))
      ],
    ));
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
