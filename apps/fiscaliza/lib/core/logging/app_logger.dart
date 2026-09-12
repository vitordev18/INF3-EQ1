import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static const String _tag = 'FISCALIZA';

  static void info(String message) => _write('INFO', message);

  static void warn(String message) => _write('WARN', message);

  static void error(String message, [Object? error, StackTrace? stack]) {
    _write('ERRO', message);
    if (error != null) _write('ERRO', '  causa: $error');
    if (stack != null && kDebugMode) debugPrintStack(stackTrace: stack);
  }

  static void _write(String level, String message) {
    if (!kDebugMode) return;
    debugPrint('[$_tag][$level] $message');
  }
}
