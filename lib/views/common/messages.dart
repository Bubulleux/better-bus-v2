import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/views/common/back_arrow.dart';
import 'package:better_bus_v2/views/common/title_bar.dart';
import 'package:flutter/material.dart';

class MessageView extends StatefulWidget {
  const MessageView({Key? key}) : super(key: key);
  static const routeName = "/messageView";

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> {
  late Message message;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    message = ModalRoute.of(context)!.settings.arguments as Message;
  }

  void close() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomTitleBar(
              title: message.title,
              leftChild: const BackArrow(),
            ),
            Expanded(
              child: ClipRect(
                clipBehavior: Clip.hardEdge,
                child: Column(
                  children: [
                    Expanded(
                        child: SingleChildScrollView(
                            clipBehavior: Clip.none,
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 20),
                                width: double.infinity,
                                child: Text(message.body)))),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton(
                          onPressed: close, child: const Text(AppString.close)),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Message {
  const Message(this.title, this.body);
  final String title;
  final String body;
}

class Messages {
  static final importantMessage =
      Message("Message important", "Message important\n" * 100);
      
  static final toVitalis =
      Message("Message important", "Message pour Vitalis\n" * 100);
}
