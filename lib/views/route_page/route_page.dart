import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/views/common/custom_future.dart';
import 'package:better_bus_v2/views/map/controller.dart';
import 'package:better_bus_v2/views/map/map_view.dart';
import 'package:better_bus_v2/views/map/search_parameter_layer.dart';
import 'package:better_bus_v2/views/route_page/route_detail.dart';
import 'package:better_bus_v2/views/route_page/route_search.dart';
import 'package:better_bus_v2/views/route_page/route_search_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({super.key});

  static const String routeName = "/RouteFinder";

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  RouteSearchParameter? parameter;
  VitalisRoute? route;
  late PageController _pageController;

  late NetworkMapController controller;

  @override
  void initState() {
    super.initState();
    controller = NetworkMapController(context);
    _pageController = PageController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void selectRoute(VitalisRoute newRoute) {
    route = newRoute;
    goToDetail();
    updateCam();
    setState(() {});
  }

  void setSearch(RouteSearchParameter newParameter) {
    parameter = newParameter;
    route = null;
    goToSearch();
    updateCam();
    setState(() {});
  }

  void updateCam() {
    if (parameter!.valid) {
      final cam = CameraFit.coordinates(coordinates: [
        parameter!.start!.position,
        parameter!.stop!.position,
        ...(route != null
            ? route!.polyLines
                .map((e) => e.wayPoints.map((e) => e.position).toList())
                .expand((e) => e)
                .toList()
            : [])
      ], padding: EdgeInsets.all(20));
      controller.animateToFit(cam);
    }
  }

  void closeDetail() {
    goToSearch();
  }

  final animationDuration = const Duration(milliseconds: 200);
  void goToSearch() => goToI(0);
  void goToDetail() => goToI(1);
  void goToI(int index) {
    if ((parameter?.valid ?? false) && _pageController.hasClients) {
      _pageController.animateToPage(index, duration: animationDuration, curve: Curves.linear);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            RouteSearch(onSearch: setSearch),
            Expanded(
              child: Stack(children: [
                NetworkMap(
                  controller: controller,
                  route: route,
                  layers: parameter != null ?
                  [RouteParameterLayer(parameter: parameter!)] : [],
                ),
              ]),
            ),
            parameter?.valid ?? false || route != null
                ? SizedBox(
                    height: 300,
                    child: PageView(
                      controller: _pageController,
                      children: [
                        RouteSearchResult(
                          key: ObjectKey(parameter!),
                          parameter: parameter!,
                          routeSelected: selectRoute,
                          route: route,
                        ),
                        route == null ? Container()
                        : RouteDetail(route: route!, parameter: parameter!, onClose: closeDetail)
                      ],
                    ))
                : Container()
            // child: route == null
            //     ?
            //     : RouteDetail(
            //         route: route!,
            //         parameter: parameter!,
            //         onClose: closeDetail,
            //       ))
            //     : Container()
          ],
        ),
      ),
    );
  }
}
