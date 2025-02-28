
import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_core/core.dart';
import 'package:flutter/material.dart';

class StopSearcher extends StatefulWidget {
  const StopSearcher({super.key});

  @override
  State<StopSearcher> createState() => _StopSearcherState();
}

class _StopSearcherState extends State<StopSearcher> {
  _StopSearcherState() {
    FullProvider.of(context).getStations().then((value) => {
          setState(() {
            busStops = value;
          })
        });
  }

  bool showResult = false;
  List<Station>? busStops;


  void fieldFocusChange(bool focus) {
    setState(() {
      showResult = focus;
    });
  }

  @override
  Widget build(BuildContext context) {

    TextField searchBar = const TextField(
      decoration: InputDecoration(
        hintText: AppString.findStop,
        border: OutlineInputBorder(),
      ),
    );

    Widget? outputWidget;

    if (showResult) {
      outputWidget = Container(
        height: 200,
        color: Colors.red,
      );
    }

    return Column(
      children: [
        Focus(
          child: searchBar,
          onFocusChange: fieldFocusChange,
        ),
        Container(
          child: outputWidget,
        ),
      ],
    );
  }
}
