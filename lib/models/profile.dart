import 'package:connect/models/clinic.dart';
import 'package:connect/models/stroke_coach.dart';
import 'package:connect/utils/logger/log.dart';

class ProfileType {
  static const String PATIENT = "PATIENT";
  static const String CAREGIVER = "CAREGIVER";
  static const String THERAPIST = "THERAPIST";
}

class Profile {
  DateTime birthday;
  String email;
  String gender;
  int id;
  String name;
  String statusMessage;
  DateTime onsetDate;
  String password;
  String phoneNo;
  List<String> roles;
  int severityLevel;
  List<bool> infectedSide;
  List<dynamic> strokeSide;
  StrokeCoach strokeCoach;
  String token;
  String type;
  int zoneOffset;
  String image;
  String usStateCode;
  String diagnosticName;
  String dominantHand;
  ClinicStatus clinicStatus;
  Subscription subscription;
  DateTime createdDate;
  bool isNewHomeUser;
  String profileImageName;
  Therapist therapist;
  List<EvaluationGraph> evaluationGraph;

  Profile(
      {this.birthday,
      this.email,
      this.gender,
      this.id,
      this.name,
      this.statusMessage,
      this.onsetDate,
      this.password,
      this.phoneNo,
      this.roles,
      this.severityLevel,
      this.infectedSide,
      this.strokeSide,
      this.strokeCoach,
      this.token,
      this.type,
      this.zoneOffset,
      this.image,
      this.usStateCode,
      this.diagnosticName,
      this.dominantHand,
      this.clinicStatus,
      this.subscription,
      this.createdDate,
      this.isNewHomeUser,
      this.profileImageName,
      this.therapist,
      this.evaluationGraph});

  factory Profile.fromJson(Map<String, dynamic> json) {
    var ret;
    try {
      List<dynamic> strokeSide = json['stroke_side'];
      List<bool> infectedSide = [false, false];

      if (strokeSide != null) {
        for (String side in strokeSide) {
          if (side == 'LEFT') {
            infectedSide[0] = true;
          }
          if (side == 'RIGHT') {
            infectedSide[1] = true;
            break;
          }
        }
      }

      String birthdayString = json['birthday'] as String;
      DateTime birthday = DateTime(1970, 1, 1);
      try {
        birthday = DateTime.parse(birthdayString);
      } catch (Exception) {}
      String onsetDateString = json['onset_date'] as String;
      DateTime onsetDate = DateTime(1970, 1, 1);
      try {
        onsetDate = DateTime.parse(onsetDateString);
      } catch (Exception) {}

      String createdDateString = json['createdDate'] as String;
      DateTime createdDate = DateTime(1980, 1, 1);
      try {
        createdDate = DateTime.parse(createdDateString);
      } catch (Exception) {}

      ret = Profile(
          birthday: birthday,
          email: json['email'],
          gender: json['gender'],
          id: json['id'],
          name: json['name'],
          statusMessage: json['status_message'],
          onsetDate: onsetDate,
          password: json['password'],
          phoneNo: json['phoneNo'],
          roles: json['roles'] != null
              ? new List<String>.from(json['roles'])
              : null,
          severityLevel: json['severity_level'],
          strokeSide: json["stroke_side"],
          infectedSide: infectedSide,
          strokeCoach: json['therapist'] != null
              ? StrokeCoach.fromJson(json['therapist'])
              : null,
          token: json['token'],
          type: json['type'],
          zoneOffset: json['zone_offset'],
          image: json['image'],
          usStateCode: json['us_state_code'],
          diagnosticName: json['diagnostic_name'],
          dominantHand: json['dominant_hand'],
          clinicStatus: ClinicStatus.fromJson(json['clinic']),
          subscription: json['subscription'] != null
              ? Subscription.fromJson(json['subscription'])
              : null,
          createdDate: createdDate,
          isNewHomeUser: json['is_new_home_user'],
          profileImageName: json['profileImageName'],
          therapist: json['therapist'] != null
              ? Therapist.fromJson(json['therapist'])
              : null,
          evaluationGraph: json['evaluation'] != null
              ? (json['evaluation'] as List)
                  .map((e) => EvaluationGraph.fromJson(e))
                  .toList()
              : null);
    } catch (e) {
      Log.d('Profile', '$e');
    }
    return ret;
  }

