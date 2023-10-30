import 'package:connect/models/stroke_coach.dart';
import 'package:equatable/equatable.dart';

class Schedule extends Equatable {
  String id;
  String division;
  String state;
  DateTime start;
  DateTime end;
  DateTime created;
  String title;
  String description;
  String link;
  StrokeCoach strokeCoach;
  bool cancelAvailability;

  @override
  List<Object> get props => [id];

  Schedule(
      {this.division,
      this.end,
      this.id,
      this.start,
      this.state,
      this.strokeCoach,
      this.title,
      this.link,
      this.created,
      this.description,
      this.cancelAvailability});

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
        id: json['id'],
        division: json['division'],
        start: DateTime.parse(json['start']).toLocal(),
        end: DateTime.parse(json['end']).toLocal(),
        state: json['state'] != null ? json['state'] : null,
        strokeCoach: json['therapist'] != null
            ? StrokeCoach.fromJson(json['therapist'])
            : null,
        title: json['title'],
        link: json['link'] != null ? json['link'] : null,
        created: json['created'] != null
            ? DateTime.parse(json['created']).toLocal()
            : null,
        description: json['description'] != null ? json['description'] : null,
        cancelAvailability: json['cancel_availability']);
  }
}

class RequestSchedule {
  String endDate;
  String endTime;
  String startDate;
  String startTime;
  int zoneOffset;

  RequestSchedule({
    this.endDate,
    this.endTime,
    this.startDate,
    this.startTime,
    this.zoneOffset,
  });

  factory RequestSchedule.fromJson(Map<String, dynamic> json) {
    return RequestSchedule(
      endDate: json['end_date'],
      endTime: json['end_time'],
      startDate: json['start_date'],
      startTime: json['start_time'],
      zoneOffset: json['zone_offset'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['end_date'] = this.endDate;
    data['end_time'] = this.endTime;
    data['start_date'] = this.startDate;
    data['start_time'] = this.startTime;
    data['zone_offset'] = this.zoneOffset;
    return data;
  }
}

class VideoCallSession {
  String apiKey;
  String sessionId;
  String token;

  VideoCallSession({this.apiKey, this.sessionId, this.token});

  factory VideoCallSession.fromJson(Map<String, dynamic> json) {
    return VideoCallSession(
      apiKey: json['api_key'],
      sessionId: json['session_id'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['api_key'] = this.apiKey;
    data['session_id'] = this.sessionId;
    data['token'] = this.token;
    return data;
  }
}

class TimeSlot {
  bool available;
  String endTime;
  String startTime;

  TimeSlot({this.available, this.endTime, this.startTime});

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      available: json['abailable_yn'],
      endTime: json['end_time'],
      startTime: json['start_time'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['abailable_yn'] = this.available;
    data['end_time'] = this.endTime;
    data['start_time'] = this.startTime;
    return data;
  }
}

class Event {
  bool allDay;
  String end;
  String id;
  String start;
  String title;

  Event({this.allDay, this.end, this.id, this.start, this.title});

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      allDay: json['allDay'],
      end: json['end'],
      id: json['id'],
      start: json['start'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['allDay'] = this.allDay;
    data['end'] = this.end;
    data['id'] = this.id;
    data['start'] = this.start;
    data['title'] = this.title;
    return data;
  }
}
