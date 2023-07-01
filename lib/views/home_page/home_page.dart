import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/data_provider/gps_data_provider.dart';
import 'package:better_bus_v2/data_provider/local_data_handler.dart';
import 'package:better_bus_v2/data_provider/version_data_provider.dart';
import 'package:better_bus_v2/info_traffic_notification.dart';
import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/model/clean/view_shortcut.dart';
import 'package:better_bus_v2/views/common/background.dart';
import 'package:better_bus_v2/views/common/closestStopDialog.dart';
import 'package:better_bus_v2/views/common/content_container.dart';
import 'package:better_bus_v2/views/common/context_menu.dart';
import 'package:better_bus_v2/views/common/title_bar.dart';
import 'package:better_bus_v2/views/home_page/navigation_bar.dart';
import 'package:better_bus_v2/views/home_page/shortcut_section.dart';
import 'package:better_bus_v2/views/log_view.dart';
import 'package:better_bus_v2/views/preferences_view.dart';
import 'package:better_bus_v2/views/route_page/route_page.dart';
import 'package:better_bus_v2/views/setting_page/setting_page.dart';
import 'package:better_bus_v2/views/stop_info/stop_info_page.dart';
import 'package:better_bus_v2/views/traffic_info_page/traffic_info_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home_widget/home_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

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

  Future findClosestStop() async{
    ClosestStopDialog.show(context);
  }

  @override
  void initState() {
    super.initState();
    GpsDataProvider.askForGPS();
    HomeWidget.widgetClicked.listen(launchWithWidget);
    initFlutterNotificationPlugin();
    checkIfAppIsNotificationLaunched();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    HomeWidget.initiallyLaunchedFromHomeWidget().then(launchWithWidget);
    HomeWidget.widgetClicked.listen(launchWithWidget);
  }

  Future checkIfAppIsNotificationLaunched() async {
    NotificationAppLaunchDetails? launchNotificationDetails =
        await FlutterLocalNotificationsPlugin().getNotificationAppLaunchDetails();
    if (launchNotificationDetails == null) {
      return;
    }
    receiveNotification(launchNotificationDetails.notificationResponse);
  }

  void receiveNotification(NotificationResponse? response) {
    if (response == null) {
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
    Navigator.of(context)
        .pushNamed(StopInfoPage.routeName, arguments: StopInfoPageArgument(shortcut.stop, shortcut.lines));
  }

  void testNotificationActivation() async {
    await LocalDataHandler.setLastNotificationPush(DateTime(2022, 11, 10));
    checkInfoTraffic();
  }

  void showMore() {
    CustomContextMenu.show(context,[
        ContextMenuAction(AppString.privicyPolicy, Icons.privacy_tip, action: showPrivacyPolicy),
        ContextMenuAction(AppString.sourceCode, Icons.code, action: showSourceCode),
    ]);
  }

  void goToSetting() {
    Navigator.of(context).pushNamed(SettingPage.routeName);
  }

  void showPrivacyPolicy() {
    Uri uri = Uri.parse("https://github.com/Bubulleux/better-bus-v2/blob/master/Privacy%20policy.md");
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void showSourceCode() {
    Uri uri = Uri.parse("https://github.com/Bubulleux/better-bus-v2");
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Background(
          child: Column(
            children: [
              CustomTitleBar(
                title: "${AppString.appName} - ${AppString.cityName}",
                leftChild: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: const Image(
                          width: 30,
                          image: AssetImage("assets/images/icon.jpg")
                          ),
                      ),
                    ),
                rightChild: IconButton(onPressed: goToSetting, icon: const Icon(Icons.settings)),
              ),
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
                      margin: const EdgeInsets.only(top: 5, right: 8, left: 8),
                      color: Theme.of(context).primaryColor,
                      child: const Row(
                        children: [
                          Text(
                            AppString.newVersion,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Spacer(),
                          Icon(Icons.download),
                        ],
                      ),
                    );
                  }
                  return Container();
                },
              ),
              CustomContentContainer(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppString.shortcut,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(onPressed: newShortcut, icon: const Icon(Icons.add)),
                    // IconButton(onPressed: testNotificationActivation, icon: const Icon(Icons.notifications_active_rounded)),
                    // IconButton(onPressed: () => LocalDataHandler.saveAlreadyPushNotification({}), icon: const Icon(Icons.notification_important_rounded)),
                    // const IconButton(onPressed: CacheDataProvider.emptyCacheData, icon: Icon(Icons.restore_from_trash)),
                    // IconButton(onPressed: gotoLog, icon: const Icon(Icons.newspaper)),
                    // IconButton(onPressed: gotoPrefs, icon: const Icon(Icons.settings)),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
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
                    label: AppString.closestStopLabel,
                    icon: Icons.location_searching,
                    onPress: findClosestStop,
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
