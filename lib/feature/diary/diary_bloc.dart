import 'dart:io';

import 'package:connect/data/diary_repository.dart';
import 'package:connect/data/local/app_dao.dart';
import 'package:connect/data/remote/auth/token_refresh_service.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/models/diary.dart';
import 'package:connect/models/error.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:flutter/services.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';

class DiaryBloc extends BaseBloc {
  DiaryBloc(BuildContext context) : super(BaseDiaryState());

  int selectWeather = 0;
  int selectFeeling = 0;

  List<String> weathersName = [
    "SUNNY",
    "CLOUDY",
    "CLEAR",
    "RAIN",
    "THUNDER",
    "RAINBOW",
    "SNOW",
    "WIND"
  ];

  List<String> feelingsName = [
    'GOOD',
    'NORMAL',
    'ANGRY',
    'DEPRESSED',
    'LOVELY',
    'WINK',
    'JOY',
    'SADNESS',
    'HEADACHE',
    'SURPRISE',
    'HAPPINESS',
    'MENTALBREAKDOWN'
  ];

  bool privateCheck = false;

  String userType = "";

  List<DiaryImage> imageUrl;

  bool loading = false;

  String writeTime;
  String sleepTime;
  String wakeTime;

  String contentMessage = "";

  Diary diaryData;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    // TODO: implement mapEventToState
    yield LoadingState();

    if (event is DiaryInitEvent) {
      loading = true;
      yield LoadingState();

      userType = await AppDao.marketPlace;

      if (event.type) {
        String date =
            "${event.selectDate.year}-${event.selectDate.month.toString().length == 1 ? "0${event.selectDate.month}" : "${event.selectDate.month}"}-${event.selectDate.day.toString().length == 1 ? "0${event.selectDate.day}" : "${event.selectDate.day}"}";
        List<dynamic> diary = await DiaryRepository.diaryGetUserData(date);

        diaryData = Diary.fromJson(diary[0]);
        for (int i = 0; i < weathersName.length; i++) {
          if (weathersName[i] == diaryData.weatherType) {
            selectWeather = i;
            break;
          }
        }

        for (int i = 0; i < feelingsName.length; i++) {
          if (feelingsName[i] == diaryData.feelingType) {
            selectFeeling = i;
            break;
          }
        }

        privateCheck = diaryData.isPrivate;

        if (diaryData.contentImages != null) imageUrl = diaryData.contentImages;
      }
      loading = false;
      yield DiaryInitState();
    }

    if (event is WeatherSelectEvent) {
      selectWeather = event.select;
      yield WeatherSelectState();
    }

    if (event is FeelingSelectEvent) {
      selectFeeling = event.select;
      yield FeelingSelectState();
    }

    if (event is MultiImageSelectEvent) {
      yield MultiImageSelectState();
    }

    if (event is PrivateCheckEvent) {
      privateCheck = !privateCheck;
      yield PrivateCheckState();
    }

    if (event is ImageRemoveEvent) {
      yield ImageRemoveState();
    }

