
import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/core/models/bus_line.dart';
import 'package:better_bus_v2/core/models/place.dart';
import 'package:better_bus_v2/core/models/station.dart';
import 'package:better_bus_v2/data_provider/gps_data_provider.dart';
import 'package:better_bus_v2/views/common/background.dart';
import 'package:better_bus_v2/views/common/custom_text_field.dart';
import 'package:better_bus_v2/views/stops_search_page/search_bus_stop_view.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';



// TODO: Move it to helper file
double getDistanceInKMeter(Place place, LatLng locationData) {
  double result = GpsDataProvider.calculateDistance(place.position.latitude,
      place.position.longitude, locationData.latitude, locationData.longitude);
  return result;
}

class SearchPageArgument{
  final bool saveInHistoric;
  final bool showHistoric;
  const SearchPageArgument({this.saveInHistoric = true, this.showHistoric = true});
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  static const String routeName = "/stopSearch";



  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late bool saveInHistoric;
  late bool showHistoric;

  List<Station>? busStops;
  Map<String, bool> resultExpand = {};
  Map<String, List<BusLine>?> busStopsLines = {};

  List<Station>? validResult;
  LatLng? locationData;



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
                    stopCallback: (Station stop) {
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



