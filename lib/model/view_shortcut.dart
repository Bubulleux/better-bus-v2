import 'package:better_bus_core/core.dart';

class ViewShortcut {


  ViewShortcut(this.shortcutName, this.isFavorite, this.stop, this.direction);

  factory ViewShortcut.fromJson(Map<String, dynamic> json, Map<String, BusLine> lines) {
    List<LineDirection> direction = <LineDirection>[];
    if (json["lines"] != null) {
      List<BusLine> lines = json["lines"]
          .map((e) => BusLine.fromCleanJson(e))
          .toList().cast<BusLine>();
      for (var l in lines) {
        direction.addAll(l.directions.map((d) => LineDirection.fromDir(l, d)));
      }
    } else {
      direction.addAll(json["directions"].map(
          (e) => LineDirection.fromJson(e, lines)
      ).toList().cast<LineDirection>());
    }

    return ViewShortcut(
      json["name"],
      json["isFavorite"],
      Station.fromJson(json["busStop"]),
      direction,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": shortcutName,
      "isFavorite": isFavorite,
      "busStop": stop.toJson(),
      "directions": direction.map((e) => e.toJson()).toList(),
    };
  }

  String shortcutName;
  Station stop;
  List<LineDirection> direction;

  @deprecated
  List<BusLine> get lines =>
      direction.map((e) => e.line).toSet().toList(growable: false);
  bool isFavorite;
}
