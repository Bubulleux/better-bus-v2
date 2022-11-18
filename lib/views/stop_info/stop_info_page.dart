import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/data_provider/maps_router.dart';
import 'package:better_bus_v2/views/common/fake_text_field.dart';
import 'package:better_bus_v2/views/stops_search_page/stops_search_page.dart';
import 'package:better_bus_v2/views/stop_info/timetable_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

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

class _StopInfoPageState extends State<StopInfoPage> with SingleTickerProviderStateMixin {
  late final TabController tabController;
  late BusStop stop;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    stop = widget.stop;
  }

  void changeBusStop() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPage())).then((value) {
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
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: FakeTextField(
                        onPress: changeBusStop,
                        value: stop.name,
                        icon: Icons.search,
                      ),
                    ),
                    TextButton(
                      onPressed: () => MapsRouter.routeToMap(stop.latitude, stop.longitude),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Icon(
                          Icons.map,
                          size: 40,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                )),
            TabBar(
              tabs: const [
                Tab(
                  text: AppString.nextPassage,
                ),
                Tab(
                  text: AppString.allSchedule,
                )
              ],
              controller: tabController,
            ),
            Container(
              color: Colors.black.withAlpha(25),
              width: double.infinity,
              height: 1,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  NextPassagePage(stop, lines: widget.stop == stop ? widget.lines : null),
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
