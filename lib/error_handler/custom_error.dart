import 'package:flutter/material.dart';

class CustomError extends Error{
  CustomError(this.content, this.icon, this.canBeRetry);


  final String content;
  final IconData? icon;
  final bool canBeRetry;

  Widget build(BuildContext context, VoidCallback? retry){
    return Center(
      child: Column(
        children: [
          Icon(icon ?? Icons.error),
          Text(content),
          if (retry != null && canBeRetry)
            ElevatedButton(
              onPressed: retry,
              child: Text("! Re-esaiyer"),
            )
          else
            Container()
        ],
      ),
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


class CustomExceptions{
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
}