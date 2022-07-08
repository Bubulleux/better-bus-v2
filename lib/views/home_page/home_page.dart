
import 'dart:ui';

import 'package:better_bus_v2/data_provider/gps_data.dart';
import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/views/common/background.dart';
import 'package:better_bus_v2/views/home_page/search_bar.dart';
import 'package:better_bus_v2/views/home_page/shortcut_section.dart';
import 'package:flutter/material.dart';
import 'package:better_bus_v2/model/clean/view_shortcut.dart';

import '../search_page/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  void searchBusStop(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage()));
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
                  child: SearchBar(),
                ),
                TextButton(
                    onPressed: () => {searchBusStop(context)},
                    child: Text("Go Search")),
                ShortcutWidgetRoot(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
