import 'package:better_bus_v2/views/home_page/navigation_bar.dart';
import 'package:better_bus_v2/views/map_pages/map_page.dart';
import 'package:better_bus_v2/views/route_page/route_page.dart';
import 'package:better_bus_v2/views/traffic_info_page/traffic_info_page.dart';
import 'package:flutter/material.dart';

import '../app_constant/app_string.dart';

class RootNav extends StatefulWidget {
  const RootNav({super.key});

  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _curIndex = 0;
  final pages = [
    MapPage(key: GlobalKey(),),
    RoutePage(key: GlobalKey(),),
    TrafficInfoPage(key: GlobalKey(),)
  ];

  Widget buildNavBar() {
   return CustomNavigationBar(
     index: _curIndex,
     onTap: (index) => setState(() {
       _curIndex = index;
     }),
   );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: IndexedStack(
          children: pages,
          index: _curIndex,
        ),
        bottomNavigationBar: buildNavBar());
  }
}
