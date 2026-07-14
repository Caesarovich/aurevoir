import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'dart:io' as io;

class AppLogger {
  AppLogger._();

  static final _instance = AppLogger._();

  static Logger get([String? tag]) {
    return Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: false,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: kDebugMode ? Level.debug : Level.error,
    );
  }
}

Logger getLogger([String? tag]) => AppLogger.get(tag);
