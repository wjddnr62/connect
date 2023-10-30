import 'package:connect/feature/user/sign/password_input_page.dart';
import 'package:connect/feature/user/sign/sign_verifying_email_page.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/common_widgets.dart';
import 'package:flutter/material.dart';

import 'sign_email_input_bloc.dart';

class SignInputEmailPage extends BlocStatefulWidget {
  static const String ROUTE_NAME = '/input_email_page';

  const SignInputEmailPage({Key key}) : super(key: key);

  @override
  _SignInputEmailState buildState() {
    return _SignInputEmailState(StateCondition.AllChanged);
  }

  static Future<Object> pushAndRemoveUntil(BuildContext context) {
    return Navigator.of(context)
        .pushNamedAndRemoveUntil(ROUTE_NAME, (route) => false);
  }
}

class _SignInputEmailState
    extends BlocState<SignEmailInputBloc, SignInputEmailPage> {
  final _textController = TextEditingController();
  static bool _isLoading = false;
  static String _errorMessage;

  _SignInputEmailState(StateCondition condition)
      : super(conditionType: condition);

  @override
  SignEmailInputBloc initBloc() => SignEmailInputBloc();

  @override
  void initState() {
    super.initState();
    _textController.text = bloc.email ?? '';
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is EmailChecking) {
      setState(() => _isLoading = !state.completed);
    }

    if (state is EmailFormatError) {
      setState(() => _errorMessage = AppStrings.of(StringKey.invalid_email));
      return;
    }

    if (state is GotoEmailVerifyingPage) {
      SignVerifyingEmailPage.push(context);
      return;
    }

    if (state is GotoInputPassword) {
      PasswordInputPage.push(context);
      return;
    }

    if (state is EmailCheckError) {
      setState(() => _errorMessage = state.error.message);
    }
  }

  @override
  blocBuilder(BuildContext context, state) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(children: [
          Container(
              margin: EdgeInsets.only(bottom: resize(100)),
              child: ListView(children: <Widget>[
                Container(
                    margin: EdgeInsets.only(
                        top: resize(32), left: resize(24), right: resize(24)),
                    child: Text(AppStrings.of(StringKey.label_email_input),
                        textAlign: TextAlign.start,
                        style: AppTextStyle.from(
                            color: AppColors.black,
                            size: TextSize.title_large,
                            weight: TextWeight.extrabold,
                            height: AppTextStyle.LINE_HEIGHT_MULTI_LINE))),
                Container(
                    margin: EdgeInsets.all(resize(24)),
                    child: TextFormField(
                        key: Key('input_email'),
                        onChanged: (text) {
                          setState(() => _errorMessage = null);
                        },
                        autofocus: true,
                        cursorColor: AppColors.black,
                        maxLines: 1,
                        enabled: !_isLoading,
                        controller: _textController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.go,
                        onEditingComplete: _isLoading ? null : () => _go(),
                        style: AppTextStyle.from(
                            size: TextSize.body_medium, color: AppColors.black),
                        decoration: InputDecoration(
                            hintText: AppStrings.of(StringKey.hint_email_input),
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
                  width: double.maxFinite,
                  margin: EdgeInsets.only(
                      bottom: resize(32), left: resize(16), right: resize(16)),
                  child: BottomButton(
                      text: _isLoading
                          ? AppStrings.of(StringKey.starting)
                          : AppStrings.of(StringKey.start),
                      onPressed: _isLoading ? null : () => _go(),
                      color:
                          _isLoading ? AppColors.disable : AppColors.purple)))
        ]));
  }

  _go() {
    bloc.add(CheckEmailFormat(email: _textController.text));
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }
}
