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


  static Future<void> updateWidget() async {
    await methodeChannel.invokeMethod("updateWidget");
  }

  static Future<void> setWidgetData(List<String> shortcuts, List<int> shortcutsIds) async {
    String data = shortcuts.join(";");
    await methodeChannel.invokeMethod("setWidgetData", {"data" : data} );
  }

  static Future<Uri?> getLaunchUri() async {
    String? uri = await methodeChannel.invokeListMethod("getLaunchUri" ) as String?;
    print("getLaunch Uri Called:");
    print(uri);
    if (uri == null) {
      return null;
    }
    return Uri.parse(uri);
  }

  static void listenWidgetLaunch(BuildContext context) {
    eventChannel.receiveBroadcastStream().listen(((dynamic value) {
      print("Event Recieve");
      if (value == null) {
        print("Value null");
        return;
      }
      if (value is! String) {
        print("value is not String");
        return;
      }

      Uri? uri = Uri.tryParse(value as String);
      if (uri == null) {
        print("Uri is Null");
        return;
      }

      if (uri.scheme == "app") {
        print(uri.scheme);
        print(uri.host);
        if (uri.host == "openshortcut") {
          launchShortcutByWidget(uri.pathSegments[0], context);
        }
        if (uri.host == "openmystop") {
          findClosestStop(context);
        }
      }

    }));
  }

  static void launchShortcutByWidget(
      String shortcutRowId, BuildContext context) async {
    List<ViewShortcut> shortcuts = await LocalDataHandler.loadShortcut();
    int shortcutIndex = int.parse(shortcutRowId);
    if (shortcutIndex == -1) {
      return;
    }
    ViewShortcut shortcut = shortcuts[shortcutIndex];

    Navigator.of(context).popUntil((route) =>
    (route.settings.name != StopInfoPage.routeName ||
        (route.settings.arguments as StopInfoPageArgument?)?.stop !=
            shortcut.stop));
    Navigator.of(context).pushNamed(StopInfoPage.routeName,
        arguments: StopInfoPageArgument(shortcut.stop, shortcut.lines));
  }


  static Future findClosestStop(BuildContext context) async {
    return ClosestStopDialog.show(context);
  }
}
