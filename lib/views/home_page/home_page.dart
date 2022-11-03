import 'package:better_bus_v2/app_constante/app_string.dart';
import 'package:better_bus_v2/data_provider/gps_data_provider.dart';
import 'package:better_bus_v2/data_provider/local_data_handler.dart';
import 'package:better_bus_v2/info_traffic_notification.dart';
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
import 'package:workmanager/workmanager.dart';

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
    initNotification();
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
    print("Check Notification");
    NotificationAppLaunchDetails? launchNotificationDetails =
      await FlutterLocalNotificationsPlugin().getNotificationAppLaunchDetails();
    if (launchNotificationDetails == null || launchNotificationDetails.notificationResponse == null){
      return;
    }
    print(launchNotificationDetails);
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

  void initNotification() async {
    flip = FlutterLocalNotificationsPlugin();

    // app_icon needs to be a added as a drawable
    // resource to the Android head project.
    var android = AndroidInitializationSettings('@mipmap/ic_launcher');

    // initialise settings for both Android and iOS device.
    var settings = InitializationSettings(android: android);
    await flip.initialize(settings);
  }

  void pushNotification() async {

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        DateTime.now().millisecond.toString(),
        DateTime.now().millisecond.toString(),
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.max
    );

    // initialise channel platform for both Android and iOS device.
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
    );
    await flip.show(DateTime.now().millisecond, 'GeeksforGeeks',
        'Your are one step away to connect with GeeksforGeeks ${DateTime.now().millisecond.toString()}',
        platformChannelSpecifics);
  }

  void pushNotificationWithDelay() {
    print("WorkManager add task");
    Workmanager().registerOneOffTask("test-somethin", "i try something", initialDelay: const Duration(seconds: 10));
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
                      IconButton(onPressed: pushNotificationWithDelay, icon: Icon(Icons.notification_add))
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
