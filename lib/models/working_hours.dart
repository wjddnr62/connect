class WorkingHours {
  String end_lunch_time;
  String end_work_time;
  bool fri;
  bool mon;
  bool sat;
  String start_lunch_time;
  String start_work_time;
  bool sun;
  bool thu;
  bool tue;
  bool wed;
  int zone_offset;

  WorkingHours(
      {this.end_lunch_time,
      this.end_work_time,
      this.fri,
      this.mon,
      this.sat,
      this.start_lunch_time,
      this.start_work_time,
      this.sun,
      this.thu,
      this.tue,
      this.wed,
      this.zone_offset});

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      end_lunch_time: json['end_lunch_time'],
      end_work_time: json['end_work_time'],
      fri: json['fri'],
      mon: json['mon'],
      sat: json['sat'],
      start_lunch_time: json['start_lunch_time'],
      start_work_time: json['start_work_time'],
      sun: json['sun'],
      thu: json['thu'],
      tue: json['tue'],
      wed: json['wed'],
      zone_offset: json['zone_offset'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['end_lunch_time'] = this.end_lunch_time;
    data['end_work_time'] = this.end_work_time;
    data['fri'] = this.fri;
    data['mon'] = this.mon;
    data['sat'] = this.sat;
    data['start_lunch_time'] = this.start_lunch_time;
    data['start_work_time'] = this.start_work_time;
    data['sun'] = this.sun;
    data['thu'] = this.thu;
    data['tue'] = this.tue;
    data['wed'] = this.wed;
    data['zone_offset'] = this.zone_offset;
    return data;
  }
}
