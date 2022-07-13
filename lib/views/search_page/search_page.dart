import 'dart:math';

import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/views/common/background.dart';
import 'package:better_bus_v2/views/common/error_handler.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:flutter/material.dart';

import '../../model/clean/bus_line.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<BusStop>? busStops;
  Map<String, bool> resultExpand = {};
  Map<String, List<BusLine>?> busStopsLines = {};

  List<BusStop>? validResult;

  @override
  void initState() {
    super.initState();
    VitalisDataProvider.getStops().then((value) {
      for (BusStop stop in value!) {
        resultExpand[stop.name] = false;
        busStopsLines[stop.name] = null;
      }
      setState(() {
        busStops = value;
        validResult = List.from(value);
      });
    });
  }

  void inputChange(String input) {
    if (validResult == null || busStops == null) {
      return;
    }
    setState(() {
      validResult!.clear();
      for (BusStop busStop in busStops!) {
        if (busStop.name.toLowerCase().contains(input.toLowerCase())) {
          validResult!.add(busStop);
        }
      }
    });
  }

  void selectBusStop(BusStop stopSelected) {
    Navigator.pop(context, stopSelected);
  }

  @override
  Widget build(BuildContext context) {
    Widget? output;
    if (busStops == null || validResult == null) {
      output = const LoadingScreen();
    } else if (validResult!.isEmpty) {
      output = const NotFoundScreen();
    } else {
      output = StopScreen(validResult!, this);
    }

    return Scaffold(
      body: SafeArea(
        child: Background(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  onChanged: inputChange,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    fillColor: Theme
                        .of(context)
                        .backgroundColor,
                    filled: true,
                  ),
                ),
                output,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Center(
        child: Text(
          "Result not found",
          style: TextStyle(
            fontSize: 40,
          ),
        ),
      ),
    );
  }
}

class StopScreen extends StatelessWidget {
  const StopScreen(this.validStops, this.rootState, {Key? key})
      : super(key: key);
  final List<BusStop> validStops;
  final _SearchPageState rootState;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemBuilder: (context, index) {
          return BusStopWidget(validStops[index], rootState);
        },
        itemCount: validStops.length,
      ),
    );
  }
}

class BusStopWidget extends StatefulWidget {
  const BusStopWidget(this.stop, this.rootWidget, {Key? key}) : super(key: key);

  final BusStop stop;
  final _SearchPageState rootWidget;

  @override
  State<BusStopWidget> createState() => _BusStopWidgetState();
}



class _BusStopWidgetState extends State<BusStopWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController expandController;
  late Animation<double> animation;

  bool get expand => widget.rootWidget.resultExpand[widget.stop.name]!;

  set expand(bool v) => widget.rootWidget.resultExpand[widget.stop.name] = v;

  List<BusLine>? get busLines =>
      widget.rootWidget.busStopsLines[widget.stop.name];

  set busLines(List<BusLine>? v) =>
      widget.rootWidget.busStopsLines[widget.stop.name] = v;

  bool getRequestLaunch = false;

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
    if (expand) {
      expand = false;
    } else {
      expand = true;
      if (getRequestLaunch == false) {
        getRequestLaunch = true;
        VitalisDataProvider.getLines(widget.stop)
            .then((value) =>
        {
          setState(() => {busLines = value})
        },
            onError: ErrorHandler.printError
        );
      }
    }
    runExpandCheck();
  }

  void widgetPressed() {
    widget.rootWidget.selectBusStop(widget.stop);
  }

  @override
  Widget build(BuildContext context) {
    Widget? busStopInfo;
    if (busLines == null) {
      busStopInfo = const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      List<Widget> children = [];
      for (BusLine line in busLines!) {
        children.add(LineWidget(line, 35, dynamicWidth: true,));
      }

      busStopInfo = Wrap(
        spacing: 3,
        runSpacing: 3,
        children: children,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: OutlinedButton(
        onPressed: widgetPressed,
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(5),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: Theme
              .of(context)
              .backgroundColor,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  widget.stop.name,
                  textAlign: TextAlign.left,
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline5,
                ),
                const Spacer(),
                TextButton(
                    onPressed: getInfo,
                    child: AnimatedBuilder(
                        animation: animation,
                        builder: (context, widget) =>
                            Transform.rotate(angle: animation.value * pi,
                                child: const Icon(Icons.keyboard_arrow_down))
                    )
                )
              ],
            ),
            SizeTransition(
              sizeFactor: animation,
              axisAlignment: 1.0,
              child: SizedBox(child: busStopInfo),
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ),
    );
  }


}
