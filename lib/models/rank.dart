class Rank {
  final String yearMonth;
  final List<RankData> rankData;

  Rank({this.yearMonth, this.rankData});

  factory Rank.fromJson(body) {
    return Rank(
        yearMonth: body['year_month'],
        rankData: (body['rank_users'] as List)
            .map((e) => RankData.fromJson(e))
            .toList());
  }
}

class RankData {
  final int userId;
  final int rank;
  final String rankTier;
  final int totalScore;
  final String userName;
  final String startDate;
  final String profileImageName;
  final String profileImagePath;
  final bool isVip;

  RankData(
      {this.userId,
      this.rank,
      this.rankTier,
      this.totalScore,
      this.userName,
      this.startDate,
      this.profileImageName,
      this.profileImagePath,
      this.isVip});

  factory RankData.fromJson(body) {
    return RankData(
        userId: body['user_id'],
        rank: body['rank'],
        rankTier: body['rank_tier'],
        totalScore: body['total_score'],
        userName: body['user_name'],
        startDate: body['start_date'],
        profileImageName: body['profile_image_name'],
        profileImagePath: body['profile_image_path'],
        isVip: body['isVip'] ?? false);
  }
}
