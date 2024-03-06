import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/data_provider/cache_data_provider.dart';
import 'package:better_bus_v2/data_provider/gtfs_data_provider.dart';
import 'package:better_bus_v2/data_provider/local_data_handler.dart';
import 'package:better_bus_v2/info_traffic_notification.dart';
import 'package:better_bus_v2/views/common/back_arrow.dart';
import 'package:better_bus_v2/views/common/messages.dart';
import 'package:better_bus_v2/views/common/title_bar.dart';
import 'package:better_bus_v2/views/interest_line_page/interest_lines_page.dart';
import 'package:better_bus_v2/views/log_view.dart';
import 'package:better_bus_v2/views/preferences_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);
  static const String routeName = "/setting";

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool gtfsDownloadWIFI = false;

  @override
  void initState() {
    super.initState();
    LocalDataHandler.getDownloadWhenWifi().then(setgtfsWifiDownload);
  }

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

  void gotToNotificationSetting() {
    Navigator.of(context).pushNamed(InterestLinePage.routeName);
  }

  void goToImportantMessage() {
    Navigator.of(context)
        .pushNamed(MessageView.routeName, arguments: Messages.importantMessage);
  }

  void goToMessageToVitalis() {
    Navigator.of(context)
        .pushNamed(MessageView.routeName, arguments: Messages.toVitalis);
  }

  void emptyCache() {
    CacheDataProvider.emptyCacheData();
  }

  void testNotificationActivation() async {
    await LocalDataHandler.setLastNotificationPush(DateTime(2022, 11, 10));
    checkInfoTraffic();
  }

  void gotoLog() {
    Navigator.of(context).pushNamed(LogView.routeName);
  }

  void gotoPrefs() {
    Navigator.of(context).pushNamed(PreferencesView.routeName);
  }

  void setgtfsWifiDownload(bool value) {
    LocalDataHandler.setDownloadWhenWifi(value);
    setState(() {
      gtfsDownloadWIFI = value;
    });
  }

  void reDownloadGTFSData() async {
    AlertDialog alert = const AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
        ],
      ),
    );
    showDialog(
        context: context,
        builder: (context) => alert,
        barrierDismissible: false);
    await GTFSDataProvider.loadFile(forceDownload: true);
    Navigator.of(context).pop();
  }

  List<SettingEntry> getOptions() {
    List<SettingEntry> options = [
      SettingEntry(
        AppString.notificationSetting,
        onClick: gotToNotificationSetting,
      ),
      SettingEntry(
        AppString.gtfsDownloadWIFI,
        description: AppString.gtfsDownloadWIFIExplain,
        child: Switch(value: gtfsDownloadWIFI, onChanged: setgtfsWifiDownload),
      ),
      SettingEntry(
        AppString.reDownloadGTFSData,
        onClick: reDownloadGTFSData,
      ),
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
        onClick: goToImportantMessage,
      ),
      SettingEntry(
        AppString.messageToVitalis,
        onClick: goToMessageToVitalis,
      ),
      SettingEntry(
        AppString.emptyCache,
        onClick: emptyCache,
      ),
    ];
    if (!kDebugMode) return options;
    options += [
      SettingEntry(
        "See shared prefs",
        onClick: gotoPrefs,
      ),
      SettingEntry(
          "Test Notifiaction",
          onClick: testNotificationActivation,
      )
    ];
    return options;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(children: [
      const CustomTitleBar(
        title: AppString.settings,
        leftChild: BackArrow(),
      ),
      Expanded(
          child: ListView(
        children: getOptions(),
      ))
    ])));
  }
}

class SettingEntry extends StatelessWidget {
  const SettingEntry(
    this.title, {
    this.onClick,
    this.description,
    this.child,
    Key? key,
  }) : super(key: key);

  final String title;
  final String? description;

  final void Function()? onClick;
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: (onClick ?? () => {}),
        child: Container(
          decoration: BoxDecoration(
              border: Border.symmetric(
                  horizontal: BorderSide(color: Colors.black.withAlpha(50)))),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  child ?? Container(),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              description != null
                  ? Text(
                      description!,
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  : Container(),
            ],
          ),
        ));
  }
}
