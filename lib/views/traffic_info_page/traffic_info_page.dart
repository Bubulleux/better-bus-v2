import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/model/clean/info_trafic.dart';
import 'package:better_bus_v2/views/common/background.dart';
import 'package:better_bus_v2/views/common/custom_futur.dart';
import 'package:better_bus_v2/views/traffic_info_page/traffic_info_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:intl/intl.dart';

import '../../model/clean/bus_line.dart';
import '../../model/clean/info_trafic.dart';

class TrafficInfoPage extends StatefulWidget {
  const TrafficInfoPage({Key? key}) : super(key: key);

  @override
  State<TrafficInfoPage> createState() => TrafficInfoPageState();
}

class TrafficInfoPageState extends State<TrafficInfoPage> {
  Future<InfoTrafficObject> getAllInformation() async{
    List<InfoTraffic> infoList = await VitalisDataProvider.getTrafficInfo();
    Map<String, BusLine> busLines = await VitalisDataProvider.getAllLines();
    infoList.removeWhere((element) => !element.isDisplay);
    return InfoTrafficObject(infoList, busLines);
  }


  @override
  void initState() {
    super.initState();
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
                Text("Info Trafic:"),
                Expanded(
                  child: CustomFutureBuilder<InfoTrafficObject>(
                    future: getAllInformation,
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