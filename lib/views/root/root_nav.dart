import 'package:better_bus_v2/views/home_page/navigation_bar.dart';
import 'package:better_bus_v2/views/map_pages/map_page.dart';
import 'package:better_bus_v2/views/route_page/route_page.dart';
import 'package:better_bus_v2/views/traffic_info_page/traffic_info_page.dart';
import 'package:flutter/material.dart';

import '../../app_constant/app_string.dart';
import '../../data_provider/local_data_handler.dart';
import '../../model/view_shortcut.dart';

class RootNav extends StatefulWidget {
  const RootNav({this.launchUri, super.key});

  final Uri? launchUri;

  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  ViewShortcut? initialShortcut;
  int? infoTrafficIndex;
  bool openClosest = false;
  int _curIndex = 0;


  List<Widget> getPages() => [
    MapPage(initialShortcut: initialShortcut, openClosest: openClosest),
    RoutePage(),
    TrafficInfoPage(focused: infoTrafficIndex)
  ];

  @override
  void initState() {
    super.initState();
    if (widget.launchUri != null) launchUri();
  }

  @override
  void didUpdateWidget(covariant RootNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.launchUri != widget.launchUri) {
      launchUri();
    }
  }

  void launchUri() async {
    assert(widget.launchUri != null);
    final uri = widget.launchUri!;
    print("Uri recie $uri");
    if (uri.scheme != "app") {
      return;
    }

    if (uri.host == "openshortcut") {
      int shortcutIndex = int.parse(uri.pathSegments[0]);
      print("Open shortcut $shortcutIndex");
      List<ViewShortcut> shortcuts = await LocalDataHandler.loadShortcut(context);
      if (shortcutIndex == -1 || !context.mounted) {
        return;
      }
      final shortcut = shortcuts.where((e) => e.isFavorite)
          .toList()[shortcutIndex];
      setState(() {
        initialShortcut = shortcut;
        _curIndex = 0;
      });
    }

    if (uri.host == "openmystop") {
      setState(() {
        _curIndex = 0;
        openClosest = true;
      });
    }
    if (uri.host == "infotraffic") {
      setState(() {
        _curIndex = 2;
        infoTrafficIndex = int.parse(uri.pathSegments[0]);
      });
    }
  }

  Widget buildNavBar() {
   return CustomNavigationBar(
     index: _curIndex,
     onTap: (index) => setState(() {
       _curIndex = index;
     }),
   );
  }

  void handlePop(bool didPop, _) {
    if (didPop) return;
    if (_curIndex != 0) {
      setState(() {
        _curIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Build with $infoTrafficIndex");
    return Scaffold(
        body: PopScope(
          canPop: false,
          onPopInvokedWithResult: handlePop,
          child: IndexedStack(
            children: getPages(),
            index: _curIndex,
          ),
        ),
        bottomNavigationBar: buildNavBar());
  }
}
