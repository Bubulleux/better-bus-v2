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

class _PositionLayerState extends State<PositionLayer> {
  Position? position;
  StreamSubscription? listener;
  LatLng? get posPoint {
    if (position == null) return null;
    return LatLng(position!.latitude, position!.longitude);
  }

  @override
  void initState() {
    super.initState();
    updatePosition();
  }

  @override
  void dispose() {
    super.dispose();
    listener?.cancel();
  }

  void updatePosition() async {
    const setttings = LocationSettings(
      accuracy: LocationAccuracy.medium,

    );
    listener = Geolocator.getPositionStream(locationSettings: setttings).listen(
        (Position newPos) {
          setState(() {
            position = newPos;
          });
        }
    );
  }


  Widget buildMarker() {
    if (position == null) return Container();
    return MarkerLayer(
      markers: [
        Marker(
            point: posPoint!,
            rotate: false,
            width: 50,
            height: 50,
            child: AnimatedRotation(
              duration: Duration(milliseconds: 500),
              turns: position!.heading / 360,
              child: Container(
                child: Icon(Icons.arrow_circle_up, size: 30,),
              ),
            )
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        buildMarker()
      ]
    );

  }
}
