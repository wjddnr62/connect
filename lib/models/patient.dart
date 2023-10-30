import 'package:connect/utils/extensions.dart';

class Patient {
  final int id;
  final String name;
  final String gender;
  final int age;
  final DateTime birthday;
  final String mobile;
  final String email;
  final int zone_offset;
  final Subscription subscription;
  final Disease disease;
  final List<Severity> severity;

  Patient(
      {this.id,
      this.name,
      this.gender,
      this.age,
      this.birthday,
      this.mobile,
      this.email,
      this.zone_offset,
      this.subscription,
      this.disease,
      this.severity});

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      name: json['name'],
      gender: json['gender'],
      age: json['age'],
      birthday: json['birthday']?.toString()?.toDateTime(),
      mobile: json['mobile'],
      email: json['email'],
      zone_offset: json['zone_offset'],
      subscription: json['subscription'] != null
          ? Subscription.fromJson(json['subscription'])
          : null,
      disease:
          json['disease'] != null ? Disease.fromJson(json['disease']) : null,
      severity: json['severity'] != null
          ? (json['severity'] as List).map((i) => Severity.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['gender'] = this.gender;
    data['age'] = this.age;
    data['birthday'] = this.birthday;
    data['mobile'] = this.mobile;
    data['email'] = this.email;
    data['zone_offset'] = this.zone_offset;
    if (this.subscription != null) {
      data['subscription'] = this.subscription.toJson();
    }
    if (this.disease != null) {
      data['disease'] = this.disease.toJson();
    }
    if (this.severity != null) {
      data['severity'] = this.severity.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Disease {
  final String disease;
  final String strokeSide;
  final DateTime onsetDate;

  Disease({this.disease, this.strokeSide, this.onsetDate});

  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
        disease: json['disease'],
        strokeSide: json['strokeSide'],
        onsetDate: json['onsetDate']?.toString()?.toDateTime());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['disease'] = this.disease;
    data['strokeSide'] = this.strokeSide;
    data['onsetDate'] = this.onsetDate;
    return data;
  }
}

class Severity {
  final String date;
  final int level;

  Severity({this.date, this.level});

  factory Severity.fromJson(Map<String, dynamic> json) {
    return Severity(
      date: json['date'],
      level: json['level'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['level'] = this.level;
    return data;
  }
}

class Subscription {
  final String plan;
  final Video video;

  Subscription({this.plan, this.video});

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      plan: json['plan'],
      video: json['video'] != null ? Video.fromJson(json['video']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['plan'] = this.plan;
    if (this.video != null) {
      data['video'] = this.video.toJson();
    }
    return data;
  }
}

class Video {
  final int done;
  final int remain;

  Video({this.done, this.remain});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      done: json['done'],
      remain: json['remain'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['done'] = this.done;
    data['remain'] = this.remain;
    return data;
  }
}
