import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/views/common/close_cross.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:flutter/material.dart';

import '../../app_constant/app_string.dart';

class RouteDetail extends StatefulWidget {
  RouteDetail({required this.route, required this.onClose}) : super(key: ObjectKey(route));

  final VitalisRoute route;
  final VoidCallback onClose;

  @override
  State<RouteDetail> createState() => _RouteDetailState();
}

class _RouteDetailState extends State<RouteDetail> {

  Widget buildWalkStep(RoutePassage item) {
    assert(item.lines == null);
    // if (index == busRoute.itinerary.length -1) {
    //   title = Text("${AppString.walkToPlace} ${item.endPlace}", style: Theme.of(context).textTheme.titleLarge,);
    // } else {
    // }

    final title = Text("${AppString.walkToStop} ${item.endPlace}", style: Theme.of(context).textTheme.titleLarge,);
    return buildRow(
      marge: Icon(Icons.directions_walk),
      content: title,
    );
  }

  Widget buildLineStep(RoutePassage item) {
    assert(item.lines != null);
    final title = RichText(text: TextSpan(
      children: [
        TextSpan(text: AppString.atTheStopTakeLine.replaceFirst("{#}", item.startPlace)),
        WidgetSpan(child: LineWidget(item.lines!, 25)),
        TextSpan(text: AppString.andGoToStop + item.endPlace),
      ],
      style: Theme.of(context).textTheme.titleLarge!.copyWith(
        fontWeight: FontWeight.normal,
      ),
    ));
    return buildRow(
      marge: LineWidget(item.lines!, 35),
      content: title,
    );
  }

  Widget buildRow({required Widget marge, required Widget content}) {
    return Row(
      children: [
        SizedBox( child: marge,),
        const SizedBox(width: 5),
        content,
      ],
    );
  }


  Widget buildItem(BuildContext context, int i) {
    final item = widget.route.itinerary[i];
    if (item.lines == null) {
      return buildWalkStep(item);
    }
    return buildLineStep(item);
  }

  @override
  Widget build(BuildContext context) {
    print("Route lenght ${widget.route.itinerary.length}");
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: CloseCross(onTap: widget.onClose),
          ),
          Expanded(
            child: ListView.separated(
              itemBuilder: buildItem,
              separatorBuilder: (_, __) => Divider(),
              itemCount: widget.route.itinerary.length,
            ),
          )
        ],
      ),
    );
  }
}
