import 'package:connect/feature/user/sign/password_confirm_page.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/common_widgets.dart';
import 'package:flutter/material.dart';

import 'password_create_bloc.dart';

class PasswordCreatePage extends BlocStatefulWidget {
  static const String ROUTE_NAME = '/create_password_page';

  static Future<Object> popAndPush(BuildContext context) =>
      Navigator.of(context).popAndPushNamed(ROUTE_NAME);

  @override
  _PasswordCreateState buildState() => _PasswordCreateState();
}

class _PasswordCreateState
    extends BlocState<PasswordCreateBloc, PasswordCreatePage> {
  final _textController = TextEditingController();
  bool nextEnable = false;

  bool _isLoading = false;
  String _errorMessage;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      bool enable = _textController.text.length >= 8;
      if (enable != nextEnable) setState(() => nextEnable = enable);
    });
  }

  @override
  PasswordCreateBloc initBloc() => PasswordCreateBloc();

  @override
  blocListener(BuildContext context, state) {
    if (state is ShowPasswordRuleError) {
      setState(() => _errorMessage = state.message);
      return;
    }

    if (state is GotoConfirmPassword) {
      PasswordConfirmPage.push(context);
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
                    child: Text(AppStrings.of(StringKey.create_password),
                        textAlign: TextAlign.start,
                        style: AppTextStyle.from(
                            color: AppColors.black,
                            size: TextSize.title_large,
                            weight: TextWeight.extrabold,
                            height: AppTextStyle.LINE_HEIGHT_MULTI_LINE))),
                Container(
                    margin: EdgeInsets.all(resize(24)),
                    child: TextFormField(
                        key: Key('create_password'),
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
                                weight: TextWeight.medium,
                                height: 1.3),
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
                              color: nextEnable ? null : AppColors.grey,
                              text: AppStrings.of(StringKey.next),
                              onPressed: () => _go()))
                    ])
                  ])))
        ]));
  }

  void _go() {
    bloc.add(CheckPasswordRule(_textController.text));
  }
}
