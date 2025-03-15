import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/views/common/custom_future.dart';
import 'package:better_bus_v2/views/map/controller.dart';
import 'package:better_bus_v2/views/map/map_view.dart';
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


  late NetworkMapController controller;

  @override
  void initState() {
    super.initState();
    controller = NetworkMapController(context);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void selectRoute(VitalisRoute newRoute) {
    route = newRoute;
    updateCam();
    setState(() {});
  }

  void setSearch(RouteSearchParameter newParameter) {
    parameter = newParameter;
    route = null;
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
    setState(() {
      route = null;
    });
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
                ),
              ]),
            ),
            parameter?.valid ?? false || route != null
                ? SizedBox(
                    height: 300,
                    child: route == null
                        ? RouteSearchResult(
                            parameter: parameter!,
                            routeSelected: selectRoute,
                          )
                        : RouteDetail(route: route!, onClose: closeDetail))
                : Container()
          ],
        ),
      ),
    );
  }
}
