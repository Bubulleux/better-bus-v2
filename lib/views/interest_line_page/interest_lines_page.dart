import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/data_provider/local_data_handler.dart';
import 'package:better_bus_v2/views/common/back_arrow.dart';
import 'package:better_bus_v2/views/common/custom_future.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:flutter/material.dart';

typedef CheckCallBack = void Function(bool checked, BusLine line);

class InterestLinePage extends StatefulWidget {
  const InterestLinePage({super.key});
  static const String routeName = "/interestedLines";

  @override
  State<InterestLinePage> createState() => _InterestLinePageState();
}

class _InterestLinePageState extends State<InterestLinePage> {
  Set<String> linesSelected = {};
  bool notificationEnable = true;

  Future<List<BusLine>> getLines() async {
    linesSelected = await LocalDataHandler.loadInterestedLine();
    notificationEnable = await LocalDataHandler.getNotificationEnable();
    setState(() {});
    List<BusLine> busLines = (await FullProvider.of(context).getAllLines()).values.toList();
    busLines.sort();
    return busLines;
  }

  void save() {
    LocalDataHandler.saveInterestedLines(linesSelected);
    LocalDataHandler.setNotificationEnable(notificationEnable);
  }

  void linePressed(bool checked, BusLine line) {
    if (checked) {
      linesSelected.add(line.id);
    } else {
      linesSelected.remove(line.id);
    }
    save();
  }

  void enableNotification() {
    notificationEnable = !notificationEnable;
    save();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              Material(
                elevation: 5,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const BackArrow(),
                              Expanded(child: Text(AppString.selectLine, style: Theme.of(context).textTheme.titleLarge)),
                            ],
                          ),
                          Text(AppString.interestedLineInfo, style: Theme.of(context).textTheme.bodySmall,),
                        ],
                      ),
                    ),
                    const Divider(),
                    InkWell(
                      onTap: enableNotification,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(3),
                        child: Row(
                          children: [
                            const Icon(Icons.notifications),
                            const Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Text(
                                    AppString.enableNotification,
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                    maxLines: 1,
                                  ),
                                )),
                            Checkbox(value: notificationEnable, onChanged: (newValue) => enableNotification())
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CustomFutureBuilder(
                    future: getLines,
                    onData: (context, data, refresh) {
                      return ListView.builder(
                        itemCount: data.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Container();
                          }

                          BusLine line = data[index - 1];
                          return LineItem(line, linesSelected.contains(line.id), linePressed);
                        },
                      );
                    }),
              ),
              // SizedBox(
              //   width: double.infinity,
              //   child: Wrap(
              //     alignment: WrapAlignment.spaceEvenly,
              //     children: [
              //       ElevatedButton(onPressed: cancel, child: const Text(AppString.cancelLabel)),
              //       ElevatedButton(onPressed: valid, child: const Text(AppString.validateLabel))
              //     ],
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}

class LineItem extends StatefulWidget {
  const LineItem(this.line, this.isChecked, this.callBack, {super.key});

  final BusLine line;
  final bool isChecked;
  final CheckCallBack callBack;

  @override
  State<LineItem> createState() => _LineItemState();
}

class _LineItemState extends State<LineItem> {
  late bool isChecked;

  @override
  void initState() {
    super.initState();
    isChecked = widget.isChecked;
  }

  void tap() {
    isChecked = !isChecked;
    widget.callBack(isChecked, widget.line);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: tap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            LineWidget(widget.line, 40),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                widget.line.name,
                softWrap: false,
                overflow: TextOverflow.fade,
                maxLines: 1,
              ),
            )),
            Checkbox(value: isChecked, onChanged: (newValue) => tap())
          ],
        ),
      ),
    );
  }
}
