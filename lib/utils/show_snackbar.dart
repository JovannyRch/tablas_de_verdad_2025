import 'package:flutter/material.dart';

void showSnackBarMessage(BuildContext context, String msg) {
  SnackBar snackBar = new SnackBar(content: new Text(msg));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
