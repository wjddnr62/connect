class ChatToken {
  String accessToken;

  ChatToken({this.accessToken});

  factory ChatToken.fromJson(Map<String, dynamic> json) {
    return ChatToken(
      accessToken: json['access_token'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['access_token'] = this.accessToken;
    return data;
  }
}
