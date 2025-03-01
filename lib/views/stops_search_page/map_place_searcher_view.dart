import 'dart:convert';

import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/core/full_provider.dart';
import 'package:better_bus_v2/core/models/place.dart';
import 'package:better_bus_v2/data_provider/gps_data_provider.dart';
import 'package:better_bus_v2/error_handler/custom_error.dart';
import 'package:better_bus_v2/views/common/custom_future.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:better_bus_v2/views/stops_search_page/map_place_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef PlaceCallback = void Function(Place place);

int maxHistoricSize = 20;

class MapPlaceSearcherView extends StatefulWidget {
  const MapPlaceSearcherView(
      {required this.search, required this.placeCallback, super.key});

  final String search;
  final PlaceCallback placeCallback;

  @override
  State<MapPlaceSearcherView> createState() => _MapPlaceSearcherViewState();
}

class _MapPlaceSearcherViewState extends State<MapPlaceSearcherView> {
  LatLng? locationData;
  bool locationPermission = true;
  late GlobalKey<CustomFutureBuilderState> futureStateKey;

  SharedPreferences? preferences;
  List<Place>? historic;

  Future<List<Place>?> getPlaces() async {
    if (widget.search == "") {
      return null;
    }
    List<Place> output = await FullProvider.of(context).api.getPlaceAutoComplete(widget.search);


    if (widget.search == "") {
      return null;
    }
    return output;
  }

  // TODO: Re implement historic
  Future<List<Place>> getHistoric() async {

    preferences ??= await SharedPreferences.getInstance();
    List<String> rawHistoric =
        preferences!.getStringList("placeHistoric") ?? [];
    List<Place> output =
        rawHistoric.map((e) => Place.fromJson(jsonDecode(e))).toList();
    return output;
  }

  Future<void> saveHistoric() async {
    preferences ??= await SharedPreferences.getInstance();
    await preferences!.setStringList("placeHistoric",
        historic!.map((e) => jsonEncode(e.toJson())).toList().cast<String>());
  }

  void addStopInHistoric(Place place) {
    historic ??= [];

    historic!.removeWhere((element) => element == place);
    historic!.insert(0, place);
    while (historic!.length > maxHistoricSize) {
      historic!.removeLast();
    }
  }

  void placeClicked(Place place) {
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
    locationData = await GpsDataProvider.getLocation(askEnableGPS: true);

    if (locationData == null) return;

    if (!mounted) return;

    widget.placeCallback(Place(AppString.myPosition, locationData!));
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
                  Place place = data?[index] ?? historic?[index] ?? [];
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
