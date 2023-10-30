class Diary {
  final int userId;
  final String writeDateTime;
  final String sleepDateTime;
  final String wakeDateTime;
  final String weatherType;
  final String feelingType;
  final String contentMessage;
  final List<DiaryImage> contentImages;
  final bool isPrivate;
  final String id;

  Diary(
      {this.userId,
      this.writeDateTime,
      this.sleepDateTime,
      this.wakeDateTime,
      this.weatherType,
      this.feelingType,
      this.contentMessage,
      this.contentImages,
      this.isPrivate,
      this.id});

  factory Diary.fromJson(body) {
    return Diary(
        userId: body['user_id'],
        writeDateTime: body['write_datetime'],
        sleepDateTime: body['sleep_datetime'],
        wakeDateTime: body['wake_datetime'],
        weatherType: body['weather_type'],
        feelingType: body['feeling_type'],
        contentMessage: body['content_message'],
        contentImages: body['content_images'] != null
            ? (body['content_images'] as List)
                .map((e) => DiaryImage.fromJson(e))
                .toList()
            : null,
        isPrivate: body['is_private'],
        id: body['id']);
  }
}

class DiaryImage {
  final int seq;
  final String imagePath;

  DiaryImage({this.seq, this.imagePath});

  factory DiaryImage.fromJson(body) {
    return DiaryImage(seq: body['seq'] as int, imagePath: body['image_path']);
  }
}

class DiaryChecks {
  final String date;
  final bool check;

  DiaryChecks({this.date, this.check});
}