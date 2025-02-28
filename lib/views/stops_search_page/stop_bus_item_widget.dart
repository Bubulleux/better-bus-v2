import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/data_provider/gps_data_provider.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:better_bus_v2/views/common/error_handler.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:better_bus_v2/views/stops_search_page/stops_search_page.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';



class BusStopWidget extends StatefulWidget {
  const BusStopWidget({
    required this.stop,
    required this.onPressed,
    required this.stopDistance,
    required this.inHistoric,
    super.key,
  });

  final Station stop;
  final VoidCallback onPressed;
  final double? stopDistance;
  final bool inHistoric;

  @override
  State<BusStopWidget> createState() => _BusStopWidgetState();
}

class _BusStopWidgetState extends State<BusStopWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController expandController;
  late Animation<double> animation;

  bool expand = false;
  List<BusLine>? busLines;

  @override
  void initState() {
    super.initState();
    prepareAnimation();
    runExpandCheck();
  }

  void prepareAnimation() {
    expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    animation = CurvedAnimation(
        parent: expandController, curve: Curves.fastLinearToSlowEaseIn);
  }

  void runExpandCheck() {
    if (expand) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  void didUpdateWidget(covariant BusStopWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    runExpandCheck();
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  void getInfo() {
    GpsDataProvider.getLocation()
        .then((value) => getDistanceInKMeter(widget.stop, value!));

    if (expand) {
      expand = false;
    } else {
      expand = true;
      FullProvider.of(context).getPassingLines(widget.stop).then(
          (value) => {
                setState(() {
                  if (!mounted) {
                    return;
                  }
                  busLines = value;
                  busLines?.sort();
                })
              },
          onError: ErrorHandler.printError);
    }
    runExpandCheck();
  }

  @override
  Widget build(BuildContext context) {
    Widget? busStopInfo;
    if (busLines == null) {
      busStopInfo = const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      List<Widget> children = [];
      for (BusLine line in busLines!) {
        children.add(LineWidget(line, 35, dynamicWidth: true));
      }

      busStopInfo = Wrap(
        spacing: 3,
        runSpacing: 3,
        children: children,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: InkWell(
        onTap: widget.onPressed,
        child: Container(
          decoration: CustomDecorations.of(context).boxBackground,
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    child: widget.inHistoric
                        ? Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Icon(
                              Icons.history,
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                        : null,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.stop.name,
                          textAlign: TextAlign.left,
                          style: Theme.of(context).textTheme.titleLarge,
                          softWrap: false,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                        ),
                        Container(
                          child: widget.stopDistance == null
                              ? null
                              : Text(
                                  "${widget.stopDistance} km",
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                      fontSize: 13),
                                ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                      onPressed: getInfo,
                      child: AnimatedBuilder(
                          animation: animation,
                          builder: (context, widget) => Transform.rotate(
                              angle: animation.value * pi,
                              child: const Icon(Icons.keyboard_arrow_down))))
                ],
              ),
              SizeTransition(
                sizeFactor: animation,
                axisAlignment: 1.0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: busStopInfo,
                ),
              )
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
      ),
    );
  }
}
