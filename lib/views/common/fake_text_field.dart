import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:flutter/material.dart';

class FakeTextField extends StatelessWidget {
  const FakeTextField({
    Key? key,
    this.value,
    this.hint,
    this.icon,
    this.prefixIcon,
    this.backgroundColor,
    required this.onPress,

  }) : super(key: key);

  final String? value;
  final String? hint;
  final IconData? icon;
  final Icon? prefixIcon;
  final VoidCallback onPress;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: CustomDecorations.borderRadius,
      color: backgroundColor ?? Colors.white,
      child: InkWell(
        onTap: onPress,
        borderRadius: CustomDecorations.borderRadius,
        child: Container(
          height: 60,
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              prefixIcon ?? Container(),
              Expanded(
                child: Text(
                  value ?? hint ?? "",
                  style: value != null ?
                  Theme.of(context).textTheme.headline6:
                  Theme.of(context).inputDecorationTheme.hintStyle,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                ),
              ),
              icon != null ?
              Row(
                children: [
                  const VerticalDivider(),
                  Icon(icon, color: Theme.of(context).primaryColor,),
                ],
              ) :
              Container(),
            ],
          ),
          decoration: CustomDecorations.of(context).boxOutlined.copyWith(
            color: backgroundColor,
          ),
        ),
      ),
    );
  }
}
