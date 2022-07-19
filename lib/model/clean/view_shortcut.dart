import 'package:better_bus_v2/model/clean/bus_line.dart';

import 'bus_stop.dart';
import 'terminal.dart';

class ViewShortcut {
  ViewShortcut(this.shortcutName, this.isFavorite,  this.stop, this.lines);

  ViewShortcut.example() : this("View Shortcut Name", false, BusStop.example(), []);
  factory ViewShortcut.fromJson(Map<String, dynamic> json) {
    return ViewShortcut(
        json["name"],
        json["isFavorite"],
        json["busStop"],
        json["lines"].map((e) => BusLine.fromJson(e)).toList().cast<BusLine>(),
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
  BusStop stop;
  List<BusLine> lines;
  bool isFavorite;
}