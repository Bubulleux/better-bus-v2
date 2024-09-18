import 'package:flutter/services.dart';

class CustomHomeWidgetRequest {
  static const methodeChannel = MethodChannel("home_widget");
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
}
