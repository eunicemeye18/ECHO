import 'dart:convert';
import 'dart:typed_data';

import 'package:echo_work/widgets/custom_circle_progress_indicator.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum ScaffoldMessengerStatus { sucess, error, alert }

class Utils {
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: CustomCircleProgressIndicator(color: Colors.white),
          ),
        );
      },
    );
  }

  static Future<String?> convertPhotoToBase64(String url) async {
    try {
      final dio = Dio();
      final response = await dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
        ), // Obtenir les données brutes
      );

      if (response.statusCode == 200 && response.data != null) {
        // Convertir les données binaires en Base64
        Uint8List bytes = Uint8List.fromList(response.data!);
        return base64Encode(bytes);
      } else {
        return null; // Retourner null si la requête échoue
      }
    } catch (e) {
      debugPrint("Erreur lors de la conversion de la photo en Base64 : $e");
      return null;
    }
  }

  static BoxDecoration decorationWithShadow({
    Color? color,
    BorderRadiusGeometry? borderRadius,
  }) {
    return BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          spreadRadius: 2,
          blurRadius: 5,
        ),
      ],
      color: color ?? Colors.white,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
    );
  }

  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  static void customScaffoldMessenger(
    BuildContext context,
    ScaffoldMessengerStatus scaffoldMessengerStatus,
    String message,
  ) {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _buildContent(scaffoldMessengerStatus, message, context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        padding: EdgeInsets.zero,
      ),
    );
  }

  static Widget _buildContent(
    ScaffoldMessengerStatus status,
    String message,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: _getGradient(status),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getBaseColor(status).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icône animée
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getIcon(status), color: Colors.white, size: 16),
          ),
          const SizedBox(width: 16),

          // Message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: Theme.of(
                    context,
                  ).textTheme.displayMedium!.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static LinearGradient _getGradient(ScaffoldMessengerStatus status) {
    switch (status) {
      case ScaffoldMessengerStatus.sucess:
        return const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ScaffoldMessengerStatus.error:
        return const LinearGradient(
          colors: [Color(0xFFE57373), Color(0xFFD32F2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ScaffoldMessengerStatus.alert:
        return const LinearGradient(
          colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  static Color _getBaseColor(ScaffoldMessengerStatus status) {
    switch (status) {
      case ScaffoldMessengerStatus.sucess:
        return const Color(0xFF4CAF50);
      case ScaffoldMessengerStatus.error:
        return const Color(0xFFE57373);
      case ScaffoldMessengerStatus.alert:
        return const Color(0xFFFFB74D);
    }
  }

  static IconData _getIcon(ScaffoldMessengerStatus status) {
    switch (status) {
      case ScaffoldMessengerStatus.sucess:
        return Icons.check_circle_outline;
      case ScaffoldMessengerStatus.error:
        return Icons.error_outline;
      case ScaffoldMessengerStatus.alert:
        return Icons.warning_amber_outlined;
    }
  }

  static String formatDateToReadableShort(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);

      String formatted = DateFormat(
        "EEE d MMM yyyy",
        "fr_FR",
      ).format(parsedDate);

      // Première lettre en majuscule
      return formatted[0].toUpperCase() + formatted.substring(1);
    } catch (e) {
      return date;
    }
  }
}
