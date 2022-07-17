import 'dart:convert';

import 'package:better_bus_v2/model/clean/bus_line.dart';
import 'package:better_bus_v2/model/clean/terminal.dart';
import 'package:better_bus_v2/model/clean/view_shortcut.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:better_bus_v2/views/view_shortcut_editor/view_shortcut_editor_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/content_container.dart';

const String shortcutViewPreference = "shortcut";

class ShortcutWidgetRoot extends StatefulWidget {
  const ShortcutWidgetRoot({Key? key}) : super(key: key);

  @override
  State<ShortcutWidgetRoot> createState() => _ShortcutWidgetRootState();
}

class _ShortcutWidgetRootState extends State<ShortcutWidgetRoot> {
  SharedPreferences? preferences;
  List<ViewShortcut>? shortcuts;

  void editShortcut(int? index) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ViewShortcutEditorPage(index, shortcuts!);
    }));
  }

  Future<List<ViewShortcut>> loadShortcut() async {
    preferences ??= await SharedPreferences.getInstance();
    List<String>? rawShortcuts = preferences!.getStringList(shortcutViewPreference);
    if (rawShortcuts == null || rawShortcuts.isEmpty){
      shortcuts = [];
      return shortcuts!;
    }

    shortcuts = [];
    for (String rawShortcut in rawShortcuts) {
      shortcuts!.add(ViewShortcut.fromJson(jsonDecode(rawShortcut)));
    }

    return shortcuts!;
  }

  @override
  void initState() {
    super.initState();
    loadShortcut();
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(onPressed: () {editShortcut(null);}, child: Text("New Shortcut"))
        ],
      ),
    );
  }
}

class ShortcutWidget extends StatelessWidget {
  const ShortcutWidget(this.shortcut, {Key? key}) : super(key: key);

  final ViewShortcut shortcut;

  @override
  Widget build(BuildContext context) {
    List<BusLine> displayLine = [];
    List<Widget> linesWidget = [];
    for (BusLine line in shortcut.lines) {
        linesWidget.add(LineWidget(line, 25, dynamicWidth: true,));
    }

    return ClickableContentContainer(
      //padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        child: Column(
          children: [
            Text(
              shortcut.shortcutName,
              style: Theme.of(context).textTheme.headline5,
            ),
            const Spacer(),
            Row(
              children: [
                Text(
                  shortcut.shortcutName,
                  style: const TextStyle(fontSize: 15),
                ),
                const Spacer(),
                Wrap(
                  children: linesWidget,
                  spacing: 3,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
