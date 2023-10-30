import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> get _externalPath async {
  final directory = await getExternalStorageDirectory();
  return directory.path;
}

Future<File> writeToExternal(String path, String message) async {
  final externalPath = await _externalPath;
  return File('$externalPath/$path').writeAsString(message);
}
