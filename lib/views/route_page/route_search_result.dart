
import 'package:better_bus_core/core.dart';
import 'package:flutter/material.dart';

import '../../error_handler/custom_error.dart';
import '../../model/provider.dart';
import '../common/custom_future.dart';
import '../common/decorations.dart';
import 'route_search.dart';
import 'route_widget_item.dart';

class RouteSearchResult extends StatefulWidget {
  RouteSearchResult({required this.parameter, this.routeSelected, this.route, super.key});

  final RouteSearchParameter parameter;
  final ValueChanged<VitalisRoute>? routeSelected;
  final VitalisRoute? route;

  @override
  State<RouteSearchResult> createState() => _RouteSearchResultState();
}

class _RouteSearchResultState extends State<RouteSearchResult>
  with AutomaticKeepAliveClientMixin<RouteSearchResult>{

  RouteSearchParameter? _parameter;
  RouteSearchParameter get parameter => _parameter!;

  GlobalKey<CustomFutureBuilderState<List<VitalisRoute>?>> futureBuilderKey =
  GlobalKey<CustomFutureBuilderState<List<VitalisRoute>?>>();

  @override
  void initState() {
    super.initState();
    _parameter = widget.parameter;
  }

@override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (parameter != widget.parameter) {
      _parameter = widget.parameter;
      futureBuilderKey.currentState?.refresh();
    }
  }

  Future<List<VitalisRoute>?> getRoutes() async {
    final provider = FullProvider.of(context).api;
    assert(_parameter != null);
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
    super.build(context);
    assert(_parameter != null);
    return CustomFutureBuilder<List<VitalisRoute>?>(
      key: futureBuilderKey,
      future: getRoutes,
      onData: (context, data, refresh) {
        return Container(
          padding: const EdgeInsets.only(top: 5),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            itemBuilder: (context, index) => RouteItemWidget(
              data[index],
              selected: widget.route == data[index],
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
    );
  }

  @override
  bool get wantKeepAlive => widget.parameter == _parameter;
}

