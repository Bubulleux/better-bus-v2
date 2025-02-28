
import 'bus_line.dart';

class Direction {
  final String destination;
  final int directionId;

  const Direction(this.destination, this.directionId);


  @override
  int get hashCode => destination.hashCode;

  @override
  bool operator ==(Object other) {
    return other is Direction && hashCode == other.hashCode;
  }
}


class LineDirection extends Direction {
  const LineDirection(this.line, super.destination, super.directionId);

  LineDirection.fromDir(BusLine line, Direction dir) :
      this(line, dir.destination, dir.directionId);

  LineDirection.fromJson(Map<String, dynamic> json, Map<String, BusLine> lines) :
      this(lines[json["lineId"]]!, json["destination"], json["directionId"]);

  final BusLine line;

  @override
  int get hashCode => line.hashCode ^ super.hashCode;

  @override
  bool operator ==(Object other) {
    return other is LineDirection && hashCode == other.hashCode;
  }

  @override
  String toString() {
    return '{${line.id}, $destination, $directionId}';
  }

  Map<String, dynamic> toJson() {
    return {
      "lineId": line.id,
      "destination": destination,
      "directionId": directionId,
    };
  }
}

class LineDirected implements LineDirection {
  final LineDirection direction;

  LineDirected(this.direction);

  @override
  String get destination => direction.destination;

  @override
  int get directionId => direction.directionId;

  @override
  BusLine get line => direction.line;

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}