  Map<String, dynamic> toJson() {
    List<String> strokeSide = [];

    if (infectedSide[0]) {
      strokeSide.add('LEFT');
    }
    if (infectedSide[1]) {
      strokeSide.add('RIGHT');
    }

    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.birthday != null)
      data['birthday'] = this.birthday.toIso8601String();
    if (this.email != null) data['email'] = this.email;
    if (this.gender != null) data['gender'] = this.gender;
    if (this.id != null) data['id'] = this.id;
    if (this.name != null) data['name'] = this.name;
    if (this.onsetDate != null)
      data['onset_date'] = this.onsetDate.toIso8601String();
    if (this.password != null) data['password'] = this.password;
    if (this.phoneNo != null) data['phoneNo'] = this.phoneNo;
    if (this.severityLevel != null) data['severity_level'] = this.severityLevel;
    if (this.infectedSide != null) data['stroke_side'] = strokeSide;
    if (this.token != null) data['token'] = this.token;
    if (this.type != null) data['type'] = this.type;
    if (this.zoneOffset != null) data['zone_offset'] = this.zoneOffset;
    if (this.roles != null) data['roles'] = this.roles;
    if (this.strokeCoach != null) data['therapist'] = this.strokeCoach.toJson();

    if (this.usStateCode != null) data['us_state_code'] = this.usStateCode;
    if (this.diagnosticName != null)
      data['diagnostic_name'] = this.diagnosticName;
    if (this.dominantHand != null) data['dominant_hand'] = this.dominantHand;

    if (this.clinicStatus != null) data['clinic'] = this.clinicStatus.toJson();
    if (this.subscription != null)
      data['subscription'] = this.subscription.toJson();
    if (this.isNewHomeUser != null)
      data['is_new_home_user'] = this.isNewHomeUser;
    return data;
  }
}

class Subscription {
  final DateTime startDate;
  final String marketPlace;
  final DateTime expireDate;
  final String planName;
  final int daysJoined;
  final int daysLeft;

  Subscription(
      {this.startDate,
      this.marketPlace,
      this.expireDate,
      this.planName,
      this.daysJoined,
      this.daysLeft});

  factory Subscription.fromJson(Map<String, dynamic> json) {
    String startDateString = json['startDate'] as String;
    DateTime startDate = DateTime(1970, 1, 1);
    try {
      startDate = DateTime.parse(startDateString);
    } catch (Exception) {}
    String expireDateString = json['expireDate'] as String;
    DateTime expireDate = DateTime(1970, 1, 1);
    try {
      expireDate = DateTime.parse(expireDateString);
    } catch (Exception) {}
    String planName = json['planName'] as String;
    int daysJoined = json['daysJoined'] as int;
    int daysLeft = json['daysLeft'] as int;
    return Subscription(
        startDate: startDate,
        marketPlace: json['marketPlace'],
        expireDate: expireDate,
        planName: planName,
        daysJoined: daysJoined,
        daysLeft: daysLeft);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.startDate != null)
      data['startDate'] = this.startDate.toIso8601String();
    data['marketPlace'] = this.marketPlace;
    if (this.expireDate != null)
      data['expireDate'] = this.expireDate.toIso8601String();
    if (this.planName != null) data['planName'] = this.planName;
    return data;
  }
}

class Therapist {
  final int id;
  final String name;
  final String image;

  Therapist({this.id, this.name, this.image});

  factory Therapist.fromJson(Map<String, dynamic> json) {
    return Therapist(id: json['id'], name: json['name'], image: json['image']);
  }
}

class EvaluationGraph {
  final String type;
  final List<String> chartLabels;
  final List<ChartValues> chartValues;

  EvaluationGraph({this.type, this.chartLabels, this.chartValues});

  factory EvaluationGraph.fromJson(Map<String, dynamic> json) {
    return EvaluationGraph(
        type: json['type'],
        chartLabels: json['chartLabels'] != null
            ? List<String>.from(json['chartLabels'])
            : null,
        chartValues: json['chartValues'] != null
            ? (json['chartValues'] as List)
                .map((e) => ChartValues.fromJson(e))
                .toList()
            : null);
  }
}

class ChartValues {
  final String x;
  final double y;

  ChartValues({this.x, this.y});

  factory ChartValues.fromJson(Map<String, dynamic> json) {
    return ChartValues(x: json['x'], y: json['y']);
  }
}
