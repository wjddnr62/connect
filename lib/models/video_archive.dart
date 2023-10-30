class VideoArchive {
  final String title;
  final String imageUrl;
  final String description;
  final String createdBy;
  final DateTime createdAt;
  final String id;
  final String videoUrl;

  VideoArchive({
    this.title,
    this.imageUrl,
    this.createdBy,
    this.createdAt,
    this.description,
    this.id,
    this.videoUrl,
  });

  factory VideoArchive.fromJson(Map<String, dynamic> json) {
    return VideoArchive(
      createdAt: DateTime.parse(json['created_at']),
      createdBy: json['created_by'],
      description: json['description'],
      id: json['id'],
      imageUrl: json['image_url'],
      title: json['title'],
      videoUrl: json['video_url'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['created_at'] = this.createdAt;
    data['created_by'] = this.createdBy;
    data['description'] = this.description;
    data['id'] = this.id;
    data['image_url'] = this.imageUrl;
    data['title'] = this.title;
    data['video_url'] = this.videoUrl;
    return data;
  }
}
