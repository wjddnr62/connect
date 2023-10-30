class VideoCallAccessInfo {
  final String api_key;
  final String session_id;
  final String token;

  VideoCallAccessInfo({this.api_key, this.session_id, this.token});

  factory VideoCallAccessInfo.fromJson(Map<String, dynamic> json) {
    return VideoCallAccessInfo(
      api_key: json['api_key'],
      session_id: json['session_id'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['api_key'] = this.api_key;
    data['session_id'] = this.session_id;
    data['token'] = this.token;
    return data;
  }
}
