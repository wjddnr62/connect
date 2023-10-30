import 'dart:async';

import 'package:connect/data/user_repository.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/models/error.dart';
import 'package:connect/user_log/events.dart';
import 'package:connect/utils/logger/log.dart';

import '../sign_info.dart';

class SignVerifyingEmailBloc extends BaseBloc {
  Timer timer;

  SignVerifyingEmailBloc() : super(_InitState());

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is RequestVerifyEmail) {
      yield VerifyingEmail();
      var res =
          await UserRepository.requestVerifyEmail(SignInfo.instance.emailId);

      if (res is ServiceError) {
        yield ShowError(error: res);
        return;
      }

      SignInfo.instance.emailVerificationToken = res;

      yield VerifyingEmail();
      timer = Timer.periodic(Duration(seconds: 5), (timer) {
        add(VerifyEmail());
      });
      return;
    }

    if (event is VerifyEmail) {
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
      }
      return;
    }

    if (event is CancelVerifyingEmail) {
      timer.cancel();
      yield CanceledVerifyingEmail();
    }
  }

  @override
  Future<void> close() {
    timer.cancel();
    return super.close();
  }
}

class _InitState extends BaseBlocState {}

class RequestVerifyEmail extends BaseBlocEvent {}

class VerifyingEmail extends BaseBlocState {}

class VerifyEmail extends BaseBlocEvent {}

class VerifiedEmail extends BaseBlocState {
  @override
  String get tag => EventSign.SIGNUP_VERIFIED_EMAIL;
}

class CancelVerifyingEmail extends BaseBlocEvent {}

class CanceledVerifyingEmail extends BaseBlocState {}
