import 'dart:math';

import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/model/clean/bus_line.dart';
import 'package:better_bus_v2/views/common/background.dart';
import 'package:better_bus_v2/views/common/content_container.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:flutter/material.dart';

import '../../model/clean/bus_stop.dart';

class TerminusSelectorPage extends StatefulWidget {
  const TerminusSelectorPage(this.stop,
      {this.previousData = const [], Key? key})
      : super(key: key);

  final BusStop stop;
  final List<BusLine> previousData;

  @override
  State<TerminusSelectorPage> createState() => _TerminusSelectorPageState();
}

class _TerminusSelectorPageState extends State<TerminusSelectorPage> {
  List<BusLine>? validBusLine;
  List<List<List<bool>>> selectedTerminus = [];

  bool get allIsSelected => selectedTerminus.every(
      (element) => element[0].every((e) => e) && element[1].every((e) => e));

  Future<List<BusLine>> getTerminus() async {
    if (validBusLine != null) {
      return validBusLine!;
    }

    List<BusLine> stopLines =
        await VitalisDataProvider.getLines(widget.stop) ?? [];
    selectedTerminus = [];
    // List<LineBoarding> lineBoarding = await Future.wait<LineBoarding>(stopLines
    //     .map((line) => VitalisDataProvider.getLineBoarding(widget.stop, line)));
    //
    // List<BusLine> result = [];
    // for (int i = 0; i < stopLines.length; i++) {
    //   result.add(BusLine(
    //       stopLines[i].id, stopLines[i].fullName, stopLines[i].color,
    //       goDirection: lineBoarding[i].go.keys.toList(),
    //       backDirection: lineBoarding[i].back.keys.toList()));
    //   selectedTerminus.add([
    //     [ for(String _ in lineBoarding[i].go.keys) false],
    //     [ for(String _ in lineBoarding[i].back.keys) false],
    //   ]);
    // }

    for (int i = 0; i < stopLines.length; i++) {
      int previousLineIndex = widget.previousData
          .indexWhere((element) => element.id == stopLines[i].id);

      selectedTerminus.add([
        stopLines[i].goDirection.map((e) {
          if (previousLineIndex == -1) {
            return false;
          }
          return widget.previousData[previousLineIndex].goDirection.contains(e);

        }).toList(),
        stopLines[i].backDirection.map((e) {
          if (previousLineIndex == -1) {
            return false;
          }
          return widget.previousData[previousLineIndex].backDirection.contains(e);

        }).toList(),
      ]);
    }

    validBusLine = stopLines;
    return stopLines;
  }

  @override
  void initState() {
    super.initState();

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
                        return const Text("!Error");
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
                  ElevatedButton(onPressed: cancel, child: const Text("! Anuler")),
                  ElevatedButton(
                      onPressed: selectAll, child: Text(allIsSelected ? "! Tout déselectier" : "! Tout selection")
                  ),
                  ElevatedButton(onPressed: validate, child: const Text("Valider")),
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
      List<String> goTerminus = [];
      List<String> backTerminus = [];
      for (int j = 0; j < selectedTerminus[i][0].length; j++) {
        if (selectedTerminus[i][0][j]) {
          goTerminus.add(validBusLine![i].goDirection[j]);
        }
      }
      for (int j = 0; j < selectedTerminus[i][1].length; j++) {
        if (selectedTerminus[i][1][j]) {
          backTerminus.add(validBusLine![i].backDirection[j]);
        }
      }

      if (goTerminus.isNotEmpty || backTerminus.isNotEmpty) {
        BusLine line = validBusLine![i];
        result.add(BusLine(line.id, line.fullName, line.color,
            goDirection: goTerminus, backDirection: backTerminus));
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
                            line.fullName,
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
  const TerminusSelection(this.rootState, this.index, this.isGo, {Key? key})
      : super(key: key);

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
        widget.isGo ? _line.goDirection : _line.backDirection;

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
