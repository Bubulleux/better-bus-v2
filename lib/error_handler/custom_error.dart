import 'package:better_bus_v2/app_constant/app_string.dart';
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
            child: const Text(AppString.retry),
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
    "Aucun bus n'est prévu pour le moment.",
    Icons.bus_alert,
    false,
  );

  static final emptyPassage = CustomError(
    "Aucun bus n'est prévu ce jour là.",
    Icons.bus_alert,
    false,
  );

  static final noInternet = CustomError(
    "Aucune connexion internet n'a été trouvée veuillez allumer votre WI-FI ou vos données mobiles.",
    Icons.signal_wifi_connected_no_internet_4,
    true,
  );

  static final searchError = CustomError(
    "Aucun arrêt de bus n'a été trouvé faites une nouvelle recherche.",
    Icons.search_off,
    false,
  );

  static final searchPlaceNoResult = CustomError(
    "Aucune adresse n'a été trouvée veuillez ré-essayer.",
    Icons.location_off,
    false,
  );

  static final routeInputError = CustomError(
    "Les informations renseignées ne sont pas complétes.",
    Icons.search_off,
    false,
  );

  static final routeResultEmpty = CustomError(
    "Aucun itinéraire n'a été trouvé.",
    Icons.search_off,
    false,
  );
}

