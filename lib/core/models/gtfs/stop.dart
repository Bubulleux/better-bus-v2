import 'package:better_bus_v2/core/models/place.dart';
import 'package:better_bus_v2/core/models/station.dart';
import 'package:latlong2/latlong.dart';

class GTFSStop extends Place {
  const GTFSStop(super.name, this.id, super.position,
  {required this.code, this.parent});

  final int id;
  final String code;
  final int? parent;

  GTFSStop.fromCSV(Map<String, String> row)
      : this(
      row["stop_name"]!,
      int.parse(row["stop_id"]!),
      LatLng(double.parse(row["stop_lat"]!),
          double.parse(row["stop_lon"]!)),
    code: row["stop_code"]!,
    parent: int.tryParse(row["parent_station"]!)
  );

  Station toStation(List<GTFSStop> children) {
    return Station(name, id, super.position,
        stops: Map<int, LatLng>.fromEntries(children.map((e) => MapEntry(e.id, e.position)))
    );
  }

}
