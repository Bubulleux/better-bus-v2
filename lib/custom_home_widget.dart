import 'dart:io';

import 'package:better_bus_v2/data_provider/local_data_handler.dart';
import 'package:better_bus_v2/model/clean/view_shortcut.dart';
import 'package:better_bus_v2/views/common/closest_stop_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'views/stop_info/stop_info_page.dart';

class CustomHomeWidgetRequest {
  static const methodeChannel = MethodChannel("home_widget");
  static const eventChannel = EventChannel("widgetLaunch");
  static bool available = false;

  static void init(BuildContext context) {
    if (!Platform.isAndroid) {
      return;
    }
    CustomHomeWidgetRequest.listenWidgetLaunch(context);
    CustomHomeWidgetRequest.checkWidgetLaunch(context);
    available = true;
  }


  static Future<void> updateWidget() async {
    if (!available) return;
    await methodeChannel.invokeMethod("updateWidget");
  }

  static Future<void> setWidgetData(List<String> shortcuts, List<int> shortcutsIds) async {
    if (!available) return;
    String data = shortcuts.join(";");
    await methodeChannel.invokeMethod("setWidgetData", {"data" : data} );
  }

  static Future<Uri?> getLaunchUri() async {
    if (!available) return null;
    String? result = await methodeChannel.invokeMethod<String?>("getLaunchUri");
    if (result == null) return null;

    Uri? uri = Uri.tryParse(result);
    if (uri == null) return null;

    return uri;

  }

  static void listenWidgetLaunch(BuildContext context) {
    if (!available) return;
    eventChannel.receiveBroadcastStream().listen(((dynamic value) {
      if (value == null) {
        return;
      }
      if (value is! String) {
        return;
      }

      Uri? uri = Uri.tryParse(value);
      if (uri == null) {
        return;
      }

      launchUri(context, uri);
    }));
  }

  static void launchUri(BuildContext context, Uri uri) {
    if (!available) return;
    if (uri.scheme != "app") {
      return;
    }

    if (uri.host == "openshortcut") {
      launchShortcutByWidget(uri.pathSegments[0], context);
    }

    if (uri.host == "openmystop") {
      findClosestStop(context);
    }
  }

  static void launchShortcutByWidget(String shortcutRowId, BuildContext context) async {
    if (!available) return;
    List<ViewShortcut> shortcuts = await LocalDataHandler.loadShortcut();
    int shortcutIndex = int.parse(shortcutRowId);
    if (shortcutIndex == -1 || !context.mounted) {
      return;
    }
    ViewShortcut shortcut = shortcuts.where((e) => e.isFavorite)
      .toList()[shortcutIndex];

    Navigator.of(context).popUntil((route) =>
    (route.settings.name != StopInfoPage.routeName ||
        (route.settings.arguments as StopInfoPageArgument?)?.stop !=
            shortcut.stop));
    Navigator.of(context).pushNamed(StopInfoPage.routeName,
        arguments: StopInfoPageArgument(shortcut.stop, shortcut.lines));
  }


  static Future findClosestStop(BuildContext context) async {
    if (!available) return;
    return ClosestStopDialog.show(context);
  }

  static Future checkWidgetLaunch(BuildContext context) async {
    if (!available) return;
    Uri? uri = await getLaunchUri();

    if (uri == null) return;

    if (context.mounted) {
      launchUri(context, uri);
    }
  }
}
