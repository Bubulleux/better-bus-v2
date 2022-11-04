import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/model/clean/info_traffic.dart';
import 'package:better_bus_v2/views/common/background.dart';
import 'package:better_bus_v2/views/common/custom_future.dart';
import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:better_bus_v2/views/interest_line_page/interest_lines_page.dart';
import 'package:better_bus_v2/views/traffic_info_page/traffic_info_item.dart';
import 'package:flutter/material.dart';

import '../../data_provider/local_data_handler.dart';
import '../../model/clean/bus_line.dart';

class TrafficInfoPage extends StatefulWidget {
  const TrafficInfoPage({this.focus, Key? key}) : super(key: key);

  final int? focus;
  @override
  State<TrafficInfoPage> createState() => TrafficInfoPageState();
}

class TrafficInfoPageState extends State<TrafficInfoPage> {

  late final GlobalKey<CustomFutureBuilderState> futureBuilderKey;

  Future<InfoTrafficObject> getAllInformation() async{
    List<InfoTraffic> infoList = await VitalisDataProvider.getTrafficInfo();
    Map<String, BusLine> busLines = await VitalisDataProvider.getAllLines();
    Set<String> favoriteLines = await LocalDataHandler.loadInterestedLine();


    infoList.removeWhere((element) => !element.isDisplay);
    infoList.sort(
        (a, b) {
          List<int> compareValues = [
            (favoriteLines.intersection(a.linesId?.toSet() ?? {}).length).compareTo(favoriteLines.intersection(b.linesId?.toSet() ?? {}).length),
            (a.isActive  ? 1 : 0).compareTo(b.isActive ? 1 : 0),
            ((a.linesId != null ? 0 : 1)).compareTo(b.linesId != null ? 0 : 1),
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
  
  void goSetting() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const InterestLinePage())).then((value) => futureBuilderKey.currentState?.refresh());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: CustomDecorations.of(context).boxBackground,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Text(
                        AppString.trafficInfoTitle,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      IconButton(onPressed: goSetting, icon: const Icon(Icons.settings))
                    ],
                  ),
                ),
                Expanded(
                  child: CustomFutureBuilder<InfoTrafficObject>(
                    future: getAllInformation,
                    key: futureBuilderKey,
                    onData: (context,  data, refresh) => ListView.builder(
                      itemCount: data.infoList.length,
                      itemBuilder: (context, index) => TrafficInfoItem(data.infoList[index], data.busLines),
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

class InfoTrafficObject {
  InfoTrafficObject(this.infoList, this.busLines);

  final List<InfoTraffic> infoList;
  final Map<String, BusLine> busLines;
}