import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/model/bus_line_color.dart';
import 'package:better_bus_v2/views/map/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';


class StopsMapLayer extends StatefulWidget {
  const StopsMapLayer({
    required this.mapController,
    required this.stops,
    this.onStopClick,
    this.onStationClick,
    this.focusedStation,
    this.focusedStop,
    this.reports,
    super.key,
  });

  final NetworkMapController mapController;
  final List<Station> stops;
  final Station? focusedStation;
  final int? focusedStop;
  final Map<Station, Report>? reports;
  final void Function(Station)? onStationClick;
  final void Function(int)? onStopClick;

  @override
  State<StopsMapLayer> createState() => _StopsMapLayerState();
}


class _StopsMapLayerState extends State<StopsMapLayer> {

  static const _animeTime = Duration(milliseconds: 250);
  static const _staticCircleSizeMaxZoom = 14;
  static const _minWidgetZoom = 15;
  static const _zoomWidgetAppear = 16;

  Marker buildMaker(Station stop, Report? report, MapCamera camera) {
    final focused = stop == widget.focusedStation;
    final onTrip = widget.mapController.focusedStopTime?.trip!.isPassingBy(stop) ?? false;
    final color = stationColor(stop);
    final trip = widget.mapController.focusedStopTime?.trip!;
    Color? lineColor;
    if (trip != null && trip.isPassingBy(stop)) {
      lineColor = trip.line.color.withAlpha(200);
    }

    return Marker(
        key: Key(stop.id.toString()),
        point: stop.position,
        child: AnimatedContainer(
          duration: _animeTime,
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              border: focused || lineColor != null
                  ? Border.all(color: lineColor ?? Colors.black26, width: 3)
                  : null,
              boxShadow: [
                BoxShadow(
                    offset: const Offset(2, 2),
                    spreadRadius: focused ? -1 : -2,
                    blurRadius: focused ? 5 : 2)
              ]),
          child: InkWell(
                  onTap: () => widget.onStationClick?.call(stop),
                  child: const Icon(
                    Icons.directions_bus,
                    size: 19,
                  )),
        ));
  }


  Color stationColor(Station station) {
    var out = Theme.of(context).primaryColor;
    final report = widget.reports?[station];

    if (report != null) {
      out = Color.lerp(out, Colors.blue, report.stillThere) ?? out;
    }
    return out;
  }


  Iterable<Marker> buildSubMarker(Station stop) sync* {
    for (final child in stop.stops.entries) {
      final focused = child.key == widget.focusedStop;
      yield Marker(
          point: child.value,
          width: 30,
          height: 30,
          child: InkWell(
            onTap: () => widget.onStopClick?.call(child.key),
            child: AnimatedScale(
              duration: _animeTime,
              scale: focused ? 0.8 : 0.5,
              child: AnimatedContainer(
                duration: _animeTime,
                padding: focused
                    ? const EdgeInsets.all(5)
                    : const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight,
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: focused ? 3 : 5,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(blurRadius: 5, spreadRadius: -1)
                    ]),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).primaryColorDark),
                ),
              ),
            ),
          ));
    }
  }

  Iterable<Marker> getMarkers(MapCamera cam) sync* {

    for (final stop in widget.stops) {
      if (stop == widget.focusedStation) {
        yield* buildSubMarker(stop);
      }
      yield buildMaker(stop, widget.reports?[stop], cam);
    }
  }

  Widget buildMarkerLayer(MapCamera cam) {
    var markers = getMarkers(cam);
    if (cam.zoom < _minWidgetZoom) {
      return Container();
    }

    return AnimatedOpacity(
      duration: _animeTime,
      opacity: cam.zoom < _zoomWidgetAppear ? 0 : 1,
      child: MarkerLayer(markers: markers.toList()),
    );
  }

  Widget buildImage(MapCamera cam) {
    double r = 10;
    if (cam.zoom < _staticCircleSizeMaxZoom) {
      r *= 8.5;
    }
    final circles = widget.stops.map(
        (e) {
          final c = stationColor(e);
          return CircleMarker(
            point: e.position, radius: r,
            useRadiusInMeter: cam.zoom < _staticCircleSizeMaxZoom,
            color: c,
            borderColor: Color.lerp(c, Colors.black, 0.3)!,
            borderStrokeWidth: r / 5,
          );
        }
    ).toList();

    return IgnorePointer(
      ignoring: true,
      child: AnimatedOpacity(
        duration: _animeTime,
          opacity: cam.zoom < _zoomWidgetAppear ? 1 : 0,
          child: CircleLayer(circles: circles)
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final cam = MapCamera.of(context);
    // print(cam.zoom);
    return Stack(
      children: [
        buildMarkerLayer(cam),
        buildImage(cam),
      ],
    );
    if (cam.zoom < 14) {
      return buildImage(cam);
    }
  }
}
