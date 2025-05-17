import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/data_provider/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AWGTFSProvider extends AppProvider {
  final ApiProvider api;
  AWGTFSProvider({required this.api, required super.downloader});

  factory AWGTFSProvider.of(BuildContext context) {
    return context.read<AWGTFSProvider>();
  }

  @override
  Future<GTFSTimeTable> getTimetable(Station station, {DateTime? time}) async {
    if (time != null && time.atMidnight() != DateTime.now().atMidnight()) {
      assert(super.isAvailable());
      return super.getTimetable(station, time: time);
    }

    GTFSTimeTable gtfsTimes = await super.getTimetable(station);
    final apiTimes = await api.getTimetable(station);

    return MatchingTimetable(apiTimes, gtfsTimes);

  }

  @override
  Future<List<InfoTraffic>> getTrafficInfos() {
    return api.getTrafficInfos();
  }

}