import 'package:connect/data/stroke_coach_repository.dart';
import 'package:connect/data/user_repository.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/models/error.dart';
import 'package:connect/models/profile.dart';
import 'package:connect/models/stroke_coach.dart';
import 'package:connect/models/working_hours.dart';

class AccountBloc extends BaseBloc {
  AccountBloc() : super(InitState());

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is LoadMyOT) {
      yield MyOTLoading();
      var profile = await UserRepository.getProfile();
      if (profile is ServiceError) {
        yield MyOTLoadFailed(profile);
      } else if (profile is Profile) {
        var strokeCoach = profile.strokeCoach;
        if (strokeCoach == null) {
          yield MyOTTherapistEmpty();
        } else {
          try {
            var workingHours =
                await StrokeCoachRepository.getStrokeCoachWorkingHours();
            yield MyOTLoaded(strokeCoach,
                (workingHours is WorkingHours) ? workingHours : null);
          } catch (e) {
            if (e is NoSuchMethodError)
              yield MyOTInfoNotSet();
            else
              yield UnknownError(e);
          }
        }
      }
    }
  }
}

class InitState extends BaseBlocState {}

class MyOTLoading extends BaseBlocState {}

class MyOTLoaded extends BaseBlocState {
  final StrokeCoach strokeCoach;
  final WorkingHours workingHours;

  MyOTLoaded(this.strokeCoach, this.workingHours);
}

// ignore: must_be_immutable
class MyOTLoadFailed extends BaseBlocState {
  final ServiceError error;

  MyOTLoadFailed(this.error);
}

// ignore: must_be_immutable
class MyOTInfoNotSet extends BaseBlocState {
  final DateTime time = DateTime.now();

  @override
  List<Object> get props => [time];
}

// ignore: must_be_immutable
class MyOTTherapistEmpty extends BaseBlocState {}

// ignore: must_be_immutable
class LoadMyOT extends BaseBlocEvent {}

// ignore: must_be_immutable
class UnknownError extends BaseBlocState {
  final ServiceError e;

  UnknownError(this.e);
}
