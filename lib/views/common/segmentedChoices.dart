import 'package:better_bus_v2/views/common/extendable_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class SegmentedChoice {
  SegmentedChoice(this.text, this.icon);
  Icon? icon;
  String text;
}

class SegmentedChoices<T> extends StatefulWidget {
  SegmentedChoices({
    required this.items,
    required this.onChange,
    required this.defaultValue,
    Key? key})
  : super(key: key);

  Map<T,SegmentedChoice> items;
  ValueChanged<T> onChange;
  T defaultValue;

  @override
  State<SegmentedChoices> createState() => _SegmentedChoicesState<T>();
}

class _SegmentedChoicesState<T> extends State<SegmentedChoices> {

  late T value;

  @override
    void didChangeDependencies() {
      super.didChangeDependencies();
      setState(() {
        value = widget.defaultValue;
      });
    }

  @override
  Widget build(BuildContext context) {
    return Container(
    width: 300,
      child: Row(
        children: widget.items.entries.map((e) => 
          ChoiceWidget(e.value, e.key == value,
            () => setState((){ value = e.key;})))
        .toList()
        )
    );
  }
}

class ChoiceWidget extends StatefulWidget {
  const ChoiceWidget(this.data, this.selected, this.onClick, {Key? key}) : super(key: key);

  final SegmentedChoice data;
  final bool selected;
  final Function onClick;

  @override
  State<ChoiceWidget> createState() => _ChoiceWidgetState();
}

class _ChoiceWidgetState extends State<ChoiceWidget> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () => widget.onClick(),
        child: Container(
          height: 50,
          color: Colors.red,
          child: Column(
          mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.data.text,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Container(
                width: 40,
                height: 10,
                decoration: BoxDecoration(
                  color: widget.selected ? Theme.of(context).primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5)
                  )
                ),
                  // borderRadius: BorderRadius.circular(0)
              )
            ],
          )
        ),
      ),
    );
  }
}
