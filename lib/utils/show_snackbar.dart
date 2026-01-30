import 'package:flutter/material.dart';

void showSnackBarMessage(BuildContext context, String msg) {
  SnackBar snackBar = SnackBar(content: Text(msg));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
