import 'package:better_bus_v2/info_traffic_notification.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:flutter/material.dart';
import 'package:better_bus_v2/views/home_page/home_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:workmanager/workmanager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.
    resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();

  Workmanager().initialize(callbackDispatcher);
  Workmanager().registerPeriodicTask("check-traffic-info", "check-traffic-info", frequency: const Duration(minutes: 15));

  runApp(const MyApp());
}

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) {
    return checkInfoTraffic();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
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
      // locale: const Locale('fr', ""),
      home: const HomePage(),
    );
  }
}
