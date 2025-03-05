/// 一些常用格式参照。可以自定义格式，例如：'yyyy/MM/dd HH:mm:ss'，'yyyy/M/d HH:mm:ss'。
/// 格式要求
/// year -> yyyy/yy   month -> MM/M    day -> dd/d
/// hour -> HH/H      minute -> mm/m   second -> ss/s
class DateFormats {
  static String full = 'yyyy-MM-dd HH:mm:ss';
  static String y_mo_d_h_m = 'yyyy-MM-dd HH:mm';
  static String y_mo_d = 'yyyy-MM-dd';
  static String y_mo = 'yyyy-MM';
  static String mo_d = 'MM-dd';
  static String mo_d_h_m = 'MM-dd HH:mm';
  static String h_m_s = 'HH:mm:ss';
  static String h_m = 'HH:mm';

  static String zh_full = 'yyyy年MM月dd日 HH时mm分ss秒';
  static String zh_y_mo_d_h_m = 'yyyy年MM月dd日 HH时mm分';
  static String zh_y_mo_d = 'yyyy年MM月dd日';
  static String zh_y_mo = 'yyyy年MM月';
  static String zh_mo_d = 'MM月dd日';
  static String zh_mo_d_h_m = 'MM月dd日 HH时mm分';
  static String zh_h_m_s = 'HH时mm分ss秒';
  static String zh_h_m = 'HH时mm分';
}

/// month->days.
// ignore: non_constant_identifier_names
Map<int, int> MONTH_DAY = {
  1: 31,
  2: 28,
  3: 31,
  4: 30,
  5: 31,
  6: 30,
  7: 31,
  8: 31,
  9: 30,
  10: 31,
  11: 30,
  12: 31,
};

/// Date Util.
class DateUtil {
  /// get DateTime By DateStr.
  static DateTime getDateTime(String dateStr, {bool? isUtc}) {
    DateTime dateTime = DateTime.tryParse(dateStr)!;
    if (isUtc != null) {
      if (isUtc) {
        dateTime = dateTime.toUtc();
      } else {
        dateTime = dateTime.toLocal();
      }
    }
    return dateTime;
  }

