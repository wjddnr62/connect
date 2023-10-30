import 'dart:async';

import 'package:connect/feature/splash/splash_page.dart';
import 'package:connect/feature/user/login/login_page.dart';
import 'package:connect/feature/user/sign/sign_up_bloc.dart';
import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_images.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/user_log/events.dart';
import 'package:connect/user_log/user_logger.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/bottons/bottom_button.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:multiscreen/multiscreen.dart';

import '../../base_bloc.dart';

class SignUpPage extends BlocStatefulWidget {
  static const String ROUTE_NAME = "/sign_up_page";

  final bool type;
  final String socialType;
  final String sid;
  final String email;
  final String name;

  SignUpPage({this.type, this.socialType, this.sid, this.email, this.name});

  static Future<Object> push(BuildContext context) {
    return Navigator.of(context).pushNamed(ROUTE_NAME);
  }

  static Future<Object> signUpPush(BuildContext context,
      {bool type, String socialType, String sid, String email, String name}) {
    return Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SignUpPage(
              type: type,
              socialType: socialType,
              sid: sid,
              email: email,
              name: name,
            )));
  }

  @override
  _SignUpState buildState() => _SignUpState();
}

class _SignUpState extends BlocState<SignUpBloc, SignUpPage> {
  static String _errorMessage;

  static bool _isLoading = false;

  final emailInputController = TextEditingController();
  final passwordInputController = TextEditingController();
  final nameInputController = TextEditingController();
  final dateOfBirthController = TextEditingController();

  FocusNode emailInputFocus = FocusNode();
  FocusNode passwordInputFocus = FocusNode();
  FocusNode nameInputFocus = FocusNode();

  bool emailPassed = false;
  bool emailVerifyPassed = false;
  bool passwordPassed = false;
  bool namePassed = false;
  bool dateBirthPassed = false;

  bool nameReadOnly = false;

  bool passwordView = false;

  bool checkPasswordLength = false;
  bool checkPasswordNonContinuous = false;
  bool checkPasswordLeastTwoTypes = false;

  String birthday;

