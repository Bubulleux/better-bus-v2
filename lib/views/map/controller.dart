import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/model/provider.dart';
import 'package:better_bus_v2/views/map/map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../data_provider/radar_provider.dart';

class NetworkMapController {
  NetworkMapState? widgetState;

  MapController get controller => widgetState!.controller;

  late FullProvider provider;

  dynamic _focused;
  int? _focusedStop;
  BusTrip? _focusedTrip;

  set focused(newFocus) {
    assert(newFocus == null || newFocus is LatLng || newFocus is Location);
    _focused = newFocus;
    focusChange.value = newFocus;
    stateChange.value = hashCode;
  }

  Location? get focused => _focused is LatLng ? Location(_focused) : _focused;

  LatLng? get focusedPos => focused is Location ? focused!.position : _focused;

  Station? get focusedStation => _focused is Station ? _focused : null;

  Place? get focusedPlace =>
      _focused is Place && _focused is! Station ? _focused : null;

  String? get focusedName => _focused is Place ? _focused!.name : null;

  int? get focusedStop =>
      focusedStation?.stops.containsKey(_focusedStop) ?? false
          ? _focusedStop
          : null;

  ValueNotifier<dynamic> focusChange = ValueNotifier(null);

  Position? _position;

  set position(Position? pos) {
    _position = pos;
  }

  Position? get position => _position;

  LatLng? get posCoord => _position != null
      ? LatLng(_position!.latitude, _position!.longitude)
      : null;

  BusTrip? get focusedTrip => _focusedTrip;

  ValueNotifier<int> stateChange = ValueNotifier(0);

  Map<LatLng, Station>? stopsPos;
  Map<Station, Report>? reports;

  Report? get report => reports?[focusedStation];

  NetworkMapController(BuildContext ctx) {
    provider = FullProvider.of(ctx);
    stateChange.value = hashCode;
  }

  void notifyChange() => stateChange.value = hashCode;

  @override
  int get hashCode =>
      _focused.hashCode ^
      focusedStop.hashCode ^
      (posCoord != null).hashCode ^
      focusedTrip.hashCode;

  Future loadStation() async {
    if (!provider.isAvailable()) return false;
    final stations = await provider.getStations();

    reports = Map.fromEntries(
        (await AppRadarProvider(provider: provider).getReports())
            .map((e) => MapEntry(e.station, e)));

    stopsPos = {for (var e in stations) e.position: e};
    widgetState?.update();
  }

  void setWidgetState(NetworkMapState state) {
    widgetState = state;
  }

  void dispose() {}

  void focus(dynamic newFocus, {double zoom = 18}) {
    focused = newFocus;
    widgetState?.update();
    animateCamTo(focusedPos!);
  }

  void setStop(int stopId) {
    assert(focusedStation?.stops.keys.contains(stopId) ?? false);
    _focusedStop = stopId;
    widgetState?.update();
    notifyChange();
  }

  void setTrip(BusTrip trip) {
    _focusedTrip = trip;
    notifyChange();
  }

  TickerFuture animateCamTo(LatLng dst, {double zoom = 18}) {
    final LatLngTween tween = LatLngTween(
      begin: controller.camera.center,
      end: dst,
    );

    final Tween<double> zoomTween =
        Tween(begin: controller.camera.zoom, end: 18);

    final animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: widgetState!,
    );
    final Animation<double> animation = CurvedAnimation(
        parent: animationController, curve: Curves.fastLinearToSlowEaseIn);

    animationController.addListener(() {
      controller.move(tween.evaluate(animation), zoomTween.evaluate(animation));
    });

    return animationController.forward();
  }

  void goToPosition({double zoom = 18}) {
    if (posCoord != null) {
      animateCamTo(posCoord!, zoom: zoom);
    }
  }
}
