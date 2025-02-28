import 'dart:convert';

import 'package:better_bus_v2/core/full_provider.dart';
import 'package:better_bus_v2/custom_home_widget.dart';
import 'package:better_bus_v2/views/common/messages.dart';
import 'package:flutter/cupertino.dart';
// import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/clean/view_shortcut.dart';

class LocalDataHandler {
  static SharedPreferences? preferences;

  static Future checkPreferences() async {
    preferences ??= await SharedPreferences.getInstance();
  }

  static Future<List<ViewShortcut>> loadShortcut(BuildContext ctx) async {
    await checkPreferences();

    List<String>? rawShortcuts = preferences!.getStringList("shortcuts");
    if (rawShortcuts == null || rawShortcuts.isEmpty) {
      return [];
    }

    final lines = await FullProvider.of(ctx).getAllLines();
    List<ViewShortcut> shortcuts = [];
    for (String rawShortcut in rawShortcuts) {
      shortcuts.add(ViewShortcut.fromJson(jsonDecode(rawShortcut), lines));
    }

    return shortcuts;
  }

  static Future<void> saveShortcuts(List<ViewShortcut> shortcuts) async {
    await checkPreferences();

    List<String> shortcutJson =
        shortcuts.map((shortcut) => jsonEncode(shortcut.toJson())).toList();

    List<String> favoriteShortcut = [];
    List<int> favoriteShortcutIds = [];
    for (int i = 0; i < shortcuts.length; i++) {
      ViewShortcut shortcut = shortcuts[i];
      if (!shortcut.isFavorite) continue;
      favoriteShortcut.add(shortcut.shortcutName);
      favoriteShortcutIds.add(i);
    }

    preferences!.setStringList("shortcuts", shortcutJson);

    CustomHomeWidgetRequest.setWidgetData(favoriteShortcut, favoriteShortcutIds);
    CustomHomeWidgetRequest.updateWidget();
  }

  static Future<Set<String>> loadInterestedLine() async {
    await checkPreferences();

    List<String>? lines = preferences!.getStringList("interested-lines");
    if (lines == null || lines.isEmpty) {
      return {};
    }

    return lines.toSet();
  }

  static Future<void> saveInterestedLines(Set<String> lines) async {
    await checkPreferences();

    preferences!.setStringList("interested-lines", lines.toList());
  }

  static Future<Set<int>?> loadAlreadyPushNotification() async {
    await checkPreferences();

    List<String>? lines =
        preferences!.getStringList("already-push-notification");

    return lines?.map((e) => int.parse(e)).toSet();
  }

  static Future<void> saveAlreadyPushNotification(Set<int> lines) async {
    await checkPreferences();

    await preferences!.setStringList(
        "already-push-notification", lines.map((e) => e.toString()).toList());
  }

  static Future<DateTime> getLastNotificationPush() async {
    await checkPreferences();

    return DateTime.fromMillisecondsSinceEpoch(
        preferences!.getInt("lastNotificationPush") ?? 0);
  }

  static Future setLastNotificationPush(DateTime lastNotificationPush) async {
    await checkPreferences();
    preferences!.setInt(
        "lastNotificationPush", lastNotificationPush.millisecondsSinceEpoch);
  }

  static Future<List<String>> loadLog() async {
    await checkPreferences();
    return preferences!.getStringList("log") ?? [];
  }

  static Future<void> addLog(String log) async {
    await checkPreferences();
    List<String> previousLog = await loadLog();
    previousLog.add("[${DateTime.now().toString()}]:\n$log");

    await preferences!.setStringList("log", previousLog);
  }

  static Future<void> clearLog() async {
    await checkPreferences();

    await preferences!.setStringList("log", []);
  }

  static Future<Map<String, String>> getAllPref() async {
    await checkPreferences();
    Set<String> keys = preferences!.getKeys();
    Map<String, String> values = {};
    for (String key in keys) {
      values[key] = preferences!.get(key).toString();
    }

    return values;
  }

  static Future<bool> getNotificationEnable() async {
    await checkPreferences();
    return preferences!.getBool("notificationEnable") ?? true;
  }

  static Future setNotificationEnable(bool value) async {
    await checkPreferences();
    preferences!.setBool("notificationEnable", value);
  }

  static Future<bool> showImportantMessage() async {
    await checkPreferences();
    int? epoch = preferences!.getInt("lastImportanteMessageDate");
    await preferences!.setInt("lastImportanteMessageDate",
        lastStartUpMessageUpdate.millisecondsSinceEpoch);

    if (epoch == null) {
      return true;
    }
    DateTime previousDate = DateTime.fromMillisecondsSinceEpoch(epoch);

    return !previousDate.isAtSameMomentAs(lastStartUpMessageUpdate);
  }

  static Future setGTFSDownloadDate(DateTime? date) async {
    await checkPreferences();
    if (date == null) {
      preferences!.remove("gtfsDownloadDate");
      return;
    }
    preferences!.setInt("gtfsDownloadDate", date.millisecondsSinceEpoch);
  }

  static Future<DateTime?> getGTFSDownloadDate() async {
    await checkPreferences();
    int? epoch = preferences!.getInt("gtfsDownloadDate");
    if (epoch == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  static Future setDownloadWhenWifi(bool value) async {
    await checkPreferences();
    await preferences!.setBool("downloadWhenWifi", value);
  }

  static Future<bool> getDownloadWhenWifi() async {
    return Future.value(false);
    await checkPreferences();
    return preferences!.getBool("downloadWhenWifi") ?? true;
  }
}
