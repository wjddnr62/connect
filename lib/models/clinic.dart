const String CLINIC_STATE_WAITING = 'WAITING';
const String CLINIC_STATE_NORMAL = 'NORMAL';

class ClinicStatus {
  final Clinic current;
  Clinic requested;
  String state;

  ClinicStatus({this.current, this.requested, this.state});

  factory ClinicStatus.fromJson(Map<String, dynamic> json) => ClinicStatus(
      current: Clinic.fromJson(json['current']),
      requested: Clinic.fromJson(json['requested']),
      state: json['state']);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if(this.current != null)
      data['current'] = this.current.toJson();
    if(this.requested != null)
    data['requested'] = this.requested.toJson();
    data['state'] = this.state;

    return data;
  }
}

class Clinic {
  int id;
  String name;

  Clinic({this.id, this.name});

  factory Clinic.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return Clinic(id: json['id'] as int, name: json['name'] as String);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}
