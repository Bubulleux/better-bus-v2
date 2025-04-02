import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:flutter/material.dart';

class FakeTextField extends StatelessWidget {
  const FakeTextField({
    super.key,
    this.value,
    this.hint,
    this.icon,
    this.prefixIcon,
    this.prefixIconColor,
    this.backgroundColor,
    this.small = false,
    required this.onPress,

  });

  final String? value;
  final String? hint;
  final IconData? icon;
  final Icon? prefixIcon;
  final Color? prefixIconColor;
  final VoidCallback onPress;
  final Color? backgroundColor;
  final bool small;

  @override
  Widget build(BuildContext context) {
   var finalStyle =  value != null ?
   Theme.of(context).textTheme.titleLarge:
   Theme.of(context).inputDecorationTheme.hintStyle;


    return SizedBox(
      child: Material(
        elevation: 2,
        borderRadius: CustomDecorations.borderRadius,
        color: backgroundColor ?? Colors.white,
        child: InkWell(
          onTap: onPress,
          borderRadius: CustomDecorations.borderRadius,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: CustomDecorations.of(context).boxOutlined.copyWith(
              color: backgroundColor,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (prefixIcon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: FittedBox(child: prefixIcon!)
                ) else Container(),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value ?? hint ?? "",
                      style: finalStyle,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ),
                icon != null ?
                Row(
                  children: [
                    const VerticalDivider(),
                    FittedBox(child: Icon(icon, color: Theme.of(context).primaryColor)),
                  ],
                ) :
                Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
