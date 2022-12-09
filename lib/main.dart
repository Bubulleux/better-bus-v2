import 'package:better_bus_v2/info_traffic_notification.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:better_bus_v2/views/interest_line_page/interest_lines_page.dart';
import 'package:better_bus_v2/views/log_view.dart';
import 'package:better_bus_v2/views/preferences_view.dart';
import 'package:better_bus_v2/views/route_detail_page/route_detail_page.dart';
import 'package:better_bus_v2/views/route_page/route_page.dart';
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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    return checkInfoTraffic();
  });
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.
    resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();

  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  runApp(MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
        primaryColorLight: const Color(0xffe6eee5),
        backgroundColor: const Color(0xdde4e4e4),
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
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: CustomDecorations.borderRadius,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: CustomDecorations.borderRadius,
            borderSide: BorderSide(
              color: Colors.lightGreen.shade500,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: CustomDecorations.borderRadius,
            borderSide: BorderSide(color: Colors.lightGreen.shade400, width: 2),
          ),
          labelStyle: const TextStyle(
            fontSize: 25,
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
      },
      // locale: const Locale('fr', ""),
      // home: const HomePage(),
    );
  }
}
