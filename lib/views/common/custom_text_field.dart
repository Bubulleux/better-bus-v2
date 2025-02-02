import 'package:better_bus_v2/views/common/custom_input_widget.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    this.label,
    this.hint,
    this.controller,
    this.autofocus,
    super.key
  });

  final String? label;
  final String? hint;
  final bool? autofocus;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return CustomInputWidget(
      child: TextField(
        controller: controller,
        autofocus: autofocus ?? false,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
