import 'dart:convert';

import 'package:better_bus_v2/data_provider/gps_data_provider.dart';
import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/error_handler/custom_error.dart';
import 'package:better_bus_v2/views/common/custom_future.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:better_bus_v2/views/stops_search_page/map_place_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_constant/app_string.dart';
import '../../model/clean/map_place.dart';

typedef PlaceCallback = void Function(MapPlace place);

int maxHistoricSize = 20;

class MapPlaceSearcherView extends StatefulWidget {
  const MapPlaceSearcherView(
      {required this.search, required this.placeCallback, Key? key})
      : super(key: key);

  final String search;
  final PlaceCallback placeCallback;

  @override
  State<MapPlaceSearcherView> createState() => _MapPlaceSearcherViewState();
}

class _MapPlaceSearcherViewState extends State<MapPlaceSearcherView> {
  LocationData? locationData;
  bool locationPermission = true;
  late GlobalKey<CustomFutureBuilderState> futureStateKey;

  SharedPreferences? preferences;
  List<MapPlace>? historic;

  Future<List<MapPlace>?> getPlaces() async {
    if (widget.search == "") {
      return null;
    }
    List<MapPlace> output =
        await VitalisDataProvider.getPlaceAutoComplete(widget.search);
    if (widget.search == "") {
      return null;
    }
    return output;
  }

  Future<List<MapPlace>> getHistoric() async {
    preferences ??= await SharedPreferences.getInstance();
    List<String> rawHistoric =
        preferences!.getStringList("placeHistoric") ?? [];
    List<MapPlace> output =
        rawHistoric.map((e) => MapPlace.fromCleanJson(jsonDecode(e))).toList();
    return output;
  }

  Future<void> saveHistoric() async {
    preferences ??= await SharedPreferences.getInstance();
    await preferences!.setStringList("placeHistoric",
        historic!.map((e) => jsonEncode(e.toJson())).toList().cast<String>());
  }

  void addStopInHistoric(MapPlace place) {
    historic ??= [];

    historic!.removeWhere((element) => element == place);
    historic!.insert(0, place);
    while (historic!.length > maxHistoricSize) {
      historic!.removeLast();
    }
  }

  void placeClicked(MapPlace place) {
    addStopInHistoric(place);
    saveHistoric();
    widget.placeCallback(place);
  }

  @override
  void initState() {
    super.initState();
    GpsDataProvider.getLocation().then((value) {
      futureStateKey.currentState?.hideRefresh();
      setState(() => locationData = value);
    });

    GpsDataProvider.askForGPSPermission()
        .then((value) => setState(() => locationPermission = value));

    futureStateKey = GlobalKey();
    getHistoric().then((value) {
      futureStateKey.currentState?.hideRefresh();
      setState(() => historic = value);
    });
  }

  @override
  void didUpdateWidget(covariant MapPlaceSearcherView oldWidget) {
    if (oldWidget.search != widget.search) {
      futureStateKey.currentState?.hideRefresh();
    }
    super.didUpdateWidget(oldWidget);
  }

  void returnLocation() async {
    locationData = await GpsDataProvider.getLocation(askEnableGPS:  true);

    if (locationData == null) return;

    if (!mounted) return;

    widget.placeCallback(MapPlace(
      title: AppString.myPosition,
      address: "",
      type: "location",
      latitude: locationData!.latitude!,
      longitude: locationData!.longitude!,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        locationPermission
            ? GestureDetector(
                onTap: returnLocation,
                child: Container(
                  decoration: CustomDecorations.of(context).boxBackground,
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      const Icon(Icons.my_location),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        AppString.myPosition,
                        style: Theme.of(context).textTheme.titleLarge,
                      )
                    ],
                  ),
                ),
              )
            : Container(),
        Expanded(
          child: CustomFutureBuilder(
            key: futureStateKey,
            future: getPlaces,
            onData: (context, data, refresh) {
              return ListView.builder(
                itemBuilder: (context, index) {
                  MapPlace place = data?[index] ?? historic?[index] ?? [];
                  return MapPlaceItemWidget(
                      place: place,
                      locationData: locationData,
                      clickCallback: () => placeClicked(place),
                      inHistoric: (historic?.contains(place) ?? false));
                },
                itemCount: data?.length ?? historic?.length ?? 0,
              );
            },
            errorTest: (data) {
              if (data != null && data.length == 0) {
                return CustomErrors.searchPlaceNoResult;
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
