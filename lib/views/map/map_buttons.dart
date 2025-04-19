import 'package:better_bus_v2/views/map/controller.dart';
import 'package:flutter/material.dart';

class MapButtons extends StatefulWidget {
  const MapButtons(this.controller, {super.key});

  final NetworkMapController controller;

  @override
  State<MapButtons> createState() => _MapButtonsState();
}

class _MapButtonsState extends State<MapButtons> {
  Widget buildBtn({required Widget child, required VoidCallback onTap}) {
    final br = BorderRadius.circular(20);
    return InkWell(
      onTap: onTap,
      child: Container(
          margin: const EdgeInsets.all(5),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              borderRadius: br,
              color: Theme.of(context).primaryColor,
            boxShadow: const [
              BoxShadow(color: Colors.black38, offset: Offset(2, 2), blurRadius: 3)
            ]
          ),
          child: child
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        buildBtn(child: Transform.rotate(angle: widget.controller.controller.camera.rotationRad,
        child: const Icon(Icons.north_outlined)), onTap: widget.controller.animateToNorth),
        Spacer(),
        widget.controller.position != null
            ? buildBtn(
            child: const Icon(Icons.my_location_outlined),
        onTap: widget.controller.goToPosition)
            : Container(),
      ],
    );
  }
}
