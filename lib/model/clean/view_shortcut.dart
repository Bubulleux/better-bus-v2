
import 'package:better_bus_v2/core/models/bus_line.dart';
import 'package:better_bus_v2/core/models/line_direction.dart';
import 'package:better_bus_v2/core/models/station.dart';


class ViewShortcut {
  ViewShortcut(this.shortcutName, this.isFavorite,  this.stop, List<BusLine> lines) {
    direction = [];
    for (var l in lines) {
      direction.addAll(l.directions.map(
        (d) => LineDirection.fromDir(l, d)
    ));
    }
  }

  ViewShortcut.v2(this.shortcutName, this.isFavorite, this.stop, this.direction);

  factory ViewShortcut.fromJson(Map<String, dynamic> json) {
    print(json["lines"]);
    return ViewShortcut(
        json["name"],
        json["isFavorite"],
        Station.fromCleanJson(json["busStop"]),
        json["lines"].map((e) => BusLine.fromCleanJson(e)).toList().cast<BusLine>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": shortcutName,
      "isFavorite": isFavorite,
      "busStop": stop.toJson(),
      "lines": lines.map((e) => e.toJson()).toList(),
    };
  }

  String shortcutName;
  Station stop;
  late List<LineDirection> direction;
  @deprecated
  List<BusLine> get lines => direction.map((e) => e.line).toSet().toList(growable: false) ;
  bool isFavorite;
}