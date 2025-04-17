import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/data_provider/gps_data_provider.dart';
import 'package:better_bus_v2/views/connection_needed/connection_needed.dart';
import 'package:better_bus_v2/views/map/controller.dart';
import 'package:better_bus_v2/views/map/map_layout.dart';
import 'package:better_bus_v2/views/map/map_view.dart';
import 'package:better_bus_v2/views/map/route_layer.dart';
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    getArgs();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void getArgs() {
    if (parameter != null) return;
    final arg = ModalRoute.of(context)!.settings.arguments as RouteSearchParameter?;
    if (arg != null) {
      parameter = arg;
      if ((arg.start == null || arg.stop == null) && arg.start != arg.stop) {
        GpsDataProvider.getLocation().then((pos){
          if (!mounted) return;
          final myPlace = Place(AppString.myPosition, position: pos!);
          setSearch(parameter!.copyWidth(
            start: arg.start ?? myPlace,
            stop: arg.stop ?? myPlace,
          ));
        });
      }
    }
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
      final bound = LatLngBounds.fromPoints([
        parameter!.start!.position,
        parameter!.stop!.position,
        ...(route != null
            ? route!.polyLines
                .map((e) => e.wayPoints.map((e) => e.position).toList())
                .expand((e) => e)
                .toList()
            : [])
      ]);
      controller.animateToBound(bound);
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
      _pageController.animateToPage(index,
          duration: animationDuration, curve: Curves.linear);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller.provider.offline) {
      return ConnectionNeeded(
        onRefresh: () => setState(() {}),
      );
    }

    return Scaffold(
      body: SafeArea(
          child: MapLayout(
        controller: controller,
        topBar: RouteSearch(onSearch: setSearch, parameter: parameter),
        topBarHeight: 160,
        mapLayers: [
          route != null ? RouteLayer(route: route!) : Container(),
          parameter != null ? RouteParameterLayer(parameter: parameter!)
              : Container(),
        ],
        body: parameter?.valid ?? false || route != null
            ? SizedBox(
                child: PageView(
                  controller: _pageController,
                  children: [
                    RouteSearchResult(
                      key: ObjectKey(parameter!),
                      parameter: parameter!,
                      routeSelected: selectRoute,
                      route: route,
                    ),
                    route != null
                        ? RouteDetail(
                            route: route!,
                            parameter: parameter!,
                            onClose: closeDetail,
                          )
                        : Container()
                  ],
                ))
            : null,
      )),
    );
  }
}
