import 'package:better_bus_v2/model/clean/route.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:better_bus_v2/views/route_detail_page/route_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../common/decorations.dart';

class RouteItemWidget extends StatefulWidget {
  const RouteItemWidget(this.vitalisRoute, {Key? key}) : super(key: key);

  final VitalisRoute vitalisRoute;

  @override
  State<RouteItemWidget> createState() => _RouteItemWidgetState();
}

final DateFormat timeFormat = DateFormat("Hm");

class _RouteItemWidgetState extends State<RouteItemWidget> {

  Widget getRouteSchema() {
    List<Widget> wrapChildren = [
      const Icon(Icons.flag, color: Colors.green, size: 15,)
    ];
    for (RoutePassage passage in widget.vitalisRoute.itinerary) {
      if (passage.lines == null) {
        wrapChildren.add(const Icon(Icons.directions_walk, size: 30,));
      } else {
        wrapChildren.add(Column(
          children: [
            LineWidget.fromRouteLine(passage.lines!, 30),
            const SizedBox(height: 5,),
            const Icon(Icons.directions_bus, size: 30,),
          ],
        ));
      }

      if (passage != widget.vitalisRoute.itinerary.last) {
        wrapChildren.add(const Icon(Icons.keyboard_double_arrow_right, size: 20,));
      }
    }
    wrapChildren.add(const Icon(Icons.flag, color: Colors.red, size: 15,));

    return Wrap(
      children: wrapChildren,
      spacing: 5,
      crossAxisAlignment: WrapCrossAlignment.end,
      alignment: WrapAlignment.start,
    );
  }

  void showDetail() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => RouteDetailPage(widget.vitalisRoute)));
  }

  @override
  Widget build(BuildContext context) {
    Duration timeTravel = widget.vitalisRoute.timeTravel;


    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: GestureDetector(
        onTap: showDetail,
        child: Container(
          decoration: CustomDecorations.of(context).boxOutlined.copyWith(
            color: Theme.of(context).primaryColorLight.withAlpha(150),
          ),
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Text(timeFormat.format((widget.vitalisRoute.itinerary[0].startTime.toLocal()))),
                    const Icon(Icons.keyboard_double_arrow_right),
                    Text(timeFormat.format(widget.vitalisRoute.itinerary.last.endTime.toLocal())),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: getRouteSchema(),
              ),
              const Divider(),
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  children: [

                    Wrap(
                      children: [
                        const Icon(Icons.directions_bus),
                        Text("${(widget.vitalisRoute.busDistanceTravel / 100).round()/10} Km"),
                      ],
                    ),
                    Text(
                      (timeTravel.inHours != 0 ? "${timeTravel.inHours} h ": "") + "${timeTravel.inMinutes % 60} min",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20
                      ),
                    ),
                    Wrap(
                      children: [
                        const Icon(Icons.directions_walk),
                        Text("${(widget.vitalisRoute.walkDistanceTravel / 100).round()/10} Km"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}