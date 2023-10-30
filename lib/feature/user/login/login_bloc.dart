import 'package:connect/data/duration_repository.dart';
import 'package:connect/data/user_repository.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/models/error.dart';
import 'package:connect/utils/appsflyer/apps_flyer.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginBloc extends BaseBloc {
  LoginBloc(BuildContext context) : super(BaseLoginState());

  SharedPreferences prefs;
  bool upPanelOpen = false;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is LoginInitEvent) {
      prefs = await SharedPreferences.getInstance();
    }

    if (event is PasswordViewEvent) {
      yield PasswordView(view: event.view);
    }

    if (event is LoginEvent) {
      yield LoadingState(loading: true);
      var response = await UserRepository.login(
          email: event.email, password: event.password);

      if (response is ServiceError) {
        yield LoginFail(error: true);
      } else if (response as bool) {
        String date =
            "${DateTime.now().year}-${DateTime.now().month.toString().length == 1 ? "0" + DateTime.now().month.toString() : DateTime.now().month}-${DateTime.now().day.toString().length == 1 ? "0" + DateTime.now().day.toString() : DateTime.now().day}";
        await DurationRepository.durationRegist(date);
        appsflyer.saveLog(neofectLogin);
        yield GoSplashToInitService();

        return;
      } else {
        yield LoginFail(error: true);
      }
      yield LoadingState(loading: false);
      yield LoginState();
      return;
    }

    if (event is AppleLoginEvent) {
      if (event.type == 1) {
        yield LoadingState(loading: false);
      }
      yield AppleLoginState(type: event.type);
    }

    if (event is StopLoadingEvent) {
      yield LoadingState(loading: false);
    }

    if (event is StartLoadingEvent) {
      yield LoadingState(loading: true);
    }

    if (event is UpPanelEvent) {
      upPanelOpen = event.openUp;
      yield UpPanelState();
    }
  }
}

class AppleLoginEvent extends BaseBlocEvent {
  final int type;

  AppleLoginEvent({this.type});
}

class AppleLoginState extends BaseBlocState {
  final int type;

  AppleLoginState({this.type});
}

class LoginFail extends BaseBlocState {
  final bool error;

  LoginFail({this.error});
}

class LoginEvent extends BaseBlocEvent {
  final String email;
  final String password;

  LoginEvent({this.email, this.password});
}

class LoginState extends BaseBlocState {}

class PasswordViewEvent extends BaseBlocEvent {
  final bool view;

  PasswordViewEvent({this.view});
}

class PasswordView extends BaseBlocState {
  final bool view;

  PasswordView({this.view});
}

class LoginInitEvent extends BaseBlocEvent {}

class BaseLoginState extends BaseBlocState {}

class StartLoadingEvent extends BaseBlocEvent {}

class StopLoadingEvent extends BaseBlocEvent {}

class UpPanelEvent extends BaseBlocEvent {
  final bool openUp;

  UpPanelEvent({this.openUp});
}

class UpPanelState extends BaseBlocState {}

class LoadingState extends BaseBlocState {
  final bool loading;

  LoadingState({this.loading});
}
