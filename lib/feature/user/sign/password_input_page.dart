import 'package:connect/feature/bottom_navigation/home_navigation.dart';
import 'package:connect/feature/home/home_calendar.dart';
import 'package:connect/feature/splash/splash_page.dart';
import 'package:connect/feature/user/password/password_reset_guide_page.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/user_log/events.dart';
import 'package:connect/user_log/user_logger.dart';
import 'package:connect/utils/logger/log.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/common_widgets.dart';
import 'package:flutter/material.dart';

import '../../base_bloc.dart';
import '../sign_info.dart';
import 'password_input_bloc.dart';

class PasswordInputPage extends BlocStatefulWidget {
  static const String ROUTE_NAME = '/input_password_password_page';

  @override
  BlocState<PasswordInputBloc, BlocStatefulWidget> buildState() {
    return _PasswordInputState();
  }

  static Future<Object> push(BuildContext context) {
    return Navigator.pushNamed(context, ROUTE_NAME);
  }
}

class _PasswordInputState
    extends BlocState<PasswordInputBloc, PasswordInputPage> {
  final _textController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage;

  _PasswordInputState();

  @override
  PasswordInputBloc initBloc() => PasswordInputBloc();

  @override
  blocListener(BuildContext context, state) {
    if (state is Logining) {
      setState(() => _isLoading = !state.completed);
    }

    if (state is ShowPasswordFormatError) {
      setState(() => _errorMessage = state.message);
      return;
    }

    if (state is ShowPasswordWrongError) {
      setState(
          () => _errorMessage = AppStrings.of(StringKey.incorrect_password));
      return;
    }

    if (state is GoSplashToInitService) {
      UserLogger.logEventName(eventName: EventSign.LOGIN_COMPLETE);
      pushNamedAndRemoveUntil(
          context, SplashPage.ROUTE_AFTER_LOGIN_BEFORE_PROFILE);
    }

    if (state is GoHome) {
      // HomeCalendarPage.pushAndRemoveUntil(context);
      HomeNavigation.pushAndRemoveUntil(context);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  blocBuilder(BuildContext context, state) {
    Log.d('_PasswordInputState', 'loading = $_isLoading');
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Stack(children: [
          Container(
              margin: EdgeInsets.only(bottom: resize(100)),
              child: ListView(children: <Widget>[
                Container(
                    margin: EdgeInsets.only(
                        top: resize(32), left: resize(24), right: resize(24)),
                    child: Text(AppStrings.of(StringKey.type_password),
                        textAlign: TextAlign.start,
                        style: AppTextStyle.from(
                            color: AppColors.black,
                            size: TextSize.title_large,
                            weight: TextWeight.extrabold,
                            height: AppTextStyle.LINE_HEIGHT_MULTI_LINE))),
                Container(
                    margin: EdgeInsets.all(resize(24)),
                    child: TextFormField(
                        key: Key('input_password'),
                        onChanged: (text) =>
                            setState(() => _errorMessage = null),
                        obscureText: true,
                        autofocus: true,
                        cursorColor: AppColors.black,
                        maxLines: 1,
                        enabled: !_isLoading,
                        controller: _textController,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.go,
                        onEditingComplete: _isLoading ? null : () => _go(),
                        style: AppTextStyle.from(
                            size: TextSize.body_medium, color: AppColors.black),
                        decoration: InputDecoration(
                            hintText:
                                '${AppStrings.of(StringKey.password)[0].toUpperCase()}${AppStrings.of(StringKey.password).substring(1)}',
                            hintStyle: AppTextStyle.from(
                                size: TextSize.caption_large,
                                color: AppColors.lightGrey04),
                            border: UnderlineInputBorder(
                                borderSide: new BorderSide(
                                    width: resize(2), color: AppColors.grey)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: new BorderSide(
                                    width: resize(2), color: AppColors.grey)),
                            errorBorder: UnderlineInputBorder(
                                borderSide: new BorderSide(
                                    width: resize(1), color: AppColors.error)),
                            errorStyle: AppTextStyle.from(
                                background: Paint()..color = AppColors.redA25,
                                size: TextSize.caption_medium,
                                color: AppColors.errorText,
                                weight: TextWeight.medium,
                                height: 1.3),
                            errorMaxLines: 3,
                            errorText: _errorMessage)))
              ])),
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  margin: EdgeInsets.all(resize(16)),
                  child: Wrap(children: <Widget>[
                    Row(children: [
                      Expanded(
                          child: BottomButton(
                              text: AppStrings.of(StringKey.previous),
                              lineBoxed: true,
                              lineColor: _isLoading
                                  ? AppColors.disable
                                  : AppColors.purple,
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      _textController.clear();
                                      SignInfo.instance.password = '';
                                      _errorMessage = null;
                                      pop(context);
                                    })),
                      SizedBox(
                        width: resize(8),
                      ),
                      Expanded(
                          child: BottomButton(
                              text: AppStrings.of(StringKey.next),
                              color: _isLoading
                                  ? AppColors.disable
                                  : AppColors.purple,
                              onPressed: _isLoading ? null : _go))
                    ]),
                    Container(
                        alignment: Alignment.center,
                        margin:
                            EdgeInsets.only(top: resize(16), bottom: resize(4)),
                        child: GestureDetector(
                            child: Text(
                                AppStrings.of(StringKey.forgot_password),
                                style: AppTextStyle.from(
                                    color: AppColors.darkGrey,
                                    size: TextSize.caption_medium,
                                    weight: TextWeight.medium)),
                            onTap: () {
                              SignInfo.instance.password = '';
                              _textController.clear();
                              PasswordResetGuidePage.push(
                                  context, SignInfo.instance.emailId);
                            }))
                  ])))
        ])));
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _go() => bloc.add(Login(_textController.text));
}
