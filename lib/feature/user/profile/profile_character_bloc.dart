import 'dart:io';

import 'package:connect/data/profile_repository.dart';
import 'package:connect/data/remote/profile/profile_service.dart';
import 'package:connect/models/error.dart';
import 'package:connect/models/profile.dart';
import 'package:connect/widgets/base_widget.dart';

import '../../base_bloc.dart';

class ProfileCharacterBloc extends BaseBloc {
  ProfileCharacterBloc(BuildContext context)
      : super(BaseProfileCharacterState());

  bool loading = false;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    yield ProfileCharacterInitState();

    if (event is SaveEvent) {
      loading = true;
      yield LoadingState();
      if (event.profileImageName == "IMAGE") {
        var res =
            await UpdateUserProfileImageService(imageFile: event.imageFile)
                .start();
        if (!res) {
          loading = false;
          yield SaveErrorState();
        } else {
          String profileDate =
              "${event.profile.birthday.year}-${event.profile.birthday.month.toString().length == 1 ? "0${event.profile.birthday.month}" : "${event.profile.birthday.month}"}-${event.profile.birthday.day.toString().length == 1 ? "0${event.profile.birthday.day}" : "${event.profile.birthday.day}"}";
          var response = await ProfileRepository.updateUserProfile(
              name: event.profile.name,
              statusMessage: event.profile.statusMessage,
              birthday: profileDate,
              gender: event.profile.gender,
              profileImageName: event.profileImageName);

          if (response is ServiceError) {
            loading = false;
            yield LoadingState();
          } else {
            loading = false;
            yield SaveState();
          }
        }
      } else {
        String profileDate =
            "${event.profile.birthday.year}-${event.profile.birthday.month.toString().length == 1 ? "0${event.profile.birthday.month}" : "${event.profile.birthday.month}"}-${event.profile.birthday.day.toString().length == 1 ? "0${event.profile.birthday.day}" : "${event.profile.birthday.day}"}";
        var response = await ProfileRepository.updateUserProfile(
            name: event.profile.name,
            statusMessage: event.profile.statusMessage,
            birthday: profileDate,
            gender: event.profile.gender,
            profileImageName: event.profileImageName);

        if (response is ServiceError) {
          loading = false;
          yield LoadingState();
        } else {
          loading = false;
          yield SaveState();
        }
      }
    }

    if (event is CharacterSelectEvent) {
      yield CharacterSelectState();
    }
  }
}

class BaseProfileCharacterState extends BaseBlocState {}

class ProfileCharacterInitEvent extends BaseBlocEvent {}

class ProfileCharacterInitState extends BaseBlocState {}

class SaveEvent extends BaseBlocEvent {
  final Profile profile;
  final File imageFile;
  final String profileImageName;

  SaveEvent({this.profile, this.imageFile, this.profileImageName});
}

class SaveErrorState extends BaseBlocState {}

class SaveState extends BaseBlocState {}

class CharacterSelectEvent extends BaseBlocEvent {}

class CharacterSelectState extends BaseBlocState {}

class LoadingState extends BaseBlocState {}
