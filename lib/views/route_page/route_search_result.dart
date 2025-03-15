
import 'package:better_bus_core/core.dart';
import 'package:flutter/material.dart';

import '../../error_handler/custom_error.dart';
import '../../model/provider.dart';
import '../common/custom_future.dart';
import '../common/decorations.dart';
import 'route_search.dart';
import 'route_widget_item.dart';

class RouteSearchResult extends StatefulWidget {
  RouteSearchResult({required this.parameter, this.routeSelected}) :
  super(key: ObjectKey(parameter));

  final RouteSearchParameter parameter;
  final ValueChanged<VitalisRoute>? routeSelected;

  @override
  State<RouteSearchResult> createState() => _RouteSearchResultState();
}

class _RouteSearchResultState extends State<RouteSearchResult> {

  RouteSearchParameter get parameter => widget.parameter;

  GlobalKey<CustomFutureBuilderState<List<VitalisRoute>?>> futureBuilderKey =
  GlobalKey<CustomFutureBuilderState<List<VitalisRoute>?>>();

@override
  void didChangeDependencies() {
    super.didChangeDependencies();
    futureBuilderKey.currentState?.refresh();
  }

  Future<List<VitalisRoute>?> getRoutes() async {
    final provider = FullProvider.of(context).api;
    if (!parameter.valid ||
        !mounted ||
        !provider.isAvailable()) {
      return null;
    }

    final result = await (provider.getVitalisRoute(parameter.start!,
        parameter.stop!, parameter.time, parameter.timeType.name));

    return result;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      //decoration: CustomDecorations.of(context).boxBackground,
      color: Colors.black12,
      // padding: const EdgeInsets.symmetric(horizontal: 5),
      child: CustomFutureBuilder<List<VitalisRoute>?>(
        // key: futureBuilderKey,
        future: getRoutes,
        onData: (context, data, refresh) {
          return ClipRRect(
            borderRadius: CustomDecorations.borderRadius,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              itemBuilder: (context, index) => RouteItemWidget(
                data[index],
                onClick: () => widget.routeSelected?.call(data[index]),
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
    );
  }
}

