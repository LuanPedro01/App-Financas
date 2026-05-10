import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  // ─── Formatting ───────────────────────────────────────────────────────────
  String get formatted => DateFormat('dd/MM/yyyy', 'pt_BR').format(this);
  String get formattedLong =>
      DateFormat('dd \'de\' MMMM \'de\' yyyy', 'pt_BR').format(this);
  String get formattedShort => DateFormat('dd/MM', 'pt_BR').format(this);
  String get formattedTime => DateFormat('HH:mm', 'pt_BR').format(this);
  String get formattedDateTime => DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(this);
  String get monthYear => DateFormat('MMMM yyyy', 'pt_BR').format(this);
  String get monthYearShort => DateFormat('MMM/yy', 'pt_BR').format(this);
  String get monthShort => DateFormat('MMM', 'pt_BR').format(this);
  String get monthFull => DateFormat('MMMM', 'pt_BR').format(this);
  String get weekDay => DateFormat('EEEE', 'pt_BR').format(this);
  String get weekDayShort => DateFormat('EEE', 'pt_BR').format(this);
  String get isoDate => DateFormat('yyyy-MM-dd').format(this);

  // ─── Comparison helpers ───────────────────────────────────────────────────
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  bool isSameMonth(DateTime other) =>
      year == other.year && month == other.month;

  bool isSameYear(DateTime other) => year == other.year;

  bool get isToday {
    final now = DateTime.now();
    return isSameDay(now);
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(yesterday);
  }

  bool get isThisMonth {
    final now = DateTime.now();
    return isSameMonth(now);
  }

  bool get isThisYear {
    final now = DateTime.now();
    return isSameYear(now);
  }

  bool get isFuture => isAfter(DateTime.now());
  bool get isPast => isBefore(DateTime.now());

  // ─── Navigation helpers ───────────────────────────────────────────────────
  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);
  DateTime get startOfMonth => DateTime(year, month, 1);
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59, 999);
  DateTime get startOfYear => DateTime(year, 1, 1);
  DateTime get endOfYear => DateTime(year, 12, 31, 23, 59, 59, 999);

  DateTime get nextMonth =>
      month == 12 ? DateTime(year + 1, 1) : DateTime(year, month + 1);
  DateTime get prevMonth =>
      month == 1 ? DateTime(year - 1, 12) : DateTime(year, month - 1);

  // ─── Relative display ─────────────────────────────────────────────────────
  String get relativeDisplay {
    if (isToday) return 'Hoje';
    if (isYesterday) return 'Ontem';
    if (isThisYear) return DateFormat('dd \'de\' MMMM', 'pt_BR').format(this);
    return formattedLong;
  }

  String get relativeShort {
    if (isToday) return 'Hoje';
    if (isYesterday) return 'Ontem';
    return formattedShort;
  }

  // ─── Duration helpers ─────────────────────────────────────────────────────
  int get daysUntil => difference(DateTime.now()).inDays.abs();
  int get daysAgo => DateTime.now().difference(this).inDays;
  int get monthsUntil {
    final now = DateTime.now();
    return (year - now.year) * 12 + (month - now.month);
  }

  bool isInRange(DateTime start, DateTime end) =>
      isAfter(start.subtract(const Duration(seconds: 1))) &&
      isBefore(end.add(const Duration(seconds: 1)));
}

extension NullableDateExtensions on DateTime? {
  String get formattedOrEmpty => this?.formatted ?? '-';
  bool get isNullOrPast => this == null || this!.isPast;
}
