import 'package:connect/utils/date_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Test DateFormat', () {
    test('Test monthString', () {
      String actual = DateFormat.monthString(1);
      String expected = 'January';
      expect(actual, expected);

      actual = DateFormat.monthString(2);
      expected = 'February';
      expect(actual, expected);

      actual = DateFormat.monthString(3);
      expected = 'March';
      expect(actual, expected);

      actual = DateFormat.monthString(4);
      expected = 'April';
      expect(actual, expected);

      actual = DateFormat.monthString(5);
      expected = 'May';
      expect(actual, expected);

      actual = DateFormat.monthString(6);
      expected = 'June';
      expect(actual, expected);

      actual = DateFormat.monthString(7);
      expected = 'July';
      expect(actual, expected);

      actual = DateFormat.monthString(8);
      expected = 'August';
      expect(actual, expected);

      actual = DateFormat.monthString(9);
      expected = 'September';
      expect(actual, expected);

      actual = DateFormat.monthString(10);
      expected = 'October';
      expect(actual, expected);

      actual = DateFormat.monthString(11);
      expected = 'November';
      expect(actual, expected);

      actual = DateFormat.monthString(12);
      expected = 'December';
      expect(actual, expected);

      try {
        DateFormat.monthString(0);
        expect(true, false);
      } catch (e) {
        expect(true, true);
      }

      try {
        DateFormat.monthString(13);
        expect(true, false);
      } catch (e) {
        expect(true, true);
      }
    });

    test('Test formatDate(String, DateTime)', () {
      DateTime dateTime = DateTime(1980, 04, 29);
      final String expected = 'April 29, 1980';
      String actual = DateFormat.formatDate('mmddyyyy', dateTime);

      expect(actual, expected);

      try {
        DateFormat.formatDate('ammddyyyy', dateTime);
        expect(true, false);
      } catch (e) {
        expect(true, true);
      }
    });

    test('Test minToHour(int)', () {
      String expected = '01';
      String actual = DateFormat.minToHour(60);
      expect(actual, expected);

      actual = DateFormat.minToHour(119);
      expect(actual, expected);

      actual = DateFormat.minToHour(600);
      expected = '10';
      expect(actual, expected);

      actual = DateFormat.minToHour(6000);
      expected = '100';
      expect(actual, expected);

      actual = DateFormat.minToHour(59);
      expected = '00';
      expect(actual, expected);
    });

    test('Test minToMin(int)', () {
      String expected = '00';
      String actual = DateFormat.minToMin(60);
      expect(actual, expected);

      actual = DateFormat.minToMin(61);
      expected = '01';
      expect(actual, expected);

      actual = DateFormat.minToMin(00);
      expected = '00';
      expect(actual, expected);

      actual = DateFormat.minToMin(30);
      expected = '30';
      expect(actual, expected);

      actual = DateFormat.minToMin(1);
      expected = '01';
      expect(actual, expected);
    });

    test('Test notificationString(DateTime)', () {
      DateTime now = DateTime.now();
      DateTime dateTime = now.subtract(Duration(seconds: 60));

      String expected = '1 minute ago';
      String actual = DateFormat.notificationString(dateTime);
      expect(actual, expected);

      dateTime = now.subtract(Duration(seconds: 120));
      expected = '2 minutes ago';
      actual = DateFormat.notificationString(dateTime);
      expect(actual, expected);

      dateTime = now.subtract(Duration(minutes: 59));
      expected = '59 minutes ago';
      actual = DateFormat.notificationString(dateTime);
      expect(actual, expected);

      dateTime = now.subtract(Duration(hours: 3));
      expected = DateFormat.formatIntl("MMMM dd, yyyy hh:mm a", dateTime);
      actual = DateFormat.notificationString(dateTime);
      expect(actual, expected);

      dateTime = now.add(Duration(hours: 3));
      expected = DateFormat.formatIntl("MMMM dd, yyyy hh:mm a", dateTime);
      try {
        actual = DateFormat.notificationString(dateTime);
        expect(true, false);
      } catch (e) {
        expect(true, true);
      }
    });
  });
}