  /// get DateTime By Milliseconds.
  static DateTime? getDateTimeByMs(int? ms, {bool isUtc = false}) {
    return ms == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: isUtc);
  }

  /// get DateMilliseconds By DateStr.
  static int? getDateMsByTimeStr(String dateStr, {bool? isUtc}) {
    final DateTime dateTime = getDateTime(dateStr, isUtc: isUtc);
    return dateTime.millisecondsSinceEpoch;
  }

  /// get Now Date Milliseconds.
  static int getNowDateMs() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  /// get Now Date Str.(yyyy-MM-dd HH:mm:ss)
  static String getNowDateStr() {
    return formatDate(DateTime.now());
  }

  static int getYesterDateMs() {
    return DateTime.now()
        .subtract(const Duration(days: 1))
        .millisecondsSinceEpoch;
  }

  /// format date by milliseconds.
  /// milliseconds 日期毫秒
  static String formatDateMs(int ms, {bool isUtc = false, String? format}) {
    return formatDate(getDateTimeByMs(ms, isUtc: isUtc), format: format!);
  }

  /// format date by date str.
  /// dateStr 日期字符串
  static String formatDateStr(String dateStr, {bool? isUtc, String? format}) {
    return formatDate(getDateTime(dateStr, isUtc: isUtc), format: format);
  }

  /// format date by DateTime.
  /// format 转换格式(已提供常用格式 DateFormats，可以自定义格式：'yyyy/MM/dd HH:mm:ss')
  /// 格式要求
  /// year -> yyyy/yy   month -> MM/M    day -> dd/d
  /// hour -> HH/H      minute -> mm/m   second -> ss/s
  static String formatDate(DateTime? dateTime, {String? format}) {
    if (dateTime == null) return '';
    format = format ?? DateFormats.full;
    if (format.contains('yy')) {
      final String year = dateTime.year.toString();
      if (format.contains('yyyy')) {
        format = format.replaceAll('yyyy', year);
      } else {
        format = format.replaceAll(
            'yy', year.substring(year.length - 2, year.length));
      }
    }

    format = _comFormat(dateTime.month, format, 'M', 'MM');
    format = _comFormat(dateTime.day, format, 'd', 'dd');
    format = _comFormat(dateTime.hour, format, 'H', 'HH');
    format = _comFormat(dateTime.minute, format, 'm', 'mm');
    format = _comFormat(dateTime.second, format, 's', 'ss');
    format = _comFormat(dateTime.millisecond, format, 'S', 'SSS');

    return format;
  }

  // AD: alias day
  // WW: week
  static String customFormatDate(dynamic? dateTime, String format) {
    if (dateTime == null) return '';

    late DateTime time;
    if (dateTime is DateTime) {
      time = dateTime;
    } else if (dateTime is int) {
      time = DateTime.fromMillisecondsSinceEpoch(dateTime);
    } else {
      return '';
    }

    if (format.contains('AD')) {
      String md = formatDay(time);
      format = format.replaceAll('AD', md);
    }

    if (format.contains('WW')) {
      String week = DateUtil.getWeekday(time);
      format = format.replaceAll('WW', week);
    }

    return formatDate(time, format: format);
  }

  static String formatDay(DateTime time) {
    String md = "";
    if (DateUtil.isToday(time)) {
      md = "今天";
    } else if (DateUtil.isYestday(time)) {
      md = "昨天";
    } else if (DateUtil.isTomorrow(time)) {
      md = "明天";
    }
    return md;
  }

  /// com format.
  static String _comFormat(
      int value, String format, String single, String full) {
    if (format.contains(single)) {
      if (format.contains(full)) {
        format =
            format.replaceAll(full, value < 10 ? '0$value' : value.toString());
      } else {
        format = format.replaceAll(single, value.toString());
      }
    }
    return format;
  }

  /// get WeekDay.
  /// dateTime
  /// isUtc
  /// languageCode zh or en
  /// short
  static String getWeekday(DateTime dateTime,
      {String languageCode = 'zh', bool short = false}) {
    String? weekday;
    switch (dateTime.weekday) {
      case 1:
        weekday = languageCode == 'zh' ? '星期一' : 'Monday';
        break;
      case 2:
        weekday = languageCode == 'zh' ? '星期二' : 'Tuesday';
        break;
      case 3:
        weekday = languageCode == 'zh' ? '星期三' : 'Wednesday';
        break;
      case 4:
        weekday = languageCode == 'zh' ? '星期四' : 'Thursday';
        break;
      case 5:
        weekday = languageCode == 'zh' ? '星期五' : 'Friday';
        break;
      case 6:
        weekday = languageCode == 'zh' ? '星期六' : 'Saturday';
        break;
      case 7:
        weekday = languageCode == 'zh' ? '星期日' : 'Sunday';
        break;
      default:
        break;
    }
    return languageCode == 'zh'
        ? (short ? weekday!.replaceAll('星期', '周') : weekday!)
        : weekday!.substring(0, short ? 3 : weekday.length);
  }

  /// get WeekDay By Milliseconds.
  static String getWeekdayByMs(int? milliseconds,
      {bool isUtc = false, String? languageCode, bool short = false}) {
    DateTime dateTime = getDateTimeByMs(milliseconds, isUtc: isUtc)!;
    return getWeekday(dateTime, languageCode: languageCode!, short: short);
  }

