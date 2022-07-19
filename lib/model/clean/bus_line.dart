import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BusLine {
  BusLine(this.id, this.fullName, this.color,
      {this.goDirection = const [],
      this.backDirection = const []});

  BusLine.example() : this("X", "Some Line name", Colors.red);

  BusLine.fromJson(Map<String, dynamic> json)
      : this(
          json["line_id"],
          json["name"],
          Color(int.parse(json["color"].replaceAll("#", "0xff"))),
          goDirection: json["direction"]["aller"].cast<String>(),
          backDirection: json["direction"]["retour"].cast<String>(),
        );

  BusLine.fromCleanJson(Map<String, dynamic> json)
      : this(
          json["id"],
          json["name"],
          Color(json["color"]),
          goDirection: json["goDirection"].cast<String>(),
          backDirection: json["backDirection"].cast<String>(),
        );

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": fullName,
      "color": color.value,
      "goDirection": goDirection,
      "backDirection": backDirection,
    };
  }

  BusLine copy() {
    return BusLine(
      id,
      fullName,
      color,
      goDirection: List<String>.from(goDirection),
      backDirection: List<String>.from(backDirection),
    );
  }

  final String id;
  final String fullName;
  final Color color;
  final List<String> goDirection;
  final List<String> backDirection;

  @override
  bool operator ==(Object other) {
    if (other is! BusLine) {
      return false;
    }

    List<String> goDir = List.from(goDirection);
    List<String> backDir = List.from(backDirection);

    List<String> otherGoDir = List.from(other.goDirection);
    List<String> otherBackDir = List.from(other.backDirection);

    goDir.sort();
    backDir.sort();
    otherBackDir.sort();
    otherGoDir.sort();

    return id == other.id &&
        listEquals(goDir, otherGoDir) &&
        listEquals(backDir, otherBackDir);
  }

  @override
  int get hashCode{
    List<String> goDir = List.from(goDirection);
    List<String> backDir = List.from(backDirection);
    goDir.sort();
    backDir.sort();

    return Object.hash(id, fullName, color, goDir, backDir);
  }
}
