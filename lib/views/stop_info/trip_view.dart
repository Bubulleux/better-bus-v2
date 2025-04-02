import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/model/bus_line_color.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class TripView extends StatelessWidget {
  TripView(BusTrip trip, {from, delay = Duration.zero}) :
        this._internal(direction: trip.direction,
          stops: trip.stopTimes,
          from: from,
          delay: delay);

  factory TripView.fromRoute(RoutePassage passage, BusTrip trip,
      Duration delay) {
    assert(passage.lines != null);
    final from = trip.stopTimes.firstWhere((e) => e.station.name == passage.startPlace).station;
    final stopInRoute = trip.stopTimes
        .skipWhile((e) => e.station != from)
        .splitAfter((e) => e.station.name == passage.endPlace)
        .first
        .toSet();
    final hightlight = (stops) => stopInRoute.contains(stops);
    return TripView._internal(direction: trip.direction, stops: trip.stopTimes,
      delay: delay, highlight: hightlight, from:  from,);
  }

  const TripView._internal({
    required this.direction,
    required this.stops,
    this.from,
    this.delay = Duration.zero,
    this.highlight = null,
    super.key,
  });

  final LineDirection direction;

  BusLine get line => direction.line;
  final List<TripStop> stops;
  final Station? from;
  final bool Function(TripStop _)? highlight;
  final Duration delay;


  Widget buildWayItem(TripStop stop) {
    return Opacity(
      opacity: (highlight?.call(stop) ?? true) ? 1 : 0.3,
      child: SizedBox(
        width: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 40,
              child: OverflowBox(
                maxHeight: 65,
                maxWidth: 30,
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: 70,
                  child: Transform.rotate(
                    angle: pi * .30,
                    alignment: Alignment.bottomCenter,
                    child: RotatedBox(
                      quarterTurns: -1,
                      child: FittedBox(
                        //alignment: Alignment.centerRight,
                          fit: BoxFit.scaleDown,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 120),
                            child: Text(stop.station.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                )),
                          )),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                height: 20,
                child: Row(
                  //alignment: Alignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        height: 5,
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: line.color,
                        ),
                      ),
                    ),
                    Container(
                        height: 20,
                        padding: const EdgeInsets.all(3),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: line.color.withAlpha(80),
                          borderRadius: BorderRadiusDirectional.circular(10),
                          border: Border.all(width: 2, color: line.color),
                        ),
                        child: Text(
                            DateFormat.Hm()
                                .format(stop.time.add(delay).toLocal()),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLineEnd() {
    return const SizedBox(
      width: 70,
      height: double.infinity,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<TripStop> stopTimes =
    from != null ? stops.skipWhile((e) => e.station != from).toList() : stops;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
          height: 80,
          child: CustomScrollView(
            scrollDirection: Axis.horizontal,
            semanticChildCount: stopTimes.length + 1,
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: stopTimes.length + 1,
                      (context, i) =>
                  i < stopTimes.length
                      ? buildWayItem(stopTimes[i])
                      : buildLineEnd(),
                ),
              )
            ],
          )),
    );
  }
}
