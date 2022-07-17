import 'package:flutter/material.dart';

class BusLine {
  const BusLine(this.id, this.fullName, this.color,
      {this.goDirection, this.backDirection});

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
    return BusLine(id, fullName, color,
        goDirection:
            goDirection != null ? List<String>.from(goDirection!) : null,
        backDirection:
            backDirection != null ? List<String>.from(backDirection!) : null
    );
  }

  final String id;
  final String fullName;
  final Color color;
  final List<String>? goDirection;
  final List<String>? backDirection;

  @override
  bool operator ==(Object other) {
    return other is BusLine && id == other.id;
  }

  @override
  int get hashCode => Object.hash(id, fullName);
}
