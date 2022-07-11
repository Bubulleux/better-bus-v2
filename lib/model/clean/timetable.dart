class Timetable {
  Timetable(this.schedule, this.terminalLabel);
  Timetable.fromJson(Map<String, dynamic> json)
  :this (
    json["horaire"].map((value) => BusSchedule.fromJson(value)).toList(),
    { for (var v in json["terminus"]) v["label"] : v["direction"] },
  );

  List<BusSchedule> schedule;
  Map<String, String> terminalLabel;
}

class BusSchedule {
  BusSchedule(this.time, this.label);

  BusSchedule.fromJson(Map<String, dynamic> json)
      : this(
          DateTime.parse(json["time"]),
          json["label"],
        );

  DateTime time;
  String label;
}
