import 'dart:async';

import 'package:connect/feature/base_bloc.dart';
import 'package:connect/feature/user/sign_info.dart';
import 'package:connect/resources/app_strings.dart';
import 'package:connect/user_log/events.dart';
import 'package:connect/utils/appsflyer/apps_flyer.dart';
import 'package:connect/utils/regular_expressions.dart';

class PasswordCreateBloc extends BaseBloc {
  PasswordCreateBloc() : super(_InitState());

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is CheckPasswordRule) {
      switch (validatePassword(event.password)) {
        case PasswordRuleViolation.Length:
          yield ShowPasswordRuleError(
              message:
              AppStrings.of(StringKey.invalid_password_length_violation));
          break;
        case PasswordRuleViolation.Consecutive:
          yield ShowPasswordRuleError(
              message: AppStrings.of(StringKey.consecutive_password_violation));
          break;
        case PasswordRuleViolation.Type:
          yield ShowPasswordRuleError(
              message:
              AppStrings.of(StringKey.least_two_types_password_violation));
          break;
        case PasswordRuleViolation.InvalidChar:
          yield ShowPasswordRuleError(
              message:
              AppStrings.of(StringKey.invalid_password_format));
          break;
        case PasswordRuleViolation.None:
          // appsflyer.saveLog(passwordInput);
          SignInfo.instance.password = event.password;
          yield GotoConfirmPassword();
          break;
      }
    }
  }
}

class _InitState extends BaseBlocState {}

class CheckPasswordRule extends BaseBlocEvent {
  final String password;

  CheckPasswordRule(this.password);
}

class GotoConfirmPassword extends BaseBlocState {
  @override
  // TODO: implement tag
  String get tag => EventSign.SIGNUP_CREATE_PASSWORD;
}

class ShowPasswordRuleError extends BaseBlocState {
  final String message;

  ShowPasswordRuleError({this.message});
}
