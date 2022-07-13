import 'package:better_bus_v2/views/common/background.dart';
import 'package:better_bus_v2/views/search_page/search_page.dart';
import 'package:better_bus_v2/views/stop_info/timetable_view.dart';
import 'package:flutter/material.dart';

import '../../model/clean/bus_stop.dart';
import 'next_passage_view.dart';

class StopInfoPage extends StatefulWidget {
  const StopInfoPage(this.stop, {Key? key}) : super(key: key);

  final BusStop stop;

  @override
  State<StopInfoPage> createState() => _StopInfoPageState();
}

class _StopInfoPageState extends State<StopInfoPage>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;
  late BusStop stop;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    stop = widget.stop;
  }

  void changeBusStop() {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => SearchPage()
    )).then((value) => setState(() {
      stop = value;
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
              child: GestureDetector(
                onTap: changeBusStop,
                child: Container(
                  height: 60,
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Text(
                        stop.name,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      const Spacer(),
                      const Icon(Icons.search)
                    ],
                  ),
                  decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
            TabBar(
              tabs: [
                Tab(text: "! Prochain Passage ",),
                Tab(text: "! Tout les horrairs",)
              ],
              controller: tabController,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  NextPassagePage(stop),
                  TimeTableView(stop),
                ],
                controller: tabController,
                key: ObjectKey(stop),
              ),
            )
          ],
        ),
      ),
    );
  }
}
