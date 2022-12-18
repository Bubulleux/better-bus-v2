import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/data_provider/gps_data_provider.dart';
import 'package:better_bus_v2/data_provider/local_data_handler.dart';
import 'package:better_bus_v2/data_provider/version_data_provider.dart';
import 'package:better_bus_v2/info_traffic_notification.dart';
import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/model/clean/view_shortcut.dart';
import 'package:better_bus_v2/views/common/background.dart';
import 'package:better_bus_v2/views/common/content_container.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:better_bus_v2/views/home_page/navigation_bar.dart';
import 'package:better_bus_v2/views/home_page/shortcut_section.dart';
import 'package:better_bus_v2/views/log_view.dart';
import 'package:better_bus_v2/views/preferences_view.dart';
import 'package:better_bus_v2/views/route_page/route_page.dart';
import 'package:better_bus_v2/views/stop_info/stop_info_page.dart';
import 'package:better_bus_v2/views/traffic_info_page/traffic_info_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home_widget/home_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:workmanager/workmanager.dart';

import '../stops_search_page/stops_search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  static const String routeName = "/";

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ShortcutWidgetRootState> shortcutSection = GlobalKey();
  late FlutterLocalNotificationsPlugin flip;

  void searchBusStop() {
    Navigator.of(context).pushNamed(SearchPage.routeName).then((value) {
      if (value == null) {
        return;
      }
      Navigator.of(context).pushNamed(StopInfoPage.routeName, arguments: StopInfoPageArgument(value as BusStop, null));
    });
  }

  void newShortcut() {
    shortcutSection.currentState!.editShortcut(null);
  }

  void goToTrafficInfo() {
    Navigator.of(context).pushNamed(TrafficInfoPage.routeName);
  }

  void goToRoutePage() {
    Navigator.of(context).pushNamed(RoutePage.routeName);
  }

  @override
  void initState() {
    super.initState();
    GpsDataProvider.askForGPS();
    HomeWidget.widgetClicked.listen(launchWithWidget);
    Workmanager().registerPeriodicTask("check-traffic-info", "checkTrafficInfo",
        frequency: const Duration(minutes: 15),
        constraints: Constraints(networkType: NetworkType.connected));
    initFlutterNotificationPlugin();
    checkIfAppIsNotificationLaunched();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    HomeWidget.initiallyLaunchedFromHomeWidget().then(launchWithWidget);
    HomeWidget.widgetClicked.listen(launchWithWidget);
  }

  Future checkIfAppIsNotificationLaunched() async{
    NotificationAppLaunchDetails? launchNotificationDetails =
    await FlutterLocalNotificationsPlugin().getNotificationAppLaunchDetails();
    if (launchNotificationDetails == null) {
      return;
    }
    receiveNotification(launchNotificationDetails.notificationResponse);
  }

  void receiveNotification(NotificationResponse? response) {
    if (response == null){
      return;
    }
    Navigator.of(context).popUntil((route) => route.settings.name != TrafficInfoPage.routeName);
    Navigator.of(context).pushNamed(TrafficInfoPage.routeName, arguments: response.id);
  }

  Future initFlutterNotificationPlugin() async {
    FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();
    var android = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var settings = InitializationSettings(android: android);
    await flip.initialize(settings, onDidReceiveNotificationResponse: receiveNotification);
  }

  void launchWithWidget(Uri? uri) {
    if (uri != null && uri.scheme == "app") {
      if (uri.host == "openshortcut") {
        launchShortcutByWidget(uri.pathSegments[0], context);
      }
    }
  }

  void gotoLog() {
    Navigator.of(context).pushNamed(LogView.routeName);
  }
  void gotoPrefs() {
    Navigator.of(context).pushNamed(PreferencesView.routeName);
  }

  void launchShortcutByWidget(String shortcutName, BuildContext context) async {
    List<ViewShortcut> shortcuts = await LocalDataHandler.loadShortcut();
    int shortcutIndex = shortcuts.indexWhere((element) => element.shortcutName == shortcutName);
    if (shortcutIndex == -1) {
      return;
    }
    ViewShortcut shortcut = shortcuts[shortcutIndex];

    Navigator.of(context).popUntil((route) => (route.settings.name != StopInfoPage.routeName ||
        (route.settings.arguments as StopInfoPageArgument?)?.stop != shortcut.stop));
    Navigator.of(context).pushNamed(StopInfoPage.routeName,
        arguments: StopInfoPageArgument(shortcut.stop, shortcut.lines));
  }

  void launchTestNotification() {
    checkInfoTraffic();
  }

  void testNotificationActivation() async{
    await LocalDataHandler.setLastNotificationPush(DateTime(2022, 11, 10));
    checkInfoTraffic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Background(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      FutureBuilder(
                        future: VersionDataProvider.checkIfNewVersion(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            throw snapshot.error!;
                          }
                          if (snapshot.hasData && snapshot.data != null) {
                            String url = snapshot.data as String;
                            return CustomContentContainer(
                              onTap: () => launchUrlString(url, mode: LaunchMode.externalApplication),
                              margin: const EdgeInsets.only(bottom: 5),
                              color: Theme.of(context).primaryColor,
                              child: Row(
                                children: const [
                                  Text(AppString.newVersion, style: TextStyle(fontWeight: FontWeight.bold),),
                                  Spacer(),
                                  Icon(Icons.download),
                                ],
                              ),
                            );
                          }
                          return Container();
                        },
                      ),
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
                            IconButton(onPressed: testNotificationActivation, icon: const Icon(Icons.notifications_active_rounded)),
                            IconButton(onPressed: launchTestNotification, icon: const Icon(Icons.notification_add)),
                            IconButton(onPressed: gotoLog, icon: const Icon(Icons.newspaper)),
                            IconButton(onPressed: gotoPrefs, icon: const Icon(Icons.settings)),

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
              CustomNavigationBar(
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
            ],
          ),
        ),
      ),
    );
  }
}
