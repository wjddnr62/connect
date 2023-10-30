import 'package:connect/resources/app_resources.dart';
import 'package:intl/intl.dart' as intl;

class DateFormat {
  static String formatDate(final String format, DateTime time) {
    String month;
    if (format == 'mmddyyyy') {
      month = monthString(time.month);

      return month + ' ${time.day}, ${time.year}';
    }

    throw Exception('support on mmddyyyy format');
  }

  static String formatDiaryDate(final String format, DateTime time) {
    return intl.DateFormat(format).format(time);
  }

  /// skip test code
  static String formatIntl(final String format, DateTime time) {
    return intl.DateFormat(format).format(time);
  }

  static String minToHour(int min) {
    if (min == null) {
      min = 0;
    }

    int hour = (min ~/ 60);

    return (hour < 10) ? '0$hour' : '$hour';
  }

  static String minToMin(int min) {
    int minInt = 0;

    minInt = (min == null) ? 0 : (min % 60);

    return (minInt < 10) ? '0$minInt' : '$minInt';
  }

  static String monthString(final int m) {
    if (m > 12 || m < 1) {
      throw Exception('input a number between 1 and 12');
    }
    String month;
    switch (m) {
      case 1:
        month = 'January';
        break;
      case 2:
        month = 'February';
        break;
      case 3:
        month = 'March';
        break;
      case 4:
        month = 'April';
        break;
      case 5:
        month = 'May';
        break;
      case 6:
        month = 'June';
        break;
      case 7:
        month = 'July';
        break;
      case 8:
        month = 'August';
        break;
      case 9:
        month = 'September';
        break;
      case 10:
        month = 'October';
        break;
      case 11:
        month = 'November';
        break;
      case 12:
        month = 'December';
        break;
    }

    return month;
  }

  static String notificationString(final DateTime date) {
    final DateTime now = DateTime.now();

    if (date.isAfter(now)) {
      throw Exception('cannot handle days after now');
    }

    final duration = now.millisecondsSinceEpoch - date.millisecondsSinceEpoch;

    final int min = duration ~/ (60 * 1000);

    if (min < 1) {
      return AppStrings.of(StringKey.few_seconds_ago);
    }

    if (min == 1) {
      return '$min ${AppStrings.of(StringKey.minute_ago)}';
    }

    if (min < 60) {
      return '$min ${AppStrings.of(StringKey.minutes_ago)}';
    }

    return DateFormat.formatIntl("MMMM dd, yyyy hh:mm a", date);
  }
}
