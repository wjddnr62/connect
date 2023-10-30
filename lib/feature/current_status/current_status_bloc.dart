import 'package:connect/data/local/app_dao.dart';
import 'package:connect/data/user_repository.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/models/advice.dart';
import 'package:connect/models/home_level.dart';
import 'package:connect/models/profile.dart';
import 'package:connect/models/training_summary.dart';

class CurrentStatusBloc extends BaseBloc {
  CurrentStatusBloc() : super(_InitState());

  Profile profile;
  TrainingSummary status;
  HomeLevel level = HomeLevel.rookie_warrior;
  StrokeCoachAdvice advice;
  String feedback;
  String token;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is CurrentStatusLoadEvent) {
      profile = await UserRepository.getProfile();
      token = await AppDao.accessToken;
      yield CurrentStatusLoadComplete();
    }
  }
}

// ignore: must_be_immutable
class _InitState extends BaseBlocState {}

// ignore: must_be_immutable
class CurrentStatusLoadEvent extends BaseBlocEvent {}

// ignore: must_be_immutable
class CurrentStatusLoadingState extends BaseBlocState {}

// ignore: must_be_immutable
class CurrentStatusLoadComplete extends BaseBlocState {}

// ignore: must_be_immutable
class CurrentStatusErrorState extends BaseBlocState {}

// ignore: must_be_immutable
class HomeLevelNotInitializedState extends CurrentStatusErrorState {}

// ignore: must_be_immutable
class LastTrainedDayLoadFailedState extends CurrentStatusErrorState {}

// ignore: must_be_immutable
class NoAdviceState extends CurrentStatusErrorState {}
