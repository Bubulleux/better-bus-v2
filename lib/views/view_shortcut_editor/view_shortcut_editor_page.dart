import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/model/clean/view_shortcut.dart';
import 'package:better_bus_v2/views/common/background.dart';
import 'package:better_bus_v2/views/common/custom_input_widget.dart';
import 'package:better_bus_v2/views/common/custom_text_field.dart';
import 'package:better_bus_v2/views/common/fake_text_field.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:better_bus_v2/views/stops_search_page/stops_search_page.dart';
import 'package:better_bus_v2/views/terminus_selector/terminus_selector_page.dart';
import 'package:flutter/material.dart';

import '../../app_constant/app_string.dart';
import '../../model/clean/bus_line.dart';

class ViewShortcutEditorPage extends StatefulWidget {
  const ViewShortcutEditorPage({super.key});
  static const String routeName = "/shortcutEditor";


  @override
  State<ViewShortcutEditorPage> createState() => _ViewShortcutEditorPageState();
}

class _ViewShortcutEditorPageState extends State<ViewShortcutEditorPage> {

  late ViewShortcut? shortcut;

  String shortcutName = "";
  bool shortcutIsFavorite = false;
  BusStop? shortcutBusStop;
  List<BusLine> shortCutBusLines = [];

  late TextEditingController textFieldNameController;

  @override
  void initState() {
    super.initState();
    textFieldNameController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    shortcut = ModalRoute.of(context)!.settings.arguments as ViewShortcut?;

    if (shortcut != null && shortcutName == "") {
      shortcutName = shortcut!.shortcutName;
      shortcutIsFavorite = shortcut!.isFavorite;
      shortcutBusStop = shortcut!.stop;
      shortCutBusLines = shortcut!.lines;
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
          color: Theme.of(context).colorScheme.background,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  CustomTextField(
                    controller: textFieldNameController,
                    label: AppString.shortcutNameLabel,
                  ),
                  CustomInputWidget(
                    onTap: () => setState(() {
                      shortcutIsFavorite = !shortcutIsFavorite;
                    }),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            AppString.addToFavorite,
                            style: Theme.of(context).textTheme.headlineSmall,
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
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: FakeTextField(
                      onPress: changeBusStop,
                      value: shortcutBusStop?.name,
                      prefixIcon: const Icon(Icons.directions_bus_outlined),
                      icon: Icons.change_circle_outlined,
                      hint: AppString.selectBusStop,
                    ),
                  ),
                  CustomInputWidget(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppString.directionLabel,
                          style: Theme.of(context).textTheme.headlineSmall,
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
    Navigator.of(context).pushNamed(SearchPage.routeName, arguments: const SearchPageArgument(saveInHistoric: false))
      .then((value) {
      if (value == null || !mounted || value == shortcutBusStop) {
        return;
      }
      setState(() {
        shortcutBusStop = value as BusStop;
        shortCutBusLines = [];
      });
    });
  }

  void selectTerminus() {
    FocusScope.of(context).unfocus();
    if (shortcutBusStop == null) {
      return;
    }
    Navigator.of(context).pushNamed(TerminusSelectorPage.routeName,
        arguments: TerminusSelectorPageArgument(shortcutBusStop!, shortCutBusLines))
        .then((value) {
      if (value == null || !mounted) {
        return;
      }
      shortCutBusLines = value as List<BusLine>;
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
