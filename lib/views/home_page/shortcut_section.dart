import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/data_provider/local_data_handler.dart';
import 'package:better_bus_v2/model/view_shortcut.dart';
import 'package:better_bus_v2/views/common/content_container.dart';
import 'package:better_bus_v2/views/common/context_menu.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:better_bus_v2/views/stop_info/stop_info_page.dart';
import 'package:better_bus_v2/views/view_shortcut_editor/view_shortcut_editor_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShortcutWidgetRoot extends StatefulWidget {
  const ShortcutWidgetRoot({this.onClicked, super.key});

  final ValueSetter<ViewShortcut>? onClicked;

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
      end: BoxDecoration(
          borderRadius: CustomDecorations.borderRadius,
          boxShadow: const [
            BoxShadow(
                color: Color(0x60303030),
                blurRadius: 20,
                spreadRadius: 1,
                offset: Offset(0, 6))
          ]));

  void editShortcut(int? index) {
    Navigator.of(context)
        .pushNamed(ViewShortcutEditorPage.routeName,
            arguments: index == null ? null : shortcuts![index])
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
        ContextMenuAction(AppString.modifyLabel, Icons.edit_outlined,
            action: () => editShortcut(index)),
        ContextMenuAction(AppString.deleteLabel, Icons.delete,
            isDangerous: true, action: () => removeShortcut(index))
      ],
    );
  }

  void showShortcutContent(int index) {
    if (widget.onClicked != null) {
      widget.onClicked!(shortcuts![index]);
      return;
    }
    Navigator.of(context).pushNamed(StopInfoPage.routeName,
        arguments: StopInfoPageArgument(
            shortcuts![index].stop, shortcuts![index].direction));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ViewShortcut>>(
      future: LocalDataHandler.loadShortcut(context),
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
              proxyDecorator:
                  (Widget child, int index, Animation<double> animation) {
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
          return Center(
            child: Text(snapshot.error.toString()),
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
    super.key,
  });

  final ViewShortcut shortcut;
  final VoidCallback onPressed;
  final VoidCallback onLongPressed;

  @override
  Widget build(BuildContext context) {
    List<Widget> linesWidget = [];
    shortcut.lines.sort();
    for (BusLine line in shortcut.lines) {
      linesWidget.add(LineWidget(line, 13, dynamicWidth: true, rounded: true,));
    }

    final stationWidget = Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      margin: const EdgeInsets.only(right: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.directions_bus,
            size: 13,
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            shortcut.stop.name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    return CustomContentContainer(
      margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      onTap: onPressed,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (shortcut.isFavorite)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.star,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      )
                    else
                      Container(width: 0),
                    Expanded(
                      child: Text(
                        shortcut.shortcutName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: shortcut.isFavorite
                              ? FontWeight.w700
                              : FontWeight.normal,
                        ),
                        softWrap: false,
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4,),
                Wrap(
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 2,
                  runSpacing: 3,
                  children: [
                    stationWidget,
                    ...linesWidget,
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onLongPressed,
            child: const Padding(
              padding: EdgeInsets.all(3),
              child: Icon(Icons.more_vert),
            ),
          ),
        ],
      ),
    );
  }
}
