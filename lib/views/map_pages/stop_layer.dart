import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/views/stops_search_page/search_bus_stop_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/diagnostics.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const animeTime = Duration(milliseconds: 300);

class StopsMapLayer extends StatefulWidget {
  const StopsMapLayer({required this.stops, required this.onStopClick, this.focusedStop, Key? key}) : super(key: key);

  final List<BusStop> stops;
  final BusStop? focusedStop;
  final void Function(BusStop) onStopClick;
  @override
  State<StopsMapLayer> createState() => _StopsMapLayerState();
}

class _StopsMapLayerState extends State<StopsMapLayer> {

  Marker buildMaker(BusStop stop, MapCamera camera) {
    final pos = LatLng(stop.latitude, stop.longitude);
    final focused = stop == widget.focusedStop;
    final asDot = camera.zoom < 15;

    return Marker(
      key: Key(stop.id.toString()),
        point: pos,
        child: AnimatedScale(
          duration: animeTime,
          scale: asDot ? 0.5 : 1,
          child: AnimatedContainer(
            duration: animeTime,
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: true ?
              Theme.of(context).primaryColor :
              Theme.of(context).primaryColorDark,
              borderRadius: BorderRadius.circular(20),
              border: focused ? Border.all(color: Colors.black26, width: 3) : null,
              boxShadow: [BoxShadow(
                offset: const Offset(2, 2),
                spreadRadius: focused ? -1 : -2,
                blurRadius: focused ? 5 : 2
              )]
            ),
            child: !asDot ?InkWell(
                onTap: () => widget.onStopClick(stop),
                child: const Icon(
                  Icons.directions_bus,
                  size: 19,
                )): Container(),
          ),
        )
    );
  }

  Iterable<Marker> buildSubMarker(BusStop stop) sync* {
    for (final child in stop.children) {
      yield Marker(
        point: child.pos,
        width: 15,
        height: 15,
        child: AnimatedContainer(
          duration: animeTime,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            border: Border.all(
              color: Theme.of(context).primaryColor,
              width: 5,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [BoxShadow(
              blurRadius: 5,
              spreadRadius: -1
            )]
          ),

        )
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final cam = MapCamera.of(context);

    return MarkerLayer(markers:
        (List<BusStop> stops) sync* {
      for (final stop in stops) {
        if (stop == widget.focusedStop) {
          yield* buildSubMarker(stop);
        }
        yield buildMaker(stop, cam);
      }
    }(widget.stops).toList());
  }
}
