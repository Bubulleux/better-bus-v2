import 'package:better_bus_v2/model/clean/bus_line.dart';
import 'package:better_bus_v2/model/clean/terminal.dart';
import 'package:better_bus_v2/model/clean/view_shortcut.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShortcutWidgetRoot extends StatefulWidget {
  const ShortcutWidgetRoot({Key? key}) : super(key: key);

  @override
  State<ShortcutWidgetRoot> createState() => _ShortcutWidgetRootState();
}

class _ShortcutWidgetRootState extends State<ShortcutWidgetRoot> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [ShortcutWidget(ViewShortcut.example())],
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
    for (Terminal terminal in shortcut.terminals) {
      if (!displayLine.contains(terminal.line) || true) {
        displayLine.add(terminal.line);
        linesWidget.add(LineWidget(terminal.line, 25, dynamicWidth: true,));
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        width: double.infinity,
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
        decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.circular(40)),
      ),
    );
  }
}
