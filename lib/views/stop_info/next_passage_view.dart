import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/error_handler/custom_error.dart';
import 'package:better_bus_v2/model/clean/bus_stop.dart';
import 'package:better_bus_v2/views/common/custom_future.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/clean/bus_line.dart';
import '../../model/clean/next_passage.dart';

class NextPassagePage extends StatefulWidget {
  const NextPassagePage(this.stop, {this.lines, Key? key}) : super(key: key);

  final BusStop stop;
  final List<BusLine>? lines;

  @override
  State<NextPassagePage> createState() => _NextPassagePageState();
}

class _NextPassagePageState extends State<NextPassagePage> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin{

  bool seeAll = false;
  late AnimationController seeAllAnimationController;
  late Animation<double> seeAllBtnAnimation;

  GlobalKey<NextPassageListWidgetState> nextPassageWidgetKey = GlobalKey<NextPassageListWidgetState>();


  @override
  void initState() {
    super.initState();
    if (widget.lines == null)
    {
      seeAll = true;
    }
    seeAllAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    seeAllBtnAnimation = CurvedAnimation(parent: seeAllAnimationController, curve: Curves.easeOut);
    seeAllAnimationController.value = seeAll ? 0 : 1;
  }


  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          SizeTransition(
            sizeFactor: seeAllBtnAnimation,
            axisAlignment: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton(
                onPressed: () {
                  seeAll = true;
                  seeAllAnimationController.reverse();
                  nextPassageWidgetKey.currentState!.refresh();
                  setState(() {});
                },
                child: const Text(AppString.seeAllLabel),
              ),
            ),
          ),
          Expanded(
            child: NextPassageListWidget(widget.stop,  seeAll ? null : widget.lines, key: nextPassageWidgetKey,),
          ),
        ],
      )
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class NextPassageListWidget extends StatefulWidget {
  const NextPassageListWidget(this.stop, this.lines, {Key? key}) : super(key: key);

  final BusStop stop;
  final List<BusLine>? lines;

  @override
  State<NextPassageListWidget> createState() => NextPassageListWidgetState();
}

class NextPassageListWidgetState extends State<NextPassageListWidget> {

  final GlobalKey<CustomFutureBuilderState<List<NextPassage>>> futureBuilderKey = GlobalKey<CustomFutureBuilderState<List<NextPassage>>>();

  void refresh() {
    futureBuilderKey.currentState!.refresh();
  }

  Future<List<NextPassage>> getData() async {
    List<NextPassage> result = await VitalisDataProvider.getNextPassage(widget.stop);
    if (widget.lines != null){
      result.removeWhere((element){
        for(BusLine line in widget.lines!){
          if (line.id == element.line.id &&
              (line.goDirection.contains(element.destination) ||
                  line.backDirection.contains(element.destination))){
            return false;
          }
        }
        return true;
      });
    }

    return result;

  }

  @override
  Widget build(BuildContext context) {
    return CustomFutureBuilder<List<NextPassage>>(
      future: getData,
      key: futureBuilderKey,
      onData: (context, data, refresh) {
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) => NextPassageWidget(data[index]),
        );
      },

      onError: (context, error, refresh) {
        return error.build(context, refresh);
      },

      refreshIndicator: (context, child, refresh) {
        return RefreshIndicator(child: child, onRefresh: refresh);
      },
      errorTest: (data) {
        if (data.isEmpty){
          return CustomErrors.emptyNextPassage;
        }
        return null;
      },
      automaticRefresh: const Duration(seconds: 30),
    );
  }
}

class NextPassageWidget extends StatelessWidget {
  const NextPassageWidget(this.nextPassage, {Key? key}) : super(key: key);
  final NextPassage nextPassage;

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat.Hm().format(nextPassage.expectedTime.toLocal());
    String minuteToWait = "${nextPassage.expectedTime.difference(DateTime.now()).inMinutes} min";
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: Theme.of(context).primaryColor)
        )
      ),
      child: Row(
        children: [
          LineWidget(nextPassage.line, 45),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                nextPassage.destination,
                style: Theme.of(context).textTheme.headline5,
                overflow: TextOverflow.fade,
                maxLines: 1,
                softWrap: false,
              ),
            ),
          ),
          Container(
            child: nextPassage.realTime ? const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(Icons.wifi),
            ) : null,
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(minuteToWait,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),),
                Text(
                    formattedTime,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
