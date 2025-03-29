import 'package:flutter/material.dart';

class HomeDrawerBtn extends StatelessWidget {
  const HomeDrawerBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Material(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(20),
        elevation: 2,
        child: InkWell(
          onTap: Scaffold.of(context).openDrawer,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.menu, size: 30,),
          ),
        ),
      ),
    );
  }
}
