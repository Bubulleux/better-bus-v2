import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/model/clean/line_boarding.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:flutter/material.dart';

import '../../model/clean/bus_line.dart';
import '../../model/clean/bus_stop.dart';

class TimeTableView extends StatefulWidget {
  const TimeTableView(this.stop, {Key? key}) : super(key: key);

  final BusStop stop;

  @override
  State<TimeTableView> createState() => _TimeTableViewState();
}

class _TimeTableViewState extends State<TimeTableView> {
  List<BusLine>? busLines;
  BusLine? busLineSelected;

  LineBoarding? boarding;
  int? boardingSelected;

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

  @override
  Widget build(BuildContext context) {
    String? directionString;
    if (boardingSelected != null) {
      directionString = (boardingSelected == 0 ? boarding!.back : boarding!.go)
          .keys
          .join(" | ");
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: Column(
        children: [
          DropdownButton<BusLine>(
            isExpanded: true,
            onChanged: selectLine,
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
          Row(
            children: [
              Expanded(
                  child: Text(
                directionString ?? " ",
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
              )),
              TextButton(
                onPressed: changeDirection,
                child: Icon(Icons.change_circle_outlined),
              )
            ],
          )
        ],
      ),
    );
  }
}
