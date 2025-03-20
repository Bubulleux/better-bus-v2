import 'package:better_bus_core/core.dart';
import 'package:flutter/material.dart';
import 'package:format/format.dart';
import 'package:intl/intl.dart';

import '../../app_constant/app_string.dart';
import '../common/informative_box.dart';

class DelayInfobox extends StatelessWidget {
  const DelayInfobox(
      {required this.stopTime,
      this.minDelay = const Duration(minutes: 1),
      this.fontSize = 17,
      super.key});

  final StopTime? stopTime;
  final Duration minDelay;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    if (stopTime == null || stopTime!.delay.abs() < minDelay) {
      return Container();
    }

    final delay = stopTime!.delay;
    return InfoBox(
      width: double.infinity,
      color: delay.isNegative ? Colors.red : Colors.orange,
      margin: const EdgeInsets.all(5),
      height: fontSize * 2.3,
      icon: Icons.warning_amber,
      child: DefaultTextStyle.merge(
        style: TextStyle(fontSize: fontSize),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              delay.isNegative
                  ? AppString.advanceOf.format(delay.abs().inMinutes)
                  : AppString.lateOf.format(delay.abs().inMinutes),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              AppString.initialTime
                  .format(DateFormat.Hm().format(stopTime!.aimedTime)),
              textScaler: const TextScaler.linear(0.8),
            )
          ],
        ),
      ),
    );
  }
}
