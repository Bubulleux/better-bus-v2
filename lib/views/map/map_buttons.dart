import 'package:better_bus_v2/views/map/controller.dart';
import 'package:flutter/material.dart';

class MapButtons extends StatelessWidget {
  const MapButtons(this.controller, {super.key});

  final NetworkMapController controller;



  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Spacer(),
        controller.position != null
            ? Container(
            margin: const EdgeInsets.all(5),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).primaryColor),
            child: InkWell(
                onTap: controller.goToPosition,
                child: const Icon(Icons.my_location_outlined)))
            : Container(),
      ],
    );
  }
}
