import 'dart:math';

import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/core/full_provider.dart';
import 'package:better_bus_v2/core/models/bus_line.dart';
import 'package:better_bus_v2/core/models/station.dart';
import 'package:better_bus_v2/views/common/background.dart';
import 'package:better_bus_v2/views/common/content_container.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:flutter/material.dart';

class TerminusSelectorPageArgument {
  final Station stop;
  final List<BusLine> previousData;

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
  late List<BusLine> previousData;

  List<BusLine>? validBusLine;
  Map<String, Map<int, List<String>>> selectedTerminus = {};

  bool get allIsSelected => validBusLine?.every(
      (line) => line.direction.entries.every(
          (d) => d.value.every((n) => selectedTerminus[line.id]?[d.key]?.contains(n) ?? false)
      )
  ) ?? false;

  Future<List<BusLine>> getTerminus() async {
    if (validBusLine != null) {
      return validBusLine!;
    }

    List<BusLine> stopLines =
        await FullProvider.of(context).getPassingLines(stop) ?? [];
    stopLines.sort();
    selectedTerminus = {for (var e in previousData) e.id: e.direction};

    // for (int i = 0; i < stopLines.length; i++) {
    //   int previousLineIndex =
    //       previousData.indexWhere((element) => element.id == stopLines[i].id);
    //
    //   if (previousLineIndex == -1) {
    //     selectedTerminus.add(stopLines[i]
    //         .direction
    //         .values
    //         .toList()
    //         .map((e) => e.map((f) => false).toList())
    //         .toList());
    //     continue;
    //   }
    //   final line = previousData[previousLineIndex];
    //
    //   selectedTerminus.add(stopLines[i]
    //       .direction
    //       .entries
    //       .toList()
    //       .map((e) =>
    //           e.value.map((f) => line.direction[e.key]!.contains(f)).toList())
    //       .toList());
    //
    //   setState(() {});
    // }

    validBusLine = stopLines;
    return stopLines;
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
    getTerminus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder<List<BusLine>>(
                  future: getTerminus(),
                  initialData: validBusLine,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.hasError) {
                        return const Text(AppString.errorLabel);
                      } else {
                        List<BusLine> lines = snapshot.data!;
                        return getListView(lines);
                      }
                    }
                    return const Center(child: CircularProgressIndicator());
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
  }

  void selectAll() {
    bool replaceValue = !allIsSelected;
    if (allIsSelected) {
      selectedTerminus = {};
    } else {
      for (var line in validBusLine!) {
        selectedTerminus[line.id] =
            line.direction.map((k, v) =>
              MapEntry(k, v)
            );
      }
    }
    setState(() {});
  }

  void validate() {
    if (validBusLine == null) {
      cancel();
      return;
    }
    List<BusLine> result = [];
    for (var curLine in selectedTerminus.entries) {
      BusLine line = validBusLine!.firstWhere((e) => e.id == curLine.key);
      result.add(BusLine(line.id, line.name, line.color, direction: curLine.value));
    }

    Navigator.pop(context, result);
  }

  void cancel() {
    Navigator.pop(context, null);
  }

  ListView getListView(List<BusLine> lines) {
    return ListView.builder(
      itemCount: lines.length,
      itemBuilder: (context, index) {
        BusLine line = validBusLine![index];

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
                  ...(lines[index]
                      .direction
                      .entries
                      .map((e) => TerminusSelection(
                            e.value,
                            selectedTerminus[line.id]?[e.key] ?? [],
                            onChanged: (newValue) {
                              setState(() {
                              if (!selectedTerminus.containsKey(line.id)) {
                                selectedTerminus[line.id] = {};
                              }

                                selectedTerminus[line.id]![e.key] = newValue;
                              });
                            },
                          ))
                      .toList()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class TerminusSelection extends StatefulWidget {
  const TerminusSelection(this.entries, this.selected,
      {required this.onChanged, super.key});

  final List<String> selected;
  final ValueChanged<List<String>> onChanged;
  final List<String> entries;

  @override
  State<TerminusSelection> createState() => _TerminusSelectionState();
}

class _TerminusSelectionState extends State<TerminusSelection>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController expandController;
  late Animation<double> animation;

  bool isExpand = false;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  void prepareAnimations() {
    expandController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
  }

  bool? checkIfAllSelected() {
    final all = widget.entries.every((e) => widget.selected.contains(e)) ? true : null;
    final none = widget.selected.isEmpty ? false : null;
    return all ?? none;
  }

  void expand() {
    if (isExpand) {
      isExpand = false;
      expandController.reverse();
    } else {
      isExpand = true;
      expandController.forward();
    }
  }

  Widget buildEntries() {
    return Column(
      children: widget.entries.asMap().entries.map((e) {
        String direction = e.value;
        return Row(
          children: [
            Checkbox(
              value: widget.selected.contains(e.value),
              onChanged: (value) {
                print(value);
                if (value == false) {
                  widget.onChanged(widget.selected.where((c) => c != e.value).toList());
                } else {
                  widget.onChanged(widget.selected + [e.value]);
                }
                setState(() {});
              },
            ),
            Text(direction),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.entries.isEmpty) {
      return Container();
    }
    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: checkIfAllSelected(),
              tristate: true,
              onChanged: (value) {
                widget.onChanged(value == true ? widget.entries : []);
                setState(() {});
              },
            ),
            Expanded(
              child: Text(
                widget.entries[0],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (widget.entries.length > 1)
              TextButton(
                  onPressed: expand,
                  child: AnimatedBuilder(
                      animation: animation,
                      builder: (context, widget) => Transform.rotate(
                          angle: animation.value * pi,
                          child: const Icon(Icons.keyboard_arrow_down))))
            else
              Container(),
          ],
        ),
        if (widget.entries.length > 1)
          SizeTransition(
            axisAlignment: 1,
            sizeFactor: animation,
            child: Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: buildEntries()),
          )
        else
          Container(),
        const Divider(),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
