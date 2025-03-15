import 'package:flutter/material.dart';

class CloseCross extends StatelessWidget {
  const CloseCross({required this.onTap, this.size = 30, super.key});

  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color(0xffcecece),
            borderRadius: BorderRadius.circular(size)
          ),
          child: const Center(child: Icon(Icons.close)),
        ),
      ),
    );
  }
}
