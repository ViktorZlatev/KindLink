import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

void showTopMessage(BuildContext context, String message,
    {Color background = const Color(0xFF6C63FF)}) {
  Flushbar(
    message: message,
    duration: const Duration(seconds: 3),
    flushbarPosition: FlushbarPosition.TOP,
    margin: const EdgeInsets.all(12),
    borderRadius: BorderRadius.circular(12),
    backgroundColor: background,
    animationDuration: const Duration(milliseconds: 500),
    forwardAnimationCurve: Curves.easeOutBack,
    reverseAnimationCurve: Curves.easeIn,
    messageSize: 16,
  ).show(context);
}
