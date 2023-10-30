


import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Brightness get _brightDark => Platform.isAndroid ? Brightness.dark : Brightness.light;
Brightness get _brightWhite => Platform.isAndroid ? Brightness.light : Brightness.dark;

SystemUiOverlayStyle get commonSystemUIOverlay =>SystemUiOverlayStyle(
    statusBarBrightness: _brightDark,
    statusBarIconBrightness: _brightDark,
    statusBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: _brightDark
);

SystemUiOverlayStyle get videoSystemUIOverlay =>SystemUiOverlayStyle(
    statusBarBrightness: _brightWhite,
    statusBarIconBrightness: _brightWhite,
    statusBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: _brightWhite
);