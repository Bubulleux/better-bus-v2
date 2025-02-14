import 'package:better_bus_v2/core/models/station.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const animeTime = Duration(milliseconds: 250);

class StopsMapLayer extends StatefulWidget {
  const StopsMapLayer(
      {required this.stops,
      this.onStopClick,
      this.onStationClick,
      this.focusedStation,
      this.focusedStop,
      super.key});

  final List<Station> stops;
  final Station? focusedStation;
  final int? focusedStop;
  final void Function(Station)? onStationClick;
  final void Function(int)? onStopClick;

  @override
  State<StopsMapLayer> createState() => _StopsMapLayerState();
}

class _StopsMapLayerState extends State<StopsMapLayer> {
  Marker buildMaker(Station stop, MapCamera camera) {
    final focused = stop == widget.focusedStation;
    final asDot = camera.zoom < 15;

    return Marker(
        key: Key(stop.id.toString()),
        point: stop.position,
        child: AnimatedScale(
          duration: animeTime,
          scale: asDot ? 0.5 : 1,
          child: AnimatedContainer(
            duration: animeTime,
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(20),
                border: focused
                    ? Border.all(color: Colors.black26, width: 3)
                    : null,
                boxShadow: [
                  BoxShadow(
                      offset: const Offset(2, 2),
                      spreadRadius: focused ? -1 : -2,
                      blurRadius: focused ? 5 : 2)
                ]),
            child: !asDot
                ? InkWell(
                    onTap: () => widget.onStationClick?.call(stop),
                    child: const Icon(
                      Icons.directions_bus,
                      size: 19,
                    ))
                : Container(),
          ),
        ));
  }

  Iterable<Marker> buildSubMarker(Station stop) sync* {
    for (final child in stop.stops.entries) {
      final focused = child == widget.focusedStop;
      yield Marker(
          point: child.value,
          width: 30,
          height: 30,
          child: InkWell(
            onTap: () => widget.onStopClick?.call(child.key),
            child: AnimatedScale(
              duration: animeTime,
              scale: focused ? 0.8 : 0.5,
              child: AnimatedContainer(
                duration: animeTime,
                padding: focused ? const EdgeInsets.all(5) : const EdgeInsets.all(15),
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
                        color: Theme.of(context).primaryColorDark
                      ),
                    ),
              ),
            ),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cam = MapCamera.of(context);

    return MarkerLayer(
        markers: (List<Station> stops) sync* {
      for (final stop in stops) {
        if (stop == widget.focusedStation) {
          yield* buildSubMarker(stop);
        }
        yield buildMaker(stop, cam);
      }
    }(widget.stops)
            .toList());
  }
}
