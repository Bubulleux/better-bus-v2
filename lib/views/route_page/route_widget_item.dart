
import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RouteItemWidget extends StatefulWidget {
  const RouteItemWidget(this.vitalisRoute, {this.onClick, super.key});

  final VitalisRoute vitalisRoute;
  final VoidCallback? onClick;

  @override
  State<RouteItemWidget> createState() => _RouteItemWidgetState();
}

class _RouteItemWidgetState extends State<RouteItemWidget> {
  DateFormat get timeFormat => DateTime.now().atMidnight() ==
          widget.vitalisRoute.itinerary.last.endTime.atMidnight()
      ? DateFormat("kk:mm", "fr")
      : DateFormat("EE d MMM\nkk:mm", "fr");

  Widget getRouteSchema() {
    List<Widget> wrapChildren = [
      // const Icon(
      //   Icons.flag,
      //   color: Colors.green,
      //   size: 15,
      // )
    ];
    for (RoutePassage passage in widget.vitalisRoute.itinerary) {
      if (passage.lines == null) {
        wrapChildren.add(const Icon(
          Icons.directions_walk,
          size: 25,
        ));
      } else {
        wrapChildren.add(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.directions_bus,
              size: 25
            ),
            const SizedBox(
              width: 5,
            ),
            LineWidget(passage.lines!, 25),
          ],
        ));
      }

      if (passage != widget.vitalisRoute.itinerary.last) {
        wrapChildren.add(const Icon(
          Icons.keyboard_double_arrow_right,
          size: 20,
        ));
      }
    }
    // wrapChildren.add(const Icon(
    //   Icons.flag,
    //   color: Colors.red,
    //   size: 15,
    // ));

    return Wrap(
      children: wrapChildren,
      spacing: 5,
      crossAxisAlignment: WrapCrossAlignment.end,
      alignment: WrapAlignment.start,
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
        elevation: 2,
        child: InkWell(
          borderRadius: CustomDecorations.borderRadius,
          onTap: showDetail,
          child: Container(
            // decoration: CustomDecorations.of(context).boxOutlined,
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                const Divider(),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getRouteSchema(),
                      const SizedBox(height: 10),
                      Text("$start - $stop"),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        time,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const SizedBox(height: 10),
                      Row(children: [
                        buildTraveledDist(widget.vitalisRoute.busDistanceTravel,
                            Icons.directions_bus),
                        const SizedBox(width: 20),
                        buildTraveledDist(
                            widget.vitalisRoute.walkDistanceTravel,
                            Icons.directions_walk),
                      ])
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
