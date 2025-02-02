import 'package:flutter/material.dart';

class CustomTitleBar extends StatelessWidget {
  const CustomTitleBar(
      {required this.title, this.leftChild, this.rightChild, super.key});

  final String title;
  final Widget? leftChild;
  final Widget? rightChild;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 20,
      color: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                leftChild ?? Container(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const Spacer(),
                rightChild ?? Container(),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 5,
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}
