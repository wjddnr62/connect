import 'dart:async';

import 'package:connect/data/user_repository.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/models/error.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/user_log/events.dart';
import 'package:connect/utils/appsflyer/apps_flyer.dart';
import 'package:connect/utils/regular_expressions.dart';

import '../sign_info.dart';

class SignEmailInputBloc extends BaseBloc {
  String email;

  SignEmailInputBloc() : super(InitState());

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is CheckEmailFormat) {
      yield EmailChecking();
      email = event.email;
      if (validateEmailFormat(event.email)) {
        var res = await UserRepository.isUser(event.email);
        if (res is ServiceError) {
          yield EmailCheckError(error: res);
        } else {
          // appsflyer.saveLog(emailInput);
          SignInfo.instance.emailId = event.email;
          if (res) {
            yield GotoInputPassword();
          } else {
            yield GotoEmailVerifyingPage();
          }
        }
      } else {
        yield EmailFormatError(message: AppStrings.of(StringKey.invalid_email));
      }
      yield EmailChecking(completed: true);
      return;
    }
  }
}

class InitState extends BaseBlocState {}

class CheckEmailFormat extends BaseBlocEvent {
  final String email;

  CheckEmailFormat({this.email});
}

class EmailChecking extends BaseBlocState {
  final bool completed;

  EmailChecking({this.completed = false});
}

class EmailFormatError extends BaseBlocState {
  final String message;

  EmailFormatError({this.message});
}

class EmailCheckError extends BaseBlocState {
  final ServiceError error;

  EmailCheckError({this.error});
}

class GotoEmailVerifyingPage extends BaseBlocState {
  @override
  String get tag => EventSign.SIGNUP_START;
}

class GotoInputPassword extends BaseBlocState {
  @override
  String get tag => EventSign.LOGIN_START;
}
