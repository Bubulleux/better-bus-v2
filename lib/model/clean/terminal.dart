
import 'bus_line.dart';

class Terminal {
  Terminal(this.endStopId, this.line, {this.goWay = true});
  Terminal.example(): this(0000, BusLine.example());
  Terminal.fromJson(Map<String, dynamic> json)
  :this(
    json["endStopId"],
    BusLine.fromCleanJson(json["line"]),
    goWay: json["goWay"],
  );

  int endStopId;
  BusLine line;
  bool goWay;

  Map<String, dynamic> toJson() {
    return {
      "endStopId": endStopId,
      "line": line.toJson(),
      "goWay": goWay,
    };
  }
}