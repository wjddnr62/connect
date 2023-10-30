import 'package:connect/models/stroke_coach.dart';

/**
 * 치료사가 배정되었을 때 받는 Advice
 */
class StrokeCoachAdvice {
  String content;
  StrokeCoach strokeCoach;

  StrokeCoachAdvice({this.content, this.strokeCoach});

  factory StrokeCoachAdvice.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return StrokeCoachAdvice();
    }
    return StrokeCoachAdvice(
      content: json['content'],
      strokeCoach: json['therapist'] != null
          ? StrokeCoach.fromJson(json['therapist'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['content'] = this.content;
    if (this.strokeCoach != null) {
      data['therapist'] = this.strokeCoach.toJson();
    }
    return data;
  }
}

/**
 * 치료사가 배정되지 않았을 때 내려오는 Advice
 */
class Advice {
  final String message;

  Advice({this.message});

  factory Advice.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return Advice();
    }
    return Advice(
      message: json['message'],
    );
  }
}
