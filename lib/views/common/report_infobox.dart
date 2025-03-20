import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/data_provider/radar_provider.dart';
import 'package:flutter/material.dart';
import 'package:format/format.dart';

import '../../app_constant/app_string.dart';
import 'informative_box.dart';

class ReportInfobox extends StatefulWidget {
  const ReportInfobox({this.report, required this.station, this.updatable = false, this.reportUpdate, super.key});

  final Report? report;
  final bool updatable;
  final Station station;
  final ValueChanged<Report>? reportUpdate;

  @override
  State<ReportInfobox> createState() => _ReportInfoboxState();
}

class _ReportInfoboxState extends State<ReportInfobox> {
  Report? report;

  @override
  void initState() {
    super.initState();
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    report = widget.report;
  }

  Future updateReport(bool stillThere) async {
    final provider = AppRadarProvider.of(context);
    if (report == null) {
      report = await provider.sendReport(widget.station);
    } else {
      report = await provider.updateReport(report!, stillThere);
    }
    widget.reportUpdate?.call(report!);
  }

  @override
  Widget build(BuildContext context) {
    if (report == null) {
      return widget.updatable ? ElevatedButton(
        onPressed: () => updateReport(true),
        child: const Text(AppString.signalController),
      ) : Container();
    }

    return InfoBox(
      color: Colors.blue,
      icon: Icons.local_police,
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              AppString.controllerSee.format(report!.lastSee.inMinutes),
            style: const TextStyle(
              fontWeight: FontWeight.bold
            )
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              children: widget.updatable ? [
                ElevatedButton(
                  onPressed: () => updateReport(false),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade200
                  ),
                  child: const Text(AppString.goAway),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => updateReport(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue
                  ),
                  child: const Text(AppString.stillThere),
                ),
              ] : [],
            ),
          )
        ],
      ),
    );
  }
}
