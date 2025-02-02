import 'package:flutter/material.dart';

class BackArrow extends StatelessWidget {
  const BackArrow({this.onPress, super.key});

  final Function? onPress;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.symmetric(horizontal: 5,),
      autofocus: false,
      iconSize: 30,
      constraints: const BoxConstraints(),
      icon: const Icon(Icons.chevron_left),
      onPressed: onPress != null ?  onPress!() : Navigator.of(context).pop,
    );
  }
}
