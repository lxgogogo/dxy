import 'package:holdem/utils/env.dart';
import 'package:logger/logger.dart';

class Log {
  static final _log = Logger(
    filter: _LogFilter(),
      printer: LongPrettyPrinter(
        methodCount: 2, // Number of method calls to be displayed
        errorMethodCount: 8, // Number of method calls if stacktrace is provided
        lineLength: 120, // Width of the output
        colors: true, // Colorful log messages
        printEmojis: false,
        printTime : true,
        noBoxingByDefault : true,
      ),
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

///自定义支持长文本log的打印器
class LongPrettyPrinter extends PrettyPrinter {
  final int warpLen; //控制换行个数

  @override
  LongPrettyPrinter({
    this.warpLen = 1000,
    stackTraceBeginIndex = 0,
    methodCount = 2,
    errorMethodCount = 8,
    lineLength = 120,
    colors = false,
    printEmojis = true,
    printTime = false,
    noBoxingByDefault = false,
  }) : super(
    stackTraceBeginIndex: stackTraceBeginIndex,
    methodCount: methodCount,
    errorMethodCount: errorMethodCount,
    lineLength: lineLength,
    colors: colors,
    printEmojis: printEmojis,
    printTime: printTime,
    noBoxingByDefault: noBoxingByDefault,
  );

  @override
  String stringifyMessage(message) {
    var msg = super.stringifyMessage(message);
    var i = 0;
    var len = warpLen;
    var newStr = "";
    while (msg.length > i + len) {
      var next = i + len;
      var last = msg.indexOf("\n", i);
      if (last < i + 1 || last > next) {
        newStr += msg.substring(i, next) + "\n";
        i = next;
      } else {
        newStr += msg.substring(i, last);
        i = last;
      }
    }
    if (i + len > msg.length) {
      newStr += msg.substring(i);
    }
    return newStr;
  }
}