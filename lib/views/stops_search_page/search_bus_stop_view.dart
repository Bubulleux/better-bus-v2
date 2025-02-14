import 'package:better_bus_v2/core/full_provider.dart';
import 'package:better_bus_v2/core/models/station.dart';
import 'package:better_bus_v2/data_provider/gps_data_provider.dart';
import 'package:better_bus_v2/error_handler/custom_error.dart';
import 'package:better_bus_v2/views/common/custom_future.dart';
import 'package:better_bus_v2/views/stops_search_page/stop_bus_item_widget.dart';
import 'package:better_bus_v2/views/stops_search_page/stops_search_page.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef StopCallback = void Function(Station stop);

class SearchBusStopView extends StatefulWidget {
  const SearchBusStopView({
    required this.search,
    this.saveInHistoric = true,
    this.showHistoric = true,
    required this.stopCallback,
    super.key
  });

  final String? search;
  final bool saveInHistoric;
  final bool showHistoric;
  final StopCallback stopCallback;


  @override
  State<SearchBusStopView> createState() => SearchBusStopViewState();
}

const historicPrefName = "historic";
const maxHistoricSize = 20;

class SearchBusStopViewState extends State<SearchBusStopView>{
  List<Station>? stops;

  List<Station>? historic;
  SharedPreferences? preferences;

  LatLng? location;
  Map<int, double>? stopDistance;

  late GlobalKey<CustomFutureBuilderState> futureBuilderState;

  // TODO: Make it less blocking and update more
  Future<List<Station>> getValidStops() async{
    stops ??= await FullProvider.of(context).getStations();
    historic ??= await getHistoric();
    location ??= await GpsDataProvider.getLocation();

    if (location != null) {
      stopDistance = {};
      for (Station stop in stops!) {
        stopDistance![stop.id] = getDistanceInKMeter(stop, location!);
      }
    }

    List<Station> output = [];
    if (widget.search == null) {
      return output;
    }

    if (location != null) {
      stops!.sort((a, b) => stopDistance![a.id]!.compareTo(stopDistance![b.id]!));
    }


    for (Station stops in historic!) {
      if (stops.name.toLowerCase().contains(widget.search!.toLowerCase())) {
        output.add(stops);
      }
    }

    for (Station busStop in stops!) {
      if (busStop.name.toLowerCase().contains(widget.search!.toLowerCase()) && !historic!.contains(busStop)) {
        output.add(busStop);
      }
    }
    return output;
  }

  Future<List<Station>> getHistoric() async {
    if (!widget.showHistoric){
      return [];
    }

    preferences ??= await SharedPreferences.getInstance();
    List<String> rawHistoric =
        preferences!.getStringList(historicPrefName) ?? [];
    List<Station> output = [];
    for (String stopName in rawHistoric) {
      int busStopIndex = stops!.indexWhere((element) => element.name == stopName);
      if (busStopIndex == -1) {
        continue;
      }
      output.add(stops![busStopIndex]);
    }
    return output;
  }

  Future<void> saveHistoric() async {
    preferences ??= await SharedPreferences.getInstance();
    await preferences!.setStringList(
        historicPrefName, historic!.map((e) => e.name).toList().cast<String>());
  }

  void addStopInHistoric(Station stop) {
    if (historic == null) {
      return;
    }

    historic!.removeWhere((element) => element == stop);
    historic!.insert(0, stop);
    while (historic!.length > maxHistoricSize) {
      historic!.removeLast();
    }
  }
  
  void stopSelected(Station stop) async {
    addStopInHistoric(stop);
    await saveHistoric();
    widget.stopCallback(stop);
  }
  
  @override
  void initState() {
    super.initState();
    futureBuilderState = GlobalKey();
  }

  @override
  void didUpdateWidget(covariant SearchBusStopView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.search != oldWidget.search) {
      futureBuilderState.currentState?.hideRefresh();
    }
  }


  @override
  Widget build(BuildContext context) {
    return CustomFutureBuilder<List<Station>>(
      future: getValidStops,
      key: futureBuilderState,
      onData: (context, data, refresh) {
        return ListView.builder(
          itemBuilder: (context, index) {
            Station stop = data[index];
            return BusStopWidget(
              stop: data[index],
              stopDistance: stopDistance != null ?
              (stopDistance![stop.id]!  * 100).roundToDouble() / 100:
              null,
              inHistoric: historic!.contains(data[index]),
              onPressed: () => stopSelected(stop),
            );
          },
          itemCount: data.length,
        );
      },
      errorTest: (data) {
        if (data.length == 0) {
          return CustomErrors.searchError;
        }
        return null;
      },
    );
  }
}
