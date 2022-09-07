import 'dart:convert';

import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/clean/view_shortcut.dart';

class  LocalDataHandler {
  static SharedPreferences? preferences;

  static Future checkPreferences() async {
    preferences ??= await SharedPreferences.getInstance();
  }

  static Future<List<ViewShortcut>> loadShortcut() async {
    await checkPreferences();

    List<String>? rawShortcuts = preferences!.getStringList("shortcuts");
    if (rawShortcuts == null || rawShortcuts.isEmpty) {
      return [];
    }

    List<ViewShortcut> shortcuts = [];
    for (String rawShortcut in rawShortcuts) {
      shortcuts.add(ViewShortcut.fromJson(jsonDecode(rawShortcut)));
    }

    return shortcuts;
  }

  static Future<void> saveShortcuts(List<ViewShortcut> shortcuts) async {
    await checkPreferences();

    List<String> shortcutJson = shortcuts.map((shortcut) =>
        jsonEncode(shortcut.toJson())).toList();

    List<String> favoriteShortcut = shortcuts.where((element) => element.isFavorite).map((element) =>
      element.shortcutName).toList();
    preferences!.setStringList("shortcuts", shortcutJson);
    HomeWidget.saveWidgetData<String>("shortcuts", favoriteShortcut.join(";")).then((saved) {
      print(saved);
      HomeWidget.updateWidget(name: "HomeWidgetExampleProvider");
    }
    );
  }
}