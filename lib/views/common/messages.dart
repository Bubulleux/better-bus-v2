import 'package:better_bus_v2/app_constant/app_string.dart';
import 'package:better_bus_v2/views/common/back_arrow.dart';
import 'package:better_bus_v2/views/common/title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

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
                              child: RichText(
                                  text: message.body,
                                  textAlign: TextAlign.justify),
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
  const Message(this.title, this.body);
  final String title;
  final TextSpan body;
}

List<TextSpan> importantMessageText = const [
  TextSpan(
    text: "Bienvenue sur Better Bus et merci d’avoir téléchargé "
        "l’application.\n\n",
    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
  ),
  TextSpan(
      text: "Tout d’abord, voici une présentation rapide :\n"
          "Better Bus est une application mobile qui a été créée dans "
          "le but d’offrir une alternative à l’application Vitalis "
          "(entreprise de transport par bus à Poitiers).\n\n"
          "Voici les choses à savoir avant d’utiliser Better Bus :\n"
          "Pour commencer, Better Bus n’est pas Vitalis mais repose cependant "
          "sur leur service. Les Conditions Générales de Vente et d’Utilisation "
          "du réseau Vitalis sont en application à partir du moment où vous "
          "utiliser leur réseau de transport en commun. Comme dit que dans "
          "les mentions légales de Vitalis, l’exactitude du contenu de "
          "l’application n’est pas garantie. Ni Vitalis ni Better Bus "
          "ne peuvent être tenus responsables en ce qui concerne les dommages "
          "directs ou indirects, prévisibles ou imprévisibles, matériels ou "
          "immatériels découlant de l’utilisation ou de l’impossibilité "
          "partielle ou totale d’utilisation de l’application Better Bus.\n"
          "Pour plus d’information, veuillez consulter les mentions légales "
          "ou le site web de Vitalis.\n\n"
          "Il est également important de préciser "
          "que Better Bus repose sur le site web de Vitalis. En cas de mauvais "
          "fonctionnement de celui-ci ou de changement de son fonctionnement, "
          "Better Bus peut se retrouver plus ou moins impacté et peut devenir "
          "inutilisable du jour au lendemain.  Pour toute question, problème "
          "avec l’application ou suggestion vous pouvez me contacter à "
          "l’adresse mail better.bus.poitiers@gmail.com ou sur le compte "
          "Instagram de l’application {insérer le compt instagrame}.\n\n"),
  TextSpan(
    text: "Si vous avez lu jusque ici, je vous remercie et vous souhaite une "
        "bonne utilisation de Better Bus.\n\n"
        "Bubulle, le développeur de Better Bus",
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
];

class Messages {
  static final importantMessage = Message(
      "Message imporant",
      TextSpan(
        children: importantMessageText,
        style: const TextStyle(color: Colors.black),
      ));

  static final toVitalis = Message(
      "Message important", TextSpan(text: "Message pour Vitalis\n" * 100));
}
