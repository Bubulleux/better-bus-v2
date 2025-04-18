import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../custom_home_widget.dart';
import '../../data_provider/gps_data_provider.dart';
import '../../data_provider/local_data_handler.dart';
import '../common/messages.dart';
import '../traffic_info_page/traffic_info_page.dart';

class Loader extends StatefulWidget {
  const Loader({required this.child, super.key});

  final Widget child;

  @override
  State<Loader> createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {

  @override
  void initState() {
    super.initState();
    initAll();
  }

  void initAll() {
    // CustomHomeWidgetRequest.init(context);
  }




  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
