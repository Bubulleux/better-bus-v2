import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/model/clean/view_shortcut.dart';
import 'package:better_bus_v2/views/common/background.dart';
import 'package:flutter/material.dart';

import '../../model/clean/bus_line.dart';

class ViewShortcutEditorPage extends StatefulWidget {
  const ViewShortcutEditorPage(this.index, this.listShortcut,  {Key? key}) : super(key: key);

  final int? index;
  final List<ViewShortcut> listShortcut;

  @override
  State<ViewShortcutEditorPage> createState() => _ViewShortcutEditorPageState();
}

class _ViewShortcutEditorPageState extends State<ViewShortcutEditorPage> {

  late List<ViewShortcut> listShortcut;
  String shortcutName = "";
  BusStop? shortcutBusStop;
  List<BusLine> shortCutBusLines = [];

  @override
  void initState() {
    super.initState();
    listShortcut = List<ViewShortcut>.from(widget.listShortcut);

    if (widget.index != null) {
      shortcutName = listShortcut[widget.index!].shortcutName;
      shortcutBusStop = listShortcut[widget.index!].stop;
      shortCutBusLines = listShortcut[widget.index!].lines;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: SafeArea(
          child:
            Column(
              children: [
                TextField(

                ),

              ],
            )
        ),
      ),
    );
  }
}
