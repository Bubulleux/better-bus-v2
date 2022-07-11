import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
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
              print(snapshot.error);
              return const Center(
                child: Text("Error"),
              );
            } else if (snapshot.hasData) {
              nextPassages = snapshot.data!;
              return ListView.builder(
                itemCount: nextPassages!.length,
                itemBuilder: (context, index) => NextPassageWidget(nextPassages![index]),
              );
            }
          }
          return Container();
        },
      )
    );
  }
}

class NextPassageWidget extends StatelessWidget {
  const NextPassageWidget(this.nextPassage, {Key? key}) : super(key: key);
  final NextPassage nextPassage;

  @override
  Widget build(BuildContext context) {
    String formattedTime = "${nextPassage.expectedTime.hour.toString().padLeft(2, "0")} : "
        "${nextPassage.expectedTime.minute.toString().padLeft(2, "0")}";
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: Theme.of(context).primaryColor)
        )
      ),
      child: Row(
        children: [
          LineWidget(nextPassage.line, 45),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              nextPassage.destination,
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          Spacer(),
          Column(
            children: [
              Text(formattedTime)
            ],
          )
        ],
      ),
    );
  }
}
