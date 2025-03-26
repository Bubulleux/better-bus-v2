import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/views/common/separator.dart';
import 'package:flutter/material.dart';

import '../common/line_widget.dart';

class LinesFilter extends StatefulWidget {
  const LinesFilter({
    required this.station,
    required this.provider,
    super.key});

  final Station station;
  final NetworkProvider provider;

  @override
  State<LinesFilter> createState() => _LinesFilterState();
}

class _LinesFilterState extends State<LinesFilter> {

  List<BusLine>? passingLines;

  @override
  void initState() {
    super.initState();
    getLines();
  }
  void getLines() {
    widget.provider.getPassingLines(widget.station).then((v) {
      if (mounted) {
        setState(() {
          passingLines = v;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (passingLines == null) {
      return CircularProgressIndicator();
    }
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: passingLines!
          .map((e) => LineWidget(e, 25, dynamicWidth: true,))
          .toList(),
    );
  }
}
