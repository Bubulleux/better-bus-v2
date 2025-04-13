import 'package:better_bus_core/core.dart';
import 'package:flutter/material.dart';

import '../../app_constant/app_string.dart';
import '../common/closest_stop_dialog.dart';
import '../map_pages/map_page.dart';
import '../route_page/route_page.dart';
import '../stop_info/stop_info_page.dart';
import '../stops_search_page/stops_search_page.dart';
import '../traffic_info_page/traffic_info_page.dart';

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({bool map = false, super.key});


  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {

  void goToTrafficInfo() {
    Navigator.of(context).pushNamed(TrafficInfoPage.routeName);
  }

  void goToRoutePage() {
    Navigator.of(context).pushNamed(RoutePage.routeName);
  }

  void goToMapTest() {
    Navigator.of(context).pushNamed(MapPage.routeName);
  }

  Future findClosestStop() async {
    ClosestStopDialog.show(context);
  }


  @override
  Widget build(BuildContext context) {
    final entries = [
      CustomNavigationItem(
        label: AppString.searchLabel,
        icon: Icons.search,
        // TODO: Make it do something
        onPress: () {},
      ),
      CustomNavigationItem(
        label: AppString.routeLabel,
        icon: Icons.route,
        onPress: goToRoutePage,
      ),
      CustomNavigationItem(
        label: AppString.trafficInfoLabel,
        icon: Icons.bus_alert,
        onPress: goToTrafficInfo,
      )
    ];

    return Material(
      elevation: 5,
      child: Wrap(
        children: [
          Container(
            height: 5,
            width: double.infinity,
            color: Theme.of(context).primaryColor,
          ),
          Container(
            width: double.infinity,
            color: Colors.white,
            child: Wrap(
              alignment: WrapAlignment.spaceAround,
              children: entries,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomNavigationItem extends StatelessWidget {
  const CustomNavigationItem({
    super.key,
    required this.label,
    required this.icon,
    required this.onPress,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPress,
        child: SizedBox(
          height: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon),
              Text(label, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ),
      ),
    );
  }
}
