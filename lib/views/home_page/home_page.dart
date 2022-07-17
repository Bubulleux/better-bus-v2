
import 'dart:ui';

import 'package:better_bus_v2/data_provider/gps_data_provider.dart';
import 'package:better_bus_v2/views/common/background.dart';
import 'package:better_bus_v2/views/home_page/search_bar.dart';
import 'package:better_bus_v2/views/home_page/shortcut_section.dart';
import 'package:better_bus_v2/views/stop_info/stop_info_page.dart';
import 'package:flutter/material.dart';

import '../search_page/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  void searchBusStop(BuildContext context) {

    Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPage())).then((value){
      if (value == null) {
        return;
      }
      Navigator.push(context, MaterialPageRoute(builder: (context) => StopInfoPage(value)));
    });
  }

  @override
  void initState() {
    super.initState();
    GpsDataProvider.askForGPS();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Background(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(40)),
                  child: const SearchBar(),
                ),
                TextButton(
                    onPressed: () => {searchBusStop(context)},
                    child: const Text("Go Search")),
                const ShortcutWidgetRoot(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
