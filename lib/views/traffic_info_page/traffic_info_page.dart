import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/model/clean/info_traffic.dart';
import 'package:better_bus_v2/views/common/back_arrow.dart';
import 'package:better_bus_v2/views/common/background.dart';
import 'package:better_bus_v2/views/common/custom_future.dart';
import 'package:better_bus_v2/views/common/title_bar.dart';
import 'package:better_bus_v2/views/interest_line_page/interest_lines_page.dart';
import 'package:better_bus_v2/views/traffic_info_page/traffic_info_item.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../data_provider/local_data_handler.dart';
import '../../model/clean/bus_line.dart';

class TrafficInfoPage extends StatefulWidget {
  const TrafficInfoPage({super.key});
  static const String routeName = "/trafficInfo";

  @override
  State<TrafficInfoPage> createState() => TrafficInfoPageState();
}

class TrafficInfoPageState extends State<TrafficInfoPage> {
  late int? focus;
  late final GlobalKey<CustomFutureBuilderState> futureBuilderKey;
  final GlobalKey focusKey = GlobalKey();
  Map<int, GlobalKey<TrafficInfoItemState>>? infoTrafficItemKey;

  List<InfoTraffic>? trafficInfos;

  Future<InfoTrafficObject> getAllInformation() async {
    List<InfoTraffic> infoList = await VitalisDataProvider.getTrafficInfo();
    Map<String, BusLine> busLines = await VitalisDataProvider.getAllLines();
    Set<String> favoriteLines = await LocalDataHandler.loadInterestedLine();

    infoList.removeWhere((element) => !element.isDisplay);
    infoList.sort(
      (a, b) {
        List<int> compareValues = [
          (a.isActive ? 1 : 0).compareTo(b.isActive ? 1 : 0),
          ((a.linesId != null ? 0 : 1)).compareTo(b.linesId != null ? 0 : 1),
          (favoriteLines.intersection(a.linesId?.toSet() ?? {}).length)
              .compareTo(
                  favoriteLines.intersection(b.linesId?.toSet() ?? {}).length),
          BusLine.compareID(
              (b.linesId?.firstOrNull ?? ""), (a.linesId?.firstOrNull ?? ""))
        ];
        for (int compareValues in compareValues) {
          if (compareValues != 0) {
            return compareValues;
          }
        }
        return 0;
      },
    );
    infoList = infoList.reversed.toList();
    return InfoTrafficObject(infoList, busLines);
  }

  @override
  void initState() {
    super.initState();
    futureBuilderKey = GlobalKey();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    focus = ModalRoute.of(context)!.settings.arguments as int?;
  }

  void goSetting() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const InterestLinePage()))
        .then((value) => futureBuilderKey.currentState?.refresh());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: SafeArea(
          child: Column(
            children: [
              CustomTitleBar(
                title: AppString.trafficInfoTitle,
                leftChild: const BackArrow(),
                rightChild: IconButton(
                    onPressed: goSetting, icon: const Icon(Icons.settings)),
              ),
              Expanded(
                child: CustomFutureBuilder<InfoTrafficObject>(
                  future: getAllInformation,
                  key: futureBuilderKey,
                  onData: (context, data, refresh) {
                    trafficInfos = data.infoList;
                    infoTrafficItemKey = {};
                    trafficInfos!.forEachIndexed((index, element) =>
                        infoTrafficItemKey![index] = GlobalKey());
                    return ScrollablePositionedList.builder(
                      itemCount: data.infoList.length,
                      initialScrollIndex: focus != null
                          ? trafficInfos!.indexWhere((e) => e.id == focus)
                          : 0,
                      itemBuilder: (context, index) => TrafficInfoItem(
                        data.infoList[index],
                        data.busLines,
                        key: infoTrafficItemKey![index],
                        deploy: data.infoList[index].id == focus,
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class InfoTrafficObject {
  InfoTrafficObject(this.infoList, this.busLines);

  final List<InfoTraffic> infoList;
  final Map<String, BusLine> busLines;
}
