import 'package:better_bus_core/core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class TripView extends StatefulWidget {
  const TripView(this.trip, {this.from, this.delay = Duration.zero, super.key});

  final BusTrip trip;
  final Station? from;
  final Duration delay;

  @override
  State<TripView> createState() => _TripViewState();
}

class _TripViewState extends State<TripView> {
  Widget buildWayItem(TripStop stop) {
    return SizedBox(
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
                        color: widget.trip.line.color,
                      ),
                    ),
                  ),
                  Container(
                      height: 20,
                      padding: const EdgeInsets.all(3),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: widget.trip.line.color.withAlpha(80),
                        borderRadius: BorderRadiusDirectional.circular(10),
                        border:
                            Border.all(width: 2, color: widget.trip.line.color),
                      ),
                      child: Text(
                          DateFormat.Hm()
                              .format(stop.time.add(widget.delay).toLocal()),
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
    List<TripStop> stopTimes = widget.from != null
        ? widget.trip.from(widget.from!)
            .toList()
        : widget.trip.stopTimes;
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
                      (context, i) => i < stopTimes.length
                      ? buildWayItem(stopTimes[i])
                      : buildLineEnd(),
                ),
              )
            ],
          )),
    );
  }
}
