import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'custom_home_widget.dart';
import 'data_provider/gps_data_provider.dart';
import 'data_provider/local_data_handler.dart';
import 'views/common/messages.dart';
import 'views/traffic_info_page/traffic_info_page.dart';

class Loader extends StatefulWidget {
  const Loader({required this.child, super.key});

  final Widget child;

  @override
  State<Loader> createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {

  late FlutterLocalNotificationsPlugin flip;
  @override
  void initState() {
    super.initState();
    initAll();
  }

  void initAll() {
    GpsDataProvider.askForGPSPermission();
    initFlutterNotificationPlugin();
    checkIfAppIsNotificationLaunched();
    checkIfFisrtTimeOpenningApp();
    // CustomHomeWidgetRequest.init(context);
  }

  Future checkIfAppIsNotificationLaunched() async {
    if (!Platform.isAndroid) return;
    NotificationAppLaunchDetails? launchNotificationDetails =
    await FlutterLocalNotificationsPlugin()
        .getNotificationAppLaunchDetails();
    if (launchNotificationDetails == null) {
      return;
    }
    receiveNotification(launchNotificationDetails.notificationResponse);
  }

  void receiveNotification(NotificationResponse? response) {
    if (response == null) {
      return;
    }
    Navigator.of(context)
        .popUntil((route) => route.settings.name != TrafficInfoPage.routeName);
    Navigator.of(context)
        .pushNamed(TrafficInfoPage.routeName, arguments: response.id);
  }

  void checkIfFisrtTimeOpenningApp() async {
    bool showImportantMessage = await LocalDataHandler.showImportantMessage();
    if (!showImportantMessage) {
      return;
    }
    Navigator.of(context)
        .pushNamed(MessageView.routeName, arguments: Messages.importantMessage);
  }

  Future initFlutterNotificationPlugin() async {
    flip = FlutterLocalNotificationsPlugin();

    AndroidFlutterLocalNotificationsPlugin? androidImp =
    flip.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    androidImp?.requestNotificationsPermission();

    var android = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var settings = InitializationSettings(android: android);
    await flip.initialize(settings,
        onDidReceiveNotificationResponse: receiveNotification);
  }
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
