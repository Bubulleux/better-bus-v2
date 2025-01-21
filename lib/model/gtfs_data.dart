import 'package:better_bus_v2/helper.dart';
import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/model/cvs_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:latlong2/latlong.dart';

class GTFSData {
  late final Map<String, BusStop> stations;
  late final Map<String, SubBusStop> stops;
  late final Map<String, GTFSRoute> routes;
  late final GTFSCalendar calendar;
  late final Map<String, GTFSTrip> trips;
  late final Map<String, List<GTFSStopTime>> stopTime;
  late final Map<String, GTFSShape> shapes;

  GTFSData(Map<String, CSVTable> files) {
    loadStops(files["stops.txt"]!);
    loadRoutes(files["routes.txt"]!);
    calendar = GTFSCalendar.fromCSV(
        files["calendar.txt"]!, files["calendar_dates.txt"]!);
    loadShapes(files["shapes.txt"]!);
    loadTrips(files["trips.txt"]!);
    loadStopTime(files["stop_times.txt"]!);
  }

  void loadStops(CSVTable table) {
    Map<String, GTFSStop> _station = {};
    Map<String, GTFSStopChild> _stops = {};
    Map<String, List<GTFSStopChild>> child = {};

    for (var e in table) {
      final parent = e["parent_station"];
      final id = e["stop_id"];
      final stopChild = GTFSStopChild.fromCSV(e);
      _stops[id] =  stopChild;
      if (parent != "") {
        if (!child.containsKey(parent)) {
          child[parent] = [];
        }
        child[parent]!.add(stopChild);
        continue;
      }
      
      _station[id] = GTFSStop.fromCSV(e);
    }

    for (var child in child.entries) {
      _station[child.key] = _station[child.key]!.withChildren(child.value);
    }

    stops = _stops;
    stations = _station;
  }

  void loadRoutes(CSVTable table) {
    routes = {for (var e in table) e["route_id"]: GTFSRoute.fromCSV(e)};
  }

  void loadTrips(CSVTable table) {
    trips = {for (var e in table) e["trip_id"]: GTFSTrip.fromCSV(e)};
  }

  void loadStopTime(CSVTable table) {
    Map<String, List<GTFSStopTime>> _stopTimes = {};
    for (var row in table) {
      String tripID = row["trip_id"];

      if (!_stopTimes.containsKey(tripID)) {
        _stopTimes[tripID] = [];
      }

      int index = int.parse(row["stop_sequence"]) - 1;

      if (_stopTimes[tripID]!.length > index) {
        _stopTimes[tripID]![index] = GTFSStopTime.fromCSV(row);
      }

      while (_stopTimes[tripID]!.length <= index) {
        _stopTimes[tripID]!.add(GTFSStopTime.fromCSV(row));
      }
    }

    stopTime = _stopTimes;
  }

  void loadShapes(CSVTable table) {
    Map<String, List<LatLng>> rawShapes = {};

    for (var e in table) {
      String id = e["shape_id"];
      if (!rawShapes.containsKey(id)) {
        rawShapes[id] = [];
      }
      double lat = double.parse(e["shape_pt_lat"]);
      double long = double.parse(e["shape_pt_lon"]);
      rawShapes[id]!.add(LatLng(lat, long));
    }

    shapes = { for (var e in rawShapes.entries) e.key : GTFSShape(e.key, e.value)};
  }

}

class GTFSStop extends BusStop {
  const GTFSStop(super.name, super.id, super.pos, {super.children});

  GTFSStop.fromCSV(Map<String, String> row)
      : this(
            row["stop_name"]!,
            int.parse(row["stop_id"]!),
            LatLng(double.parse(row["stop_lat"]!),
                double.parse(row["stop_lon"]!)));

  GTFSStop withChildren(List<SubBusStop> newChildren) {
    return GTFSStop(name, id, pos, children: newChildren);
  }
}

class GTFSStopChild extends SubBusStop {
  GTFSStopChild(super.id, super.pos);

  GTFSStopChild.fromCSV(Map<String, String> row)
      : this(
            int.parse(row["stop_id"]!),
            LatLng(double.parse(row["stop_lat"]!),
                double.parse(row["stop_lon"]!)));
}

class GTFSRoute {
  final String id;
  final String shortName;
  final String longName;
  final Color color;

  GTFSRoute(this.id, this.shortName, this.longName, this.color);

  GTFSRoute.fromCSV(Map<String, String> row)
      : this(
          row["route_id"]!,
          row["route_short_name"]!,
          row["route_long_name"]!,
          colorFromHex("#" + row["route_color"]!),
        );
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

class GTFSTrip {
  final String routeID;
  final String serviceID;
  final String headSign;
  final bool direction;
  final String shapeID;

  GTFSTrip(this.routeID, this.serviceID, this.headSign, this.direction,
      this.shapeID);

  GTFSTrip.fromCSV(Map<String, String> row)
      : this(
          row["route_id"]!,
          row["service_id"]!,
          row["trip_headsign"]!,
          row["direction_id"] == "1",
          row["shape_id"]!,
        );
}

class GTFSStopTime {
  final String tripID;
  final Duration arival;
  final String stopID;
  final double distanceTravel;

  GTFSStopTime(this.tripID, this.arival, this.stopID, this.distanceTravel);

  GTFSStopTime.fromCSV(Map<String, String> row)
      : this(
          row["trip_id"]!,
          parseDuration(row["arrival_time"]!),
          row["stop_id"]!,
          double.parse(row["shape_dist_traveled"]!),
        );
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
