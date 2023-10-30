import 'package:connect/data/clinic_repository.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/models/clinic.dart';
import 'package:connect/models/error.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ConnectClinicBloc extends BaseBloc {
  ClinicRepository repository;

  ConnectClinicBloc(BuildContext context) : super(_InitState()) {
    repository = Provider.of<ClinicRepository>(context, listen: false);
  }

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is LoadClinics) {
      yield Loading();

      var response = await repository.getClinicList();

      if (response is ServiceError) {
        yield ShowError(error: response);
        return;
      }

      yield LoadComplete(clinics: response);
      return;
    }

    if (event is SaveClinic) {
      yield CheckToSaveClinic();
      return;
    }

    if (event is ConfirmToSave) {
      yield Saving();

      var response = await repository.saveClinic(event.clinic);
      if (response is ServiceError) {
        yield ShowError(error: response);
        return;
      }

      yield SaveComplete();
    }
  }
}

class _InitState extends BaseBlocState {}

class LoadClinics extends BaseBlocEvent {}

class LoadComplete extends BaseBlocState {
  final List<Clinic> clinics;

  LoadComplete({this.clinics});
}

class SaveClinic extends BaseBlocEvent {
  final Clinic clinic;

  SaveClinic(this.clinic);
}

class CheckToSaveClinic extends BaseBlocState {}

class ConfirmToSave extends BaseBlocEvent {
  final Clinic clinic;

  ConfirmToSave(this.clinic);
}

class Saving extends BaseBlocState {}

class SaveComplete extends BaseBlocState {}
