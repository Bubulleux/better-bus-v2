import 'dart:convert';
import 'dart:ui';

import 'package:better_bus_v2/data_provider/local_data_handler.dart';
import 'package:better_bus_v2/model/clean/bus_line.dart';
import 'package:better_bus_v2/model/clean/terminal.dart';
import 'package:better_bus_v2/model/clean/view_shortcut.dart';
import 'package:better_bus_v2/views/common/context_menu.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:better_bus_v2/views/common/fake_textfiel.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:better_bus_v2/views/stop_info/stop_info_page.dart';
import 'package:better_bus_v2/views/view_shortcut_editor/view_shortcut_editor_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/content_container.dart';

class ShortcutWidgetRoot extends StatefulWidget {
  const ShortcutWidgetRoot({Key? key}) : super(key: key);

  @override
  State<ShortcutWidgetRoot> createState() => ShortcutWidgetRootState();
}

class ShortcutWidgetRootState extends State<ShortcutWidgetRoot> {
  SharedPreferences? preferences;
  List<ViewShortcut>? shortcuts;

  void editShortcut(int? index) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ViewShortcutEditorPage(index == null ? null : shortcuts![index]);
    })).then((value) {
      if (value == null || !mounted) {
        return;
      }
      if (index == null) {
        shortcuts!.add(value);
      } else {
        shortcuts![index] = value;
      }
      LocalDataHandler.saveShortcuts(shortcuts!);
      setState(() {});
    });
  }

  void removeShortcut(int index) {
    if (shortcuts == null) {
      return;
    }
    ViewShortcut removedShortcut = shortcuts!.removeAt(index);
    LocalDataHandler.saveShortcuts(shortcuts!);

    void cancel() {
      shortcuts!.insert(index, removedShortcut);
      LocalDataHandler.saveShortcuts(shortcuts!);
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      setState(() {});
    }

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          const Text("! Le racourcie a bien été supprimer"),
          const Spacer(),
          TextButton(
            onPressed: cancel,
            child: const Text("! Annuler"),
          )
        ],
      ),
      duration: const Duration(seconds: 5),
    ));
    setState(() {});
  }

  void showContextMenu(int index) {
    CustomContextMenu.show(context,
        [
          ContextMenuAction("! Modifier", Icons.edit_outlined,
              action: () => editShortcut(index)),
          ContextMenuAction("! Supprimer", Icons.delete,
              isDangerous: true, action: () => removeShortcut(index))
        ],
    );
  }

  void showShortcutContent(int index) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => StopInfoPage(shortcuts![index].stop, lines: shortcuts![index].lines),
    ));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<ViewShortcut>>(
              future: LocalDataHandler.loadShortcut(),
              initialData: shortcuts,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  shortcuts = snapshot.data!;
                  return ListView.builder(
                    itemCount: shortcuts!.length,
                    itemBuilder: (context, index) => ShortcutWidget(
                      shortcut: shortcuts![index],
                      onPressed: () => showShortcutContent(index),
                      onLongPressed: () => showContextMenu(index),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text("! Error"),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ShortcutWidget extends StatelessWidget {
  const ShortcutWidget({
    required this.shortcut,
    required this.onPressed,
    required this.onLongPressed,
    Key? key,
  }) : super(key: key);

  final ViewShortcut shortcut;
  final VoidCallback onPressed;
  final VoidCallback onLongPressed;

  @override
  Widget build(BuildContext context) {
    List<Widget> linesWidget = [];
    for (BusLine line in shortcut.lines) {
      linesWidget.add(LineWidget(
        line,
        25,
        dynamicWidth: true,
      ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onLongPress: onLongPressed,
        onTap: onPressed,
        splashColor: Colors.black,
        borderRadius: CustomDecorations.borderRadius,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius:CustomDecorations.borderRadius,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (shortcut.isFavorite)
                    Icon(
                      Icons.star,
                      color: Theme.of(context).primaryColorDark,
                    )
                  else
                    Container(),
                  Flexible(
                    child: Text(
                      shortcut.shortcutName,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: shortcut.isFavorite
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text(
                    shortcut.stop.name,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  Expanded(
                    child: Wrap(
                      children: linesWidget,
                      alignment: WrapAlignment.end,
                      spacing: 3,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
