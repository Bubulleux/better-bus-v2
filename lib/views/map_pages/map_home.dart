import 'package:better_bus_v2/views/common/background.dart';
import 'package:flutter/material.dart';

import '../../app_constant/app_string.dart';
import '../../model/view_shortcut.dart';
import '../common/content_container.dart';
import '../home_page/shortcut_section.dart';

class MapHome extends StatefulWidget {
  const MapHome({required this.onClicked, super.key});

  final ValueSetter<ViewShortcut> onClicked;

  @override
  State<MapHome> createState() => _MapHomeState();
}

class _MapHomeState extends State<MapHome> {
  GlobalKey<ShortcutWidgetRootState> shortcutSection = GlobalKey();

  void newShortcut() {
    shortcutSection.currentState!.editShortcut(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          // elevation: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            margin: const EdgeInsets.only(bottom: 5),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                offset: Offset(0, 5),
                  blurRadius: 2,
                  spreadRadius: -1,
                  color: Colors.black26
              )]
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppString.shortcut,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton(
                    onPressed: newShortcut, child: const Icon(Icons.add)),
              ],
            ),
          ),
        ),
        Expanded(
          child: ShortcutWidgetRoot(
            key: shortcutSection,
            onClicked: widget.onClicked,
          ),
        ),
      ],
    );
  }
}

