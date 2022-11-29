import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/model/clean/view_shortcut.dart';
import 'package:better_bus_v2/views/common/background.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:better_bus_v2/views/common/fake_text_field.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:better_bus_v2/views/stops_search_page/stops_search_page.dart';
import 'package:better_bus_v2/views/terminus_selector/terminus_selector_page.dart';
import 'package:flutter/material.dart';

import '../../app_constant/app_string.dart';
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
        child: Container(
          color: Theme.of(context).backgroundColor,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: textFieldNameController,
                      style: Theme.of(context).textTheme.headline5,
                      decoration: const InputDecoration(
                        labelText: AppString.shortcutNameLabel,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => setState(() {
                          shortcutIsFavorite = !shortcutIsFavorite;
                        }),
                        borderRadius: CustomDecorations.borderRadius,
                        child: Container(
                          decoration: CustomDecorations.of(context).boxOutlined,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          child: Row(
                            children: [
                              Text(
                                AppString.addToFavorite,
                                style: Theme.of(context).textTheme.headline5,
                              ),
                              const Spacer(),
                              Icon(
                                shortcutIsFavorite
                                    ? Icons.star
                                    : Icons.star_outline,
                                color: Theme.of(context).primaryColor,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FakeTextField(
                      onPress: changeBusStop,
                      value: shortcutBusStop?.name,
                      prefixIcon: const Icon(Icons.directions_bus_outlined),
                      icon: Icons.change_circle_outlined,
                      hint: AppString.selectBusStop,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: CustomDecorations.of(context).boxOutlined,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppString.directionLabel,
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
                            const Center(
                                child: Text(AppString.emptyDirectionSelection)),
                          const VerticalDivider(),
                          Center(
                            child: ElevatedButton(
                              onPressed: selectTerminus,
                              child: const Text(AppString.changeDirection),
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
                          child: const Text(AppString.cancelLabel),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        ElevatedButton(
                          onPressed: valid,
                          child: const Text(AppString.validateLabel),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void changeBusStop() {
    FocusScope.of(context).unfocus();
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
    FocusScope.of(context).unfocus();
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
      return AppString.setShortcutName;
    } else if (shortcutBusStop == null) {
      return AppString.emptyStopSelection;
    } else if (shortCutBusLines.isEmpty) {
      return AppString.emptyLineSelection;
    }
    return null;
  }

  void valid() {
    String? error = checkError();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
