import 'package:better_bus_v2/info_traffic_notification.dart';
import 'package:better_bus_v2/views/common/messages.dart';
import 'package:better_bus_v2/views/credit_page.dart';
import 'package:better_bus_v2/views/interest_line_page/interest_lines_page.dart';
import 'package:better_bus_v2/views/log_view.dart';
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
import 'package:better_bus_v2/views/home_page/home_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:workmanager/workmanager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_constant/app_string.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  // Workmanager().executeTask((taskName, inputData) async {
  //   try {
  //     await checkInfoTraffic();
  //   } catch(e) {
  //     return Future.value(false);
  //   }
  //   return Future.value(true);
  // });
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  AndroidFlutterLocalNotificationsPlugin? androidImp =
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  androidImp?.requestNotificationsPermission();


  // Workmanager().initialize(callbackDispatcher);
  // Workmanager().registerPeriodicTask("check-traffic-info", "checkTrafficInfo",
  //     frequency: const Duration(minutes: 15));
  checkInfoTraffic();
  runApp(const BetterBusApp());
}


class BetterBusApp extends StatefulWidget {
  const BetterBusApp({Key? key}) : super(key: key);


  @override
  State<BetterBusApp> createState() => _BetterBusAppState();
}

class _BetterBusAppState extends State<BetterBusApp> with WidgetsBindingObserver{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppString.appName,
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.lightGreen,
        primaryColorLight: const Color(0xffe6eee5),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.lightGreen,
          backgroundColor: const Color(0xdde4e4e4),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontSize: 16,
          ),
          bodySmall: TextStyle(fontSize: 13),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
      ),

      localizationsDelegates: GlobalMaterialLocalizations.delegates,

      supportedLocales: const [
        Locale('fr', ""),
        Locale('en', ""),
      ],
      initialRoute: "/",
      routes: {
        HomePage.routeName: (context) => const HomePage(),

        SettingPage.routeName: (context) => const SettingPage(),
        MessageView.routeName: (context) => const MessageView(),

        SearchPage.routeName: (context) => const SearchPage(),
        PlaceSearcherPage.routeName: (context) => const PlaceSearcherPage(),

        StopInfoPage.routeName: (context) => const StopInfoPage(),

        ViewShortcutEditorPage.routeName: (context) => const ViewShortcutEditorPage(),
        TerminusSelectorPage.routeName: (context) => const TerminusSelectorPage(),

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
