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
    setState(() {
      selected = previousData.toSet();
    });
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
                      setState(() {
                      });
                    }, lines: data);
                  },
                ),
              ),
              Material(
                elevation: 2,
                //color: Colors.transparent,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(AppString.selectAll)),
                          Switch(value: allIsSelected, onChanged: (_) => selectAll())
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                              onPressed: cancel,
                              child: const Text(AppString.cancelLabel)),

                          ElevatedButton(
                              onPressed: validate,
                              child: const Text(AppString.validateLabel)),
                        ],
                      ),
                    ],
                  ),
                ),
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
  Widget build(BuildContext context) {
    return ListView.builder(
      clipBehavior: Clip.none,
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
                    selected: widget.selected.where((e) => e.line == line).toSet(),
                    onChanged: (value) {
                      setState(() {
                        widget.selected.removeWhere((e) => e.line == line);
                        widget.selected.addAll(
                            value.map((e) => LineDirection.fromDir(line, e)));
                        widget.onChanged(widget.selected);
                      });
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
