import 'package:better_bus_v2/model/clean/info_trafic.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:better_bus_v2/views/traffic_info_page/traffic_info_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';

import '../../model/clean/bus_line.dart';

class TrafficInfoItem extends StatelessWidget {
  const TrafficInfoItem(this.infoTraffic, this.busLines, {Key? key}) : super(key: key);

  final InfoTraffic infoTraffic;
  final Map<String, BusLine> busLines;

  static final dateFormat = DateFormat("dd/MM/yy");

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: CustomDecorations.of(context).boxBackground,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              infoTraffic.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: infoTraffic.isActive ? Theme.of(context).primaryColorDark : null,
                fontWeight: infoTraffic.isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Wrap(
              alignment: WrapAlignment.start,
              spacing: 5,
              runSpacing: 5,
              children: infoTraffic.linesId
                      ?.map((e) => busLines[e] != null
                          ? LineWidget(
                              busLines[e]!,
                              25,
                              dynamicWidth: true,
                            )
                          : Container())
                      .toList() ??
                  [],
            ),
            SizedBox(
              width: double.infinity,
              child: infoTraffic.stopTime.difference(infoTraffic.startTime).compareTo(const Duration(days: 1)) > 0
                  ? Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        Text(
                          dateFormat.format(infoTraffic.startTime),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Icon(Icons.arrow_right_alt, color: Theme.of(context).primaryColorDark),
                        Text(
                          dateFormat.format(infoTraffic.stopTime),
                          style: Theme.of(context).textTheme.headlineSmall,
                        )
                      ],
                    )
                  : Text(
                      dateFormat.format(infoTraffic.stopTime),
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
            ),
            HtmlWidget(infoTraffic.content),
          ],
        ),
      ),
    );
  }
}
