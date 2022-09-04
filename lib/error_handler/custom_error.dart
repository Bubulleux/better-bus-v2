import 'package:flutter/material.dart';

class CustomError extends Error{
  CustomError(this.content, this.icon, this.canBeRetry);


  final String content;
  final IconData? icon;
  final bool canBeRetry;

  Widget build(BuildContext context, VoidCallback? retry){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon ?? Icons.error, size: 40,),
        Text(content, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center,),
        if (retry != null && canBeRetry)
          ElevatedButton(
            onPressed: retry,
            child: const Text("! Re-esaiyer"),
          )
        else
          Container()
      ],
    );
  }

  @override
  String toString() {
    return content;
  }
}

class CustomException extends CustomError{
  CustomException(this.exception): super(exception.toString(), null, true);

  final Exception exception;
}

extension ToError on Exception{
  CustomException toError() {
    return CustomException(this);
  }
}


class CustomErrors{
  static final emptyNextPassage = CustomError(
    "! Aucun Bus n'est prevue pour le moment",
    Icons.bus_alert,
    false,
  );

  static final emptyPassage = CustomError(
    "! Aucun Bus n'est prevue ce jours la",
    Icons.bus_alert,
    false,
  );

  static final noInternet = CustomError(
    "! Aucun connection internet n'a été trouver veuillez allumier votre wifi ou vos donnée mobil",
    Icons.signal_wifi_connected_no_internet_4,
    true,
  );

  static final searchError = CustomError(
    "! Aucun n'arret de bus n'a été trouver revoyer votre recherche",
    Icons.search_off,
    false,
  );

  static final searchPlaceNoResult = CustomError(
    "! Aucun location n'a été trouvez veuillez réessier",
    Icons.location_off,
    false,
  );

  static final routeInputError = CustomError(
    "! Les information rensigné ne sont pas compléte",
    Icons.search_off,
    false,
  );

  static final routeResultEmpty = CustomError(
    "! Aucun n'itinéraire a été trouver",
    Icons.search_off,
    false,
  );
}