//格式化时间前缀 今天 明天 昨天
  static String formatDatePrefix(int date,
      {bool hasHM = true, bool hasWeek = false}) {
    if (date == null) {
      return "";
    }
    var time = DateTime.fromMillisecondsSinceEpoch(date);

    return formatDatePrefixByDateTime(time, hasHM: hasHM, hasWeek: hasWeek);
  }

  static String formatDatePrefixByDateTime(DateTime time,
      {bool hasHM = true, bool hasWeek = false}) {
    String pre = "";
    if (isToday(time)) {
      pre = "今天";
    } else if (isYestday(time)) {
      pre = "昨天";
    } else if (isTomorrow(time)) {
      pre = "明天";
    } else {
      pre = '';
    }

    final middle = formatDate(time, format: 'yyyy-MM-dd');

    return pre +
        (hasHM ? " " + middle : "") +
        (hasWeek ? " " + getWeekday(time, short: true) : "");
  }

  //格式化时间前缀 （xx分钟/小时前）/（今天/明天/昨天/(x月x日) xx:xx 星期x）
  static String formatDateAlias(int date,
      {bool hasBefore = true,
      bool hasMDText = false,
      bool onlyMDText = false,
      bool hasHM = false,
      bool hasWeek = false}) {
    if (date == null) {
      return "";
    }

    var time = DateTime.fromMillisecondsSinceEpoch(date);

    if (hasBefore) {
      var today = DateTime.now();

      Duration diff = today.difference(time);

      if (diff.compareTo(Duration.zero) >= 0) {
        if (diff.inMinutes <= 60 * 5) {
          return "${diff.inMinutes}分钟前";
        } else if (diff.inHours <= 24) {
          return "${diff.inHours}小时前";
        }
      }
    }

    String md = "";
    if (hasMDText) {
      if (isToday(time)) {
        md = "今天";
      } else if (isYestday(time)) {
        md = "昨天";
      } else if (isTomorrow(time)) {
        md = "明天";
      } else {
        md = !onlyMDText ? formatDate(time, format: 'M月dd日') : '';
      }
    } else {
      md = formatDate(time, format: 'M月dd日');
    }

    String hm = "";
    if (hasHM) {
      hm = " " + formatDate(time, format: 'HH:mm');
    }

    String week = "";
    if (hasWeek) {
      week = " " + getWeekday(time);
    }

    return md + hm + week;
  }

  //          1. 2分钟以内：显示“刚刚”
  //           2. 当天内，超过2分钟：显示时间（时分），例如：12:01
  //           3. 前一天消息：显示 “昨天 时间（时分）”，例如“昨天 12:01”
  //           4. 前2-7天，显示星期x+时间，例如：星期一 19:01
  //           5. 7天以前并且为本年度的，显示 日期+时间，例如：5月1日 10:01
  //           6. 本年度以前的数据，显示 年月日+时间，例如：2022年5月1日 10:01
  static String formatDateAlias2(int date) {
    if (date == null) {
      return "";
    }
    final time = DateTime.fromMillisecondsSinceEpoch(date);
    final today = DateTime.now();
    final diff = today.difference(time);
    final week = getWeekday(time);
    if (diff.inMinutes <= 5) {
      return "刚刚";
    } else if (isToday(time)) {
      return formatDate(time, format: 'HH:mm');
    } else if (isYestday(time)) {
      return "昨天 ${formatDate(time, format: 'H:mm')}";
    } else if (diff.inDays >= 2 && diff.inDays <= 7) {
      return '$week ${formatDate(time, format: 'H:mm')}';
    } else {
      final year = time.year == today.year ? '' : '${time.year}年';
      return '$year${formatDate(time, format: 'MM月dd日 HH:mm')}';
    }
  }

  //5分钟内：刚刚
