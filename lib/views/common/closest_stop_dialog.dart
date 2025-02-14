import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/core/full_provider.dart';
import 'package:better_bus_v2/core/models/station.dart';
import 'package:better_bus_v2/data_provider/gps_data_provider.dart';
import 'package:better_bus_v2/error_handler/custom_error.dart';
import 'package:better_bus_v2/views/common/custom_future.dart';
import 'package:better_bus_v2/views/stop_info/stop_info_page.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class ClosestStopDialog {
  static Future show(BuildContext context) async {
    Station? stop = await showDialog(
        context: context,
        builder: (BuildContext context) {
        return AlertDialog(
            title: const Text(AppString.myStop),
            content: CustomFutureBuilder<List<Station>?>(
              future: () => getClosestStops(context),
              onData: (context, data, refresh) {
              List<Station> stops = data;
              if (stops.length == 1) {
                goToStop(context, stops[0]);
                return Container();
              }

              return SizedBox(
                  width: double.maxFinite,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: stops.length,
                    itemBuilder: (BuildContext context, int index) {
                    Station stop = stops[index];
                    return InkWell(
                        onTap: () => goToStop(context, stop),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(stop.name),
                          ),
                        );
                    },
                    separatorBuilder: (context, i) => const Divider(),
                    ),
                  );
              },
              onLoading: (context) => const Center(heightFactor: 1.5, child: CircularProgressIndicator()),
              onError: (context, error, retry) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    error.build(context, retry),
                    const SizedBox(height: 30,),
                    ElevatedButton(onPressed: () => Navigator.of(context).pop(), 
                    child: const Text("Ok")),
                  ],
                );
              },
              errorTest: (data) {
                List<Station>? stops = data;
                if (stops!.isEmpty) {
                  return CustomErrors.noCloseStop;
                }
                return null;
              },
        )
          );
        },
barrierDismissible: false,
                    );
    if (stop != null) {
      Navigator.of(context).pushNamed(StopInfoPage.routeName, 
        arguments: StopInfoPageArgument(stop, null));
    }
  }

  static Future<List<Station>?> getClosestStops(context) async {
    LatLng? location = await GpsDataProvider.getLocation(askEnableGPS: true);
    List<Station>? stops = await FullProvider.of(context).getStations();
    List<Station> result = [];
  
    if (location == null) {
      throw CustomErrors.locationDisable;
    }

    for (Station stop in stops!) {
      double distance = GpsDataProvider.calculateDistance(
          location.latitude, location.longitude, stop.position.latitude, stop.position.longitude);
      if (distance < 0.1) {
        result.add(stop);
      }
    }
    return result;
  }

  static void goToStop(BuildContext context, Station stop) {
    Navigator.of(context).pop(stop);
  }
}
