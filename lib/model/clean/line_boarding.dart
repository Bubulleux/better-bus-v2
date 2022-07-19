import 'bus_line.dart';

class LineBoarding {
  LineBoarding(this.busStop, this.go, this.back);

  LineBoarding.fromJson(Map<String, dynamic> json, BusLine line)
      : this(
          int.parse(json["stop_id"]),
          {
            for (int i = 0; i < json["boarding_ids"]["aller"].length; i++)
              line.goDirection[i]: int.parse(json["boarding_ids"]["aller"][i])
          },
          {
            for (int i = 0; i < json["boarding_ids"]["retour"].length; i++)
              line.backDirection[i]:
                  int.parse(json["boarding_ids"]["retour"][i])
          },
        );

  int busStop;
  Map<String, int> go;
  Map<String, int> back;
}
