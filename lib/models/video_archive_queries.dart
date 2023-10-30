import 'package:connect/resources/app_strings.dart';

enum VideoArchiveOrderBy {
  MOST_POPULAR,
  NEWEST,
  OLDEST,
}

enum VideoArchiveCategory { ALL, THERAPIST_LIVE, HOME_TRAINING, BOOKMARK }

final Map<VideoArchiveOrderBy, String> orderStringMap = {
  VideoArchiveOrderBy.MOST_POPULAR: AppStrings.of(StringKey.most_popular),
  VideoArchiveOrderBy.NEWEST: AppStrings.of(StringKey.newest),
  VideoArchiveOrderBy.OLDEST: AppStrings.of(StringKey.oldest),
};

final Map<VideoArchiveCategory, String> categoryStringMap = {
  VideoArchiveCategory.ALL: AppStrings.of(StringKey.all),
  VideoArchiveCategory.THERAPIST_LIVE:
      AppStrings.of(StringKey.stroke_coach_live),
  VideoArchiveCategory.HOME_TRAINING: AppStrings.of(StringKey.home_training),
  VideoArchiveCategory.BOOKMARK: AppStrings.of(StringKey.bookmark),
};
