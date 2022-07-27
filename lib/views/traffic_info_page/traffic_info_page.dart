import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/model/clean/info_trafic.dart';
import 'package:better_bus_v2/views/common/background.dart';
import 'package:better_bus_v2/views/common/custom_futur.dart';
import 'package:better_bus_v2/views/traffic_info_page/traffic_info_item.dart';
import 'package:flutter/material.dart';

class TrafficInfoPage extends StatelessWidget {
  const TrafficInfoPage({Key? key}) : super(key: key);

  Future<List<InfoTraffic>> getAllInformation() async{
    List<InfoTraffic> result = await VitalisDataProvider.getTrafficInfo();
    result.removeWhere((element) => !element.isDisplay);
    return result;
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
                  child: CustomFutureBuilder<List<InfoTraffic>>(
                    future: getAllInformation,
                    onData: (context, data, refresh) => ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) => TrafficInfoItem(data[index]),
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
