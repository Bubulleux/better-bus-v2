import 'dart:io';

import 'package:better_bus_v2/custom_home_widget.dart';
import 'package:better_bus_v2/model/loading_step.dart';
import 'package:better_bus_v2/views/root/loading_page.dart';
import 'package:better_bus_v2/views/root/root_nav.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../data_provider/app_provider.dart';
import '../../data_provider/gps_data_provider.dart';
import '../../data_provider/local_data_handler.dart';
import '../common/messages.dart';

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool loading = true;
  Uri? launchUri;

  List<LoadingStep> get steps => provider.loader.steps;

  FullProvider get provider => FullProvider.of(context);

  late FlutterLocalNotificationsPlugin flip;

  @override
  void initState() {
    super.initState();
    GpsDataProvider.askForGPSPermission();
    initProvider();
    initHomeWidget();
    initFlutterNotificationPlugin();
    checkIfAppIsNotificationLaunched();
    checkIfFisrtTimeOpenningApp();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (provider.isAvailable()) {
      setState(() {
        loading = false;
      });
    }
  }

  initProvider() async {
    if (provider.isAvailable()) {
      setState(() {
        loading = false;
      });
      return;
    }
    print("Provider not init");

    if (!kDebugMode && await provider.fastInit()) {
      loadingEnd();
    }

    final success = await provider.init();
    print("Sucess : $success");

    loadingEnd();
  }

  void loadingEnd() {
    if (mounted && provider.isAvailable()) {
      setState(() {
        loading = false;
      });
      return;
    }
    print("Provider is not available still loading...");
  }

  void initHomeWidget() async {
    await provider.awaitInit();
    CustomHomeWidgetRequest.init(context, (uri) {
      print("Uri Recieave $uri, Loading: $loading");
      setState(() {
        launchUri = uri;
      });
    });
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
    setState(() {
      launchUri = Uri.parse("app://infotraffic/${response.id}");
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return LoadingPage(steps);
    }

    return RootNav(
      launchUri: launchUri,
    );
  }
}
