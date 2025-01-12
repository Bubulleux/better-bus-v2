import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/diagnostics.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class StopsMapLayer extends StatefulWidget {
  const StopsMapLayer(this.stops, {Key? key}) : super(key: key);

  final List<BusStop> stops;

  @override
  State<StopsMapLayer> createState() => _StopsMapLayerState();
}

class _StopsMapLayerState extends State<StopsMapLayer> {
  
  Widget buildMaker(BusStop stop, MapCamera camera) {
    if (camera.zoom < 15) {
      return Container(color: Colors.red, width: 5, height: 5,);
    }
    return ElevatedButton(
        onPressed: () => {},
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(-1),
        ),
        child: const Icon(Icons.directions_bus, size: 19,));
  }
  
  @override
  Widget build(BuildContext context) {
    final cam = MapCamera.of(context);
    print(cam.zoom);
    
    return MarkerLayer(markers:
        (List<BusStop> stops) sync* {
      for (final stop in stops) {
        yield Marker(point: LatLng(stop.latitude, stop.longitude), child:
        buildMaker(stop, cam),
        );
      }
    }(widget.stops).toList());
  }
}
