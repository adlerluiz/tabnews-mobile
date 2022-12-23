import 'package:flutter/material.dart';

class MessengerService {
  void show(context, {String text = '', int duration = 2}) {
    SnackBar snackBar = SnackBar(
      content: Text(text),
      duration: Duration(seconds: duration),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void clear(context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}
