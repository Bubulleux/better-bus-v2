import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/core/full_provider.dart';
import 'package:better_bus_v2/core/models/bus_line.dart';
import 'package:better_bus_v2/core/models/line_timetable.dart';
import 'package:better_bus_v2/core/models/station.dart';
import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/views/common/custom_input_widget.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeTableView extends StatefulWidget {
  const TimeTableView(this.stop, {super.key});

  final Station stop;

  @override
  State<TimeTableView> createState() => _TimeTableViewState();
}

class _TimeTableViewState extends State<TimeTableView>
    with AutomaticKeepAliveClientMixin {
  List<BusLine>? busLines;
  BusLine? busLineSelected;

  int? boardingSelected;

  DateTime selectedDate = DateTime.now();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    FullProvider.of(context).getPassingLines(widget.stop).then((value) {
      if (mounted) {
        setState(() {
          busLines = value;
          busLines?.sort();
        });
      }
    });
  }

  void selectLine(BusLine? line) {
    setState(() {
      boardingSelected = null;
      busLineSelected = line;
    });

    if (line == null) {
      return;
    }

    changeDirection();
  }

  Widget timetableEmpty = const Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(
        height: 50,
        width: double.infinity,
      ),
      Icon(Icons.error_outline),
      Text(AppString.noBusToday),
    ],
  );

  void changeDirection() {
    if (busLineSelected == null) {
      return;
    }
    if (boardingSelected == null) {
      setState(() {
        boardingSelected = busLineSelected!.direction.keys.first;
      });
      return;
    }

    setState(() {
      if (boardingSelected == 0 && busLineSelected!.direction[1] != null) {
        boardingSelected = 1;
      } else if (busLineSelected!.direction[0] != null) {
        boardingSelected = 0;
      }
    });
    if (busLineSelected!.direction[0] == null ||
        busLineSelected!.direction[1] == null) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(AppString.onlyOneDirection),
      ));
    }
  }

  void selectDate() {
    showDatePicker(
            locale: const Locale("fr", "FR"),
            context: context,
            initialDate: selectedDate,
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now().add(const Duration(days: 365)))
        .then((value) {
      if (value == null) {
        return;
      }
      if (mounted) {
        setState(() {
          selectedDate = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    String? directionString;
    if (boardingSelected != null) {
      directionString = busLineSelected!.direction[boardingSelected]!
          .join(" | ");
    }

    Widget timeTableBody = Container();
    if (busLineSelected != null && boardingSelected != null) {
      timeTableBody = FutureBuilder(
        future: FullProvider.of(context).getLineTimetable(widget.stop, busLineSelected!,
            boardingSelected!, selectedDate),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("Error"),
              );
            } else if (snapshot.hasData) {
              LineTimetable timetable = snapshot.data!;
              if (timetable.passingTimes.isEmpty) {
                return timetableEmpty;
              }
              return TimetableOutput(timetable);
            }
          }
          return const SizedBox(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: SingleChildScrollView(
        child: Column(
          children: [
            CustomInputWidget(
              child: DropdownButton<BusLine>(
                isExpanded: true,
                onChanged: selectLine,
                underline: Container(),
                hint: const Text(AppString.selectALine),
                value: busLineSelected,
                items: (busLines ?? [])
                    .map<DropdownMenuItem<BusLine>>((BusLine value) {
                  return DropdownMenuItem<BusLine>(
                    value: value,
                    child: Row(
                      children: [
                        LineWidget(value, 25),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              value.name,
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            CustomInputWidget(
              onTap: changeDirection,
              child: Row(
                children: [
                  const Icon(Icons.directions_bus_outlined),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                      child: Text(
                    directionString ?? " ",
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.fade,
                    softWrap: true,
                  )),
                  TextButton(
                    onPressed: changeDirection,
                    child: const Icon(Icons.change_circle_outlined),
                  )
                ],
              ),
            ),
            CustomInputWidget(
              onTap: selectDate,
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_outlined),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(
                      DateFormat("dd/MM/yyyy").format(selectedDate),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  )),
                  TextButton(
                    onPressed: selectDate,
                    child: const Icon(Icons.change_circle_outlined),
                  ),
                ],
              ),
            ),
            timeTableBody,
          ],
        ),
      ),
    );
  }
}

class TimetableOutput extends StatelessWidget {
  const TimetableOutput(this.timetable, {super.key});

  final LineTimetable timetable;

  @override
  Widget build(BuildContext context) {
    Map<int, List<MapEntry<DateTime, String>>> timetableSorted = {};
    for (var schedule in timetable.passingTimes.entries) {
      if (!timetableSorted.containsKey(schedule.key.hour)) {
        timetableSorted[schedule.key.hour] = [];
      }
      timetableSorted[schedule.key.hour]!.add(schedule);
    }

    List<Widget> labelsPassage = [];
    for (MapEntry<String, String> entry in timetable.destinations.entries) {
      labelsPassage.add(Text(
        "${entry.value}: ${entry.key}",
        textAlign: TextAlign.left,
        style: Theme.of(context).textTheme.bodySmall,
      ));
    }

    return Container(
      padding: const EdgeInsets.only(top: 3),
      child: Column(
        children: [
          ListView.builder(
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            itemCount: timetableSorted.length,
            itemBuilder: (context, index) {
              int key = timetableSorted.keys.elementAt(index);
              List<Widget> rowContent = [];
              for (var schedule in timetableSorted[key]!) {
                rowContent.add(SizedBox(
                  width: 45,
                  child: Text.rich(TextSpan(
                    text: schedule.key.minute.toString(),
                    children: [
                      TextSpan(
                        text: schedule.value,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    style: Theme.of(context).textTheme.bodyMedium,
                  )),
                ));
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Theme.of(context).primaryColor),
                    color: index % 2 == 0
                        ? Theme.of(context).primaryColorLight
                        : null,
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Container(
                          width: 35,
                          //height: double.infinity,
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  bottomLeft: Radius.circular(15))),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 3),
                          child: Text(
                            key.toString(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Wrap(
                              direction: Axis.horizontal,
                              //runSpacing: 20,
                              children: rowContent,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            width: double.infinity,
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: labelsPassage,
            ),
          ),
        ],
      ),
    );
  }
}
