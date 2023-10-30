import 'package:connect/data/local/app_dao.dart';
import 'package:connect/data/rank_repository.dart';
import 'package:connect/data/user_repository.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/models/error.dart';
import 'package:connect/models/profile.dart';
import 'package:connect/models/rank.dart';
import 'package:connect/widgets/base_widget.dart';

class RankBloc extends BaseBloc {
  RankBloc(BuildContext context) : super(BaseRankState());

  DateTime nowDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  Rank rankList;
  dynamic rankData;

  bool loading = false;

  String marketPlace = "";
  int serviceDate = 0;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is RankInitEvent) {
      loading = true;
      yield LoadingState();

      marketPlace = await AppDao.marketPlaceName ?? "Free";

      String date =
          "${nowDate.year}-${nowDate.month.toString().length == 1 ? "0${nowDate.month}" : "${nowDate.month}"}";
      rankData = await RankRepository.rankGetDataMe(date);

      if (rankData is ServiceError) {
        loading = false;
        yield RankDataError();
      }

      if (rankData == null) {
        rankData = RankData(
            userId: 0,
            rank: 0,
            rankTier: 'STONE',
            totalScore: 0,
            profileImagePath: "",
            profileImageName: "Empathy",
            userName: await AppDao.nickname,
            startDate: DateTime.now().toIso8601String());
      }
      rankList = await RankRepository.rankGetData(date);

      if (rankList is ServiceError) {
        loading = false;
        yield RankDataError();
      }

      Profile profile = await UserRepository.getProfile();

      serviceDate = profile.subscription.daysJoined;
          // DateTime.now().difference(DateTime.parse(rankData.startDate)).inDays;



      loading = false;
      yield RankInitState();
    }
  }
}

class RankInitEvent extends BaseBlocEvent {}

class RankInitState extends BaseBlocState {}

class BaseRankState extends BaseBlocState {}

class LoadingState extends BaseBlocState {}

class RankDataError extends BaseBlocState {}
