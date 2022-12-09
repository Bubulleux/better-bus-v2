import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/data_provider/local_data_handler.dart';
import 'package:better_bus_v2/data_provider/vitalis_data_provider.dart';
import 'package:better_bus_v2/model/clean/bus_line.dart';
import 'package:better_bus_v2/views/common/custom_future.dart';
import 'package:better_bus_v2/views/common/line_widget.dart';
import 'package:flutter/material.dart';

typedef CheckCallBack = void Function(bool checked, BusLine line);

class InterestLinePage extends StatefulWidget {
  const InterestLinePage({Key? key}) : super(key: key);
  static const String routeName = "/interestedLines";

  @override
  State<InterestLinePage> createState() => _InterestLinePageState();
}

class _InterestLinePageState extends State<InterestLinePage> {
  Set<String> linesSelected = {};

  Future<List<BusLine>> getLines() async {
    linesSelected = await LocalDataHandler.loadInterestedLine();
    List<BusLine> busLines = (await VitalisDataProvider.getAllLines()).values.toList();
    busLines.sort();
    return busLines;
  }

  void cancel() {
    // BusLine.compare("12", "12e");
    Navigator.pop(context);
  }

  void valid() {
    LocalDataHandler.saveInterestedLines(linesSelected);
    Navigator.pop(context);
  }

  void linePressed(bool checked, BusLine line) {
    if (checked) {
      linesSelected.add(line.id);
    } else {
      linesSelected.remove(line.id);
    }
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(AppString.selectLine, style: Theme.of(context).textTheme.headlineSmall),
              ),
              Expanded(
                child: CustomFutureBuilder(future: getLines, onData: (context, data, refresh) {
                  return ListView.separated(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      BusLine line = data[index];
                      return LineItem(line, linesSelected.contains(line.id), linePressed);
                    },
                    separatorBuilder: (context, index) {
                      return const Divider();
                    },
                  );
                }),
              ),
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(onPressed: cancel, child: const Text(AppString.cancelLabel)),
                    ElevatedButton(onPressed: valid, child: const Text(AppString.validateLabel))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class LineItem extends StatefulWidget {
  const LineItem(this.line, this.isChecked, this.callBack, {Key? key}) : super(key: key);
  
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
                  child: Text(widget.line.fullName, softWrap: false, overflow: TextOverflow.fade, maxLines: 1,),
                )
            ),
            Checkbox(value: isChecked, onChanged: (newValue) => tap())
          ],
        ),
      ),
    );
  }
}

