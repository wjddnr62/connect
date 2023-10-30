import 'push_notification.dart';

class PushHistory {
  final PushNotification notify;
  bool isRead;
  final DateTime created;

  PushHistory({this.notify, this.isRead, this.created});

  static PushHistory fromJson(Map<String, dynamic> json) {
    json['data']['type'] = json['type'];

    return PushHistory(
        notify: PushNotification.fromJson(json['data']),
        isRead: json['is_read'],
        created: DateTime.parse(json['created']).toLocal());
  }

  Map<String, dynamic> toJson() {
    return {
      'json': notify.toJson(),
      'is_read': isRead,
      'created': created.toString()
    };
  }
}

class PushHistoryList {
  List<PushHistory> contents;
  PageInfo page_info;

  PushHistoryList({this.contents, this.page_info});

  factory PushHistoryList.fromJson(Map<String, dynamic> json) {
    var res = json;
    return PushHistoryList(
      contents: res['contents'] != null
          ? (res['contents'] as List)
              .map((i) => PushHistory.fromJson(i))
              .toList()
          : null,
      page_info:
          res['page_info'] != null ? PageInfo.fromJson(res['page_info']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.contents != null) {
      data['contents'] = this.contents.map((v) => v.toJson()).toList();
    }
    if (this.page_info != null) {
      data['page_info'] = this.page_info.toJson();
    }
    return data;
  }
}

class PageInfo {
  int page_number;
  int total_count;
  int total_page;

  PageInfo({this.page_number, this.total_count, this.total_page});

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return PageInfo(
      page_number: json['page_number'],
      total_count: json['total_count'],
      total_page: json['total_page'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['page_number'] = this.page_number;
    data['total_count'] = this.total_count;
    data['total_page'] = this.total_page;
    return data;
  }
}
