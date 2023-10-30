import 'dart:io';

import 'package:connect/data/remote/diary/diary_delete_service.dart';
import 'package:connect/data/remote/diary/diary_get_user_all_data_service.dart';
import 'package:connect/data/remote/diary/diary_get_user_data_service.dart';
import 'package:connect/data/remote/diary/diary_user_image_upload_service.dart';
import 'package:connect/data/remote/diary/diary_user_modify_service.dart';
import 'package:connect/data/remote/diary/diary_user_save_service.dart';
import 'package:connect/data/remote/diary/diary_user_write_check_service.dart';

class DiaryRepository {
  static Future<dynamic> diaryGetUserData(String date) =>
      DiaryGetUserDataService(date: date).start();

  static Future<dynamic> diaryGetUserAllData() =>
      DiaryGetUserAllDataService().start();

  static Future<dynamic> diaryUserImageUpload(File imageFile) =>
      DiaryUserImageUploadService(imageFile: imageFile).start();

  static Future<dynamic> diaryUserSaveService(
          String writeDatetime,
          String sleepDatetime,
          String wakeDatetime,
          String weatherType,
          String feelingType,
          String contentMessage,
          List<Map<String, dynamic>> contentImages,
          bool isPrivate) =>
      DiaryUserSaveService(
              writeDatetime: writeDatetime,
              sleepDatetime: sleepDatetime,
              wakeDatetime: wakeDatetime,
              weatherType: weatherType,
              feelingType: feelingType,
              contentMessage: contentMessage,
              isPrivate: isPrivate,
              contentImages: contentImages)
          .start();

  static Future<dynamic> diaryUserModifyService(
          String writeDatetime,
          String sleepDatetime,
          String wakeDatetime,
          String weatherType,
          String feelingType,
          String contentMessage,
          List<Map<String, dynamic>> contentImages,
          bool isPrivate,
          String id) =>
      DiaryUserModifyService(
              writeDatetime: writeDatetime,
              sleepDatetime: sleepDatetime,
              wakeDatetime: wakeDatetime,
              weatherType: weatherType,
              feelingType: feelingType,
              contentMessage: contentMessage,
              isPrivate: isPrivate,
              contentImages: contentImages,
              id: id)
          .start();

  static Future<dynamic> diaryUserWriteCheckService(String date) =>
      DiaryUserWriteCheckService(date: date).start();

  static Future<dynamic> diaryDeleteService(String id) => DiaryDeleteService(id: id).start();
}
