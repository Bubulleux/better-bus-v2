import 'package:better_bus_v2/views/common/background.dart';
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

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
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
                onTap: () {
                  print("Search Bar pressed");
                },
                child: Container(
                  height: 60,
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Text(
                        widget.stop.name,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Spacer(),
                      Icon(Icons.search)
                    ],
                  ),
                  decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
            TabBar(
              tabs: const [
                Tab(text: "! Prochain Passage",),
                Tab(text: "! Tout les horrairs",)
              ],
              controller: tabController,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  NextPassagePage(widget.stop),
                  Container(),
                ],
                controller: tabController,
              ),
            )
          ],
        ),
      ),
    );
  }
}
