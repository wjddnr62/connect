import 'dart:io';

import 'package:connect/data/local/app_dao.dart';
import 'package:connect/feature/splash/splash_page.dart';
import 'package:connect/models/error.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/utils/logger/log.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/common_widgets.dart';
import 'package:flutter/material.dart';

import '../../connect_config.dart';

enum ErrorType {
  Network,
  Unknown,
}

// ignore: must_be_immutable
class ErrorPage extends BasicStatelessWidget {
  static const ROUTE_NAME = '/error_page';
  static const String _tag = 'ErrorPage';
  ErrorType errorType;
  ServiceError error;
  VoidCallback retry;
  String buttonText;

  static Map<String, dynamic> params = {};
  static const PARAM_KEY_ERROR_TYPE = 'error_type';
  static const PARAM_KEY_ERROR = 'error';
  static const PARAM_KEY_RETRY = 'retry';
  static const PARAM_KEY_BUTTON_TEXT = 'button_text';

  static Future<Object> popAndPush(BuildContext context,
      {Map<String, dynamic> params}) {
    return Navigator.of(context).popAndPushNamed(ROUTE_NAME, arguments: params);
  }

  static Future<Object> push(BuildContext context,
      {Map<String, dynamic> params}) {
    return Navigator.of(context).pushNamed(ROUTE_NAME, arguments: params);
  }

  static Future<Object> pushAndRemoveUntil(BuildContext context,
      {Map<String, dynamic> params}) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
        ROUTE_NAME, (route) => false,
        arguments: params);
  }

  ErrorPage({
    Key key,
    this.errorType = ErrorType.Unknown,
    this.error,
    this.retry,
    this.buttonText,
  }) : super(key: key);

  @override
  Widget buildWidget(BuildContext context) {
    RouteSettings settings = ModalRoute.of(context).settings;
    if (settings != null) {
      Map params = settings.arguments;
      this.errorType = params[PARAM_KEY_ERROR_TYPE] as ErrorType;
      this.error = params[PARAM_KEY_ERROR] as ServiceError;
      this.retry = params[PARAM_KEY_RETRY] as VoidCallback;
      this.buttonText = params[PARAM_KEY_BUTTON_TEXT] as String;
    }

    return WillPopScope(
        onWillPop: () async {
          if (retry == null) {
            pop(context);
          } else {
            retry();
          }
          return true;
        },
        child: Scaffold(body: _buildBody(context)));
  }

  Widget _buildBody(BuildContext context) {
    String errorImage = AppImages.ic_warning;
    String errorMessage = AppStrings.of(StringKey.desc_unknown_error);

    switch (errorType) {
      case ErrorType.Network:
        errorImage = AppImages.ic_warning;
        errorMessage = AppStrings.of(StringKey.desc_internet_connection_error);
        break;
      case ErrorType.Unknown:
      default:
        break;
    }

    List<Widget> list = [
      Image.asset(errorImage, width: resize(56), height: resize(56))
    ];

    if (error == null || gFlavor == Flavor.PROD) {
      list.add(Expanded(
          child: Container(
              margin: EdgeInsets.only(
                  top: resize(48), left: resize(24), right: resize(24)),
              child: Text(errorMessage,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.from(
                      size: TextSize.caption_large,
                      color: AppColors.grey,
                      weight: TextWeight.medium)))));
    } else {
      list.add(Container(
          margin: EdgeInsets.only(
              top: resize(48), left: resize(24), right: resize(24)),
          child: Text(errorMessage,
              textAlign: TextAlign.center,
              style: AppTextStyle.from(
                  size: TextSize.caption_large,
                  color: AppColors.grey,
                  weight: TextWeight.medium))));

      list.add(Expanded(
          child: Container(
              width: double.infinity,
              color: AppColors.lightGrey04,
              margin: EdgeInsets.all(resize(16)),
              padding: EdgeInsets.all(resize(16)),
              child: ListView(children: <Widget>[
                Text(
                    'CODE: ${error.code ?? 'UNKNOWN'}\nMESSAGE:${error.message ?? 'NO MESSAGE'}',
                    textAlign: TextAlign.start,
                    style: AppTextStyle.from(
                        size: TextSize.caption_large,
                        color: AppColors.darkGrey,
                        height: AppTextStyle.LINE_HEIGHT_MULTI_LINE))
              ]))));
    }

    if (errorType == ErrorType.Network || Platform.isIOS && retry == null) {
      Log.d(_tag, 'retry = $retry');
    } else {
      list.add(Container(
          margin: EdgeInsets.only(
              right: resize(16), left: resize(16), bottom: resize(32)),
          child: BottomButton(
              text: buttonText ?? AppStrings.of(StringKey.try_again),
              onPressed: () async {
                if ((error?.code ?? '') == 'INVALID_TOKEN') {
                  await Future.wait([
                    AppDao.setAccessToken(null),
                    AppDao.setName(null),
                    AppDao.setEmail(null),
                    AppDao.setUpdatedProfile(false)
                  ]);

                  SplashPage.pushAndRemoveUntil(
                      context, SplashPage.ROUTE_BEFORE_INTRO);
                  return;
                }
                retry == null ? pop(context) : retry();
              })));
    }

    return Container(
        margin: EdgeInsets.only(
          top: resize(192),
        ),
        child: Align(
            alignment: Alignment.bottomCenter,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: list)));
  }
}