  signUpText(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: resize(30),
      padding: EdgeInsets.only(left: resize(20), right: resize(20)),
      child: Text(
        AppStrings.of(StringKey.sign_up),
        style: AppTextStyle.from(
            color: AppColors.black,
            size: TextSize.title_medium,
            weight: TextWeight.extrabold),
      ),
    );
  }

  emailCheck() {
    bloc.add(CheckEmailFormat(email: emailInputController.text));
  }

  emailInput(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: resize(24), right: resize(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.of(StringKey.email),
            style: AppTextStyle.from(
                weight: TextWeight.bold,
                size: TextSize.caption_small,
                color: _errorMessage == null
                    ? AppColors.darkGrey
                    : AppColors.error),
            textAlign: TextAlign.left,
          ),
          emptySpaceH(height: 8),
          TextFormField(
              onChanged: (text) {
                setState(() => _errorMessage = null);
                setState(() {
                  emailPassed = false;
                  bloc.emailSend = false;
                  emailVerifyPassed = false;
                });
                emailCheck();
              },
              autofocus: true,
              cursorColor: AppColors.black,
              maxLines: 1,
              controller: emailInputController,
              focusNode: emailInputFocus,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (value) {
                FocusScope.of(context).requestFocus(passwordInputFocus);
              },
              onEditingComplete: _isLoading ? null : () => emailCheck(),
              style: AppTextStyle.from(
                  size: TextSize.body_small, color: AppColors.black),
              decoration: InputDecoration(
                  suffixIcon: _errorMessage != null
                      ? Padding(
                          padding: EdgeInsets.only(
                              right: resize(16),
                              top: resize(12),
                              bottom: resize(12)),
                          child: Image.asset(
                            AppImages.ic_warning_circle,
                            width: resize(24),
                            height: resize(24),
                          ),
                        )
                      : null,
                  hintText: AppStrings.of(StringKey.type_your_email),
                  hintStyle: AppTextStyle.from(
                      size: TextSize.caption_large,
                      color: AppColors.lightGrey03),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: resize(1),
                          color: _errorMessage == null
                              ? AppColors.lightGrey04
                              : AppColors.error)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: resize(1),
                          color: _errorMessage == null
                              ? AppColors.lightGrey04
                              : AppColors.error)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: resize(1),
                          color: _errorMessage == null
                              ? AppColors.purple
                              : AppColors.error)),
                  contentPadding: EdgeInsets.only(
                    left: resize(16),
                    right: resize(8),
                  ))),
          emptySpaceH(height: 8),
          Container(
            width: MediaQuery.of(context).size.width,
            height: resize(40),
            child: Row(
              children: [
                _errorMessage != null
                    ? Expanded(
                        child: Text(
                          _errorMessage,
                          style: AppTextStyle.from(
                              size: TextSize.caption_medium,
                              color: AppColors.errorText,
                              weight: TextWeight.medium),
                          textAlign: TextAlign.left,
                        ),
                      )
                    : Container(),
                _errorMessage != null
                    ? emptySpaceW(width: 10)
                    : Expanded(child: Container()),
                emailVerifyPassed
                    ? Container(
                        width: resize(120),
                        height: resize(40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppImages.ic_check_circle_fill_true,
                              width: resize(24),
                              height: resize(24),
                            ),
                            emptySpaceW(width: 4),
                            Padding(
                              padding: EdgeInsets.only(top: resize(2)),
                              child: Text(
                                AppStrings.of(StringKey.verified),
                                style: AppTextStyle.from(
                                    color: AppColors.green,
                                    size: TextSize.caption_medium),
                                textAlign: TextAlign.center,
                              ),
                            )
                          ],
                        ),
                      )
                    : MaterialButton(
                        disabledColor: AppColors.lightGrey02,
                        disabledTextColor: AppColors.lightGrey03,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                resize(AppDimen.buttonRound))),
                        minWidth: resize(120),
                        height: resize(40),
                        color: AppColors.purple,
                        textColor: AppColors.white,
                        child: Center(
                          child: Text(AppStrings.of(bloc.emailSend
                              ? StringKey.resend
                              : StringKey.verify_email)),
                        ),
                        onPressed: emailPassed
                            ? () {
                                if (bloc.emailSend) {
                                  bloc.add(RequestVerifyEmail(
                                      email: emailInputController.text));
                                } else {
                                  verificationDescription();
                                }
                              }
                            : null)
              ],
            ),
          )
        ],
      ),
    );
  }

  passwordCheck() {
    bloc.add(CheckPasswordRule(password: passwordInputController.text));
    setState(() {});
  }

  passwordInput(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: resize(24), right: resize(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.of(StringKey.Password),
            style: AppTextStyle.from(
                weight: TextWeight.bold,
                size: TextSize.caption_small,
                color: AppColors.darkGrey),
            textAlign: TextAlign.left,
          ),
          emptySpaceH(height: 8),
          TextFormField(
              onChanged: (text) {
                passwordCheck();
              },
              onFieldSubmitted: (value) {
                FocusScope.of(context).requestFocus(nameInputFocus);
              },
              onEditingComplete: _isLoading ? null : () => passwordCheck(),
              cursorColor: AppColors.black,
              maxLines: 1,
              controller: passwordInputController,
              focusNode: passwordInputFocus,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              obscureText: passwordView ? false : true,
              style: AppTextStyle.from(
                  size: TextSize.body_small, color: AppColors.black),
              decoration: InputDecoration(
                  suffixIcon: Padding(
                    padding: EdgeInsets.only(
                        right: resize(16), top: resize(12), bottom: resize(12)),
                    child: GestureDetector(
                      onTap: () {
                        bloc.add(PasswordViewEvent(view: !passwordView));
                      },
                      child: Image.asset(
                        passwordView
                            ? AppImages.ic_eye_slash
                            : AppImages.ic_eye,
                        width: resize(24),
                        height: resize(24),
                      ),
                    ),
                  ),
                  hintText: AppStrings.of(StringKey.type_your_password),
                  hintStyle: AppTextStyle.from(
                      size: TextSize.caption_large,
                      color: AppColors.lightGrey03),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: resize(1), color: AppColors.lightGrey04)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: resize(1), color: AppColors.lightGrey04)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: resize(1), color: AppColors.purple)),
                  contentPadding: EdgeInsets.only(
                    left: resize(16),
                    right: resize(8),
                  ))),
          emptySpaceH(height: 12),
          passwordInvalid(AppStrings.of(StringKey.password_length_check_text)),
          emptySpaceH(height: 4),
          passwordInvalid(
              AppStrings.of(StringKey.non_continuous_characters_or_numbers)),
          emptySpaceH(height: 4),
          passwordInvalid(
              AppStrings.of(StringKey.contain_at_least_two_types_of)),
        ],
      ),
    );
  }

  passwordInvalid(text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          invalidTypeCheck(text, 0),
          width: resize(16),
          height: resize(16),
        ),
        emptySpaceW(width: 4),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: resize(3)),
            child: Text(
              text,
              style: AppTextStyle.from(
                size: TextSize.caption_small,
                color: invalidTypeCheck(text, 1),
              ),
              textAlign: TextAlign.start,
            ),
          ),
        )
      ],
    );
  }

  invalidTypeCheck(text, type) {
    if (text == AppStrings.of(StringKey.password_length_check_text) &&
        !checkPasswordLength) {
      if (type == 0) {
        return AppImages.ic_check_circle_fill_false;
      } else {
        return AppColors.grey;
      }
    } else if (text == AppStrings.of(StringKey.password_length_check_text) &&
        checkPasswordLength) {
      if (type == 0) {
        return AppImages.ic_check_circle_fill_true;
      } else {
        return AppColors.green;
      }
    }
    if (text == AppStrings.of(StringKey.non_continuous_characters_or_numbers) &&
            !checkPasswordNonContinuous ||
        !checkPasswordLength) {
      if (type == 0) {
        return AppImages.ic_check_circle_fill_false;
      } else {
        return AppColors.grey;
      }
    } else if (text ==
            AppStrings.of(StringKey.non_continuous_characters_or_numbers) &&
        checkPasswordNonContinuous &&
        checkPasswordLength) {
      if (type == 0) {
        return AppImages.ic_check_circle_fill_true;
      } else {
        return AppColors.green;
      }
    }
    if (text == AppStrings.of(StringKey.contain_at_least_two_types_of) &&
            !checkPasswordLeastTwoTypes ||
        !checkPasswordLength) {
      if (type == 0) {
        return AppImages.ic_check_circle_fill_false;
      } else {
        return AppColors.grey;
      }
    } else if (text == AppStrings.of(StringKey.contain_at_least_two_types_of) &&
        checkPasswordLeastTwoTypes &&
        checkPasswordLength) {
      if (type == 0) {
        return AppImages.ic_check_circle_fill_true;
      } else {
        return AppColors.green;
      }
    }
  }

  nameInput(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: resize(24), right: resize(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.of(StringKey.name),
            style: AppTextStyle.from(
                weight: TextWeight.bold,
                size: TextSize.caption_small,
                color: AppColors.darkGrey),
            textAlign: TextAlign.left,
          ),
          emptySpaceH(height: 8),
          TextFormField(
              readOnly: nameReadOnly,
              onChanged: (text) {
                setState(() {
                  if (text.length >= 1) {
                    namePassed = true;
                  } else {
                    namePassed = false;
                  }
                });
              },
              onFieldSubmitted: (value) {
                selectDate();
              },
              cursorColor: AppColors.black,
              maxLines: 1,
              controller: nameInputController,
              focusNode: nameInputFocus,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              style: AppTextStyle.from(
                  size: TextSize.body_small, color: AppColors.black),
              decoration: InputDecoration(
                  hintText: AppStrings.of(StringKey.please_enter_your_name),
                  hintStyle: AppTextStyle.from(
                      size: TextSize.caption_large,
                      color: AppColors.lightGrey03),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: resize(1), color: AppColors.lightGrey04)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: resize(1), color: AppColors.lightGrey04)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: resize(1), color: AppColors.purple)),
                  contentPadding: EdgeInsets.only(
                    left: resize(16),
                    right: resize(8),
                  ))),
        ],
      ),
    );
  }

  selectDate() {
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        minTime: DateTime(1920, 1, 1),
        maxTime: DateTime(DateTime.now().year, 12, 31), onCancel: () {
      dateOfBirthController.clear();
      setState(() {
        dateBirthPassed = false;
      });
    }, onConfirm: (date) {
      dateOfBirthController.text = "${date.day} / ${date.month} / ${date.year}";
      birthday =
          "${date.year}-${date.month.toString().length == 1 ? "0" + date.month.toString() : date.month}-${date.day.toString().length == 1 ? "0" + date.day.toString() : date.day}";
      setState(() {
        dateBirthPassed = true;
      });
    }, currentTime: DateTime.now(), locale: LocaleType.en);
  }

  dateOfBirthInput(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: resize(24), right: resize(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.of(StringKey.data_of_birth),
            style: AppTextStyle.from(
                weight: TextWeight.bold,
                size: TextSize.caption_small,
                color: AppColors.darkGrey),
            textAlign: TextAlign.left,
          ),
          emptySpaceH(height: 8),
          TextFormField(
              onTap: () {
                selectDate();
              },
              controller: dateOfBirthController,
              cursorColor: AppColors.black,
              readOnly: true,
              maxLines: 1,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTextStyle.from(
                  size: TextSize.body_small, color: AppColors.black),
              decoration: InputDecoration(
                  hintText: AppStrings.of(StringKey.date_of_birth),
                  hintStyle: AppTextStyle.from(
                      size: TextSize.caption_large,
                      color: AppColors.lightGrey03),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: resize(1), color: AppColors.lightGrey04)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: resize(1), color: AppColors.lightGrey04)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: resize(1), color: AppColors.purple)),
                  contentPadding: EdgeInsets.only(
                    left: resize(16),
                    right: resize(8),
                  ))),
        ],
      ),
    );
  }

  signUpButton(context) {
    return Padding(
      padding: EdgeInsets.only(left: resize(24), right: resize(24)),
      child: BottomButton(
        onPressed: (emailPassed &&
                passwordPassed &&
                namePassed &&
                dateBirthPassed &&
                emailVerifyPassed)
            ? () {
                bloc.add(SignUpEvent(
                    email: emailInputController.text,
                    password: passwordInputController.text,
                    name: nameInputController.text,
                    birthDay: birthday));
              }
            : null,
        text: AppStrings.of(StringKey.sign_up),
        textColor: (emailPassed &&
                passwordPassed &&
                namePassed &&
                dateBirthPassed &&
                emailVerifyPassed)
            ? AppColors.white
            : AppColors.lightGrey03,
      ),
    );
  }

  _buildMain(context) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (notification) {
        notification.disallowGlow();
        return true;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              emptySpaceH(height: 16),
              signUpText(context),
              emptySpaceH(height: 40),
              emailInput(context),
              emptySpaceH(height: 16),
              passwordInput(context),
              emptySpaceH(height: 8),
              nameInput(context),
              emptySpaceH(height: 8),
              dateOfBirthInput(context),
              emptySpaceH(height: 26),
              signUpButton(context),
              emptySpaceH(height: 24)
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    emailInputFocus.addListener(() {
      if (!emailInputFocus.hasFocus) {
        emailCheck();
      }
    });

    passwordInputFocus.addListener(() {
      if (!passwordInputFocus.hasFocus) {
        passwordCheck();
      }
    });
  }

  @override
  void dispose() {
    emailInputFocus.unfocus();
    passwordInputFocus.unfocus();
    nameInputFocus.unfocus();
    if (bloc.timer != null) bloc.timer.cancel();
    super.dispose();
  }

  bool isLoading = false;

  _buildProgress(BuildContext context) {
    if (!isLoading) return Container();

    return FullscreenDialog();
  }

  @override
  Widget blocBuilder(BuildContext context, state) {
    // TODO: implement blochBuilder
    return BlocBuilder(
      cubit: bloc,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: baseAppBar(
            context,
            backgroundColor: AppColors.white,
            elevation: 0.0,
            leading: IconButton(
                icon: Image.asset(AppImages.ic_chevron_left),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ),
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [_buildMain(context), _buildProgress(context)],
          ),
        );
      },
    );
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is SignUpInitState) {
      setState(() {
        _errorMessage = null;
      });
    }

    if (state is LoadingState) {
      setState(() {
        isLoading = true;
      });
    }

    if (state is EmailChecking) {
      setState(() {
        _isLoading = !state.completed;
        if (_errorMessage == null) {
          if (emailInputController.text.length != 0) emailPassed = true;
        } else {
          emailPassed = false;
        }
      });
    }

    if (state is EmailGood) {
      setState(() {
        emailPassed = true;
      });
    }

    if (state is EmailFormatError) {
      setState(() {
        if (emailInputController.text.length == 0) {
          _errorMessage = null;
          emailPassed = false;
        } else {
          _errorMessage = state.message;
        }
      });
      return;
    }

    if (state is EmailReduplicationError) {
      setState(() {
        if (emailInputController.text.length == 0) {
          _errorMessage = null;
          emailPassed = false;
        } else {
          _errorMessage = state.message;
        }
      });
      return;
    }

    if (state is EmailCheckError) {
      setState(() {
        if (emailInputController.text.length == 0) {
          _errorMessage = null;
          emailPassed = false;
        } else {
          _errorMessage = state.error.message;
        }
      });
    }

    if (state is PasswordView) {
      setState(() => passwordView = state.view);
    }

    if (state is PasswordRuleReturn) {
      setState(() {
        if (state.checkTypeList.contains(0)) {
          checkPasswordLength = false;
          passwordPassed = false;
        } else {
          checkPasswordLength = true;
        }

        if (state.checkTypeList.contains(1)) {
          checkPasswordNonContinuous = false;
          passwordPassed = false;
        } else {
          checkPasswordNonContinuous = true;
        }

        if (state.checkTypeList.contains(2)) {
          checkPasswordLeastTwoTypes = false;
          passwordPassed = false;
        } else {
          checkPasswordLeastTwoTypes = true;
        }

        if (state.checkTypeList.contains(4)) {
          passwordPassed = false;
        } else {
          checkPasswordLength = true;
          checkPasswordNonContinuous = true;
          checkPasswordLeastTwoTypes = true;
          passwordPassed = true;
        }
      });
      setState(() {});
    }

    if (state is LoginError) {
      LoginPage.pushAndRemoveUntil(context);
    }

    if (state is SignUpError) {
      setState(() {
        isLoading = false;
      });
      // 에러 처리
    }

    if (state is GoSplashToInitService) {
      setState(() {
        if (bloc.timer != null) bloc.timer.cancel();
        isLoading = false;
      });
      UserLogger.logEventName(eventName: EventSign.LOGIN_COMPLETE);
      pushNamedAndRemoveUntil(context, SplashPage.ROUTE_FIRST_LOGIN);
    }

    if (state is VerifiedEmail) {
      emailVerifyPassed = true;
      setState(() {});
    }

    if (state is ReloadState) {
      setState(() {});
    }
  }

  @override
  initBloc() {
    // TODO: implement initBloc
    return SignUpBloc(context)..add(SignUpInitEvent());
  }

  verificationDescription() {
    showDialog(
        barrierDismissible: true,
        context: (context),
        builder: (_) {
          return Dialog(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(resize(32)),
                  topRight: Radius.circular(resize(32)),
                  bottomLeft: Radius.circular(resize(40)),
                  bottomRight: Radius.circular(resize(40))),
            ),
            backgroundColor: AppColors.white,
            child: Container(
              width: resize(312),
              height: resize(348),
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  emptySpaceH(height: 32),
                  Image.asset(
                    AppImages.ic_check_circle_green,
                    width: resize(64),
                    height: resize(64),
                  ),
                  emptySpaceH(height: 16),
                  Container(
                    padding:
                        EdgeInsets.only(left: resize(16), right: resize(16)),
                    color: AppColors.white,
                    child: Center(
                      child: Text(
                        AppStrings.of(StringKey.verification_message),
                        style: AppTextStyle.from(
                            size: TextSize.caption_large,
                            color: AppColors.darkGrey,
                            weight: TextWeight.semibold,
                            height: 1.45),
                        textAlign: TextAlign.left,
                        // strutStyle: StrutStyle(leading: 0.55),
                      ),
                    ),
                  ),
                  Expanded(child: Container()),
                  Container(
                    width: resize(MediaQuery.of(context).size.width),
                    height: resize(72),
                    child: RaisedButton(
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          bloc.add(RequestVerifyEmail(
                              email: emailInputController.text));
                        },
                        color: AppColors.lightPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(resize(32)),
                              bottomRight: Radius.circular(resize(32))),
                        ),
                        elevation: 0,
                        child: Center(
                          child: Container(
                            width: resize(160),
                            height: resize(23.6),
                            child: Center(
                              child: Text(
                                AppStrings.of(StringKey.confirm),
                                style: AppTextStyle.from(
                                    color: AppColors.white,
                                    size: TextSize.body_small,
                                    weight: TextWeight.semibold),
                              ),
                            ),
                          ),
                        )),
                  )
                ],
              ),
            ),
          );
        });
  }
}
