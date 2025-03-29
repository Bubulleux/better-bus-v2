import 'package:better_bus_v2/views/common/title_bar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app_constant/app_string.dart';
import '../common/messages.dart';
import '../setting_page/setting_page.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  void showPrivacyPolicy() {
    Uri uri = Uri.parse(
        "https://github.com/Bubulleux/better-bus-v2/blob/master/Privacy%20policy.md");
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void showSourceCode() {
    Uri uri = Uri.parse("https://github.com/Bubulleux/better-bus-v2");
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void makeATip() {
    Uri uri = Uri.parse("https://www.buymeacoffee.com/Bubulle");
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void goToImportantMessage(BuildContext context) {
    Navigator.of(context)
        .pushNamed(MessageView.routeName, arguments: Messages.importantMessage);
  }

  void goToMessageToVitalis(BuildContext context) {
    Navigator.of(context)
        .pushNamed(MessageView.routeName, arguments: Messages.toVitalis);
  }

  void goToSetting(BuildContext context) {
    SettingPage.push(context);
  }

  Widget buildTitle() {
    return CustomTitleBar(
      title: AppString.appName, // TODO : Maybe city name
      leftChild: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: const Image(
              width: 30, image: AssetImage("assets/images/icon.jpg")),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final body = [
      SettingEntry(
        AppString.privicyPolicy,
        onClick: showPrivacyPolicy,
      ),
      SettingEntry(
        AppString.sourceCode,
        onClick: showSourceCode,
      ),
      SettingEntry(
        AppString.makeTips,
        onClick: makeATip,
      ),
      SettingEntry(
        AppString.importantMessage,
        onClick: () => goToImportantMessage(context),
      ),
      SettingEntry(
        AppString.messageToVitalis,
        onClick: () => goToMessageToVitalis(context),
      ),
      SettingEntry(
        AppString.settings,
        onClick: () => goToSetting(context),
      ),
    ];
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            buildTitle(),
            Expanded(child:
            ListView(children: body,))
          ],
        ),
      ),
    );
  }
}
