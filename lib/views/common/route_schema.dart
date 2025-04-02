import 'package:better_bus_core/core.dart';
import 'package:flutter/material.dart';

import 'line_widget.dart';

class RouteSchema extends StatelessWidget {
  const RouteSchema({required this.route, this.size = 25, super.key});

  final VitalisRoute route;
  final double size;

  @override
  Widget build(BuildContext context) {
    List<Widget> wrapChildren = [
      // const Icon(
      //   Icons.flag,
      //   color: Colors.green,
      //   size: 15,
      // )
    ];
    for (RoutePassage passage in route.itinerary) {
      if (passage.lines == null) {
        wrapChildren.add(Icon(
          Icons.directions_walk,
          size: size,
        ));
      } else {
        wrapChildren.add(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
                Icons.directions_bus,
                size: size,
            ),
            SizedBox(
              width: size / 5,
            ),
            LineWidget(passage.lines!, size),
          ],
        ));
      }

      if (passage != route.itinerary.last) {
        wrapChildren.add(Icon(
          Icons.keyboard_double_arrow_right,
          size: size * 0.8,
        ));
      }
    }
    // wrapChildren.add(const Icon(
    //   Icons.flag,
    //   color: Colors.red,
    //   size: 15,
    // ));

    return Wrap(
      spacing: size / 5,
      runSpacing: size / 4,
      crossAxisAlignment: WrapCrossAlignment.end,
      alignment: WrapAlignment.start,
      children: wrapChildren,
    );
  }
}
