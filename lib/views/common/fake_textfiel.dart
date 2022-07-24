import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:flutter/material.dart';

class FakeTextField extends StatelessWidget {
  const FakeTextField({
    Key? key,
    this.value,
    this.hint,
    this.icon,
    this.prefixIcon,
    required this.onPress,

  }) : super(key: key);

  final String? value;
  final String? hint;
  final IconData? icon;
  final IconData? prefixIcon;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      borderRadius: CustomDecorations.borderRadius,
      splashColor: Colors.black,
      child: Container(
        height: 60,
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            prefixIcon != null ?
                Icon(prefixIcon):
                Container(),
            Expanded(
              child: Text(
                value ?? hint ?? "",
                style: Theme.of(context).textTheme.headline6,
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
        decoration: CustomDecorations.of(context).boxOutlined,
      ),
    );
  }
}
