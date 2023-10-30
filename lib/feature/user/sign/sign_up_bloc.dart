import 'dart:async';

import 'package:connect/data/duration_repository.dart';
import 'package:connect/data/user_repository.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/models/error.dart';
import 'package:connect/resources/app_strings.dart';
import 'package:connect/user_log/events.dart';
import 'package:connect/utils/appsflyer/apps_flyer.dart';
import 'package:connect/utils/logger/log.dart';
import 'package:connect/utils/regular_expressions.dart';
import 'package:connect/widgets/base_widget.dart';

import '../sign_info.dart';

class SignUpBloc extends BaseBloc {
  SignUpBloc(BuildContext context) : super(BaseSignUpState());

  String email;
  Timer timer;
  bool emailSend = false;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is SignUpInitEvent) {
      appsflyer.saveLog(signNeofect);
      yield SignUpInitState();
    }

    if (event is CheckEmailFormat) {
      yield EmailChecking();
      email = event.email;
      if (validateEmailFormat(event.email)) {
        var res = await UserRepository.isUser(event.email);
        if (res is ServiceError) {
          yield EmailCheckError(error: res);
        } else {
          if (res) {
            yield EmailReduplicationError(
                message:
                    AppStrings.of(StringKey.this_email_is_already_signed_up));
            // AppStrings.of(StringKey.incorrect_email));
          } else {
            yield EmailGood();
          }
        }
      } else {
        yield EmailFormatError(
            message: AppStrings.of(StringKey.incorrect_email));
      }
      yield EmailChecking(completed: true);
      return;
    }

    if (event is PasswordViewEvent) {
      yield PasswordView(view: event.view);
    }

    if (event is CheckPasswordRule) {
      yield PassState();
      List<int> checkTypeNum = List();
      List<PasswordRuleViolation> checkType = checkPassword(event.password);
      if (checkType.contains(PasswordRuleViolation.Length)) {
        checkTypeNum.add(0);
      }
      if (checkType.contains(PasswordRuleViolation.Consecutive)) {
        checkTypeNum.add(1);
      }
      if (checkType.contains(PasswordRuleViolation.Type)) {
        checkTypeNum.add(2);
      }
      if (checkType.length != 0 && checkType.isNotEmpty) {
        checkTypeNum.add(4);
      }
      yield PasswordRuleReturn(checkTypeList: checkTypeNum);
    }

    if (event is SignUpEvent) {
      yield LoadingState();
      var response = await UserRepository.signup(
          email: event.email,
          password: event.password,
          name: event.name,
          birthday: event.birthDay,
          role: SignInfo.instance.role);

      if (response is ServiceError) {
        yield SignUpError();
        return;
      }

      appsflyer.saveLog(neofectSign);

      var loginResponse = await UserRepository.login(
          email: event.email, password: event.password);

      if (loginResponse is ServiceError) {
        yield LoginError();
      } else if (loginResponse as bool) {
        String date =
            "${DateTime.now().year}-${DateTime.now().month.toString().length == 1 ? "0" + DateTime.now().month.toString() : DateTime.now().month}-${DateTime.now().day.toString().length == 1 ? "0" + DateTime.now().day.toString() : DateTime.now().day}";
        await DurationRepository.durationRegist(date);
        yield GoSplashToInitService();
      }
    }

    if (event is RequestVerifyEmail) {
      emailSend = true;
      yield VerifyingEmail();
      if (timer != null) {
        timer.cancel();
      }
      var res = await UserRepository.requestVerifyEmail(event.email);

      if (res is ServiceError) {
        yield ShowError(error: res);
        return;
      }

      SignInfo.instance.emailVerificationToken = res;
      yield PassState();
      yield VerifyingEmail();
      timer = Timer.periodic(Duration(seconds: 5), (timer) {
        add(VerifyEmail());
      });
      return;
    }

    if (event is VerifyEmail) {
      yield PassState();
      Log.d('verifyEmail', 'verifyEmail');
      var res = await UserRepository.verifyEmail(
          SignInfo.instance.emailVerificationToken);
      if (res is ServiceError) {
        timer.cancel();
        yield ShowError(error: res);
        return;
      }

      if (res is bool && res) {
        timer.cancel();
        yield VerifiedEmail();
        yield PassState();
      }
      return;
    }

    if (event is ReloadEvent) {
      yield PassState();
      yield ReloadState();
    }
  }
}

class EmailCheckError extends BaseBlocState {
  final ServiceError error;

  EmailCheckError({this.error});
}

class EmailChecking extends BaseBlocState {
  final bool completed;

  EmailChecking({this.completed = false});
}

class EmailGood extends BaseBlocState {}

class EmailReduplicationError extends BaseBlocState {
  final String message;

  EmailReduplicationError({this.message});
}

class EmailFormatError extends BaseBlocState {
  final String message;

  EmailFormatError({this.message});
}

class CheckEmailFormat extends BaseBlocEvent {
  final String email;

  CheckEmailFormat({this.email});
}

class PasswordViewEvent extends BaseBlocEvent {
  final bool view;

  PasswordViewEvent({this.view});
}

class PasswordView extends BaseBlocState {
  final bool view;

  PasswordView({this.view});
}

class CheckPasswordRule extends BaseBlocEvent {
  final String password;

  CheckPasswordRule({this.password});
}

class PasswordRuleReturn extends BaseBlocState {
  final List<int> checkTypeList;

  PasswordRuleReturn({this.checkTypeList});
}

class SignUpEvent extends BaseBlocEvent {
  final String email;
  final String password;
  final String name;
  final String birthDay;

  SignUpEvent({this.email, this.password, this.name, this.birthDay});
}

class SocialSignUpEvent extends BaseBlocEvent {
  final String email;
  final String password;
  final String socialType;
  final String sid;

  SocialSignUpEvent({this.email, this.password, this.socialType, this.sid});
}

class SignUpError extends BaseBlocState {}

class LoginError extends BaseBlocState {}

class SignUpInitEvent extends BaseBlocEvent {}

class SignUpInitState extends BaseBlocState {}

class BaseSignUpState extends BaseBlocState {}

class LoadingState extends BaseBlocState {}

class RequestVerifyEmail extends BaseBlocEvent {
  final String email;

  RequestVerifyEmail({this.email});
}

class VerifyingEmail extends BaseBlocState {}

class VerifyEmail extends BaseBlocEvent {}

class VerifiedEmail extends BaseBlocState {
  @override
  String get tag => EventSign.SIGNUP_VERIFIED_EMAIL;
}

class PassState extends BaseBlocState {}

class ReloadEvent extends BaseBlocEvent {}

class ReloadState extends BaseBlocState {}
