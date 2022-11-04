import 'package:better_bus_v2/model/clean/info_traffic.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:better_bus_v2/views/common/extendable_view.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../model/clean/bus_line.dart';

class TrafficInfoItem extends StatefulWidget {
  const TrafficInfoItem(this.infoTraffic, this.busLines, {Key? key}) : super(key: key);

  final InfoTraffic infoTraffic;
  final Map<String, BusLine> busLines;

  static final dateFormat = DateFormat("EE d MMM", "fr");

  @override
  State<TrafficInfoItem> createState() => _TrafficInfoItemState();
}

class _TrafficInfoItemState extends State<TrafficInfoItem> with SingleTickerProviderStateMixin {
  late ExpandableWidgetController expandableController;

  @override
  void initState() {
    super.initState();
    expandableController = ExpandableWidgetController(root: this);
  }

  @override
  void dispose() {
    expandableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<BusLine> itemLines = [];
    for (String lineID in widget.infoTraffic.linesId ?? []) {
      itemLines.add(widget.busLines[lineID]!);
    }
    itemLines.sort();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: CustomDecorations.borderRadius,
          onTap: () {
            expandableController.tickAnimation();
          },
          splashColor: Colors.black,
          child: Container(
            decoration: CustomDecorations.of(context).boxBackground,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.infoTraffic.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: widget.infoTraffic.isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                ),
                const SizedBox(
                  height: 5,
                ),
                SizedBox(
                  width: double.infinity,
                  child: widget.infoTraffic.stopTime
                              .difference(widget.infoTraffic.startTime)
                              .compareTo(const Duration(days: 1)) >
                          0
                      ? Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            Text(
                              TrafficInfoItem.dateFormat.format(widget.infoTraffic.startTime),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const Icon(Icons.keyboard_double_arrow_right),
                            Text(
                              TrafficInfoItem.dateFormat.format(widget.infoTraffic.stopTime),
                              style: Theme.of(context).textTheme.titleLarge,
                            )
                          ],
                        )
                      : Text(
                          TrafficInfoItem.dateFormat.format(widget.infoTraffic.stopTime),
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 5,
                  runSpacing: 5,
                  children: itemLines.map((e) => LineWidget(e, 25, dynamicWidth: true)).toList(),
                ),
                ExpendableWidget(
                  child: HtmlWidget(
                    widget.infoTraffic.content,
                    onTapUrl: (url) {
                      return launchUrlString(url, mode: LaunchMode.externalApplication);
                    },
                  ),
                  controller: expandableController,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
