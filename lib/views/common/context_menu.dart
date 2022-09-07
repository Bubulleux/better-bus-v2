import 'dart:ui';

import 'package:flutter/material.dart';

class CustomContextMenu extends StatefulWidget {
  const CustomContextMenu({required this.actions, Key? key}) : super(key: key);

  final List<ContextMenuAction> actions;

  static Future<void> show(
      BuildContext context, List<ContextMenuAction> actions) async {
    await Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          CustomContextMenu(actions: actions),
      opaque: false,
      transitionDuration: const Duration(milliseconds: 300),
    ));
  }

  @override
  State<CustomContextMenu> createState() => _CustomContextMenuState();
}

class _CustomContextMenuState extends State<CustomContextMenu> {
  Animation<double>? controller;
  Animation<Color?>? backgroundAnimation;
  Animation<Offset?>? menuAnimation;
  Animation<double>? blurAnimation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (controller == null) {
      controller = ModalRoute.of(context)!.animation;
      backgroundAnimation = ColorTween(
        begin: Colors.transparent,
        end: const Color.fromRGBO(0, 0, 0, 180),
      ).animate(controller!);

      menuAnimation = Tween(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(
          CurvedAnimation(parent: controller!, curve: Curves.easeOutBack)
      );
      
      blurAnimation = Tween(
        begin: 0.0,
        end: 2.0,
      ).animate(
        CurvedAnimation(parent: controller!, curve: Curves.easeOut),
      );
    }
  }

  void actionPressed(VoidCallback callback) {
    Navigator.pop(context);
    callback();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller!,
      builder: (context, child) => Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: GestureDetector(
            onTap: () => {Navigator.pop(context)},
            child: Container(
              height: double.infinity,
              width: double.infinity,
              color: backgroundAnimation!.value,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FractionalTranslation(
                  translation: menuAnimation!.value!,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).backgroundColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          separatorBuilder: (context, index) =>
                              const Divider(color: Colors.black),
                          itemCount: widget.actions.length,
                          itemBuilder: (context, index) {
                            ContextMenuAction e = widget.actions[index];
                            return TextButton(
                              onPressed: () => actionPressed(e.action),
                              child: Row(
                                children: [
                                  Icon(
                                    e.icon,
                                    size: 30,
                                  ),
                                  Text(e.actionName,
                                      style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.normal,
                                      ))
                                ],
                              ),
                              style: TextButton.styleFrom(
                                  primary: e.isDangerous
                                      ? const Color(0xffff0000)
                                      : Colors.black,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3)),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 10),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ContextMenuAction {
  ContextMenuAction(this.actionName, this.icon,
      {required this.action, this.isDangerous = false});

  String actionName;
  IconData icon;
  VoidCallback action;
  bool isDangerous;
}
