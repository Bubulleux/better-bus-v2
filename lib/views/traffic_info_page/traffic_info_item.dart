import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';


class TrafficInfoItem extends StatefulWidget {
  const TrafficInfoItem(this.infoTraffic, this.busLines,{this.deploy = false, super.key});

  final InfoTraffic infoTraffic;
  final Map<String, BusLine> busLines;
  final bool deploy;


  static final dateFormat = DateFormat("EE d MMM", "fr");

  @override
  State<TrafficInfoItem> createState() => TrafficInfoItemState();

}

class TrafficInfoItemState extends State<TrafficInfoItem> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // late ExpandableWidgetController expandableController;
  late Animation<double> animation;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    // expandableController = ExpandableWidgetController(root: this);
    // if (widget.deploy) {
    //   expandableController.tickAnimation();
    // }
    animationController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    animation = Tween(begin: 15.0, end: 5.0).animate(animationController);
    animationController.addListener(() {setState(() {});});
    if (widget.deploy) {
      animationController.forward();
    } else {
      animationController.value = 1;
    }

  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    List<BusLine> itemLines = [];
    for (String lineID in widget.infoTraffic.linesId ?? []) {
      if (widget.busLines[lineID] == null) continue;
      itemLines.add(widget.busLines[lineID]!);
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Colors.transparent,
        elevation: animation.value,
        shape: RoundedRectangleBorder(borderRadius: CustomDecorations.borderRadius),
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
              // Text(widget.infoTraffic.id.toString()),
              const Divider(thickness: 1,),
              SizedBox(
                width: double.infinity,
                child: widget.infoTraffic.stopTime
                            .difference(widget.infoTraffic.startTime)
                            .compareTo(const Duration(days: 1)) > 0
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
              HtmlWidget(
                widget.infoTraffic.content,
                onTapUrl: (url) {
                  return launchUrlString(url, mode: LaunchMode.externalApplication);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
