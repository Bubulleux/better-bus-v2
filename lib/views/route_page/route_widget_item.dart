import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:better_bus_v2/views/common/route_schema.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RouteItemWidget extends StatefulWidget {
  const RouteItemWidget(this.vitalisRoute,
      {this.onClick, this.selected = false, super.key});

  final VitalisRoute vitalisRoute;
  final VoidCallback? onClick;
  final bool selected;

  @override
  State<RouteItemWidget> createState() => _RouteItemWidgetState();
}

class _RouteItemWidgetState extends State<RouteItemWidget> {
  DateFormat get timeFormat => DateTime.now().atMidnight() ==
          widget.vitalisRoute.itinerary.last.endTime.atMidnight()
      ? DateFormat("kk:mm", "fr")
      : DateFormat("EE d MMM\nkk:mm", "fr");

  Widget getRouteSchema() {
    return RouteSchema(
      route: widget.vitalisRoute,
      size: 23,
    );
  }

  void showDetail() {
    widget.onClick?.call();
  }

  Widget buildTraveledDist(int dst, IconData icon) {
    return Wrap(
      children: [
        Icon(
          icon,
          size: 15,
        ),
        Text("${(dst / 100).round() / 10} km",
            style: const TextStyle(
              fontSize: 13,
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Duration timeTravel = widget.vitalisRoute.timeTravel;

    final start = timeFormat
        .format((widget.vitalisRoute.itinerary[0].startTime.toLocal()));
    final stop =
        timeFormat.format(widget.vitalisRoute.itinerary.last.endTime.toLocal());

    final time =
        "${timeTravel.inHours != 0 ? "${timeTravel.inHours} h " : ""}${timeTravel.inMinutes % 60} min";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Material(
        borderRadius: CustomDecorations.borderRadius,
        child: InkWell(
          borderRadius: CustomDecorations.borderRadius,
          onTap: showDetail,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: CustomDecorations.borderRadius,
                boxShadow: const [
                  BoxShadow(
                    spreadRadius: 3,
                    blurRadius: 3,
                    offset: Offset(2, 2),
                    color: Colors.black12,
                  )
                ]),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: Row(
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      getRouteSchema(),
                      const Spacer(),
                      Text(
                        time,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(start),
                        const Icon(Icons.arrow_right_outlined),
                        Text(stop),
                      ],
                    ),
                    const Spacer(),
                    Row(children: [
                      buildTraveledDist(widget.vitalisRoute.busDistanceTravel,
                          Icons.directions_bus),
                      const SizedBox(width: 20),
                      buildTraveledDist(widget.vitalisRoute.walkDistanceTravel,
                          Icons.directions_walk),
                    ])
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
