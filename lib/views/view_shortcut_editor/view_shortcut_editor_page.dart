import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/model/clean/view_shortcut.dart';
import 'package:better_bus_v2/views/common/background.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:better_bus_v2/views/search_page/search_page.dart';
import 'package:better_bus_v2/views/terminus_selector/terminus_selector_page.dart';
import 'package:flutter/material.dart';

import '../../model/clean/bus_line.dart';

class ViewShortcutEditorPage extends StatefulWidget {
  const ViewShortcutEditorPage(this.shortcut, {Key? key}) : super(key: key);

  final ViewShortcut? shortcut;

  @override
  State<ViewShortcutEditorPage> createState() => _ViewShortcutEditorPageState();
}

class _ViewShortcutEditorPageState extends State<ViewShortcutEditorPage> {
  String shortcutName = "----";
  bool shortcutIsFavorite = false;
  BusStop? shortcutBusStop;
  List<BusLine> shortCutBusLines = [];

  late TextEditingController textFieldNameController;

  @override
  void initState() {
    super.initState();

    textFieldNameController = TextEditingController();

    if (widget.shortcut != null) {
      shortcutName = widget.shortcut!.shortcutName;
      shortcutIsFavorite = widget.shortcut!.isFavorite;
      shortcutBusStop = widget.shortcut!.stop;
      shortCutBusLines = widget.shortcut!.lines;
    }

    textFieldNameController.text = shortcutName;

    textFieldNameController.addListener(() {
      shortcutName = textFieldNameController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: SafeArea(
          child: Column(
            children: [
              TextField(
                controller: textFieldNameController,
              ),
              Checkbox(
                  value: shortcutIsFavorite,
                  onChanged: (value) {
                    setState(() => shortcutIsFavorite = value!);
                  }),
              GestureDetector(
                onTap: changeBusStop,
                child: Container(
                  child: Row(
                    children: [
                      Text(shortcutBusStop != null
                          ? shortcutBusStop!.name
                          : "! Selection un arret"),
                      const Icon(Icons.change_circle_outlined),
                    ],
                  ),
                ),
              ),
              TextButton(
                  onPressed: selectTerminus, child: Text("Select terminus")),
              Wrap(
                children:
                    shortCutBusLines.map((e) => LineWidget(e, 30)).toList(),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: cancel,
                      child: const Text("! Cancel"),
                    ),
                    SizedBox(width: 20,),
                    ElevatedButton(
                      onPressed: valid,
                      child: const Text("! Valider"),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void changeBusStop() {
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const SearchPage(saveInHistoric: false)))
        .then((value) {
      if (value == null || !mounted || value! == shortcutBusStop) {
        return;
      }
      setState(() {
        shortcutBusStop = value!;
        shortCutBusLines = [];
      });
    });
  }

  void selectTerminus() {
    if (shortcutBusStop == null) {
      return;
    }

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TerminusSelectorPage(
                  shortcutBusStop!,
                  previousData: shortCutBusLines,
                ))).then((value) {
      if (value == null || !mounted) {
        return;
      }
      shortCutBusLines = value;
      setState(() {});
    });
  }

  String? checkError(){
    if (shortcutName == "") {
      return "! Donner un nom a votre raccourcie";
    } else if (shortcutBusStop == null) {
      return "! Aucun arret de bus n'a été selectioner";
    } else if (shortCutBusLines.isEmpty){
      return "! Acune Line n'a été sélectioner";
    }

  }

  void valid() {
    String? error = checkError();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline),
            Text(error)
          ],
        ),
      ));
      return;
    }

    Navigator.pop(context, ViewShortcut(shortcutName, shortcutIsFavorite, shortcutBusStop!, shortCutBusLines));
  }

  void cancel() {
    Navigator.pop(context);
  }
}
