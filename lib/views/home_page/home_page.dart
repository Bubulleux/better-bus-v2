import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/data_provider/gps_data_provider.dart';
import 'package:better_bus_v2/data_provider/local_data_handler.dart';
import 'package:better_bus_v2/model/clean/view_shortcut.dart';
import 'package:better_bus_v2/views/common/background.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:better_bus_v2/views/home_page/navigation_bar.dart';
import 'package:better_bus_v2/views/home_page/shortcut_section.dart';
import 'package:better_bus_v2/views/route_page/route_page.dart';
import 'package:better_bus_v2/views/stop_info/stop_info_page.dart';
import 'package:better_bus_v2/views/traffic_info_page/traffic_info_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home_widget/home_widget.dart';

import '../stops_search_page/stops_search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ShortcutWidgetRootState> shortcutSection = GlobalKey();
  late FlutterLocalNotificationsPlugin flip;

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

  void goToTrafficInfo() {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => const TrafficInfoPage(),
    ));
  }

  void goToRoutePage() {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => const RoutePage(),
    ));
  }

  @override
  void initState() {
    super.initState();
    GpsDataProvider.askForGPS();
    HomeWidget.widgetClicked.listen(launchWithWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    HomeWidget.initiallyLaunchedFromHomeWidget().then(launchWithWidget);
    HomeWidget.widgetClicked.listen(launchWithWidget);
  }


  void launchWithWidget(Uri? uri) {
    if (uri != null && uri.scheme == "app") {
      if (uri.host == "openshortcut") {
        launchShortcutByWidget(uri.pathSegments[0]);
      }
    }
  }

  void checkIfAppIsNotificationLaunched() async{
    NotificationAppLaunchDetails? launchNotificationDetails =
      await FlutterLocalNotificationsPlugin().getNotificationAppLaunchDetails();
    if (launchNotificationDetails == null || launchNotificationDetails.notificationResponse == null){
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => TrafficInfoPage(focus: launchNotificationDetails.notificationResponse!.id)));
  }

  void launchShortcutByWidget(String shortcutName) async {
    List<ViewShortcut> shortcuts = await LocalDataHandler.loadShortcut();
    int shortcutIndex = shortcuts.indexWhere((element) => element.shortcutName == shortcutName);
    if (shortcutIndex == -1) {
      return;
    }
    ViewShortcut shortcut = shortcuts[shortcutIndex];
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StopInfoPage(shortcut.stop, lines: shortcut.lines,),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Background(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: CustomDecorations
                      .of(context)
                      .boxBackground,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppString.shortcut,
                          style: Theme
                              .of(context)
                              .textTheme
                              .headlineSmall,
                        ),
                      ),
                      IconButton(onPressed: newShortcut, icon: const Icon(Icons.add)),
                    ],
                  ),
                ),

                Expanded(
                  child: ShortcutWidgetRoot(key: shortcutSection),
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        child: [
          CustomNavigationItem(
            label: AppString.searchLabel,
            icon: Icons.search,
            onPress: searchBusStop,
          ),
          CustomNavigationItem(
            label: AppString.routeLabel,
            icon: Icons.route,
            onPress: goToRoutePage,
          ),
          CustomNavigationItem(
            label: AppString.trafficInfoLabel,
            icon: Icons.bus_alert,
            onPress: goToTrafficInfo,
          )
        ],
      ),
    );
  }
}
