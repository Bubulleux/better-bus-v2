import 'package:better_bus_v2/helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BusLine extends Comparable<BusLine>{
  BusLine(this.id, this.fullName, this.color,
      {this.goDirection = const [],
      this.backDirection = const []});

  BusLine.example() : this("X", "Some Line name", Colors.red);

  BusLine.fromJson(Map<String, dynamic> json)
      : this(
          json["line_id"],
          json["name"],
          colorFromHex(json["color"]),
          goDirection: json["direction"]["aller"].cast<String>(),
          backDirection: json["direction"]["retour"].cast<String>(),
        );

  BusLine.fromSimpleJson(Map<String, dynamic> json)
      : this(
    json["slug"],
    json["name"],
    Color(int.parse(json["color"].replaceAll("#", "0xff"))),
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

  static List<String> parseId(String id) {
    List<String> parsedId = [];
    String currentElement = "";
    bool currentElementIsInt = false;

    for (int i = 0; i < id.length; i++) {
      String char = id[i];
      bool isInt = int.tryParse(char) != null;
      if (currentElement != ""  && currentElementIsInt != isInt) {
        parsedId.add(currentElement);
        currentElement = "";
      }

      currentElement += char;
      currentElementIsInt = isInt;
    }
    parsedId.add(currentElement);

    return parsedId;
  }

  @override
  int compareTo(BusLine other){
    return compareID(id, other.id);
  }

  static int compareID(String a, String b) {
    List<String> parsedA = parseId(a);
    List<String> parsedB = parseId(b);
    if (a.isEmpty ||b.isEmpty) {
      return a.compareTo(b);
    }
    List<Function> compareFunctions = [
      (List<String> id) => int.tryParse(id[0]) ?? int.tryParse(id[0]) ?? double.infinity,
      (List<String> id) => id.length == 1  && id[0].length == 1 ? id[0].codeUnits[0] : double.infinity,
      (List<String> id) => id[0] == "N" ? int.parse(id[1]) : double.infinity,
      (List<String> id) => id[0] == "S" ? int.parse(id[1]) : double.infinity,
      (List<String> id) => id[0] == "P" ? int.parse(id[1]) : double.infinity,
      (List<String> id) => id[0][0] == "f" ? 0 : 1,
    ];

    for (Function compareFunction in compareFunctions) {
      int compareValue = compareFunction(parsedA).compareTo(compareFunction(parsedB));
      if (compareValue != 0) {
        return compareValue;
      }
    }

    return 0;
  }
}
