import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/model/clean/route.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:better_bus_v2/views/route_detail_page/route_step_tab.dart';
import 'package:flutter/material.dart';



class RouteDetailPage extends StatefulWidget {

  const RouteDetailPage({super.key});

  static const String routeName = "/routeDetail";

  @override
  State<RouteDetailPage> createState() => _RouteDetailPageState();
}

class _RouteDetailPageState extends State<RouteDetailPage> with SingleTickerProviderStateMixin{
  late final TabController tabController;
  late VitalisRoute busRoute;


  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    busRoute = ModalRoute.of(context)!.settings.arguments as VitalisRoute;
    tabController = TabController(length: busRoute.itinerary.length, vsync: this);
    tabController.addListener(() {setState(() {});});
  }


  @override
  Widget build(BuildContext context) {

    List<Widget> tabs = [];
    List<Widget> tabContent = [];

    busRoute.itinerary.asMap().forEach((i, element) {
      if (element.lines == null) {
        tabs.add(const Tab(icon: Icon(Icons.directions_walk),));
      } else {
        tabs.add(Tab(child:
        Column(
          children: [
            LineWidget.fromRouteLine(element.lines!, 20),
            const Icon(Icons.directions_bus),
          ],
        )
        ));
      }
      tabContent.add(RouteStepPage(busRoute, i));
    });

    return Scaffold(

      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                TextButton(
                  child: const Icon(Icons.chevron_left),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    // alignment: Alignment.center,
                    child: TabBar(
                      tabs: tabs,
                      controller: tabController,
                      // indicatorSize: TabBarIndicatorSize.tab,
                      isScrollable: true,
                      labelPadding: const EdgeInsets.all(8),
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: tabContent,
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                children: [
                  tabController.index != 0 ?
                  ElevatedButton(onPressed: () => tabController.animateTo(tabController.index - 1), child: const Text(AppString.previousLabel)):
                  Container(width: 5,),
                  tabController.index != busRoute.itinerary.length -1 ?
                  ElevatedButton(onPressed: () => tabController.animateTo(tabController.index + 1), child: const Text(AppString.nextLabel)):
                  Container(width: 5,),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
