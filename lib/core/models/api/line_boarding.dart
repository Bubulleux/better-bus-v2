import 'package:better_bus_v2/core/models/bus_line.dart';

class LineBoarding {
  LineBoarding(this.busStop, this.go, this.back);

  LineBoarding.fromJson(Map<String, dynamic> json, BusLine line)
  {
    busStop = int.parse(json["stop_id"]);
    List<String> rawGo = json["boarding_ids"]["aller"].toSet().toList().cast<String>();
    List<String> rawBack = json["boarding_ids"]["retour"].toSet().toList().cast<String>();
    go = {
      for (int i = 0; i < rawGo.length; i++)
        line.goDirection[i]: int.parse(rawGo[i])
    };

    back = {
      for (int i = 0; i < rawBack.length; i++)
        line.backDirection[i]: int.parse(rawBack[i])
    };
  }

  late int busStop;
  late Map<String, int> go;
  late Map<String, int> back;
}
