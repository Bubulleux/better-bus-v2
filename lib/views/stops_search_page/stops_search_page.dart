
import 'package:better_bus_v2/data_provider/gps_data_provider.dart';
import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/views/common/background.dart';
import 'package:better_bus_v2/views/common/custom_text_field.dart';
import 'package:better_bus_v2/views/stops_search_page/search_bus_stop_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

import '../../app_constant/app_string.dart';
import '../../model/clean/bus_line.dart';



double getDistanceInKMeter(BusStop stop, GeoPoint locationData) {
  double result = GpsDataProvider.calculateDistance(stop.latitude,
      stop.longitude, locationData.latitude, locationData.longitude);
  return result;
}

class SearchPageArgument{
  final bool saveInHistoric;
  final bool showHistoric;
  const SearchPageArgument({this.saveInHistoric = true, this.showHistoric = true});
}

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key})
      : super(key: key);
  static const String routeName = "/stopSearch";



  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late bool saveInHistoric;
  late bool showHistoric;

  List<BusStop>? busStops;
  Map<String, bool> resultExpand = {};
  Map<String, List<BusLine>?> busStopsLines = {};

  List<BusStop>? validResult;
  GeoPoint? locationData;



  TextEditingController textFieldController = TextEditingController();
  String? search;

  late GlobalKey<SearchBusStopViewState> searchViewStopKey;

  @override
  void initState() {
    super.initState();
    textFieldController.addListener(inputChange);
    // loadPage();

    searchViewStopKey = GlobalKey();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SearchPageArgument argument = ModalRoute.of(context)!.settings.arguments as SearchPageArgument? ?? const SearchPageArgument();
    saveInHistoric = argument.saveInHistoric;
    showHistoric = argument.saveInHistoric;
  }

  void inputChange() {
    setState(() {
      search = textFieldController.value.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Background(
          child: Padding(
            padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
            child: Column(
              children: [
                CustomTextField(
                  autofocus: true,
                  hint: AppString.searchStopHint,
                  controller: textFieldController,
                ),
                Expanded(
                  child: SearchBusStopView(
                    search: search,
                    stopCallback: (BusStop stop) {
                      Navigator.of(context).pop(stop);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



