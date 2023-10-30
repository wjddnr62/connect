import 'dart:async';

import 'package:connect/data/user_repository.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/models/error.dart';
import 'package:connect/resources/app_resources.dart';

import '../sign_info.dart';

class PasswordInputBloc extends BaseBloc {
  PasswordInputBloc() : super(InitState());

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is Login) {
      yield Logining();
      SignInfo.instance.password = event.password;
      var response = await UserRepository.login(
          email: SignInfo.instance.emailId,
          password: SignInfo.instance.password);

      if (response is ServiceError) {
        yield ShowPasswordWrongError(response.message);
      } else if (response as bool) {
        yield GoSplashToInitService();
        return;
      } else {
        yield ShowPasswordWrongError(
            AppStrings.of(StringKey.password_not_matched));
      }
      yield Logining(completed: true);
      return;
    }
  }
}

class InitState extends BaseBlocState {}

class Login extends BaseBlocEvent {
  final String password;

  Login(this.password);
}

class ShowPasswordWrongError extends BaseBlocState {
  final String message;

  ShowPasswordWrongError(this.message);
}

class ShowPasswordFormatError extends BaseBlocState {
  final String message;

  ShowPasswordFormatError({this.message});
}

class Logining extends BaseBlocState {
  final bool completed;

  Logining({this.completed = false});
}
