import 'package:connect/data/goal_repository.dart';
import 'package:connect/data/local/app_dao.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/models/error.dart';
import 'package:connect/models/goal.dart';
import 'package:connect/utils/appsflyer/apps_flyer.dart';
import 'package:connect/widgets/base_widget.dart';

class GoalBloc extends BaseBloc {
  GoalBloc(BuildContext context) : super(BaseGoalState());

  String name;
  List<String> serveys = List();
  bool loading = false;
  Goal serveyData;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is GoalInitEvent) {
      name = await AppDao.nickname;
      yield GoalInitState();
    }

    if (event is GoalDataGetEvent) {
      loading = true;
      yield LoadingState();

      serveyData = await GoalRepository.getGoalData();
      loading = false;
      yield GoalDataGetState();
    }

    if (event is GoalDataSaveUserEvent) {
      loading = true;
      yield LoadingState();

      var res = await GoalRepository.putGoalUserData(serveys);

      if (res is ServiceError) {
        return;
      }

      if (res) {
        appsflyer.saveLog(survey);
        loading = false;
        yield GoalDataSaveUserState();
      }
    }
  }
}

class GoalDataGetEvent extends BaseBlocEvent {}

class GoalDataGetState extends BaseBlocState {}

class GoalDataSaveUserEvent extends BaseBlocEvent {}

class GoalDataSaveUserState extends BaseBlocState {}

class GoalInitEvent extends BaseBlocEvent {}

class GoalInitState extends BaseBlocState {}

class BaseGoalState extends BaseBlocState {}

class LoadingState extends BaseBlocState {}
