import 'package:better_bus_v2/data_provider/local_data_handler.dart';
import 'package:better_bus_v2/info_traffic_notification.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:flutter/material.dart';
import 'package:better_bus_v2/views/home_page/home_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    await LocalDataHandler.addLog("Work Manager Manage");
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
  int? notificationID = await checkIfAppIsNotificationLaunched();
  runApp(MyApp(launchNotificationId:  notificationID,));
}

Future<int?> checkIfAppIsNotificationLaunched() async{
  NotificationAppLaunchDetails? launchNotificationDetails =
  await FlutterLocalNotificationsPlugin().getNotificationAppLaunchDetails();
  if (launchNotificationDetails == null || launchNotificationDetails.notificationResponse == null){
    return null;
  }
  return launchNotificationDetails.notificationResponse!.id;
}


class MyApp extends StatelessWidget {
  const MyApp({this.launchNotificationId, Key? key}) : super(key: key);

  final int? launchNotificationId;

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
      home: HomePage(launchNotificationId: launchNotificationId),
    );
  }
}
