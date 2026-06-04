import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

void showAppToast(String msg) {
  showToast(
    msg,
    duration: const Duration(seconds: 2),
    position: ToastPosition.center,
    backgroundColor: Colors.black87,
    radius: 8,
    textPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    textStyle: const TextStyle(fontSize: 15, color: Colors.white),
  );
}
