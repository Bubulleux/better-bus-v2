import 'package:better_bus_v2/data_provider/gps_data_provider.dart';
import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/error_handler/custom_error.dart';
import 'package:better_bus_v2/views/common/custom_futur.dart';
import 'package:better_bus_v2/views/stops_search_page/stop_bus_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/clean/bus_stop.dart';

typedef StopCallback = void Function(BusStop stop);

class SearchBusStopView extends StatefulWidget {
  const SearchBusStopView({
    required this.search,
    this.saveInHistoric = true,
    this.showHistoric = true,
    required this.stopCallback,
    Key? key
  }) : super(key: key);

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
  List<BusStop>? stops;

  List<BusStop>? historic;
  SharedPreferences? preferences;

  LocationData? location;

  late GlobalKey<CustomFutureBuilderState> futureBuilderState;

  Future<List<BusStop>> getValidStops() async{
    stops ??= await VitalisDataProvider.getStops();
    historic ??= await getHistoric();

    List<BusStop> output = [];
    if (widget.search == null) {
      return output;
    }

    for (BusStop stops in historic!) {
      if (stops.name.toLowerCase().contains(widget.search!.toLowerCase())) {
        output.add(stops);
      }
    }

    for (BusStop busStop in stops!) {
      if (busStop.name.toLowerCase().contains(widget.search!.toLowerCase()) && !historic!.contains(busStop)) {
        output.add(busStop);
      }
    }
    return output;
  }

  Future getLocation() async {
    location = await GpsDataProvider.getLocation();
    setState(() {});
  }

  Future<List<BusStop>> getHistoric() async {
    if (!widget.showHistoric){
      return [];
    }

    preferences ??= await SharedPreferences.getInstance();
    List<String> rawHistoric =
        preferences!.getStringList(historicPrefName) ?? [];
    List<BusStop> output = [];
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

  void addStopInHistoric(BusStop stop) {
    if (historic == null) {
      return;
    }

    historic!.removeWhere((element) => element == stop);
    historic!.insert(0, stop);
    while (historic!.length > maxHistoricSize) {
      historic!.removeLast();
    }
  }
  
  void stopSelected(BusStop stop) async {
    addStopInHistoric(stop);
    await saveHistoric();
    widget.stopCallback(stop);
  }
  
  @override
  void initState() {
    super.initState();
    futureBuilderState = GlobalKey();
    getLocation();
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
    return CustomFutureBuilder<List<BusStop>>(
      future: getValidStops,
      key: futureBuilderState,
      onData: (context, data, refresh) {
        return ListView.builder(
          itemBuilder: (context, index) {
            BusStop stop = data[index];
            return BusStopWidget(
              stop: data[index],
              stopDistance: location != null ?
              (GpsDataProvider.calculateDistance(location!.latitude, location!.longitude,stop.latitude, stop.longitude)  * 100).roundToDouble() / 100:
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