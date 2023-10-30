import 'dart:async';

import 'package:connect/data/user_repository.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/models/error.dart';

const ROLE_CAREGIVER = 'CAREGIVER';
const ROLE_PATIENT = 'PATIENT';

class ResetPasswordBloc extends BaseBloc {
  final String email;

  ResetPasswordBloc({this.email}) : super(InputtingEmail());

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is InputEmail) {
      yield InputtingEmail();
      return;
    }

    if (event is RequestSendMail) {
      yield ShowingGuide();

      var res = await UserRepository.requestPasswordReset(email);

      if (res is ServiceError) {
        yield UnknownError(res);
        return;
      }

      return;
    }

    if (event is Back) {
      yield Finish();
      return;
    }
  }

  @override
  void dispose() {
    super.close();
  }
}

class InputEmail extends BaseBlocEvent {}

class InputtingEmail extends BaseBlocState {}

class RequestSendMail extends BaseBlocEvent {}

class ShowingGuide extends BaseBlocState {}

class ErrorEmail extends BaseBlocState {}

class UnknownError extends BaseBlocState {
  final error;
  final backTo;

  UnknownError(this.error, {this.backTo});
}

class Back extends BaseBlocEvent {}

class Finish extends BaseBlocState {}
