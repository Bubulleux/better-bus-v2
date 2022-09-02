import 'package:better_bus_v2/data_provider/gps_data_provider.dart';
import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/views/common/background.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

import '../../model/clean/bus_stop.dart';
import '../../model/clean/map_place.dart';

class PlaceSearchPage extends StatefulWidget {
  const PlaceSearchPage({Key? key}) : super(key: key);

  @override
  State<PlaceSearchPage> createState() => _PlaceSearchPageState();
}

class _PlaceSearchPageState extends State<PlaceSearchPage> {
  late TextEditingController textFieldController;
  List<BusStop>? stops;

  List<BusStop>? validStops;
  List<MapPlace>? validPlaces;

  LocationData? locationData;

  void inputChange(){
    String input = textFieldController.value.text;

    refreshStopsSearch(input);
    refreshPlaceSearch(input);
  }

  void refreshStopsSearch(String search) {
    if (stops == null) {
      return;
    }

    String optimisedSearch = search.toLowerCase();
    validStops = [];

    for (BusStop stop in stops!) {
      if (stop.name.toLowerCase().contains(optimisedSearch)){
        validStops!.add(stop);
      }
      if (validStops!.length >= 5) {
        break;
      }
    }

    setState(() {});
  }

  void refreshPlaceSearch(String search){
    if (search == "") {
      return;
    }

    validPlaces = null;
    setState(() {});
    VitalisDataProvider.getPlaceAutocomplet(search).then(
        (value) {
          validPlaces = value;
          setState(() {
          });
        }
    );
  }

  @override
  void initState() {
    super.initState();
    textFieldController = TextEditingController();
    textFieldController.addListener(() {inputChange();});

    VitalisDataProvider.getStops().then((value) {
      stops = value;
      refreshStopsSearch(textFieldController.value.text);
    });
    GpsDataProvider.getLocation().then((value){
      locationData = value;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    textFieldController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> listViewContent = [];

    Widget titleWidget(String title){
      return Container(
        decoration: CustomDecorations.of(context).boxBackground,
        child: Text(title),
      );
    }

    const Widget loading = CircularProgressIndicator();

    listViewContent.add(titleWidget("! Arrét de bus"));

    if (validStops != null) {
      for (BusStop stop in validStops!){
        listViewContent.add(
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(MapPlace(title: stop.name, type: "busStop", latitude: stop.latitude, longitude: stop.longitude)),
              child: Container(
                child: Row(
                  children: [
                    Text(stop.name),
                    const Spacer(),

                  ],
                ),
              ),
            ),
          )
        );
      }
    } else {
      listViewContent.add(loading);
    }

    listViewContent.add(titleWidget("! Adresse"));

    if (validPlaces != null) {
      for (MapPlace place in validPlaces!){
        listViewContent.add(
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(place),
                child: Container(
                  child: Row(
                    children: [
                      Text(place.title),
                      const Spacer(),

                    ],
                  ),
                ),
              ),
            )
        );
      }
    } else {
      listViewContent.add(loading);
    }

    return Scaffold(
      body: SafeArea(
        child: Background(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                TextField(
                  controller: textFieldController,
                  decoration: InputDecoration(
                    fillColor: Theme.of(context).backgroundColor,
                    filled: true,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) => listViewContent[index],
                    itemCount: listViewContent.length,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


