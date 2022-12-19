import 'package:better_bus_v2/views/common/back_arrow.dart';
import 'package:better_bus_v2/views/common/background.dart';
import 'package:better_bus_v2/views/common/content_container.dart';
import 'package:flutter/material.dart';

import '../app_constant/app_string.dart';

class AppInfo extends StatelessWidget {
  const AppInfo({Key? key}) : super(key: key);

  static const String routeName = "info-page";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                CustomContentContainer(
                  margin: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      const BackArrow(),
                      Text(AppString.appInfoPageTitle, style: Theme.of(context).textTheme.titleLarge,)
                    ],
                  ),
                ),
                Expanded(
                  child: CustomContentContainer(
                    child: const SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: SingleChildScrollView(
                        child: Text(AppString.appInfo),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
