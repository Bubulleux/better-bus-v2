import 'package:flutter/services.dart';

class CustomHomeWidgetRequest {
  static const methodeChannel = MethodChannel("better.bus.poitier/homeWidget");
  Future<void> updateWidget() async {
    await methodeChannel.invokeListMethod("updateWidget");
  }
}