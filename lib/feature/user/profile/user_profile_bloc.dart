import 'package:connect/data/local/app_dao.dart';
import 'package:connect/data/rank_repository.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/models/error.dart';
import 'package:connect/models/profile.dart';
import 'package:connect/models/rank.dart';
import 'package:connect/widgets/base_widget.dart';

class UserProfileBloc extends BaseBloc {
  UserProfileBloc(BuildContext context) : super(BaseUserProfileState());

  Profile profile;
  DateTime nowDate = DateTime.now();
  RankData rankData;
  bool loading = false;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    // TODO: implement mapEventToState
    if (event is UserProfileInitEvent) {
      loading = true;
      yield LoadingState();
      profile = event.profile;

      String date =
          "${nowDate.year}-${nowDate.month.toString().length == 1 ? "0${nowDate.month}" : "${nowDate.month}"}";
      rankData = await RankRepository.rankGetDataMe(date);

      if (rankData is ServiceError) {
        loading = false;
        yield UserProfileInitState();
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

      loading = false;
      yield UserProfileInitState();
    }
  }


}

class LoadingState extends BaseBlocState {}

class UserProfileInitEvent extends BaseBlocEvent {
  final Profile profile;

  UserProfileInitEvent({this.profile});
}

class UserProfileInitState extends BaseBlocState {}

class BaseUserProfileState extends BaseBlocState {}