import 'package:flutter/material.dart';

class SegmentedChoice {
  SegmentedChoice(this.text, this.icon);
  Icon? icon;
  String text;
}

class SegmentedChoices<T> extends StatefulWidget {
  const SegmentedChoices({
    required this.items,
    required this.onChange,
    required this.defaultValue,
    Key? key})
  : super(key: key);

  final Map<T,SegmentedChoice> items;
  final ValueChanged<T> onChange;
  final T defaultValue;

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

  void valueChange(T newValue) {
    (widget as SegmentedChoices<T>).onChange(newValue);
    setState(() {
      value = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
          ),
          const BoxShadow(
            color: Colors.white,
            spreadRadius: -3,
            blurRadius: 3

          )
        ],
        borderRadius: BorderRadius.circular(10)
      ),
      width: 300,
        child: Padding(
          padding: const EdgeInsets.all(8).copyWith(bottom: 0),
          child: Row(
            children: widget.items.entries.map((e) => 
              ChoiceWidget(e.value, e.key == value,
                () => valueChange(e.key)))
            .toList()
            ),
        )
      ),
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

class _ChoiceWidgetState extends State<ChoiceWidget>
  with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 200));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (widget.selected) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    super.didChangeDependencies();
  }

  @override
  bool get wantKeepAlive => true;


  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Expanded(
      child: InkWell(
        onTap: () => widget.onClick(),
        child: Column(
        mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.data.text,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(
              height: 10,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: widget.selected ? 10 : 0,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                      )
                    ),
                  )
              )
            ),
          ],
        ),
      ),
    );
  }
}
