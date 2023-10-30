String get dayOfTheWeek {
  return weekDayString(DateTime.now().weekday);
}

String get month {
  return monthString(DateTime.now().month);
}

String weekDayString(final int dayWeek) {
  if (dayWeek > 7 || dayWeek < 1) {
    throw Exception('input a number between 1 and 7');
  }

  String month;
  switch (dayWeek) {
    case DateTime.monday:
      month = 'Mon';
      break;
    case DateTime.tuesday:
      month = 'Tue';
      break;
    case DateTime.wednesday:
      month = 'Wed';
      break;
    case DateTime.thursday:
      month = 'Thu';
      break;
    case DateTime.friday:
      month = 'Fri';
      break;
    case DateTime.saturday:
      month = 'Sat';
      break;
    case DateTime.sunday:
      month = 'Sun';
      break;
  }

  return month;
}

String monthString(final int mon) {
  if (mon > 12 || mon < 1) {
    throw Exception('input a number between 1 and 12, month is $mon');
  }
  String month;
  switch (mon) {
    case DateTime.january:
      month = 'January';
      break;
    case DateTime.february:
      month = 'February';
      break;
    case DateTime.march:
      month = 'March';
      break;
    case DateTime.april:
      month = 'April';
      break;
    case DateTime.may:
      month = 'May';
      break;
    case DateTime.june:
      month = 'June';
      break;
    case DateTime.july:
      month = 'July';
      break;
    case DateTime.august:
      month = 'August';
      break;
    case DateTime.september:
      month = 'September';
      break;
    case DateTime.october:
      month = 'October';
      break;
    case DateTime.november:
      month = 'November';
      break;
    case DateTime.december:
      month = 'December';
      break;
  }

  return month;
}

List<DateTime> get thisWeek {
  return weekDateTimes(DateTime.now());
}

List<DateTime> weekDateTimes(DateTime dateTime) {
  List<DateTime> ret = [];
  var initDay = dateTime.subtract(Duration(days: dateTime.weekday % 7));

  for (int i = 0; i < 7; i++) {
    ret.add(initDay.add(Duration(days: i)));
  }

  return ret;
}

List<DateTime> prevWeek({DateTime dateTime}) {
  dateTime ??= DateTime.now();
  List<DateTime> ret = weekDateTimes(dateTime.subtract(Duration(days: 7)));
  return ret;
}

List<DateTime> lastWeek({int ago}) {
  return weekDateTimes(DateTime.now().subtract(Duration(days: 7 * ago)));
}

List<DateTime> nextWeek({DateTime dateTime}) {
  dateTime ??= DateTime.now();
  List<DateTime> ret = weekDateTimes(dateTime.add(Duration(days: 7)));
  return ret;
}

int get todayWeek {
  return DateTime.now().weekday % 7;
}

bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

bool isToday(DateTime date) {
  return isSameDay(DateTime.now(), date);
}
