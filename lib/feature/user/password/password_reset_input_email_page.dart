import 'package:connect/feature/user/password/reset_password_bloc.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/common_widgets.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:flutter/material.dart';

import '../../base_bloc.dart';

class PasswordResetInputEmailPage extends BlocStatefulWidget {
  const PasswordResetInputEmailPage({Key key}) : super(key: key);

  @override
  BlocState<ResetPasswordBloc, BlocStatefulWidget> buildState() {
    return _PasswordResetInputEmailState();
  }
}

class _PasswordResetInputEmailState
    extends BlocState<ResetPasswordBloc, PasswordResetInputEmailPage> {
  final _textController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage;

  @override
  ResetPasswordBloc initBloc() => ResetPasswordBloc();

  @override
  blocListener(BuildContext context, state) {
    if (prevState is Loading) {
      pop(context);
    }

    if (state is Loading) {
      showDialog(
        context: context,
        builder: (context) => WillPopScope(
          onWillPop: () async => pop(context),
          child: FullscreenDialog(),
        ),
        barrierDismissible: false,
      );
    }

    if (state is ErrorEmail) {
      setState(() {
        _errorMessage = AppStrings.of(StringKey.invalid_email);
      });

      return;
    }
  }

  @override
  blocBuilder(BuildContext context, state) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(
              bottom: resize(100),
            ),
            child: ListView(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(
                    top: resize(32),
                    left: resize(24),
                    right: resize(24),
                  ),
                  child: Text(
                    AppStrings.of(StringKey.reset_password),
                    textAlign: TextAlign.start,
                    style: AppTextStyle.from(
                      color: AppColors.black,
                      size: TextSize.title_large,
                      weight: TextWeight.extrabold,
                      height: AppTextStyle.LINE_HEIGHT_MULTI_LINE,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: resize(32),
                    left: resize(24),
                    right: resize(24),
                  ),
                  child: Text(
                    AppStrings.of(StringKey.reset_password_desc),
                    textAlign: TextAlign.start,
                    style: AppTextStyle.from(
                      color: AppColors.darkGrey,
                      size: TextSize.body_small,
                      weight: TextWeight.medium,
                      height: AppTextStyle.LINE_HEIGHT_MULTI_LINE,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(resize(24)),
                  child: TextFormField(
                    key: Key('input_email_password_reset'),
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
                      size: TextSize.body_medium,
                      color: AppColors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: AppStrings.of(StringKey.hint_email_input),
                      hintStyle: AppTextStyle.from(
                        size: TextSize.caption_large,
                        color: AppColors.lightGrey04,
                      ),
                      border: UnderlineInputBorder(
                        borderSide: new BorderSide(
                          width: resize(2),
                          color: AppColors.grey,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: new BorderSide(
                          width: resize(2),
                          color: AppColors.grey,
                        ),
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderSide: new BorderSide(
                          width: resize(1),
                          color: AppColors.error,
                        ),
                      ),
                      errorStyle: AppTextStyle.from(
                        background: Paint()..color = AppColors.redA25,
                        size: TextSize.caption_medium,
                        color: AppColors.errorText,
                        weight: TextWeight.medium,
                      ),
                      errorMaxLines: 3,
                      errorText: _errorMessage,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.maxFinite,
              margin: EdgeInsets.only(
                bottom: resize(32),
                left: resize(16),
                right: resize(16),
              ),
              child: BottomButton(
                text: _isLoading
                    ? AppStrings.of(StringKey.sending)
                    : AppStrings.of(StringKey.request_password_reset),
                onPressed: _isLoading ? null : () => _go(),
                color: _isLoading ? AppColors.disable : AppColors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _go() {}
}
