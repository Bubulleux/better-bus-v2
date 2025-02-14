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
  List<List<List<bool>>> selectedTerminus = [];

  bool get allIsSelected => selectedTerminus.every(
      (element) => element[0].every((e) => e) && element[1].every((e) => e));

  Future<List<BusLine>> getTerminus() async {
    if (validBusLine != null) {
      return validBusLine!;
    }

    List<BusLine> stopLines = await FullProvider.of(context).getPassingLines(stop) ?? [];
    stopLines.sort();
    selectedTerminus = [];


    for (int i = 0; i < stopLines.length; i++) {
      int previousLineIndex = previousData
          .indexWhere((element) => element.id == stopLines[i].id);

      if (previousLineIndex == -1) {
        selectedTerminus.add(
          stopLines[i].direction.values.toList().map(
              (e) => e.map((f) => false).toList()
          ).toList()
        );
        continue;
      }
      final line = previousData[previousLineIndex];

      selectedTerminus.add(
          stopLines[i].direction.entries.toList().map(
                  (e) => e.value.map((f) => line.direction[e.key]!.contains(f)).toList()
          ).toList()
      );

      setState(() {});
    }

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
    TerminusSelectorPageArgument argument = ModalRoute.of(context)!.settings.arguments as TerminusSelectorPageArgument;
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
                  ElevatedButton(onPressed: cancel, child: const Text(AppString.cancelLabel)),
                  ElevatedButton(
                      onPressed: selectAll, child: Text(allIsSelected ? AppString.unSelectAll : AppString.selectAll)
                  ),
                  ElevatedButton(onPressed: validate, child: const Text(AppString.validateLabel)),
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
    for (int i = 0; i < selectedTerminus.length; i++) {
      List<List<bool>> element = selectedTerminus[i];
      element[0].fillRange(0, element[0].length, replaceValue);
      element[1].fillRange(0, element[1].length, replaceValue);
    }
    setState(() {});
  }

  void validate() {
    if (validBusLine == null) {
      cancel();
      return;
    }
    List<BusLine> result = [];
    for (int i = 0; i < selectedTerminus.length; i++) {
      List<List<String>> terminus = [[], []];
      for (int k = 0; k < 2; k++) {

        for (int j = 0; j < selectedTerminus[i][0].length; j++) {
          if (selectedTerminus[i][0][j]) {
            terminus[k].add(validBusLine![i].direction[k]![j]);
          }
        }
      }

      if (terminus[0].isNotEmpty || terminus[1].isNotEmpty) {
        BusLine line = validBusLine![i];
        result.add(BusLine(line.id, line.name, line.color,
        direction: {0: terminus[0], 1: terminus[1]}));
      }
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
                  TerminusSelection(this, index, true),
                  TerminusSelection(this, index, false),
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
  const TerminusSelection(this.rootState, this.index, this.isGo, {super.key});

  final _TerminusSelectorPageState rootState;
  final int index;
  final bool isGo;

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
    expandController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
  }

  bool? checkIfAllSelected(List<bool> list) {
    bool getFalse = false;
    bool getTrue = false;

    for (bool e in list) {
      if (e) {
        getTrue = true;
      } else {
        getFalse = true;
      }
      if (getTrue && getFalse) {
        return null;
      }
    }

    return getFalse ? false : true;
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    List<String> getDirection(BusLine _line) =>
        widget.isGo ? _line.direction[1]! : _line.direction[0]!;

    BusLine line = widget.rootState.validBusLine![widget.index];
    List<bool> entrySelected =
        widget.rootState.selectedTerminus[widget.index][widget.isGo ? 0 : 1];
    bool? allSelected = checkIfAllSelected(entrySelected);

    if (entrySelected.isEmpty) {
      return Container();
    }
    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: allSelected,
              tristate: true,
              onChanged: (value) {
                value ??= false;
                entrySelected.fillRange(0, entrySelected.length, value);
                setState(() {});
              },
            ),
            Expanded(
              child: Text(
                getDirection(line)[0],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (entrySelected.length > 1)
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
        if (entrySelected.length > 1)
          SizeTransition(
            axisAlignment: 1,
            sizeFactor: animation,
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Column(
                children: Iterable<int>.generate(entrySelected.length)
                    .map((int index) {
                  String direction = getDirection(line)[index];
                  return Row(
                    children: [
                      Checkbox(
                        value: entrySelected[index],
                        onChanged: (value) {
                          entrySelected[index] = value!;
                          setState(() {});
                        },
                      ),
                      Text(direction),
                    ],
                  );
                }).toList(),
              ),
            ),
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
