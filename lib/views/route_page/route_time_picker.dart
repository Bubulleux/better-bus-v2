import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/views/common/segmented_choices.dart';
import 'package:better_bus_v2/views/common/wheel_scroll_selector.dart';
import 'package:better_bus_v2/views/route_page/route_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:better_bus_v2/helper.dart';

class RouteTimePicker extends StatefulWidget {
  const RouteTimePicker(this.parameter, {super.key});

  final RouteTimeParameter parameter;

  @override
  State<RouteTimePicker> createState() => _RouteTimePickerState();
}

class _RouteTimePickerState extends State<RouteTimePicker> {
  
  late RouteTimeType timeType;
  late DateTime time;
  List<String> dates = [AppString.today, AppString.tomorrow] +
    List.generate(12, (index) => DateFormat("EE d MMMM", "fr").format(
          DateTime.now().atMidnight().add(Duration(days: index + 2))));
  late int selectedDate;

  @override
  void initState() {
    super.initState();
    timeType = widget.parameter.timeType;
    time = widget.parameter.time;
    
  }

  void dateChange(int index) {
    DateTime newDate = DateTime.now().add(Duration(days: index));
    time = time.copyWith(day: newDate.day, month: newDate.month, year: newDate.year);
  }

  void hoursChange(int index) {
    time = time.copyWith(hour: index);
  }

  void minutesChange(int index) {
    time = time.copyWith(minute: index);
  }

  void submit() {
    Navigator.of(context).pop(RouteTimeParameter(timeType, time));
  }

  @override
  Widget build(BuildContext context) {
      return Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedChoices<RouteTimeType>(
              items: {
                  RouteTimeType.departure: SegmentedChoice(AppString.departureAt, null),
                  RouteTimeType.arrival: SegmentedChoice(AppString.arrivalAt, null),
                },
              onChange: (newValue) => timeType = newValue,
              defaultValue: timeType,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: SizedBox(
                height: 150,
                child: WheelScrollSelector(dates, dateChange, 
                  time.difference(DateTime.now().atMidnight()).inDays),
              ),
            ),
            Container(
              height: 150,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    child: WheelScrollSelector(
                      List.generate(24, (i) => NumberFormat("00").format(i)),
                      hoursChange, time.hour
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(":", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  SizedBox(
                    width: 80,
                    child: WheelScrollSelector(
                      List.generate(60, (i) => NumberFormat("00").format(i)),
                      minutesChange, time.minute
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: submit, child: const Text(AppString.validateLabel))
          ],
        ),
      );
  }
}
