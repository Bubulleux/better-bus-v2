import 'dart:async';

import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/data_provider/app_provider.dart';
import 'package:better_bus_v2/views/map/map_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../data_provider/radar_provider.dart';

class NetworkMapController {
  NetworkMapState? widgetState;

  MapController get controller => widgetState!.controller;

  late AppProvider provider;

  dynamic _focused;
  int? _focusedStop;
  StopTime? _focusedStopTime;
  StreamSubscription? events;

  set focused(newFocus) {
    assert(newFocus == null || newFocus is LatLng || newFocus is Location);
    _focused = newFocus;
    focusChange.value = newFocus;
    stateChange.value = hashCode;
  }

  Location? get focused =>
      _focused is LatLng ? Location(position: _focused as LatLng) : _focused;

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
    notifyChange();
  }

  Position? get position => _position;

  LatLng? get posCoord => _position != null
      ? LatLng(_position!.latitude, _position!.longitude)
      : null;

  StopTime? get focusedStopTime => _focusedStopTime;

  ValueNotifier<int> stateChange = ValueNotifier(0);

  Map<LatLng, Station>? stopsPos;
  Map<Station, Report>? reports;

  bool get sendAvailable => AppRadarProvider(provider: provider).sentAvailable;

  Future? _nextFetch;

  Report? get report => reports?[focusedStation];

  var camOffset = Offset.zero;
  var camPadding = EdgeInsets.zero;

  NetworkMapController(BuildContext ctx) {
    provider = AppProvider.of(ctx);
    stateChange.value = hashCode;
  }

  void notifyChange() {
    stateChange.value = hashCode;
    widgetState?.update();
  }

  @override
  int get hashCode =>
      _focused.hashCode ^
      focusedStop.hashCode ^
      (posCoord != null).hashCode ^
      focusedStopTime.hashCode ^
      Object.hashAll(reports?.values ?? []);

  Future loadStation() async {
    await provider.awaitInit();
    assert(provider.isAvailable());
    if (_nextFetch == null) fetchLoop();
    final stations = await provider.getStations();
    widgetState?.update();

    stopsPos = {for (var e in stations) e.position: e};
    widgetState?.update();
  }

  Future fetchLoop() async {
    if (!provider.isAvailable()) return;
    await fetchReports();
    _nextFetch?.ignore();
    if (!(widgetState?.mounted ?? false)) return;
    _nextFetch = Future.delayed(const Duration(minutes: 1), fetchLoop);
    return _nextFetch;
  }

  Future fetchReports() async {
    List<Report> rawReports = await provider.radar.getReports();
    reports = Map.fromEntries(rawReports.map((e) => MapEntry(e.station, e)));
    widgetState?.update();
  }

  void setWidgetState(NetworkMapState state) {
    widgetState = state;

    events?.cancel();
    events = controller.mapEventStream.listen(onEvent);
  }

  void dispose() {
    _nextFetch?.ignore();
    events?.cancel();
  }

  void onEvent(MapEvent event) {
    if (event.source == MapEventSource.onMultiFinger) {
      notifyChange();
    }
  }

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

  void setStopTime(StopTime stopTime) {
    _focusedStopTime = stopTime;
    notifyChange();
  }

  void updateReport(Report report) {
    assert(reports != null);
    final radar = provider.radar;
    radar.updateReport(report, report.updates.values.last);
    reports![report.station] = report;
    notifyChange();
  }

  bool canSentReport(Station station) {
    if (!sendAvailable || posCoord == null) return false;

    return station.position.distance(posCoord!) < 0.3 || kDebugMode;
  }

  TickerFuture animateCamTo(LatLng dst, {double zoom = 17, double? angle}) {
    final fit = CameraFit.coordinates(coordinates: [dst],
    padding: camPadding, maxZoom: 17);
    final cam = controller.camera;
    final LatLngTween tween = LatLngTween(
      begin: cam.center,
      end: fit.fit(cam).center,
    );

    final Tween<double> zoomTween =
        Tween(begin: controller.camera.zoom, end: zoom);

    final Tween<double> angleTween =
    Tween(begin: cam.rotationRad, end: angle ?? cam.rotationRad);

    final animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: widgetState!,
    );
    final Animation<double> animation = CurvedAnimation(
        parent: animationController, curve: Curves.fastLinearToSlowEaseIn);

    const factor = 360 / pi * 2;

    animationController.addListener(() {
      controller.moveAndRotate(tween.evaluate(animation), zoomTween.evaluate(animation),
      angleTween.evaluate(animation) * factor);
      notifyChange();
    });

    return animationController.forward();
  }

  TickerFuture animateToBound(LatLngBounds bound) {
    final fit = CameraFit.bounds(bounds: bound, padding: camPadding + const EdgeInsets.all(10));
    final cam = fit.fit(controller.camera);

    return animateCamTo(cam.center, zoom: cam.zoom);
  }

  TickerFuture animateToNorth() {
    final cam = controller.camera;
    return animateCamTo(cam.center, zoom: cam.zoom, angle: 0);
  }

  void goToPosition({double zoom = 17}) {
    if (posCoord != null) {
      animateCamTo(posCoord!, zoom: zoom);
    }
  }

  void setCamPadding(EdgeInsets padding) {
    camPadding = padding;
  }
}
