class StrokeCoach {
  String birthday;
  String country;
  String email;
  String gender;
  int id;
  String image;
  String introduction;
  String mobile;
  String name;
  String password;
  String state;
  String token;
  String type;

  StrokeCoach({
    this.birthday,
    this.country,
    this.email,
    this.gender,
    this.id,
    this.image,
    this.introduction,
    this.mobile,
    this.name,
    this.password,
    this.state,
    this.token,
    this.type,
  });

  factory StrokeCoach.fromJson(Map<String, dynamic> json) {
    return StrokeCoach(
      birthday: json['birthday'],
      country: json['country'],
      email: json['email'],
      gender: json['gender'],
      id: json['id'],
      image: json['image'],
      introduction: json['introduction'],
      mobile: json['mobile'],
      name: json['name'],
      password: json['password'],
      state: json['state'],
      token: json['token'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['birthday'] = this.birthday;
    data['country'] = this.country;
    data['email'] = this.email;
    data['gender'] = this.gender;
    data['id'] = this.id;
    data['image'] = this.image;
    data['introduction'] = this.introduction;
    data['mobile'] = this.mobile;
    data['name'] = this.name;
    data['password'] = this.password;
    data['state'] = this.state;
    data['token'] = this.token;
    data['type'] = this.type;
    return data;
  }
}
