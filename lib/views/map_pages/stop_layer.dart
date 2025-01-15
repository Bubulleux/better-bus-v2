import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/views/stops_search_page/search_bus_stop_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/diagnostics.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


class StopsMapLayer extends StatefulWidget {
  const StopsMapLayer(this.stops, {required this.onStopClick, Key? key}) : super(key: key);

  final List<BusStop> stops;
  final void Function(BusStop) onStopClick;
  @override
  State<StopsMapLayer> createState() => _StopsMapLayerState();
}

class _StopsMapLayerState extends State<StopsMapLayer> {

  Marker buildMaker(BusStop stop, MapCamera camera) {
    final pos = LatLng(stop.latitude, stop.longitude);
    if (camera.zoom < 15) {
      return Marker(point: pos, child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            border: Border.all(color: Colors.black26, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(10))
          ),
      ),
        width: 10, height: 10);
    }
    return Marker(point: pos, child: ElevatedButton(
        onPressed: () => widget.onStopClick(stop),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(-1),
        ),
        child: const Icon(Icons.directions_bus, size: 19,))
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final cam = MapCamera.of(context);
    print(cam.zoom);
    
    return MarkerLayer(markers:
        (List<BusStop> stops) sync* {
      for (final stop in stops) {
        yield buildMaker(stop, cam);
      }
    }(widget.stops).toList());
  }
}
