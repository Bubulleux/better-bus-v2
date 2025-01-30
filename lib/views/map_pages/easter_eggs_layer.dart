import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';

class EasterEgg {
  const EasterEgg(this.pos, this.svg, this.hiddenChar);

  final LatLng pos;
  final String svg;
  final String hiddenChar;
}

const _kiss = "assets/svg/stop_and_kiss.svg";
const _miss = "assets/svg/stop_and_miss.svg";

const List<EasterEgg> easterEggs = [
  EasterEgg(LatLng(46.5852595, 0.332725), _miss, "💩"),
  EasterEgg(LatLng(46.58393969040217, 0.3579758852971781), _kiss, "😘"),
];

class EasterEggsLayer extends StatefulWidget {
  const EasterEggsLayer({Key? key}) : super(key: key);

  @override
  State<EasterEggsLayer> createState() => _EasterEggsLayerState();
}

class _EasterEggsLayerState extends State<EasterEggsLayer> {
  Set<LatLng> hidden = {};

  @override
  Widget build(BuildContext context) {
    final MapCamera camera = MapCamera.of(context);

    if (camera.zoom < 18) {
      return Container();
    }
    for (final e in easterEggs) {
      if (hidden.contains(e.pos)) continue;

      if (camera.visibleBounds.contains(e.pos)) {
        final center = (camera.project(e.pos) - camera.pixelOrigin).toOffset();
        final secPos =  LatLng(e.pos.latitude + 0.00005, e.pos.longitude + 0.00005);
        final dx = (camera.project(secPos) - camera.project(e.pos)).x * 1;
        final bounds = Rect.fromCenter(
          center: center,
          width: dx,
          height: dx,
        );
        return MobileLayerTransformer(
          child: Stack(children: [
            StopSign(bounds, e, () {hidden.add(e.pos);})
          ]),
        );
      }
    }
    return Container();
  }
}

class StopSign extends StatefulWidget {
  StopSign(this.pos, this.easterEgg, this.clicked, {Key? key}) : super(key: key);
  final Rect pos;
  final EasterEgg easterEgg;
  final VoidCallback clicked;

  @override
  State<StopSign> createState() => _StopSignState();
}

class _StopSignState extends State<StopSign> {
  bool clicked = false;

  void onCLick() {
    Future.delayed(const Duration(seconds: 5)).then((_) => widget.clicked());
    setState(() {
      clicked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
      rect: widget.pos,
      child: GestureDetector(
          onTap: onCLick,
          child: Stack(
              children: [
                AnimatedOpacity(
                  duration: Duration(seconds: 5),
                  opacity: clicked ? 0 : 1,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: FittedBox(
                      child: Text(
                        widget.easterEgg.hiddenChar,
                        textScaler: const TextScaler.linear(10),
                        style: const TextStyle(
                          color: Colors.black
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedScale(
                  duration: Duration(milliseconds: 200),
                  scale: clicked ? 0 : 1,
                  child: SvgPicture.asset(widget.easterEgg.svg),
                )
              ],
            )));
  }
}
