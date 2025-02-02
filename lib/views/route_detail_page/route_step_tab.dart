import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/data_provider/maps_router.dart';
import 'package:better_bus_v2/model/clean/route.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RouteStepPage extends StatelessWidget {
  const RouteStepPage(this.busRoute, this.index, {super.key});

  final VitalisRoute busRoute;
  final int index;

  @override
  Widget build(BuildContext context) {
    Widget title;
    Widget body;
    if (busRoute.itinerary[index].lines == null) {
      if (index == busRoute.itinerary.length -1) {
        title = Text("${AppString.walkToPlace} ${busRoute.itinerary[index].endPlace}", style: Theme.of(context).textTheme.titleLarge,);
      } else {
        title = Text("${AppString.walkToStop} ${busRoute.itinerary[index].endPlace}", style: Theme.of(context).textTheme.titleLarge,);
      }
      body = Text(busRoute.itinerary[index].instruction);
    } else {
      title = RichText(text: TextSpan(
        children: [
          TextSpan(text: AppString.atTheStopTakeLine.replaceFirst("{#}", busRoute.itinerary[index].startPlace)),
          WidgetSpan(child: LineWidget.fromRouteLine(busRoute.itinerary[index].lines!, 25)),
          TextSpan(text: AppString.andGoToStop + busRoute.itinerary[index].endPlace),
        ],
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.normal,
        ),
      ));
      body = Container();
    }


    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          title,
          SizedBox(
            width: double.infinity,
            child: Wrap(
              children: [
                Text(DateFormat("Hm").format(busRoute.itinerary[index].startTime.toLocal())),
                const Icon(Icons.keyboard_double_arrow_right),
                Text(DateFormat("Hm").format(busRoute.itinerary[index].endTime.toLocal())),
              ],
              alignment: WrapAlignment.spaceBetween,
            ),
          ),
          const Divider(),
          body,
          busRoute.itinerary[index].lines == null?
              ElevatedButton(
                child: const Text(AppString.seeOnMaps),
                onPressed: () => MapsRouter.routeToMap(
                    busRoute.polyLines[index].lineString[busRoute.polyLines[index].lineString.length - 2],
                    busRoute.polyLines[index].lineString[busRoute.polyLines[index].lineString.length - 1]),
              ):
              Container(),
          Expanded(child: Container()),
        ],
      ),
    );
  }
}
