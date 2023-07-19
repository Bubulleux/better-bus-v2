import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/views/common/back_arrow.dart';
import 'package:better_bus_v2/views/common/title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher_string.dart';

class MessageView extends StatefulWidget {
  const MessageView({Key? key}) : super(key: key);
  static const routeName = "/messageView";

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> {
  late Message message;
  String body = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    message = ModalRoute.of(context)!.settings.arguments as Message;
    rootBundle
        .loadString("assets/messages/" + message.fileName)
        .then((value) => setState(() => body = value))
        .onError((error, stackTrace) => print(error));
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
                              child: HtmlWidget(
                                body,
                                onTapUrl: (url) => launchUrlString(
                                  url,
                                  mode: LaunchMode.externalApplication,
                                ),
                              ),
                            ))),
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
  const Message(this.title, this.fileName);
  final String title;
  final String fileName;
}

DateTime lastStartUpMessageUpdate = DateTime(2022, 07, 19);

class Messages {
  static final importantMessage = Message("Message imporant", "important.html");

  static final toVitalis = Message("Message pour Vitalis", "vitalis.html");
}
