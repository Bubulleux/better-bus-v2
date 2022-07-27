import 'package:better_bus_v2/model/clean/info_trafic.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:flutter/material.dart';

class TrafficInfoItem extends StatelessWidget {
  const TrafficInfoItem(this.infoTraffic, {Key? key}) : super(key: key);

  final InfoTraffic infoTraffic;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: CustomDecorations.of(context).boxBackground,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          children: [
            Text(
              infoTraffic.title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              infoTraffic.content,
              maxLines: 3,
              overflow: TextOverflow.fade,
            )
          ],
        ),
      ),
    );
  }
}
