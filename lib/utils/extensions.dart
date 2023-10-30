import 'dart:collection';

import 'package:connect/models/push_notification.dart';
import 'package:flutter_sendbird_plugin/flutter_sendbird_plugin.dart';
import 'package:intl/intl.dart';

import 'calendar_utils.dart';

extension DateTimeExtension on DateTime {
  String toMonthDayCommaYear() {
    return DateFormat("MMM dd, yyyy").format(this);
  }

  String toMonthCommaYear() {
    return DateFormat("MMM, yyyy").format(this);
  }

  String get isoYYYYMMDD => this.toIso8601String().substring(0, 10);

  DateTime get weekStart => this.add(Duration(days: 1 - this.weekday));

  DateTime get weekEnd => this.add(Duration(days: 7 - this.weekday));

  String get isoHHMM => this.toIso8601String().substring(11, 16);

  String get mmddyyyy => '${monthString(this.month)} ${this.day}, ${this.year}';

  String get mmyyyy => '${monthString(this.month)}, ${this.year}';

  String get yyyymm => '${DateFormat("yyyy-MM").format(this)}';

  DateTime get tomorrow {
    DateTime tom = this.add(Duration(days: 1));

    /// summer time
    while (this.day == tom.day) {
      tom = tom.add(Duration(hours: 1));
    }

    return DateTime(tom.year, tom.month, tom.day);
  }

  DateTime get yesterday {
    DateTime yes = this.subtract(Duration(days: 1));

    /// summer time
    while (this.day == yes.day) {
      yes = yes.subtract(Duration(days: 1));
    }

    return DateTime(yes.year, yes.month, yes.day);
  }
}

extension StringExtension on String {
  String nullToEmpty() {
    return this == null ? "" : this;
  }

  DateTime toDateTime() {
    try {
      return DateTime.parse(this);
    } catch (Exception) {}
    return null;
  }

  String capitalizeFirstLetter() {
    return this[0].toUpperCase() + this.substring(1);
  }
}

extension SendBirdMessageExtension on SendBirdMessage {
  PushNotification toPushNotification(){
    HashMap<String, dynamic> map = HashMap();
    map['title'] = this.senderNickname;
    map['contents'] = this.message;
    return PushNotification(json: map, type: NotificationType.sendbird_messasing);
  }
}
