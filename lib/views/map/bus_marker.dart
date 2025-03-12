import 'dart:math';

import 'package:better_bus_core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../data_provider/gps_data_provider.dart';

class BusMarker {
  final StopTime stopTime;

  BusTrip get trip => stopTime.trip!;

  DateTime get start => trip.stopTimes.first.time;

  // double get distance => next!.time.isAfter(time)
  //   ? next!.travelDist *
  //     (time.difference(start).inMilliseconds /
  //         (next!.time.difference(start).inMilliseconds + 1))
  // : next!.travelDist.toDouble();

  double get distance => next!.travelDist.toDouble();

  TripStop? next;
  LatLngTween? posTween;
  double? tweenDst;

  late final Iterator<LatLng> iterator;
  LatLng? lastWayPoint;
  double traveled = 0;
  double previousTraveled = 0;
  double angle = 0;
  late LatLng busPos;

  late DateTime time;

  BusMarker({required this.stopTime}) {
    iterator = trip.shape.wayPoints.iterator;
    iterator.moveNext();
    busPos = trip.shape.wayPoints.first;
  }

  void updateTween() {
    if (next == null || next!.time.isBefore(time)) {
      next = trip.stopTimes.firstWhere((e) => time.isBefore(e.time),
          orElse: () => trip.stopTimes.last);
    }

    while (lastWayPoint == null || distance > traveled) {
      lastWayPoint = iterator.current;
      final hasNext = iterator.moveNext();
      if (!hasNext) return;

      tweenDst = GpsDataProvider.calculateDistancePos(
              lastWayPoint!, iterator.current) *
          1000;
      traveled += tweenDst!;
    }

    posTween = LatLngTween(begin: lastWayPoint!, end: iterator.current);
    angle = atan2(
      iterator.current.latitude - lastWayPoint!.latitude,
      iterator.current.longitude - lastWayPoint!.longitude,
    );
    // busPos = LatLngTween(begin: startPoint, end: endPoint).e
  }

  bool inBound(LatLngBounds bound) {
    return bound.isOverlapping(LatLngBounds(
      lastWayPoint!,
      iterator.current,
    ));
  }

  Marker build(DateTime newTime, BuildContext context) {
    time = newTime.subtract(stopTime.delay);
    if (time.isBefore(start)) {
      time = start;
    }
    updateTween();

    final x = (distance - traveled - tweenDst! ) / tweenDst!;
    busPos = iterator.current;
    busPos = posTween!.transform(x);

    return Marker(
      point: busPos,
      alignment: Alignment.center,
      width: 30,
      height: 10,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          color: Colors.purpleAccent,
        ),
      ),
    );
  }
}
