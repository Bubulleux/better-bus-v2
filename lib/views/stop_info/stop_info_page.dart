import 'package:better_bus_v2/views/common/fake_textfiel.dart';
import 'package:better_bus_v2/views/stops_search_page/stops_search_page.dart';
import 'package:better_bus_v2/views/stop_info/timetable_view.dart';
import 'package:flutter/material.dart';

import '../../model/clean/bus_line.dart';
import '../../model/clean/bus_stop.dart';
import 'next_passage_view.dart';

class StopInfoPage extends StatefulWidget {
  const StopInfoPage(this.stop, {this.lines, Key? key}) : super(key: key);

  final BusStop stop;
  final List<BusLine>? lines;

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
    return;
    Navigator.push(context,
            MaterialPageRoute(builder: (context) => const SearchPage()))
        .then((value) {
      if (value == null) {
        return;
      }
      setState(() {
        stop = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
              child: FakeTextField(
                onPress: changeBusStop,
                value: stop.name,
                icon: Icons.search,
              )
            ),
            TabBar(
              tabs: const [
                Tab(
                  text: "! Prochain Passage ",
                ),
                Tab(
                  text: "! Tout les horrairs",
                )
              ],
              controller: tabController,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  NextPassagePage(stop, lines: widget.lines),
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
