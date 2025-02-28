import 'package:better_bus_core/src/helper.dart';
import 'package:latlong2/latlong.dart';

import '../station.dart';
import 'csv_parser.dart';
import 'line.dart';
import 'stop.dart';
import 'stop_time.dart';
import 'trip.dart';

class GTFSData {
  late final Map<int, Station> stations;
  late final Map<int, Station> stopsParent;

  late final Map<int, GTFSLine> routes;
  late final GTFSCalendar calendar;
  late final Map<int, GTFSTrip> trips;
  late final Map<int, List<GTFSStopTime>> stopTime;

  //late final Map<String, GTFSShape> shapes;

  GTFSData(Map<String, CSVTable> files) {
    loadStops(files["stops.txt"]!);
    loadRoutes(files["routes.txt"]!, files["trips.txt"]!);
    calendar = GTFSCalendar.fromCSV(
        files["calendar.txt"]!, files["calendar_dates.txt"]!);
    //loadShapes(files["shapes.txt"]!);
    loadStopTime(files["stop_times.txt"]!);
    loadTrips(files["trips.txt"]!);
  }

  void loadStops(CSVTable table) {
    Map<int, GTFSStop> rawStations = {};
    Map<int, List<GTFSStop>> rawStops = {};
    //Map<String, BusStop> _stopParent = {};
    //Map<String, List<GTFSStopChild>> child = {};

    for (var e in table) {
      final curStop = GTFSStop.fromCSV(e);
      if (curStop.parent == null) {
        rawStations[curStop.id] = curStop;
      } else {
        if (!rawStops.containsKey(curStop.parent!)) {
          rawStops[curStop.parent!] = [];
        }
        rawStops[curStop.parent!]!.add(curStop);
      }
      // final parent = e["parent_station"];
      // final id = e["stop_id"];
      // final stopChild = GTFSStopChild.fromCSV(e);
      // _stops[id] =  stopChild;
      // if (parent != "") {
      //   if (!child.containsKey(parent)) {
      //     child[parent] = [];
      //   }
      //   child[parent]!.add(stopChild);
      //   continue;
      // }
      //
      // _station[id] = GTFSStop.fromCSV(e);
    }
    Map<int, Station> result = {};
    Map<int, Station> newStopParent = {};

    for (var e in rawStations.entries) {
      final stops = rawStops[e.key]!;
      final station = e.value.toStation(stops);
      result[e.key] = station;
      newStopParent.addEntries(stops.map((e) => MapEntry(e.id, station)));
    }

    stations = result;
    stopsParent = newStopParent;
  }

  void loadRoutes(CSVTable table, CSVTable tripTable) {
    routes = {
      for (var e in table) int.parse(e["route_id"]): GTFSLine.fromCSV(e)
    };
  }

  void loadTrips(CSVTable table) {
    trips = {
      for (var e in table)
        int.parse(e["trip_id"]):
            GTFSTrip(e, stopTime[int.parse(e["trip_id"]!)]!, this)
    };
  }

  void loadStopTime(CSVTable table) {
    Map<int, List<GTFSStopTime>> stopTimes = {};
    for (var row in table) {
      int tripID = int.parse(row["trip_id"]!);

      if (!stopTimes.containsKey(tripID)) {
        stopTimes[tripID] = [];
      }

      int index = int.parse(row["stop_sequence"]) - 1;

      if (stopTimes[tripID]!.length > index) {
        stopTimes[tripID]![index] = GTFSStopTime(row);
      }

      while (stopTimes[tripID]!.length <= index) {
        stopTimes[tripID]!.add(GTFSStopTime(row));
      }
    }

    stopTime = stopTimes;
  }

// void loadShapes(CSVTable table) {
//   Map<String, List<LatLng>> rawShapes = {};
//
//   for (var e in table) {
//     String id = e["shape_id"];
//     if (!rawShapes.containsKey(id)) {
//       rawShapes[id] = [];
//     }
//     double lat = double.parse(e["shape_pt_lat"]);
//     double long = double.parse(e["shape_pt_lon"]);
//     rawShapes[id]!.add(LatLng(lat, long));
//   }
//
//   shapes = { for (var e in rawShapes.entries) e.key : GTFSShape(e.key, e.value)};
// }
}

class GTFSService {
  final Set<int> enableDays;
  final DateTime startDate;
  final DateTime endDate;

  GTFSService(this.enableDays, this.startDate, this.endDate);

  factory GTFSService.fromCSV(Map<String, String> row) {
    Set<int> enableDays = {};
    List<String> weekDays = [
      "monday",
      "tuesday",
      "wednesday",
      "thursday",
      "friday",
      "saturday",
      "sunday"
    ];

    for (int i = 1; i < 8; i++) {
      if (row[weekDays[i - 1]] == "1") {
        enableDays.add(i);
      }
    }

    return GTFSService(
        enableDays,
        DateTime.parse(row["start_date"]!),
        DateTime.parse(row["end_date"]!)
            .add(const Duration(days: 1, seconds: -1)));
  }

  bool isEnable(DateTime date) {
    if (date.isBefore(startDate) | date.isAfter(endDate)) return false;
    return enableDays.contains(date.weekday);
  }
}

enum ExceptionType { add, remove }

class GTFSServiceException {
  final String serviceID;
  final DateTime date;
  final ExceptionType type;

  GTFSServiceException(this.serviceID, this.date, this.type);

  GTFSServiceException.fromCSV(Map<String, String> row)
      : this(
          row["service_id"]!,
          DateTime.parse(row["date"]!),
          ExceptionType.values[int.parse(row["exception_type"]!) - 1],
        );
}

class GTFSCalendar {
  final Map<String, GTFSService> services;
  final List<GTFSServiceException> exceptions;

  GTFSCalendar(this.services, this.exceptions);

  factory GTFSCalendar.fromCSV(
      CSVTable servicesTable, CSVTable exceptionsTable) {
    Map<String, GTFSService> services = {
      for (var row in servicesTable) row["service_id"]: GTFSService.fromCSV(row)
    };

    List<GTFSServiceException> exceptions = [
      for (var row in exceptionsTable) GTFSServiceException.fromCSV(row)
    ];

    return GTFSCalendar(services, exceptions);
  }

  Set<String> getEnablesServices(DateTime date) {
    date = date.atMidnight();
    Set<String> servicesEnable = {};
    for (var items in services.entries) {
      if (!items.value.isEnable(date)) continue;
      servicesEnable.add(items.key);
    }

    for (var exception in exceptions) {
      if (exception.date != date) continue;

      if (exception.type == ExceptionType.add) {
        servicesEnable.add(exception.serviceID);
      }

      if (exception.type == ExceptionType.remove) {
        servicesEnable.remove(exception.serviceID);
      }
    }

    return servicesEnable;
  }
}

class GTFSShape {
  final String shapeId;
  final List<LatLng> wayPoints;

  GTFSShape(this.shapeId, this.wayPoints);
}

Duration parseDuration(String time) {
  List<String> timeParts = time.split(":");
  int hours = int.parse(timeParts[0]);
  int minutes = int.parse(timeParts[1]);
  int seconds = int.parse(timeParts[2]);

  return Duration(hours: hours, minutes: minutes, seconds: seconds);
}
