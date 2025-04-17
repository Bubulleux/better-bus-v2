import 'package:flutter/material.dart';

import '../../app_constant/app_string.dart';
import '../common/closest_stop_dialog.dart';
import '../map_pages/map_page.dart';
import '../route_page/route_page.dart';
import '../traffic_info_page/traffic_info_page.dart';

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({required this.index, required this.onTap, super.key});

  final int index;
  final ValueChanged<int> onTap;


  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  final items = const [
    CustomNavigationItem(
      label: AppString.mapLabel,
      icon: Icons.map,
    ),
    CustomNavigationItem(
      label: AppString.routeLabel,
      icon: Icons.route,
    ),
    CustomNavigationItem(
      label: AppString.trafficInfoLabel,
      icon: Icons.bus_alert,
    )
  ];

  Widget buildItem(int index) {
    final active = index == widget.index;
    final icon = items[index].icon;
    final label = items[index].label;

    return Material(
      color: Colors.transparent,
      key: Key(index.toString()),
      child: InkWell(
        onTap: () => widget.onTap(index),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: 50,
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.symmetric(horizontal: 25),
          decoration: BoxDecoration(
            color: active ? Theme.of(context).primaryColor.withAlpha(150) : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
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

  @override
  Widget build(BuildContext context) {
    final entries = items.asMap().keys.map(buildItem).toList();

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

class CustomNavigationItem {
  const CustomNavigationItem({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;
}
