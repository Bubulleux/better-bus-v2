import 'package:better_bus_v2/data_provider/gps_data_provider.dart';
import 'package:better_bus_v2/model/clean/map_place.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class MapPlaceItemWidget extends StatelessWidget {
  const MapPlaceItemWidget({
    Key? key,
    required this.place,
    required this.locationData,
    required this.clickCallback,
  }) : super(key: key);

  final MapPlace place;
  final LocationData? locationData;
  final VoidCallback clickCallback;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: GestureDetector(
        onTap: clickCallback,
        child: Container(
          decoration: CustomDecorations.of(context).boxBackground,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              locationData != null
                  ? Text(
                      "${(GpsDataProvider.calculateDistance(locationData!.latitude, locationData!.longitude,
                          place.latitude, place.longitude) * 100).roundToDouble() / 100} Km",
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                ),
              )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
