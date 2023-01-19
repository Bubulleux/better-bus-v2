import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/data_provider/connectivity_checker.dart';
import 'package:better_bus_v2/data_provider/local_data_handler.dart';
import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/model/clean/info_traffic.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

final DateFormat dateFormat = DateFormat("EEEE d MMMM", "fr");

Future<bool> checkInfoTraffic() async {
  // await LocalDataHandler.addLog("Start function");

  FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();
  // await LocalDataHandler.addLog("Sep 1");

  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      "info-traffic",
      "info-traffic",
      importance: Importance.max,
      priority: Priority.max,
  );
  // await LocalDataHandler.addLog("Sep 2");
  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  var android = const AndroidInitializationSettings('@mipmap/ic_launcher');
  var settings = InitializationSettings(android: android);
  await flip.initialize(settings);

  // await LocalDataHandler.addLog("Sep 3");

  if (!await ConnectivityChecker.isConnected()) {
    // await LocalDataHandler.addLog("No internet");
    return false;
  }
  // await LocalDataHandler.addLog("Sep 4");
  bool notificationEnable = await LocalDataHandler.getNotificationEnable();
  // await LocalDataHandler.addLog("Sep 5");
  if (!notificationEnable) {
    // await LocalDataHandler.addLog("notification disable");
    return true;
  }
  // await LocalDataHandler.addLog("Sep 6");
  List<InfoTraffic> infoTraffics = await VitalisDataProvider.getTrafficInfo();
  Set<String> interestedBusLines = await LocalDataHandler.loadInterestedLine();
  Set<int>? alreadyPushNotifications = await LocalDataHandler.loadAlreadyPushNotification();
  DateTime lastNotificationPush = await LocalDataHandler.getLastNotificationPush();
  // await LocalDataHandler.addLog("Sep 7");


  alreadyPushNotifications ??= {};
  // await LocalDataHandler.addLog("Sep 8");
  // await LocalDataHandler.addLog("Infos: \n${alreadyPushNotifications.toString()}\n${lastNotificationPush.toString()}\n${infoTraffics.toSet().toList().length.toString()}");
  for (InfoTraffic infoTraffic in infoTraffics) {
    // await LocalDataHandler.addLog("Start: ${infoTraffic.title}");
    bool becameActive = infoTraffic.startTime.isBefore(DateTime.now()) && infoTraffic.startTime.isAfter(lastNotificationPush);
    bool hasBeenUpdated = infoTraffic.updateDate.isBefore(DateTime.now()) && infoTraffic.updateDate.isAfter(lastNotificationPush);
    // await LocalDataHandler.addLog("Sub Sep 1");

    if ((infoTraffic.linesId != null && interestedBusLines.intersection(infoTraffic.linesId?.toSet() ?? {}).isEmpty) ||
        !infoTraffic.isDisplay || (alreadyPushNotifications.contains(infoTraffic.id) && !becameActive && ! hasBeenUpdated)) {
      // await LocalDataHandler.addLog("Sub Sep Exit");
      continue;
    }
    // await LocalDataHandler.addLog("Sub Sep 2");
    alreadyPushNotifications.add(infoTraffic.id);
    await flip.show(infoTraffic.id,
        AppString.appName,
        infoTraffic.title,
        platformChannelSpecifics);
    // await LocalDataHandler.addLog("Sucess");
  }
  // await LocalDataHandler.addLog("Sep 9");

  alreadyPushNotifications = alreadyPushNotifications.intersection(infoTraffics.where((element) => element.isDisplay).map((e) => e.id).toSet());
  await LocalDataHandler.setLastNotificationPush(DateTime.now());
  await LocalDataHandler.saveAlreadyPushNotification(alreadyPushNotifications);
  // await LocalDataHandler.addLog("Finish Notification routin");
  return true;
}