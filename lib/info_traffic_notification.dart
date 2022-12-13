import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/data_provider/connectivity_checker.dart';
import 'package:better_bus_v2/data_provider/local_data_handler.dart';
import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/model/clean/info_traffic.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:format/format.dart';

final DateFormat dateFormat = DateFormat("EEEE d MMMM", "fr");

Future<bool> checkInfoTraffic() async {

  FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();

  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      "info-traffic",
      "info-traffic",
      importance: Importance.max,
      priority: Priority.max,
  );
  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  if (!await ConnectivityChecker.isConnected()) {
    return false;
  }
  bool notificationEnable = await LocalDataHandler.getNotificationEnable();
  if (!notificationEnable) {
    return true;
  }
  List<InfoTraffic> infoTraffics = await VitalisDataProvider.getTrafficInfo();
  Set<String> interestedBusLines = await LocalDataHandler.loadInterestedLine();
  Set<int>? alreadyPushNotifications = await LocalDataHandler.loadAlreadyPushNotification();
  DateTime lastNotificationPush = await LocalDataHandler.getLastNotificationPush();


  alreadyPushNotifications ??= {};
  for (InfoTraffic infoTraffic in infoTraffics) {
    bool becameActive = infoTraffic.startTime.isBefore(DateTime.now()) && infoTraffic.startTime.isAfter(lastNotificationPush);
    bool hasBeenUpdated = infoTraffic.updateDate.isBefore(DateTime.now()) && infoTraffic.updateDate.isAfter(lastNotificationPush);

    if ((infoTraffic.linesId != null && interestedBusLines.intersection(infoTraffic.linesId?.toSet() ?? {}).isEmpty) ||
        !infoTraffic.isDisplay || (alreadyPushNotifications.contains(infoTraffic.id) && !becameActive && ! hasBeenUpdated)) {
      continue;
    }
    alreadyPushNotifications.add(infoTraffic.id);
    await flip.show(infoTraffic.id, infoTraffic.title,
        infoTraffic.stopTime
            .difference(infoTraffic.startTime)
            .compareTo(const Duration(days: 1)) > 0 ?
          AppString.notificationBodyMultipleDay.format(dateFormat.format(infoTraffic.startTime), dateFormat.format(infoTraffic.stopTime)):
        AppString.notificationBodyOneDay.format(dateFormat.format(infoTraffic.startTime)),
        platformChannelSpecifics);
  }

  alreadyPushNotifications = alreadyPushNotifications.intersection(infoTraffics.where((element) => element.isDisplay).map((e) => e.id).toSet());
  await LocalDataHandler.setLastNotificationPush(DateTime.now());
  await LocalDataHandler.saveAlreadyPushNotification(alreadyPushNotifications);
  return true;
}