import 'package:better_bus_v2/core/models/place.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:better_bus_v2/views/stops_search_page/stops_search_page.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class MapPlaceItemWidget extends StatelessWidget {
  const MapPlaceItemWidget(
      {super.key,
      required this.place,
      required this.locationData,
      required this.clickCallback,
      required this.inHistoric});

  final Place place;
  final LatLng? locationData;
  final VoidCallback clickCallback;
  final bool inHistoric;

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
              RichText(
                  text: TextSpan(
                children: [
                  inHistoric ? 
                  WidgetSpan(
                    child: Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Icon(Icons.history,
                                color: Theme.of(context).primaryColor),
                          )
                  ) : const TextSpan(),
                  TextSpan(text: place.name),
                ],
                style: Theme.of(context).textTheme.titleLarge,
              )),
              place.name != place.address && place.address != ""
                  ? Text(
                      place.address ?? "",
                      style: Theme.of(context).textTheme.titleMedium,
                    )
                  : Container(),
              locationData != null
                  ? Text(
                      "${(getDistanceInKMeter(place, locationData!) * 100).roundToDouble() / 100} Km",
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
