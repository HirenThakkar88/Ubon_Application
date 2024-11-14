import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomLoader {
  static Future<void> showLoaderForTask({
    required BuildContext context,
    required Future<void> Function() task,
  }) async {
    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    // Execute the task
    try {
      await task();
    } finally {
      // Remove the loading overlay
      Navigator.of(context).pop();
    }
  }
}