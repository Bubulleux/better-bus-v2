import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/error_handler/custom_error.dart';
import 'package:better_bus_v2/views/common/custom_future.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:better_bus_v2/views/map/controller.dart';
import 'package:better_bus_v2/views/map/map_view.dart';
import 'package:better_bus_v2/views/map/map_view_port.dart';
import 'package:better_bus_v2/views/route_page/route_search.dart';
import 'package:better_bus_v2/views/route_page/route_widget_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../model/provider.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({super.key});

  static const String routeName = "/RouteFinder";

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  RouteSearchParameter? parameter;
  VitalisRoute? route;

  GlobalKey<CustomFutureBuilderState<List<VitalisRoute>?>> futureBuilderKey =
      GlobalKey<CustomFutureBuilderState<List<VitalisRoute>?>>();

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

  Future<List<VitalisRoute>?> getRoutes() async {
    final provider = FullProvider.of(context).api;
    if (parameter == null ||
        !parameter!.valid ||
        !mounted ||
        !provider.isAvailable()) {
      return null;
    }

    final result = await (provider.getVitalisRoute(parameter!.start!,
        parameter!.stop!, parameter!.time, parameter!.timeType.name));
    setState(() {
      route = null;
    });
    return result;
  }

  void selectRoute(VitalisRoute newRoute) {
    route = newRoute;
    updateCam();
    setState(() {});
  }

  void setSearch(RouteSearchParameter newParameter) {
    parameter = newParameter;
    futureBuilderKey.currentState?.refresh();
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
            SizedBox(
              height: 300,
              child: Container(
                //decoration: CustomDecorations.of(context).boxBackground,
                color: Colors.black12,
                // padding: const EdgeInsets.symmetric(horizontal: 5),
                child: CustomFutureBuilder<List<VitalisRoute>?>(
                  key: futureBuilderKey,
                  future: getRoutes,
                  onData: (context, data, refresh) {
                    return ClipRRect(
                      borderRadius: CustomDecorations.borderRadius,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        itemBuilder: (context, index) => RouteItemWidget(
                          data[index],
                          onClick: () => selectRoute(data[index]),
                        ),
                        itemCount: data!.length,
                      ),
                    );
                  },
                  errorTest: (data) {
                    if (data == null) {
                      return CustomErrors.routeInputError;
                    } else if (data!.isEmpty) {
                      return CustomErrors.routeResultEmpty;
                    }
                    return null;
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
