
import 'package:better_bus_v2/core/models/bus_line.dart';
import 'package:better_bus_v2/core/models/station.dart';


class ViewShortcut {
  ViewShortcut(this.shortcutName, this.isFavorite,  this.stop, this.lines);

  factory ViewShortcut.fromJson(Map<String, dynamic> json) {
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
  List<BusLine> lines;
  bool isFavorite;
}