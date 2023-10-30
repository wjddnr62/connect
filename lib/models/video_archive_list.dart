import 'package:connect/models/video_archive.dart';

class VideoArchiveList {
  final List<VideoArchive> data;
  final bool hasNext;
  final int pageNumber;

  VideoArchiveList({this.data, this.hasNext, this.pageNumber});

  factory VideoArchiveList.fromJson(Map<String, dynamic> json) {
    return VideoArchiveList(
      data: json['data'] != null
          ? (json['data'] as List).map((i) => VideoArchive.fromJson(i)).toList()
          : null,
      hasNext: json['has_next'],
      pageNumber: json['page_number'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['has_next'] = this.hasNext;
    data['page_number'] = this.pageNumber;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
