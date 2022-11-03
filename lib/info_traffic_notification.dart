import 'package:async/async.dart';
import 'package:better_bus_v2/data_provider/connectivity_checker.dart';
import 'package:better_bus_v2/data_provider/local_data_handler.dart';
import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/model/clean/bus_line.dart';
import 'package:better_bus_v2/model/clean/info_trafic.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'app_constante/app_string.dart';

Future<bool> checkInfoTraffic() async {
  if (!await ConnectivityChecker.isConnected()) {
    print("Error no internet connection");
    return false;
  }

  List<InfoTraffic> infoTraffics = await VitalisDataProvider.getTrafficInfo();
  Set<String> interestedBusLines = await LocalDataHandler.loadInterestedLine();
  Set<int>? alreadyPushNotifications = await LocalDataHandler.loadAlreadyPushNotification();

  FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();
  var android = const AndroidInitializationSettings('@mipmap/ic_launcher');
  var settings = InitializationSettings(android: android);
  await flip.initialize(settings);
  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      "info-traffic",
      "info-traffic",
      importance: Importance.max,
      priority: Priority.max,
  );
  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  alreadyPushNotifications ??= {};
  for (InfoTraffic infoTraffic in infoTraffics) {
    if ((infoTraffic.linesId != null && interestedBusLines.intersection(infoTraffic.linesId?.toSet() ?? {}).isEmpty) ||
        !infoTraffic.isDisplay || alreadyPushNotifications.contains(infoTraffic.id)) {
      continue;
    }
    alreadyPushNotifications.add(infoTraffic.id);
    await flip.show(infoTraffic.id, infoTraffic.title,
        null,
        platformChannelSpecifics);
  }

  alreadyPushNotifications = alreadyPushNotifications.intersection(infoTraffics.where((element) => element.isDisplay).map((e) => e.id).toSet());
  await LocalDataHandler.saveAlreadyPushNotification(alreadyPushNotifications);
  return true;
}