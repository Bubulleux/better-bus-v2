import 'package:better_bus_v2/app_constante/app_string.dart';
import 'package:flutter/material.dart';

import '../../model/clean/view_shortcut.dart';

class ShortcutOrderEditorPage extends StatefulWidget {
  const ShortcutOrderEditorPage(this.shortcuts, {Key? key}) : super(key: key);

  final List<ViewShortcut> shortcuts;

  @override
  State<ShortcutOrderEditorPage> createState() => _ShortcutOrderEditorPageState();
}

class _ShortcutOrderEditorPageState extends State<ShortcutOrderEditorPage> {
  late List<ViewShortcut> newShortcuts;

  @override
  void initState() {
    super.initState();
    newShortcuts = widget.shortcuts;
  }

  void cancel() {}

  void valid() {}

  void edit(int? index) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Expanded(
                  child: ReorderableListView(
                      // padding: EdgeInsets.all(50),
                      children: [
                        for (int i = 0; i < newShortcuts.length; i++)
                          ListTile(
                            trailing: ReorderableDelayedDragStartListener(index:  i, child: Icon(Icons.drag_handle),),
                            key: ObjectKey(newShortcuts[i]),
                            title: Text(newShortcuts[i].shortcutName),
                          )

                      ],
                      onReorder: (int oldIndex, int newIndex) {
                        setState(() {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final ViewShortcut item = newShortcuts.removeAt(oldIndex);
                          newShortcuts.insert(newIndex, item);
                        });
                      })),
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceAround,
                  children: [
                    ElevatedButton(onPressed: cancel, child: const Text(AppString.cancelLabel)),
                    ElevatedButton(onPressed: valid, child: Text(AppString.validateLabel)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
