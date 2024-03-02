import 'package:flutter/material.dart';

class WheelScrollSelector extends StatefulWidget {
  const WheelScrollSelector(this.content, this.onChange, this.defaultValue,
    {Key? key}) : super(key: key);

  final List<String> content;
  final ValueChanged<int> onChange;
  final int defaultValue;
  @override
  State<WheelScrollSelector> createState() => _WheelScrollSelectorState();
}

class _WheelScrollSelectorState extends State<WheelScrollSelector> {
  
  late FixedExtentScrollController scrollControler;
  late int currentItem;

  @override
    void initState() {
      super.initState();
      scrollControler = FixedExtentScrollController(initialItem: widget.defaultValue);
      currentItem = widget.defaultValue;
    }

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView(
      itemExtent: 50,
      controller: scrollControler,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: (value) => setState(() {
          currentItem = value;
          widget.onChange(value);
      }),
      children: widget.content.indexed.map((e) => 
        Padding(
          padding: const EdgeInsets.all(5),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.center,
            child: Text(e.$2),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              border: Border.all(
                width: 2,
                color: currentItem == e.$1 ? Theme.of(context).primaryColor:
                  Colors.transparent,
              ),
              boxShadow: const [
                BoxShadow(
                  spreadRadius: 1,
                  blurRadius: 3,
                  color: Colors.black26
                )
              ]
            ),                        
          ),
        )
      ).toList(),
    );
  }
}
