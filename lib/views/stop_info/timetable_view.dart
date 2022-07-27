import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/model/clean/line_boarding.dart';
import 'package:better_bus_v2/model/clean/timetable.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/clean/bus_line.dart';
import '../../model/clean/bus_stop.dart';

class TimeTableView extends StatefulWidget {
  const TimeTableView(this.stop, {Key? key}) : super(key: key);

  final BusStop stop;

  @override
  State<TimeTableView> createState() => _TimeTableViewState();
}

class _TimeTableViewState extends State<TimeTableView> with AutomaticKeepAliveClientMixin{
  List<BusLine>? busLines;
  BusLine? busLineSelected;

  LineBoarding? boarding;
  int? boardingSelected;

  DateTime selectedDate = DateTime.now();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    VitalisDataProvider.getLines(widget.stop).then((value) {
      if (mounted) {
        setState(() {
          busLines = value;
        });
      }
    });
  }

  void selectLine(BusLine? line) {
    setState(() {
      boarding = null;
      boardingSelected = null;
      busLineSelected = line;
    });

    if (line == null) {
      return;
    }

    VitalisDataProvider.getLineBoarding(widget.stop, line).then((value) {
      if (mounted) {
        setState(() {
          boarding = value;
          changeDirection();
        });
      }
    });
  }

  Widget timetableEmpty = Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: const [
      Icon(Icons.error_outline),
      Text("! Aucun Bus Ne passera se jours la sur cette ligne")
    ],
  );

  void changeDirection() {
    if (boarding == null) {
      return;
    }
    if (boardingSelected == null) {
      setState(() {
        if (boarding!.back.isNotEmpty) {
          boardingSelected = 0;
        } else {
          boardingSelected = 1;
        }
      });
      return;
    }

    setState(() {
      if (boardingSelected == 0 && boarding!.go.isNotEmpty) {
        boardingSelected = 1;
      } else if (boarding!.back.isNotEmpty) {
        boardingSelected = 0;
      }
    });
    if (boarding!.go.isEmpty || boarding!.back.isEmpty) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("! Il n'y a qu'une seul direction"),
      ));
    }
  }

  void selectDate() {
    showDatePicker(
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
      directionString = (boardingSelected == 0 ? boarding!.back : boarding!.go)
          .keys
          .join(" | ");
    }

    Widget timeTableBody = Container();
    if (busLineSelected != null && boardingSelected != null) {
      timeTableBody = FutureBuilder(
        future: VitalisDataProvider.getTimetable(widget.stop, busLineSelected!,
            boardingSelected!, boarding!, selectedDate),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("Error"),
              );
            } else if (snapshot.hasData) {
              Timetable timetable = snapshot.data! as Timetable;
              if (timetable.schedule.isEmpty) {
                return timetableEmpty;
              }
              return TimetableOutput(timetable);
            }
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: Column(
        children: [
          InputDecoration(
            DropdownButton<BusLine>(
              isExpanded: true,
              onChanged: selectLine,
              underline: Container(),
              value: busLineSelected,
              items: (busLines ?? [])
                  .map<DropdownMenuItem<BusLine>>((BusLine value) {
                return DropdownMenuItem<BusLine>(
                  value: value,
                  child: Row(
                    children: [
                      LineWidget(value, 30),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            value.fullName,
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
          InputDecoration(
            Row(
              children: [
                const Icon(Icons.directions_bus_outlined),
                const SizedBox(width: 8,),
                Expanded(
                    child: Text(
                  directionString  ?? " ",
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
          GestureDetector(
            onTap: selectDate,
            child: InputDecoration(
              Row(
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
          ),
          Expanded(child: timeTableBody),
        ],
      ),
    );
  }

}

class InputDecoration extends StatelessWidget {
  const InputDecoration(this.child, {Key? key}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: child,
      ),
    );
  }
}

class TimetableOutput extends StatelessWidget {
  const TimetableOutput(this.timetable, {Key? key}) : super(key: key);

  final Timetable timetable;

  @override
  Widget build(BuildContext context) {
    Map<int, List<BusSchedule>> timetableSorted = {};
    for (BusSchedule schedule in timetable.schedule) {
      if (!timetableSorted.containsKey(schedule.time.hour)) {
        timetableSorted[schedule.time.hour] = [];
      }
      timetableSorted[schedule.time.hour]!.add(schedule);
    }

    List<Widget> labelsPassage = [];
    for (MapEntry<String, String> entry in timetable.terminalLabel.entries) {
      labelsPassage.add(Text(
        "${entry.key}: ${entry.value}",
        textAlign: TextAlign.left,
        style: Theme.of(context).textTheme.bodySmall,
      ));
    }

    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: timetableSorted.length,
              itemBuilder: (context, index) {
                int key = timetableSorted.keys.elementAt(index);
                List<Widget> rowContent = [];
                for (BusSchedule schedule in timetableSorted[key]!) {
                  rowContent.add(SizedBox(
                    width: 45,
                    child: Text.rich(TextSpan(
                      text: schedule.time.minute.toString(),
                      children: [
                        TextSpan(
                          text: schedule.label,
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
                        border:
                            Border.all(color: Theme.of(context).primaryColor)),
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
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(20)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: labelsPassage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
