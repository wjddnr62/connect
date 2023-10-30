import 'package:connect/data/remote/clinic/clinic_service.dart';
import 'package:connect/models/clinic.dart';
import 'package:connect/models/error.dart';
import 'package:flutter/foundation.dart';

class ClinicRepository with ChangeNotifier {
  Clinic clinic;
  ClinicStatus clinicStatus;

  setClinic(Clinic clinic) {
    this.clinic = clinic;
    notifyListeners();
  }

  Future<dynamic> getClinicList() async {
    return await GetClinicListService().start();
  }

  Future<dynamic> saveClinic(Clinic clinic) async {
    var response = await SaveClinicService(clinic).start();

    if (response is ServiceError) {
      return response;
    }

    if (response) {
      clinicStatus.requested = clinic;
      clinicStatus.state = CLINIC_STATE_WAITING;

      notifyListeners();
    }
  }
}
