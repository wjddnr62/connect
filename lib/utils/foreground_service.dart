import 'package:connect/data/remote/base_service.dart';
import 'package:connect/data/tracking_repository.dart';
import 'package:connect/models/tracking.dart';
import 'package:connect/utils/toast/toast.dart';
import 'package:flutter_foreground_plugin/flutter_foreground_plugin.dart';
import 'package:foreground_service/foreground_service.dart';
import 'package:pedometer/pedometer.dart';
import 'package:connect/utils/extensions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void stopForegroundService() async {
  await ForegroundService.stopForegroundService();
}

void startForegroundService() async {
  await initPlatformState();
  if (!await ForegroundService.foregroundServiceIsStarted()) {
    await ForegroundService.notification.startEditMode();
    await ForegroundService.notification.setTitle("Tracking Steps");
    await ForegroundService.notification
        .setText("Rehabit is tracking your steps.");
    await ForegroundService.notification.finishEditMode();
    await ForegroundService.startForegroundService(foregroundServiceFunction);
    await ForegroundService.getWakeLock();
  } else {}
  await ForegroundService.setupIsolateCommunication((message) async {
    await initPlatformState();
  });
}

bool pedometerStart = false;

void foregroundServiceFunction() async {
  if (!ForegroundService.isIsolateCommunicationSetup) {
    await ForegroundService.setupIsolateCommunication((message) async {
      await initPlatformState();
    });
  }

  ForegroundService.sendToPort("send");
}

requestActivityRecognition() async {
  var status = await Permission.activityRecognition.status;
  if (await Permission.activityRecognition.request().isGranted) {
    startForegroundService();
    return true;
  } else {
    showToast("Please allow Rehabit to access to your steps record.");
    openAppSettings().then((value) async {
      status = await Permission.activityRecognition.status;
      if (status.isGranted) {
        startForegroundService();
        return true;
      }
    });
  }
  if (status.isPermanentlyDenied) {
    showToast("Please allow Rehabit to access to your steps record.");
    openAppSettings().then((value) async {
      status = await Permission.activityRecognition.status;
      if (status.isGranted) {
        startForegroundService();
        return true;
      }
    });
  }
  if (status.isDenied || status.isUndetermined) {
    Map<Permission, PermissionStatus> statuses =
        await [Permission.activityRecognition].request();
    if (statuses[Permission.activityRecognition].isGranted) {
      startForegroundService();
      return true;
    } else {
      showToast("Please allow Rehabit to access to your steps record.");
      openAppSettings().then((value) async {
        status = await Permission.activityRecognition.status;
        if (status.isGranted) {
          startForegroundService();
          return true;
        }
      });
    }
  }
}

Stream<StepCount> _stepCountStream;
Stream<PedestrianStatus> _pedestrianStatusStream;
SharedPreferences sharedPreferences;

void onStepCount(StepCount event) async {
  /// Handle step count changed
  if (await ForegroundService.foregroundServiceIsStarted()) {
    if (sharedPreferences == null) {
      sharedPreferences = await SharedPreferences.getInstance();
    }
    int saveStep = sharedPreferences.getInt("STEP") ?? 0;
    if (event.steps < saveStep) {
      await sharedPreferences.setInt("STEP", 0);
    }
    if (sharedPreferences.getString("DATETIME") == DateTime.now().isoYYYYMMDD) {
      await TrackingRepository.trackerPut(
          Tracking(step: event.steps - sharedPreferences.getInt("STEP")),
          DateTime.now().isoYYYYMMDD);
    } else {
      await sharedPreferences.setString("DATETIME", DateTime.now().isoYYYYMMDD);
      await sharedPreferences.setInt("STEP", event.steps);
    }
  }

  print("Step : ${event.steps}");
}

void onPedestrianStatusChanged(PedestrianStatus event) {
  /// Handle status changed
  print("Status : ${event.status}");
}

void onPedestrianStatusError(error) {
  /// Handle the error
  print("StatusError : $error");
}

void onStepCountError(error) {
  print("StepError : $error");

  /// Handle the error
}

Future<void> initPlatformState() async {
  /// Init streams
  _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
  _stepCountStream = Pedometer.stepCountStream;

  /// Listen to streams and handle errors
  _stepCountStream.listen(onStepCount).onError(onStepCountError);
  _pedestrianStatusStream
      .listen(onPedestrianStatusChanged)
      .onError(onPedestrianStatusError);
}
