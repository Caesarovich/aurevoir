import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// A singleton class that provides a logger instance for the application.
class AppLogger {
  AppLogger._();

  static final LogPrinter _basePrinter = PrettyPrinter(
    methodCount: 0,
    printEmojis: false,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  );

  static const Level _level = kDebugMode ? Level.debug : Level.error;

  static final Logger _logger = Logger(
    printer: _basePrinter,
    level: _level,
  );

  /// Returns the shared logger. If [tag] is provided, returns a logger
  /// that prefixes every line with the tag (e.g. "\[MyTag\] ...").
  static Logger get([String? tag]) {
    if (tag == null || tag.isEmpty) return _logger;
    return Logger(printer: _TagPrinter(tag, _basePrinter), level: _level);
  }
}

/// A small printer that delegates to another printer and prefixes each
/// output line with the provided tag.
class _TagPrinter extends LogPrinter {
  _TagPrinter(this._tag, this._delegate);

  final String _tag;
  final LogPrinter _delegate;

  @override
  List<String> log(LogEvent event) {
    final lines = _delegate.log(event);
    return lines.map((l) => '[$_tag] $l').toList();
  }
}

/// Returns a logger instance for the given [tag]. If no tag is provided,
Logger getLogger([String? tag]) => AppLogger.get(tag);
