import 'dart:convert';
import 'dart:ui';

class BusLine implements Comparable<BusLine>{
  const BusLine(this.id, this.name, this.color,
  {required this.direction});
  final String id;
  final String name;
  final Color color;
  // TODO: Implement direction
  final Map<int, List<String>> direction;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  bool operator ==(Object other) {
    return other is BusLine && hashCode == other.hashCode;
  }

  static List<String> _parseId(String id) {
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

  static int compareID(String a, String b) {

    List<String> parsedA = _parseId(a);
    List<String> parsedB = _parseId(b);
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

  @override
  String toString() {
    return "{$id $name}";
  }

  @override
  int compareTo(BusLine other){
    return compareID(id, other.id);
  }
  // TODO: old json methode
  BusLine.fromCleanJson(Map<String, dynamic> json)
      : this(
    json["id"],
    json["name"],
    Color(json["color"]),
    direction: {},
    // goDirection: json["goDirection"].cast<String>(),
    // backDirection: json["backDirection"].cast<String>(),
  );

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "color": color.value,
      "directions": direction,
      // "goDirection": goDirection,
      // "backDirection": backDirection,
    };
  }
}