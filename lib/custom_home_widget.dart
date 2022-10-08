import 'package:flutter/services.dart';

class CustomHomeWidgetRequest {
  static const methodeChannel = MethodChannel("better.bus.poitier/homeWidget");
  static Future<void> updateWidget() async {
    await methodeChannel.invokeMethod("updateWidget");
  }
}