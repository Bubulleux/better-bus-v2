import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/data_provider/local_data_handler.dart';
import 'package:better_bus_v2/model/clean/bus_line.dart';
import 'package:better_bus_v2/model/clean/view_shortcut.dart';
import 'package:better_bus_v2/views/common/content_container.dart';
import 'package:better_bus_v2/views/common/context_menu.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:better_bus_v2/views/stop_info/stop_info_page.dart';
import 'package:better_bus_v2/views/view_shortcut_editor/view_shortcut_editor_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShortcutWidgetRoot extends StatefulWidget {
  const ShortcutWidgetRoot({Key? key}) : super(key: key);

  @override
  State<ShortcutWidgetRoot> createState() => ShortcutWidgetRootState();
}

class ShortcutWidgetRootState extends State<ShortcutWidgetRoot> {
  SharedPreferences? preferences;
  List<ViewShortcut>? shortcuts;

  final DecorationTween decorationTweenReorder = DecorationTween(
      begin: BoxDecoration(
        borderRadius: CustomDecorations.borderRadius,
      ),
      end: BoxDecoration(borderRadius: CustomDecorations.borderRadius, boxShadow: const [
        BoxShadow(color: Color(0x60303030), blurRadius: 20, spreadRadius: 1, offset: Offset(0, 6))
      ]));

  void editShortcut(int? index) {
    Navigator.of(context).pushNamed(ViewShortcutEditorPage.routeName, arguments: index == null ? null : shortcuts![index])
        .then((value) {
      if (value == null || !mounted) {
        return;
      }
      if (index == null) {
        shortcuts!.add(value as ViewShortcut);
      } else {
        shortcuts![index] = value as ViewShortcut;
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
          const Text(AppString.deleteShortcutNotification),
          const Spacer(),
          TextButton(
            onPressed: cancel,
            child: Text(
              AppString.cancelLabel,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          )
        ],
      ),
      duration: const Duration(seconds: 5),
    ));
    setState(() {});
  }

  void showContextMenu(int index) {
    CustomContextMenu.show(
      context,
      [
        ContextMenuAction(AppString.modifyLabel, Icons.edit_outlined, action: () => editShortcut(index)),
        ContextMenuAction(AppString.deleteLabel, Icons.delete, isDangerous: true, action: () => removeShortcut(index))
      ],
    );
  }

  void showShortcutContent(int index) {
    Navigator.of(context).pushNamed(StopInfoPage.routeName,
        arguments: StopInfoPageArgument(shortcuts![index].stop, shortcuts![index].lines));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ViewShortcut>>(
      future: LocalDataHandler.loadShortcut(),
      initialData: shortcuts,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          shortcuts = snapshot.data!;
          if (shortcuts!.isEmpty) {
            return Center(
              child: Container(
                decoration: CustomDecorations.of(context).boxBackground,
                padding: const EdgeInsets.all(8),
                child: RichText(
                    text: TextSpan(
                        children: const [
                      TextSpan(
                        text: AppString.emptyShortcut,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      TextSpan(
                        text: AppString.emptyShortcutAdvice,
                      )
                    ],
                        style: TextStyle(
                          color: Colors.black.withAlpha(150),
                        ))),
              ),
            );
          }
          return ReorderableListView.builder(
              itemCount: shortcuts!.length,
              itemBuilder: (context, index) => ShortcutWidget(
                    key: ObjectKey(shortcuts![index]),
                    shortcut: shortcuts![index],
                    onPressed: () => showShortcutContent(index),
                    onLongPressed: () => showContextMenu(index),
                  ),
              proxyDecorator: (Widget child, int index, Animation<double> animation) {
                return Material(
                  color: Colors.transparent,
                  child: DecoratedBoxTransition(
                    decoration: decorationTweenReorder.animate(animation),
                    child: child,
                  ),
                );
              },
              onReorder: (int oldIndex, int newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final ViewShortcut item = shortcuts!.removeAt(oldIndex);
                shortcuts!.insert(newIndex, item);
                LocalDataHandler.saveShortcuts(shortcuts!);
                setState(() {});
              });
        } else if (snapshot.hasError) {
          return const Center(
            child: Text(AppString.errorLabel),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
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
    shortcut.lines.sort();
    for (BusLine line in shortcut.lines) {
      linesWidget.add(LineWidget(line, 25, dynamicWidth: true));
    }

    return CustomContentContainer(
      margin: EdgeInsets.only(bottom: 8),
      onTap: onPressed,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (shortcut.isFavorite)
                  Icon(
                    Icons.star,
                    color: Theme.of(context).primaryColorDark,
                  )
                else
                  Container(width: 0),
                Text(
                  shortcut.shortcutName,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: shortcut.isFavorite ? FontWeight.w500 : FontWeight.normal,
                  ),
                  softWrap: false,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                ),
                IconButton(
                  onPressed: onLongPressed,
                  icon: const Icon(Icons.more_vert),
                  padding: EdgeInsets.zero,
                )
              ],
            ),
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
                  runSpacing: 3,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
