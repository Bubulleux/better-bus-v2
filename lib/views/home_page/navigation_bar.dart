import 'package:flutter/material.dart';

class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({super.key, required this.child});

  final List<CustomNavigationItem> child;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5,
      child: Wrap(
        children: [
          Container(
            height: 5,
            width: double.infinity,
            color: Theme.of(context).primaryColor,
          ),
          Container(
            width: double.infinity,
            color: Colors.white,
            child: Wrap(
              children: child,
              alignment: WrapAlignment.spaceAround,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomNavigationItem extends StatelessWidget {
  const CustomNavigationItem({
    super.key,
    required this.label,
    required this.icon,
    required this.onPress,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPress,
        child: SizedBox(
          height: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon),
              Text(label, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ),
      ),
    );
  }
}
