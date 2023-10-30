import 'dart:async';

import 'package:connect/data/user_repository.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/feature/user/sign_info.dart';
import 'package:connect/models/error.dart';
import 'package:connect/user_log/events.dart';
import 'package:connect/user_log/user_logger.dart';
import 'package:connect/utils/appsflyer/apps_flyer.dart';

class PasswordConfirmBloc extends BaseBloc {
  PasswordConfirmBloc() : super(_InitState());

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is ComparePassword) {
      if (event.password == SignInfo.instance.password) {
        var response = await UserRepository.signup(
            email: SignInfo.instance.emailId,
            password: SignInfo.instance.password,
            role: SignInfo.instance.role,
            // emailVerificationToken: SignInfo.instance.emailVerificationToken
        );

        if (response is ServiceError) {
          yield ShowError(error: response);
          return;
        }

        // appsflyer.saveLog(passwordCheckComplete);
        UserLogger.logEventName(eventName: EventSign.SIGNUP_CONFIRM_PASSWORD);
        yield GoSplashToInitService();
        return;
      }

      yield PasswordNotMatched();
    }
  }
}

class _InitState extends BaseBlocState {}

class ComparePassword extends BaseBlocEvent {
  final String password;

  ComparePassword(this.password);
}

class PasswordNotMatched extends BaseBlocState {}
