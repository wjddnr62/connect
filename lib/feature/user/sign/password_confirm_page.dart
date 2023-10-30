import 'package:connect/feature/base_bloc.dart';
import 'package:connect/feature/splash/splash_page.dart';
import 'package:connect/feature/user/sign/password_confirm_bloc.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/user_log/events.dart';
import 'package:connect/user_log/user_logger.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/common_widgets.dart';
import 'package:connect/widgets/pages/error_page.dart';
import 'package:flutter/material.dart';

class PasswordConfirmPage extends BasicPage {
  static const String ROUTE_NAME = '/password_confirm_page';

  static Future<Object> push(BuildContext context) =>
      Navigator.of(context).pushNamed(ROUTE_NAME);

  @override
  Widget buildWidget(BuildContext context) => _PasswordConfirmPage();

  @override
  void handleArgument(BuildContext context) {}
}

class _PasswordConfirmPage extends BlocStatefulWidget {
  @override
  BlocState<PasswordConfirmBloc, BlocStatefulWidget> buildState() =>
      _PasswordConfirmState();
}

class _PasswordConfirmState
    extends BlocState<PasswordConfirmBloc, _PasswordConfirmPage> {
  final _textController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage;

  @override
  PasswordConfirmBloc initBloc() => PasswordConfirmBloc();

  @override
  blocListener(BuildContext context, state) {
    if (state is PasswordNotMatched) {
      setState(
          () => _errorMessage = AppStrings.of(StringKey.password_not_matched));
    }

    if (state is GoSplashToInitService) {
      UserLogger.logEventName(eventName: EventSign.SIGNUP_COMPLETE);
      pushNamedAndRemoveUntil(
          context, SplashPage.ROUTE_AFTER_LOGIN_BEFORE_PROFILE);
    }

    if (state is ShowError) {
      ErrorPage.push(context, params: {ErrorPage.PARAM_KEY_ERROR: state.error});
    }
  }

  @override
  blocBuilder(BuildContext context, state) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(children: [
          Container(
              margin: EdgeInsets.only(
                bottom: resize(100),
              ),
              child: ListView(children: <Widget>[
                Container(
                    margin: EdgeInsets.only(
                      top: resize(32),
                      left: resize(24),
                      right: resize(24),
                    ),
                    child: Text(AppStrings.of(StringKey.confirm_password),
                        textAlign: TextAlign.start,
                        style: AppTextStyle.from(
                            color: AppColors.black,
                            size: TextSize.title_large,
                            weight: TextWeight.extrabold,
                            height: AppTextStyle.LINE_HEIGHT_MULTI_LINE))),
                Container(
                    margin: EdgeInsets.all(resize(24)),
                    child: TextFormField(
                        key: Key('confirm_password'),
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
                        onEditingComplete:
                            _isLoading ? null : () => _go(_textController.text),
                        style: AppTextStyle.from(
                            size: TextSize.body_medium, color: AppColors.black),
                        decoration: InputDecoration(
                            hintText: AppStrings.of(StringKey.password),
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
                                weight: TextWeight.medium),
                            errorMaxLines: 3,
                            errorText: _errorMessage)))
              ])),
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  margin: EdgeInsets.only(
                      left: resize(16),
                      right: resize(16),
                      top: resize(16),
                      bottom: resize(32)),
                  child: Wrap(children: <Widget>[
                    Row(children: [
                      Expanded(
                          child: BottomButton(
                              text: AppStrings.of(StringKey.previous),
                              lineBoxed: true,
                              onPressed: () {
                                _errorMessage = null;
                                pop(context);
                              })),
                      SizedBox(width: resize(8)),
                      Expanded(
                          child: BottomButton(
                              text: AppStrings.of(StringKey.next),
                              onPressed: () => _go(_textController.text)))
                    ])
                  ])))
        ]));
  }

  void _go(String password) {
    bloc.add(ComparePassword(password));
  }
}
