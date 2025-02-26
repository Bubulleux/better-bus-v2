import 'dart:math';

import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/core/full_provider.dart';
import 'package:better_bus_v2/core/models/bus_line.dart';
import 'package:better_bus_v2/core/models/line_direction.dart';
import 'package:better_bus_v2/core/models/station.dart';
import 'package:better_bus_v2/views/common/background.dart';
import 'package:better_bus_v2/views/common/content_container.dart';
import 'package:better_bus_v2/views/common/custom_future.dart';
import 'package:better_bus_v2/views/common/directionSelector.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:flutter/material.dart';

class TerminusSelectorPageArgument {
  final Station stop;
  final Set<LineDirection> previousData;

  const TerminusSelectorPageArgument(this.stop, this.previousData);
}

class TerminusSelectorPage extends StatefulWidget {
  const TerminusSelectorPage({super.key});

  static const String routeName = "/terminusSelector";

  @override
  State<TerminusSelectorPage> createState() => _TerminusSelectorPageState();
}

class _TerminusSelectorPageState extends State<TerminusSelectorPage> {
  late Station stop;
  late Set<LineDirection> previousData;

  List<BusLine>? allLines;
  Set<LineDirection> selected = {};

  bool get allIsSelected =>
      allLines?.every((line) => selected.containsAll(
          line.directions.map((e) => LineDirection.fromDir(line, e)))) ??
      false;

  Future<List<BusLine>> getData() async {
    if (!mounted) return [];

    allLines = await FullProvider.of(context).getPassingLines(stop);
    return allLines!;
  }

  // Future<List<BusLine>> getTerminus() async {
  //   if (validBusLine != null) {
  //     return validBusLine!;
  //   }
  //
  //   List<BusLine> stopLines =
  //       await FullProvider.of(context).getPassingLines(stop) ?? [];
  //   stopLines.sort();
  //   selectedTerminus = {for (var e in previousData) e.id: e.oldDir};
  //
  //   for (int i = 0; i < stopLines.length; i++) {
  //     int previousLineIndex =
  //         previousData.indexWhere((element) => element.id == stopLines[i].id);
  //
  //     if (previousLineIndex == -1) {
  //       selectedTerminus.add(stopLines[i]
  //           .direction
  //           .values
  //           .toList()
  //           .map((e) => e.map((f) => false).toList())
  //           .toList());
  //       continue;
  //     }
  //     final line = previousData[previousLineIndex];
  //
  //     selectedTerminus.add(stopLines[i]
  //         .direction
  //         .entries
  //         .toList()
  //         .map((e) =>
  //             e.value.map((f) => line.direction[e.key]!.contains(f)).toList())
  //         .toList());
  //
  //     setState(() {});
  //   }
  //
  //   validBusLine = stopLines;
  //   return stopLines;
  // }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    TerminusSelectorPageArgument argument = ModalRoute.of(context)!
        .settings
        .arguments as TerminusSelectorPageArgument;
    stop = argument.stop;
    previousData = argument.previousData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: CustomFutureBuilder(
                  future: getData,
                  onData: (ctx, data, r) {
                    return LineDirectionList(selected: selected, onChanged: (value) {
                      r();
                      setState(() {
                        selected = value;
                      });
                    }, lines: data);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: cancel,
                      child: const Text(AppString.cancelLabel)),
                  ElevatedButton(
                      onPressed: selectAll,
                      child: Text(allIsSelected
                          ? AppString.unSelectAll
                          : AppString.selectAll)),
                  ElevatedButton(
                      onPressed: validate,
                      child: const Text(AppString.validateLabel)),
                ],
              )
            ],
          ),
        ),
      ),
    );
    return Container();
  }

  void selectAll() {
    setState(() {
      if (allIsSelected) {
        selected = {};
      } else {
        for (var line in allLines!) {
          selected.addAll(line.getLinesDirection());
        }
      }
    });
  }

  void validate() {
    if (allLines == null) {
      cancel();
      return;
    }

    Navigator.pop(context, selected);
  }

  void cancel() {
    Navigator.pop(context, null);
  }
}

class LineDirectionList extends StatefulWidget {
  const LineDirectionList(
      {super.key,
      required this.selected,
      required this.onChanged,
      required this.lines});

  final List<BusLine> lines;
  final Set<LineDirection> selected;
  final void Function(Set<LineDirection> value) onChanged;

  @override
  State<LineDirectionList> createState() => _LineDirectionListState();
}

class _LineDirectionListState extends State<LineDirectionList> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {

    });
  }
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.lines.length,
      itemBuilder: (context, index) {
        BusLine line = widget.lines[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: NormalContentContainer(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              child: Column(
                children: [
                  Row(
                    children: [
                      LineWidget(line, 40),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            line.name,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                  DirectionSelector(
                    line,
                    previousData: widget.selected.where((e) => e.line == line).toSet(),
                    onChanged: (value) {
                      widget.selected.removeWhere((e) => e.line == line);
                      widget.selected.addAll(
                          value.map((e) => LineDirection.fromDir(line, e)));
                    },
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
