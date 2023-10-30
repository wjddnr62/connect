import 'package:connect/data/profile_repository.dart';
import 'package:connect/data/user_repository.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/models/error.dart';
import 'package:connect/models/profile.dart';

class ProfilePageBloc extends BaseBloc {
  ProfilePageBloc() : super(ProfileLoading());

  bool loading = false;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is LoadProfile) {
      loading = true;
      yield LoadingState();
      /// final userType = await AppDao.userType;
      /// userType 현재는 ProfileType.PATIENT 만 들어오지만 나중에 다른 경우에 대한 처리를 해야 한다.
      var response = await UserRepository.getProfile();
      if (response is ServiceError) {
        loading = false;
        yield ProfileLoadingError(response);
      } else {
        loading = false;
        yield ProfileLoaded(response);
      }
    }

    if (event is ProfileUpdateEvent) {
      loading = true;
      yield LoadingState();
      String profileDate =
          "${event.profile.birthday.year}-${event.profile.birthday.month.toString().length == 1 ? "0${event.profile.birthday.month}" : "${event.profile.birthday.month}"}-${event.profile.birthday.day.toString().length == 1 ? "0${event.profile.birthday.day}" : "${event.profile.birthday.day}"}";
      var res = await ProfileRepository.updateUserProfile(
          name: event.profile.name,
          statusMessage: event.profile.statusMessage,
          birthday: event.date ?? profileDate,
          gender: event.gender ?? event.profile.gender,
          profileImageName: event.profile.profileImageName);
      if (res is ServiceError) {
        loading = false;
        yield ProfileLoadingError(res);
      } else {
        var response = await UserRepository.getProfile();
        if (response is ServiceError) {
          loading = false;
          yield ProfileLoadingError(response);
        } else {
          loading = false;
          yield ProfileLoaded(response);
        }
      }
    }
  }
}

class LoadingState extends BaseBlocState {}

class ProfileLoading extends BaseBlocState {}

class ProfileLoadingError extends BaseBlocState {
  final ServiceError error;

  ProfileLoadingError(this.error);
}

class ProfileLoaded extends BaseBlocState {
  final Profile profile;

  ProfileLoaded(this.profile);
}

class LoadProfile extends BaseBlocEvent {}

class ProfileUpdateEvent extends BaseBlocEvent {
  final Profile profile;
  final String date;
  final String gender;

  ProfileUpdateEvent({this.profile, this.date, this.gender});
}

class GenderUpdateState extends BaseBlocState {}
