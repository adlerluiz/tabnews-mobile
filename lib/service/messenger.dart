import 'package:flutter/material.dart';

class MessengerService {
  void show(dynamic context, {String text = '', int duration = 2}) {
    final SnackBar snackBar = SnackBar(
      content: Text(text),
      duration: Duration(seconds: duration),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void clear(dynamic context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}
