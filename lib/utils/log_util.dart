import 'package:holdem/utils/env.dart';
import 'package:logger/logger.dart';

class Log {
  static final _log = Logger(
    filter: _LogFilter(),
    printer: PrettyPrinter(lineLength: 500),

    level: Level.debug
  );

  static void d(dynamic message) => _log.d(message);

  static void w(dynamic message) => _log.w(message);

  static void e(dynamic message) => _log.e(message);
}

class _LogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => !Env.isDistribute;
}
