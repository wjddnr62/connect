import 'package:connect/resources/app_resources.dart';
import 'package:flutter/material.dart';

emptySpaceW({double width}) {
  return SizedBox(
    width: resize(width),
  );
}

emptySpaceH({double height}) {
  return SizedBox(
    height: resize(height),
  );
}
