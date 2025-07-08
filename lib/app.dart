import 'package:flutter/material.dart';

import 'model/app_config.dart';


import 'dart:async';
import 'dart:io';

import 'package:better_bus_v2/data_provider/gps_data_provider.dart';
import 'package:better_bus_v2/info_traffic_notification.dart';
import 'package:better_bus_v2/views/common/messages.dart';
import 'package:better_bus_v2/views/credit_page.dart';
import 'package:better_bus_v2/views/interest_line_page/interest_lines_page.dart';
import 'package:better_bus_v2/views/log_view.dart';
import 'package:better_bus_v2/views/map_pages/map_page.dart';
import 'package:better_bus_v2/views/preferences_view.dart';
import 'package:better_bus_v2/views/route_detail_page/route_detail_page.dart';
import 'package:better_bus_v2/views/route_page/route_page.dart';
import 'package:better_bus_v2/views/setting_page/setting_page.dart';
import 'package:better_bus_v2/views/stop_info/stop_info_page.dart';
import 'package:better_bus_v2/views/stops_search_page/place_searcher_page.dart';
import 'package:better_bus_v2/views/stops_search_page/stops_search_page.dart';
import 'package:better_bus_v2/views/terminus_selector/terminus_selector_page.dart';
import 'package:better_bus_v2/views/traffic_info_page/traffic_info_page.dart';
import 'package:better_bus_v2/views/view_shortcut_editor/view_shortcut_editor_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
// import 'package:workmanager/workmanager.dart';

import 'app_constant/app_string.dart';
import 'model/app_config.dart';
import 'views/root/root.dart';


@pragma('vm:entry-point')
void callbackDispatcher() {
  // Workmanager().executeTask((taskName, inputData) async {
  //   try {
  //     await checkInfoTraffic();
  //   } catch (e) {
  //     return Future.value(false);
  //   }
  //   return Future.value(true);
  // });
}

Future initFlip() async {
  var flip = FlutterLocalNotificationsPlugin();

  AndroidFlutterLocalNotificationsPlugin? androidImp =
  flip.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  androidImp?.requestNotificationsPermission();

  var android = const AndroidInitializationSettings('@mipmap/ic_launcher');
  var settings = InitializationSettings(android: android);
  await flip.initialize(settings);
}

final StreamController<String?> selectNotificationStream =
StreamController<String?>.broadcast();

Future runBetterBus(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // Workmanager().initialize(callbackDispatcher);
  // Workmanager().registerPeriodicTask("check-traffic-info", "checkTrafficInfo",
  //     frequency: const Duration(minutes: 15));
  await GpsDataProvider.initGps(config);


  runApp(MultiProvider(
    providers: [
      Provider(create: (_) => config.createProvider())
    ],
    child: BetterBusApp(config: config),
  ));
}

class BetterBusApp extends StatefulWidget {
  const BetterBusApp({required this.config, super.key});

  final AppConfig config;

  @override
  State<BetterBusApp> createState() => _BetterBusAppState();
}

class _BetterBusAppState extends State<BetterBusApp>
    with WidgetsBindingObserver {

  @override
  Widget build(BuildContext context) {
    final pc = widget.config.primaryColor;
    return MaterialApp(
      title: AppString.appName,
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: pc,
        primaryColorLight: const Color(0xffe6eee5),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: pc,
          backgroundColor: const Color(0xdde4e4e4),
        ),
        textTheme: const TextTheme(
          // bodyMedium: TextStyle(
          //   fontSize: 16,
          // ),
          // bodySmall: TextStyle(fontSize: 13),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            // textStyle: TextStyle(
            //   fontSize: 13
            // ),
            // iconSize: 20,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
      ),
      // localizationsDelegates: GlobalMaterialLocalizations.delegates,
      // supportedLocales: const [
      //   Locale('fr', ""),
      //   Locale('en', ""),
      // ],
      initialRoute: MapPage.routeName,
      routes: {
        // TODO: Eurk...
        // HomePage.routeName: (context) => const HomePage(),
        MapPage.routeName: (context) => const AppRoot(),
        SettingPage.routeName: (context) => const SettingPage(),
        MessageView.routeName: (context) => const MessageView(),
        SearchPage.routeName: (context) => const SearchPage(),
        PlaceSearcherPage.routeName: (context) => const PlaceSearcherPage(),
        StopInfoPage.routeName: (context) => const StopInfoPage(),
        ViewShortcutEditorPage.routeName: (context) =>
        const ViewShortcutEditorPage(),
        TerminusSelectorPage.routeName: (context) =>
        const TerminusSelectorPage(),
        TrafficInfoPage.routeName: (context) => const TrafficInfoPage(),
        InterestLinePage.routeName: (context) => const InterestLinePage(),
        RoutePage.routeName: (context) => const RoutePage(),
        RouteDetailPage.routeName: (context) => const RouteDetailPage(),
        LogView.routeName: (context) => const LogView(),
        PreferencesView.routeName: (context) => const PreferencesView(),
        AppInfo.routeName: (context) => const AppInfo(),
      },
    );
  }
}