//5分钟～1小时：1小时内
//1～24小时： x小时前
//大于24小时：xxxx-xx-xx xx:xx:xx

  static String formatDateAlias3(int date) {
    if (date == null || date == 0) return "";

    final now = DateTime.now();
    final target = DateTime.fromMillisecondsSinceEpoch(date);
    final difference = now.difference(target);

    if (difference.inMinutes <= 5) {
      return "刚刚";
    } else if (difference.inMinutes <= 60) {
      // 5~60分钟
      return "1小时内";
    } else if (difference.inHours <= 24) {
      // 1~24小时
      return "${difference.inHours}小时前";
    } else {
      // 超过24小时
      return formatDateMs(date, format: DateFormats.full);
    }
  }

  //今天
  static bool isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  /// get day of year.
  /// 在今年的第几天.
  static int getDayOfYear(DateTime dateTime) {
    int year = dateTime.year;
    int month = dateTime.month;
    int days = dateTime.day;
    for (int i = 1; i < month; i++) {
      days = days + MONTH_DAY[i]!.toInt();
    }
    if (isLeapYearByYear(year) && month > 2) {
      days = days + 1;
    }
    return days;
  }

  /// get day of year.
  /// 在今年的第几天.
  static int getDayOfYearByMs(int ms, {bool isUtc = false}) {
    return getDayOfYear(DateTime.fromMillisecondsSinceEpoch(ms, isUtc: isUtc));
  }

  //是否明天
  static bool isTomorrow(DateTime date) {
    var today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        (date.day - today.day == 1);
  }

  //是否昨天
  static bool isYestday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        (date.day - today.day == -1);
  }

  /// is today.
  /// 是否是当天.
  static bool isTodayNow(int milliseconds, {bool isUtc = false, int? locMs}) {
    if (milliseconds == null || milliseconds == 0) return false;
    DateTime old =
        DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: isUtc);
    DateTime now;
    if (locMs != null) {
      now = DateUtil.getDateTimeByMs(locMs)!;
    } else {
      now = isUtc ? DateTime.now().toUtc() : DateTime.now().toLocal();
    }
    return old.year == now.year && old.month == now.month && old.day == now.day;
  }

  /// is yesterday by dateTime.
  /// 是否是昨天.
  static bool isYesterday(DateTime dateTime, DateTime locDateTime) {
    if (yearIsEqual(dateTime, locDateTime)) {
      int spDay = getDayOfYear(locDateTime) - getDayOfYear(dateTime);
      return spDay == 1;
    } else {
      return (locDateTime.year - dateTime.year == 1) &&
          dateTime.month == 12 &&
          locDateTime.month == 1 &&
          dateTime.day == 31 &&
          locDateTime.day == 1;
    }
  }

  /// is yesterday by millis.
  /// 是否是昨天.
  static bool isYesterdayByMs(int ms, int locMs) {
    return isYesterday(DateTime.fromMillisecondsSinceEpoch(ms),
        DateTime.fromMillisecondsSinceEpoch(locMs));
  }

  static bool isBeforeYestday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        (date.day - today.day == -2);
  }

  static bool isThisYear(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year;
  }

  static bool isCompareDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  /// is Week.
  /// 是否是本周.
  static bool isWeek(int ms, {bool isUtc = false, int? locMs}) {
    if (ms == null || ms <= 0) {
      return false;
    }
    DateTime _old = DateTime.fromMillisecondsSinceEpoch(ms, isUtc: isUtc);
    DateTime _now;
    if (locMs != null) {
      _now = DateUtil.getDateTimeByMs(locMs, isUtc: isUtc)!;
    } else {
      _now = isUtc ? DateTime.now().toUtc() : DateTime.now().toLocal();
    }

    DateTime old =
        _now.millisecondsSinceEpoch > _old.millisecondsSinceEpoch ? _old : _now;
    DateTime now =
        _now.millisecondsSinceEpoch > _old.millisecondsSinceEpoch ? _now : _old;
    return (now.weekday >= old.weekday) &&
        (now.millisecondsSinceEpoch - old.millisecondsSinceEpoch <=
            7 * 24 * 60 * 60 * 1000);
  }

  //是否同天
  static bool dayIsEqual(DateTime dateTime, DateTime locDateTime) {
    return dateTime.day == locDateTime.day;
  }

  static bool dayIsEqualByMs(int ms, int locMs) {
    return dayIsEqual(DateTime.fromMillisecondsSinceEpoch(ms),
        DateTime.fromMillisecondsSinceEpoch(locMs));
  }

  /// year is equal.
  /// 是否同年.
  static bool yearIsEqual(DateTime dateTime, DateTime locDateTime) {
    return dateTime.year == locDateTime.year;
  }

  /// year is equal.
  /// 是否同年.
  static bool yearIsEqualByMs(int ms, int locMs) {
    return yearIsEqual(DateTime.fromMillisecondsSinceEpoch(ms),
        DateTime.fromMillisecondsSinceEpoch(locMs));
  }

  //是否同月
  static bool monthIsEqualByMs(int ms, int locMs) {
    return monthIsEqual(DateTime.fromMillisecondsSinceEpoch(ms),
        DateTime.fromMillisecondsSinceEpoch(locMs));
  }

  static bool monthIsEqual(DateTime dateTime, DateTime locDateTime) {
    return dateTime.month == locDateTime.month;
  }

  /// Return whether it is leap year.
  /// 是否是闰年
  static bool isLeapYear(DateTime dateTime) {
    return isLeapYearByYear(dateTime.year);
  }

  /// Return whether it is leap year.
  /// 是否是闰年
  static bool isLeapYearByYear(int year) {
    return year % 4 == 0 && year % 100 != 0 || year % 400 == 0;
  }
}
