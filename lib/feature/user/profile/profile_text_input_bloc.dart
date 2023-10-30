import 'package:connect/data/profile_repository.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/models/error.dart';
import 'package:connect/models/profile.dart';
import 'package:connect/widgets/base_widget.dart';

class ProfileTextInputBloc extends BaseBloc {
  ProfileTextInputBloc(BuildContext context)
      : super(BaseProfileTextInputState());

  bool loading = false;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    yield LoadingState();
    if (event is ProfileTextInputInitEvent) {
      yield TextSetState();
    }

    if (event is ProfileUpdateEvent) {
      loading = true;
      yield LoadingState();
      String profileDate =
          "${event.profile.birthday.year}-${event.profile.birthday.month.toString().length == 1 ? "0${event.profile.birthday.month}" : "${event.profile.birthday.month}"}-${event.profile.birthday.day.toString().length == 1 ? "0${event.profile.birthday.day}" : "${event.profile.birthday.day}"}";
      var res = await ProfileRepository.updateUserProfile(
          name: event.name ?? event.profile.name ?? "",
          statusMessage:
              event.statusMessage ?? event.profile.statusMessage ?? "",
          birthday: profileDate,
          gender: event.profile.gender,
          profileImageName: event.profile.profileImageName);
      if (res is ServiceError) {
        loading = false;
        yield LoadingState();
      } else {
        loading = false;
        yield ProfileUpdateState();
      }
    }
  }
}

class ProfileUpdateEvent extends BaseBlocEvent {
  final Profile profile;
  final String name;
  final String statusMessage;

  ProfileUpdateEvent({this.profile, this.name, this.statusMessage});
}

class ProfileUpdateState extends BaseBlocState {}

class LoadingState extends BaseBlocState {}

class TextSetState extends BaseBlocState {}

class ProfileTextInputInitEvent extends BaseBlocEvent {}

class BaseProfileTextInputState extends BaseBlocState {}
