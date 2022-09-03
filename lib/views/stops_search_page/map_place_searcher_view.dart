import 'package:better_bus_v2/data_provider/gps_data_provider.dart';
import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/error_handler/custom_error.dart';
import 'package:better_bus_v2/views/common/custom_futur.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:better_bus_v2/views/stops_search_page/map_place_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:location/location.dart';

import '../../model/clean/map_place.dart';

typedef PlaceCallback = void Function(MapPlace place);

class MapPlaceSearcherView extends StatefulWidget {
  const MapPlaceSearcherView({required this.search, required this.placeCallback, Key? key}) : super(key: key);

  final String search;
  final PlaceCallback placeCallback;

  @override
  State<MapPlaceSearcherView> createState() => _MapPlaceSearcherViewState();
}

class _MapPlaceSearcherViewState extends State<MapPlaceSearcherView> {
  LocationData? locationData;
  late GlobalKey<CustomFutureBuilderState> futureStateKey;

  Future<List<MapPlace>?> getPlaces() async {
    if (widget.search == "") {
      return null;
    }
    List<MapPlace> output = await VitalisDataProvider.getPlaceAutocomplet(widget.search);
    if (widget.search == ""){
      return null;
    }
    return output;
  }

  @override
  void initState() {
    super.initState();
    GpsDataProvider.getLocation().then((value) => setState(() => locationData = value));
    futureStateKey = GlobalKey();
  }

  @override
  void didUpdateWidget(covariant MapPlaceSearcherView oldWidget) {
    if (oldWidget.search != widget.search) {
      // setState(() {});
      futureStateKey.currentState?.hideRefresh();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        locationData != null
            ? GestureDetector(
                onTap: () => widget.placeCallback(MapPlace(
                  title: "! Ma position",
                  type: "location",
                  latitude: locationData!.latitude!,
                  longitude: locationData!.longitude!,
                )),
                child: Container(
                  decoration: CustomDecorations.of(context).boxBackground,
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      const Icon(Icons.my_location),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        "! Ma position",
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
              if (data == null) {
                return Container();
              }
              return ListView.builder(
                itemBuilder: (context, index) {
                  MapPlace place = data[index];
                  return MapPlaceItemWidget(
                      place: place, locationData: locationData, clickCallback: () => widget.placeCallback(place));
                },
                itemCount: data.length,
              );
            },
            errorTest: (data) {
              if (data != null && data.length == 0) {
                return CustomErrors.searchPlaceNoResult;
              }
            },
          ),
        ),
      ],
    );
  }
}
