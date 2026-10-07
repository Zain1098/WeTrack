import 'package:intl/intl.dart';

/// Helper functions for deterministic, date-only manipulation
class DateHelpers {
  /// Strips hours, minutes, seconds, and milliseconds
  static DateTime toDateOnly(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  /// Calculates inclusive difference in days between two date-only values
  static int daysBetween(DateTime from, DateTime to) {
    final d1 = toDateOnly(from);
    final d2 = toDateOnly(to);
    return d2.difference(d1).inDays;
  }

  /// Returns YYYY-MM-DD ISO string
  static String formatIso(DateTime dt) {
    return DateFormat('yyyy-MM-dd').format(dt);
  }

  /// Parses YYYY-MM-DD ISO string to date-only DateTime
  static DateTime parseIso(String iso) {
    final parts = iso.split('-').map(int.parse).toList();
    return DateTime(parts[0], parts[1], parts[2]);
  }

  /// Formats date nicely: 'Sep 28, 2026'
  static String formatFriendly(DateTime dt) {
    return DateFormat('MMM d, yyyy').format(dt);
  }

  /// Formats date with day name: 'Mon, Sep 28'
  static String formatDayAndMonth(DateTime dt) {
    return DateFormat('EEE, MMM d').format(dt);
  }

  /// Formats month & year: 'October 2026'
  static String formatMonthYear(DateTime dt) {
    return DateFormat('MMMM yyyy').format(dt);
  }

  /// Safely adds calendar days without DST duration drift
  static DateTime addDays(DateTime dt, int days) {
    return DateTime(dt.year, dt.month, dt.day + days);
  }

  /// Safely subtracts calendar days without DST duration drift
  static DateTime subtractDays(DateTime dt, int days) {
    return DateTime(dt.year, dt.month, dt.day - days);
  }
}
