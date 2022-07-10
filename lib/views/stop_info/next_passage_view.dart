import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:flutter/material.dart';

import '../../model/clean/next_passage.dart';

class NextPassagePage extends StatefulWidget {
  const NextPassagePage(this.stop, {Key? key}) : super(key: key);

  final BusStop stop;

  @override
  State<NextPassagePage> createState() => _NextPassagePageState();
}

class _NextPassagePageState extends State<NextPassagePage> {

  List<NextPassage>? nextPassages;

  Future<List<NextPassage>> refreshData() async {
    nextPassages = await VitalisDataProvider.getNextPassage(widget.stop);
    return nextPassages!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: FutureBuilder<List<NextPassage>>(
        future: refreshData(),
        builder: (BuildContext context, AsyncSnapshot<List<NextPassage>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("Error"),
              );
            } else if (snapshot.hasData) {
            }
          }
        },
      )
    );
  }
}
