import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/model/clean/view_shortcut.dart';
import 'package:better_bus_v2/views/common/background.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:better_bus_v2/views/common/fake_textfiel.dart';
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
  String shortcutName = "";
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
      resizeToAvoidBottomInset: false,
      body: Background(
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.all(15),
            color: Theme.of(context).backgroundColor,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: textFieldNameController,
                    style:Theme.of(context).textTheme.headline5,
                    decoration:
                        InputDecoration(labelText: "! Nom du Racourcie"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: CustomDecorations.of(context).boxOutlined,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Text(
                          "Mettre en Favorie",
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        Spacer(),
                        Checkbox(
                          value: shortcutIsFavorite,
                          onChanged: (value) {
                            setState(() => shortcutIsFavorite = value!);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FakeTextField(
                    onPress: changeBusStop,
                    value: shortcutBusStop?.name,
                    prefixIcon: Icons.directions_bus_outlined,
                    icon: Icons.change_circle_outlined,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: CustomDecorations.of(context).boxOutlined,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "! Direction: ",
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        if (shortCutBusLines.isNotEmpty)
                          Wrap(
                            runAlignment: WrapAlignment.start,
                            spacing: 5,
                            runSpacing: 5,
                            children: shortCutBusLines
                                .map((e) => LineWidget(e, 40))
                                .toList(),
                          )
                        else
                          const Center(child: Text("! Aucun Direction n'a ??t?? selectioner"))
                        ,
                        const VerticalDivider(),
                        Center(
                          child: ElevatedButton(
                            onPressed: selectTerminus,
                            child: Text("!Changer les direction"),
                          ),
                        )
                      ],
                    ),
                  ),
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
                      SizedBox(
                        width: 20,
                      ),
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

  String? checkError() {
    if (shortcutName == "") {
      return "! Donner un nom a votre raccourcie";
    } else if (shortcutBusStop == null) {
      return "! Aucun arret de bus n'a ??t?? selectioner";
    } else if (shortCutBusLines.isEmpty) {
      return "! Acune Line n'a ??t?? s??lectioner";
    }
  }

  void valid() {
    String? error = checkError();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        ),
      );
      return;
    }

    Navigator.pop(
        context,
        ViewShortcut(shortcutName, shortcutIsFavorite, shortcutBusStop!,
            shortCutBusLines));
  }

  void cancel() {
    Navigator.pop(context);
  }
}
