import 'package:flutter/material.dart';

class CustomContextMenu extends StatefulWidget {
  const CustomContextMenu({required this.actions, super.key});

  final List<ContextMenuAction> actions;

  static Future<void> show(
      BuildContext context, List<ContextMenuAction> actions) async {
    showModalBottomSheet(context: context, builder: (context) {
      return CustomContextMenu(actions: actions);
    });
    return ;
  }

  @override
  State<CustomContextMenu> createState() => _CustomContextMenuState();
}

class _CustomContextMenuState extends State<CustomContextMenu> {


  void actionPressed(VoidCallback callback) {
    Navigator.pop(context);
    callback();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
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
                  e.icon != null ?
                  Icon(
                    e.icon,
                    size: 30,
                  ) : Container(),
                  Expanded(
                    //width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text(e.actionName,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.normal,
                            )),
                      ),
                    ),
                  )
                ],
              ),
              style: TextButton.styleFrom(
                  foregroundColor: e.isDangerous
                      ? const Color(0xffff0000)
                      : Colors.black, shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3)),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10),
                  tapTargetSize:
                  MaterialTapTargetSize.shrinkWrap),
            );
          },
        ),
      ),
    );
  }
}

class ContextMenuAction {
  ContextMenuAction(this.actionName, this.icon,
      {required this.action, this.isDangerous = false});

  String actionName;
  IconData? icon;
  VoidCallback action;
  bool isDangerous;
}
