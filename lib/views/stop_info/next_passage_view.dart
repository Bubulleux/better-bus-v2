import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/clean/next_passage.dart';

class NextPassagePage extends StatefulWidget {
  const NextPassagePage(this.stop, {Key? key}) : super(key: key);

  final BusStop stop;

  @override
  State<NextPassagePage> createState() => _NextPassagePageState();
}

class _NextPassagePageState extends State<NextPassagePage>{

  List<NextPassage>? nextPassages;

  Future<List<NextPassage>> initData() async {
    if (nextPassages != null) {
      return nextPassages!;
    }
    nextPassages = await VitalisDataProvider.getNextPassage(widget.stop);
    return nextPassages!;
  }

  @override
  void setState(VoidCallback fn) {
    nextPassages = null;
    super.setState(fn);
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: FutureBuilder<List<NextPassage>>(
        future: initData(),
        initialData: nextPassages,
        builder: (BuildContext context, AsyncSnapshot<List<NextPassage>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("Error"),
              );
            } else if (snapshot.hasData) {
              if (nextPassages!.isEmpty){
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline),
                    Text("! Aucun bus n'est prevus de passer")
                  ],
                );
              }

              return NextPassageListWidget(nextPassages!, widget.stop);
            }
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      )
    );
  }
}

class NextPassageListWidget extends StatefulWidget {
  const NextPassageListWidget(this.nextPassages, this.stop, {Key? key}) : super(key: key);

  final List<NextPassage> nextPassages;
  final BusStop stop;

  @override
  State<NextPassageListWidget> createState() => _NextPassageListWidgetState();
}

class _NextPassageListWidgetState extends State<NextPassageListWidget> {
  late List<NextPassage> nextPassages = List.from(widget.nextPassages);


  Future<void> refreshData() async {
    List<NextPassage> result = await VitalisDataProvider.getNextPassage(widget.stop);
    if (mounted) {
      setState(() {
        nextPassages = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refreshData,
      child: ListView.builder(
        itemCount: nextPassages.length,
        itemBuilder: (context, index) => NextPassageWidget(nextPassages[index]),
      ),
    );
  }
}

class NextPassageWidget extends StatelessWidget {
  const NextPassageWidget(this.nextPassage, {Key? key}) : super(key: key);
  final NextPassage nextPassage;

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat.Hm().format(nextPassage.expectedTime.toLocal());
    String minuteToWait = "${nextPassage.expectedTime.difference(DateTime.now()).inMinutes} min";
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: Theme.of(context).primaryColor)
        )
      ),
      child: Row(
        children: [
          LineWidget(nextPassage.line, 45),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                nextPassage.destination,
                style: Theme.of(context).textTheme.headline5,
                overflow: TextOverflow.fade,
                maxLines: 1,
                softWrap: false,
              ),
            ),
          ),
          Container(
            child: nextPassage.realTime ? const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(Icons.wifi),
            ) : null,
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              children: [
                Text(minuteToWait,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),),
                const Spacer(),
                Text(formattedTime),
              ],
            ),
          )
        ],
      ),
    );
  }
}