    if (event is ImageGetUrlEvent) {
      loading = true;
      yield LoadingState();

      imageUrl = List();
      if (event.type) {
        if (diaryData.contentImages != null &&
            diaryData.contentImages.length == 3) {
          for (int i = 0; i < diaryData.contentImages.length; i++) {
            imageUrl.add(DiaryImage(
                seq: i + 1, imagePath: diaryData.contentImages[i].imagePath));
          }
        } else {
          if (diaryData.contentImages != null &&
              diaryData.contentImages.length > 0) {
            for (int i = 0; i < diaryData.contentImages.length; i++) {
              imageUrl.add(DiaryImage(
                  seq: i + 1, imagePath: diaryData.contentImages[i].imagePath));
            }
          }

          // for (int i = 0; i < event.imageList.length; i++) {
          if (event.imageList.isNotEmpty)
            await event.imageList[0].getByteData(quality: 30).then((value) async {
              Directory tempDir = await getTemporaryDirectory();
              String tempPath = tempDir.path;
              var filePath = tempPath + '/temp.${event.imageList[0].name.split(".")[1]}';
              File file = await File(filePath).writeAsBytes(value.buffer.asUint8List(value.offsetInBytes, value.lengthInBytes));
              var res = await DiaryRepository.diaryUserImageUpload(file);
              imageUrl.add(DiaryImage(
                  seq: 0 +
                      (diaryData.contentImages != null
                          ? diaryData.contentImages.length
                          : 0) +
                      1,
                  imagePath: res));
            });
            // await FlutterAbsolutePath.getAbsolutePath(
            //         event.imageList[i].identifier)
            //     .then((value) async {
            //   final file = File(value);
            //   var res = await DiaryRepository.diaryUserImageUpload(file);
            //   imageUrl.add(DiaryImage(
            //       seq: i +
            //           (diaryData.contentImages != null
            //               ? diaryData.contentImages.length
            //               : 0) +
            //           1,
            //       imagePath: res));
            // });
          // }
        }
      } else {
        // for (int i = 0; i < event.imageList.length; i++) {
        if (event.imageList.isNotEmpty)
          await event.imageList[0].getByteData(quality: 30).then((value) async {
            Directory tempDir = await getTemporaryDirectory();
            String tempPath = tempDir.path;
            var filePath = tempPath + '/temp.${event.imageList[0].name.split(".")[1]}';
            File file = await File(filePath).writeAsBytes(value.buffer.asUint8List(value.offsetInBytes, value.lengthInBytes));
            var res = await DiaryRepository.diaryUserImageUpload(file);
            imageUrl.add(DiaryImage(seq: 1, imagePath: res));
          });
          // await FlutterAbsolutePath.getAbsolutePath(
          //         event.imageList[i].identifier)
          //     .then((value) async {
          //   final file = File(value);
          //   var res = await DiaryRepository.diaryUserImageUpload(file);
          //   imageUrl.add(DiaryImage(seq: i + 1, imagePath: res));
          // });
        // }
      }

      yield ImageGetUrlState(image: imageUrl);
    }

    if (event is DiarySaveEvent) {
      List<Map<String, Object>> contentImages = List();
      for (int i = 0; i < event.image.length; i++) {
        contentImages
            .add({"seq": imageUrl[i].seq, "image_path": imageUrl[i].imagePath});
      }

      var res;

      if (event.type) {
        res = await DiaryRepository.diaryUserModifyService(
            writeTime,
            sleepTime,
            wakeTime,
            weathersName[selectWeather],
            feelingsName[selectFeeling],
            contentMessage,
            imageUrl.length == 0 ? null : contentImages,
            privateCheck,
            diaryData.id);
      } else {
        res = await DiaryRepository.diaryUserSaveService(
            writeTime,
            sleepTime,
            wakeTime,
            weathersName[selectWeather],
            feelingsName[selectFeeling],
            contentMessage,
            imageUrl.length == 0 ? null : contentImages,
            privateCheck);
      }

      if (res is ServiceError) {
        loading = false;
        yield DiarySaveFailState();
      } else {
        loading = false;
        yield DiarySaveState();
      }
    }
  }
}

class ImageRemoveEvent extends BaseBlocEvent {}

class ImageRemoveState extends BaseBlocState {}

class PrivateCheckEvent extends BaseBlocEvent {}

class PrivateCheckState extends BaseBlocState {}

class MultiImageSelectEvent extends BaseBlocEvent {}

class MultiImageSelectState extends BaseBlocState {}

class FeelingSelectEvent extends BaseBlocEvent {
  final int select;

  FeelingSelectEvent({this.select});
}

class FeelingSelectState extends BaseBlocState {}

class WeatherSelectEvent extends BaseBlocEvent {
  final int select;

  WeatherSelectEvent({this.select});
}

class WeatherSelectState extends BaseBlocState {}

class LoadingState extends BaseBlocState {}

class BaseDiaryState extends BaseBlocState {}

class ImageGetUrlEvent extends BaseBlocEvent {
  final List<Asset> imageList;
  final bool type;

  ImageGetUrlEvent({this.imageList, this.type});
}

class ImageGetUrlState extends BaseBlocState {
  final List<DiaryImage> image;

  ImageGetUrlState({this.image});
}

class DiarySaveEvent extends BaseBlocEvent {
  final List<DiaryImage> image;
  final bool type;

  DiarySaveEvent({this.image, this.type});
}

class DiarySaveState extends BaseBlocState {}

class DiarySaveFailState extends BaseBlocState {}

class DiaryInitState extends BaseBlocState {}

class DiaryInitEvent extends BaseBlocEvent {
  final bool type;
  final DateTime selectDate;

  DiaryInitEvent({this.type, this.selectDate});
}
