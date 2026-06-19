import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  // Converts a true moment in time to Colombia wall-clock time (represented as a UTC DateTime)
  static DateTime toColombiaTime(DateTime date) {
    return date.toUtc().subtract(const Duration(hours: 5));
  }

  // Returns the current wall-clock time in Colombia
  static DateTime nowColombia() {
    return DateTime.now().toUtc().subtract(const Duration(hours: 5));
  }

  // Formats a true moment in time to 12-hour format in Colombia time
  static String formatTime(DateTime matchDate) {
    return DateFormat('hh:mm a').format(toColombiaTime(matchDate));
  }

  // Formats a true moment in time to a short date
  static String formatDate(DateTime matchDate) {
    return DateFormat('dd MMM yyyy').format(toColombiaTime(matchDate)).toUpperCase();
  }

  // Formats a wall-clock date (like selectedDate) to short day
  static String formatShortDay(DateTime wallClockDate) {
    return DateFormat('EEE', 'es').format(wallClockDate).toUpperCase();
  }

  // Formats a wall-clock date to day number
  static String formatDayNumber(DateTime wallClockDate) {
    return DateFormat('dd').format(wallClockDate);
  }

  // Checks if a true moment in time (matchDate) falls on the same calendar day as a wall-clock date (selectedDate)
  static bool isMatchOnSelectedDate(DateTime matchDate, DateTime selectedDate) {
    final colMatch = toColombiaTime(matchDate);
    return colMatch.year == selectedDate.year &&
        colMatch.month == selectedDate.month &&
        colMatch.day == selectedDate.day;
  }

  // Checks if a wall-clock date is today in Colombia
  static bool isToday(DateTime wallClockDate) {
    final today = nowColombia();
    return wallClockDate.year == today.year &&
        wallClockDate.month == today.month &&
        wallClockDate.day == today.day;
  }

  // Checks if a wall-clock date is tomorrow in Colombia
  static bool isTomorrow(DateTime wallClockDate) {
    final tomorrow = nowColombia().add(const Duration(days: 1));
    return wallClockDate.year == tomorrow.year &&
        wallClockDate.month == tomorrow.month &&
        wallClockDate.day == tomorrow.day;
  }
}
