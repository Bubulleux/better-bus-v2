import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/views/common/background.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<BusStop>? busStops;
  List<BusStop>? validResult;

  @override
  void initState() {
    super.initState();
    VitalisDataProvider.getStops().then((value) {
      setState(() {
        busStops = value;
        validResult = List.from(value!);
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

  @override
  Widget build(BuildContext context) {
    Widget? output;
    if (busStops == null || validResult == null) {
      output = LoadingScreen();
    } else if (validResult!.isEmpty) {
      output = NotFoundScreen();
    } else {
      output = StopScreen(validResult!);
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
                    border: OutlineInputBorder(),
                    fillColor: Theme.of(context).backgroundColor,
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
  const StopScreen(this.validStops, {Key? key}) : super(key: key);
  final List<BusStop> validStops;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemBuilder: (context, index) {
          return BusStopWidget(validStops[index]);
        },
        itemCount: validStops.length,
      ),
    );
  }
}

class BusStopWidget extends StatefulWidget {
  const BusStopWidget(this.stop, {this.expand = false, Key? key})
      : super(key: key);

  final BusStop stop;
  final bool expand;

  @override
  State<BusStopWidget> createState() => _BusStopWidgetState();
}

class _BusStopWidgetState extends State<BusStopWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController expandController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    prepareAnimation();
    runExpandCheck();
  }

  void prepareAnimation() {
    expandController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    animation = CurvedAnimation(
        parent: expandController, curve: Curves.fastLinearToSlowEaseIn);
  }

  void runExpandCheck() {
    if (widget.expand) {
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: OutlinedButton(
        onPressed: () {
          expandController.forward();
        },
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.all(5),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: Theme.of(context).backgroundColor,
        ),
        child: Row(
          children: [
            Text(
              widget.stop.name,
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.headline5,
            ),
            SizeTransition(
              sizeFactor: animation,
              axisAlignment: 1.0,
              child: SizedBox(
                height: 50,
              ),
            )
          ],
        ),
      ),
    );
  }
}
