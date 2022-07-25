import 'dart:ui';

import 'package:better_bus_v2/data_provider/gps_data_provider.dart';
import 'package:better_bus_v2/views/common/background.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:better_bus_v2/views/home_page/bottom_bar.dart';
import 'package:better_bus_v2/views/home_page/shortcut_section.dart';
import 'package:better_bus_v2/views/stop_info/stop_info_page.dart';
import 'package:flutter/material.dart';

import '../common/fake_textfiel.dart';
import '../search_page/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ShortcutWidgetRootState> shortcutSection = GlobalKey();

  void searchBusStop() {
    Navigator.push(context,
            MaterialPageRoute(builder: (context) => const SearchPage()))
        .then((value) {
      if (value == null) {
        return;
      }
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StopInfoPage(value),
          ));
    });
  }
  
  void newShortcut() {
    shortcutSection.currentState!.editShortcut(null);
  }

  @override
  void initState() {
    super.initState();
    GpsDataProvider.askForGPS();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Background(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  decoration: CustomDecorations.of(context).boxBackground,
                  padding: EdgeInsets.all(10),
                  child: FakeTextField(
                    onPress: searchBusStop,
                    icon: Icons.search,
                    hint: "! Rechercher un arret",
                  ),
                ),
                Expanded(
                    child: ShortcutWidgetRoot(key: shortcutSection),
                ),
                CustomBottomAppBar()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
