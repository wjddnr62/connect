import 'dart:io';

import 'package:connect/connect_app.dart';
import 'package:connect/data/duration_repository.dart';
import 'package:connect/data/remote/base_service.dart';
import 'package:connect/data/user_repository.dart';
import 'package:connect/feature/splash/splash_page.dart';
import 'package:connect/feature/user/login/login_bloc.dart';
import 'package:connect/feature/user/password/forgot_password_page.dart';
import 'package:connect/feature/user/sign/sign_up_page.dart';
import 'package:connect/feature/user/sign/sign_up_select_page.dart';
import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_images.dart';
import 'package:connect/resources/app_strings.dart';
import 'package:connect/resources/app_text_style.dart';
import 'package:connect/user_log/events.dart';
import 'package:connect/user_log/user_logger.dart';
import 'package:connect/utils/appsflyer/apps_flyer.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:connect/utils/regular_expressions.dart';
import 'package:connect/utils/social_login.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/bottons/bottom_button.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:multiscreen/multiscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../connect_config.dart';
import '../../base_bloc.dart';

class LoginPage extends BlocStatefulWidget {
  static const String ROUTE_NAME = '/login_page';

  static Future<Object> push(BuildContext context) {
    return Navigator.of(context).pushNamed(ROUTE_NAME);
  }

  static Future<Object> pushAndRemoveUntil(BuildContext context) {
    return Navigator.of(context)
        .pushNamedAndRemoveUntil(ROUTE_NAME, (route) => false);
  }

  @override
  _LoginState buildState() => _LoginState();
}

class _LoginState extends BlocState<LoginBloc, LoginPage> {
  final emailInputController = TextEditingController();
  final passwordInputController = TextEditingController();

  FocusNode emailInputFocus = FocusNode();
  FocusNode passwordInputFocus = FocusNode();

  bool error = false;

  bool passwordView = false;

  bool emailPassed = false;
  bool passwordPassed = false;

  bool loginPassed = false;

  bool isLoading = false;

  bool appleWeb = false;

  PanelController panelController = PanelController();

  neofectLogo(context) {
    return Image.asset(
      AppImages.img_logo_rehabit_black,
      width: resize(146),
      height: resize(32),
    );
  }

  emailInput(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: AppColors.white,
      child: TextFormField(
          onChanged: (text) {
            setState(() {
              error = false;
              if (validateEmailFormat(text)) {
                emailPassed = true;
                if (passwordPassed) {
                  loginPassed = true;
                }
              } else {
                emailPassed = false;
                loginPassed = false;
              }
            });
          },
          cursorColor: AppColors.black,
          maxLines: 1,
          controller: emailInputController,
          focusNode: emailInputFocus,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (value) {
            FocusScope.of(context).requestFocus(passwordInputFocus);
          },
          style: AppTextStyle.from(
              size: TextSize.body_small, color: AppColors.black),
          decoration: InputDecoration(
              suffixIcon: error
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
                  size: TextSize.caption_large, color: AppColors.lightGrey03),
              border: OutlineInputBorder(
                  borderSide: BorderSide(
                      width: resize(1),
                      color: !error ? AppColors.lightGrey04 : AppColors.error)),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      width: resize(1),
                      color: !error ? AppColors.lightGrey04 : AppColors.error)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      width: resize(1),
                      color: !error ? AppColors.purple : AppColors.error)),
              contentPadding: EdgeInsets.only(
                left: resize(16),
                right: resize(8),
              ))),
    );
  }

  passwordInput(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: resize(74),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: resize(48),
            color: AppColors.white,
            child: TextFormField(
                onChanged: (text) {
                  setState(() {
                    error = false;
                    if (text.length >= 6) {
                      passwordPassed = true;
                      if (emailPassed) {
                        loginPassed = true;
                      }
                    } else {
                      passwordPassed = false;
                      loginPassed = false;
                    }
                  });
                },
                onFieldSubmitted: (value) {
                  if (loginPassed) {
                    login(context);
                  }
                },
                cursorColor: AppColors.black,
                maxLines: 1,
                controller: passwordInputController,
                focusNode: passwordInputFocus,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                obscureText: passwordView ? false : true,
                style: AppTextStyle.from(
                    size: TextSize.body_small, color: AppColors.black),
                decoration: InputDecoration(
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(
                          right: resize(16),
                          top: resize(12),
                          bottom: resize(12)),
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
                            width: resize(1),
                            color: !error
                                ? AppColors.lightGrey04
                                : AppColors.error)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: resize(1),
                            color: !error
                                ? AppColors.lightGrey04
                                : AppColors.error)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: resize(1),
                            color:
                                !error ? AppColors.purple : AppColors.error)),
                    contentPadding: EdgeInsets.only(
                      left: resize(16),
                      right: resize(8),
                    ))),
          ),
          emptySpaceH(height: 8),
          error
              ? Container(
                  height: resize(18),
                  child: Text(
                    AppStrings.of(StringKey.wrong_email_of_password),
                    style: AppTextStyle.from(
                        color: AppColors.error, size: TextSize.caption_medium),
                  ),
                )
              : Container(
                  height: resize(18),
                )
        ],
      ),
    );
  }

  forgotPassword(context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          ForgotPasswordPage.push(context);
        },
        child: Container(
          child: Text(
            AppStrings.of(StringKey.forgot_password),
            style: AppTextStyle.from(
                color: AppColors.purple, size: TextSize.caption_medium),
            textAlign: TextAlign.left,
          ),
        ),
      ),
    );
  }

  login(context) {
    bloc.add(LoginEvent(
        email: emailInputController.text,
        password: passwordInputController.text));
  }

  loginButton(context) {
    return BottomButton(
      onPressed: loginPassed
          ? () {
              appsflyer.saveLog(neofectSelect);
              login(context);
            }
          : null,
      text: AppStrings.of(StringKey.login),
      textColor: loginPassed ? AppColors.white : AppColors.lightGrey03,
    );
  }

  orText(context) {
    return Text(
      AppStrings.of(StringKey.or),
      style: AppTextStyle.from(
          color: AppColors.grey, size: TextSize.caption_small),
      textAlign: TextAlign.center,
    );
  }

  loginGoogle(context) {
    return ElevatedButton(
        onPressed: () {
          appsflyer.saveLog(googleSelect);
          googleLogin(context);
        },
        style: ElevatedButton.styleFrom(
            primary: AppColors.white,
            side: BorderSide(color: AppColors.lightGrey04, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            elevation: 0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 54,
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                AppImages.ic_sign_google,
                width: resize(24),
                height: resize(24),
              ),
              emptySpaceW(width: 16),
              Text(
                AppStrings.of(StringKey.continue_with_google),
                style: AppTextStyle.from(
                    color: AppColors.black,
                    size: TextSize.caption_large,
                    weight: TextWeight.semibold),
                textAlign: TextAlign.left,
              )
            ],
          ),
        ));
  }

  loginFacebook(context) {
    return ElevatedButton(
        onPressed: () {
          appsflyer.saveLog(facebookSelect);
          facebookLogin(context);
        },
        style: ElevatedButton.styleFrom(
            primary: AppColors.white,
            side: BorderSide(color: AppColors.lightGrey04),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            elevation: 0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 54,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  AppImages.ic_sign_facebook,
                  width: resize(24),
                  height: resize(24),
                ),
                emptySpaceW(width: 16),
                Text(
                  AppStrings.of(StringKey.sign_in_with_facebook),
                  style: AppTextStyle.from(
                      color: AppColors.black,
                      size: TextSize.caption_large,
                      weight: TextWeight.semibold),
                  textAlign: TextAlign.left,
                )
              ],
            ),
          ),
        ));
  }

  loginApple(context) {
    return ElevatedButton(
        onPressed: () {
          appsflyer.saveLog(appleSelect);
          if (Platform.isIOS) {
            appleLogin(context);
            bloc.add(StartLoadingEvent());
          } else {
            bloc.add(AppleLoginEvent(type: 0));
          }
        },
        style: ElevatedButton.styleFrom(
            primary: AppColors.white,
            side: BorderSide(color: AppColors.lightGrey04),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            elevation: 0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 54,
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                AppImages.ic_sign_apple,
                width: resize(24),
                height: resize(24),
              ),
              emptySpaceW(width: 16),
              Text(
                AppStrings.of(StringKey.sign_in_with_apple),
                style: AppTextStyle.from(
                    color: AppColors.black,
                    size: TextSize.caption_large,
                    weight: TextWeight.semibold),
                textAlign: TextAlign.left,
              )
            ],
          ),
        ));
  }

  signUpText(context) {
    return GestureDetector(
      onTap: () {
        SignUpSelectPage.push(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppStrings.of(StringKey.dont_have_an_account),
            style: AppTextStyle.from(
              color: AppColors.darkGrey,
              size: TextSize.caption_medium,
            ),
          ),
          emptySpaceW(width: 8),
          Text(
            AppStrings.of(StringKey.sign_up),
            style: AppTextStyle.from(
                color: AppColors.darkGrey,
                size: TextSize.caption_medium,
                weight: TextWeight.bold,
                decoration: TextDecoration.underline),
          )
        ],
      ),
    );
  }

  _buildProgress(BuildContext context) {
    if (!isLoading) return Container();

    return FullscreenDialog();
  }

  bool setView = false;
  int touch = 0;

  setRelease() {
    if (gProduction != "prod-release") {
      return setView
          ? Container(
              width: MediaQuery.of(context).size.width,
              height: resize(50),
              color: AppColors.lightGrey01,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: GestureDetector(
                        onTap: () {
                          bloc.prefs.setString("set", "DEV");
                          mainCommon();
                        },
                        child: Container(
                          child: Center(
                            child: Text(
                              "DEV",
                              style: AppTextStyle.from(
                                  size: TextSize.body_medium,
                                  weight:
                                      (bloc.prefs.getString("set") ?? "DEV") ==
                                              "DEV"
                                          ? TextWeight.bold
                                          : TextWeight.medium),
                            ),
                          ),
                        ),
                      )),
                      Expanded(
                          child: GestureDetector(
                        onTap: () {
                          bloc.prefs.setString("set", "STAGE");
                          mainCommon();
                        },
                        child: Container(
                          child: Center(
                            child: Text(
                              "STAGE",
                              style: AppTextStyle.from(
                                  size: TextSize.body_medium,
                                  weight: bloc.prefs.getString("set") == "STAGE"
                                      ? TextWeight.bold
                                      : TextWeight.medium),
                            ),
                          ),
                        ),
                      )),
                      !kReleaseMode
                          ? Expanded(
                              child: GestureDetector(
                              onTap: () {
                                bloc.prefs.setString("set", "PROD");
                                mainCommon();
                              },
                              child: Container(
                                child: Center(
                                  child: Text(
                                    "PROD",
                                    style: AppTextStyle.from(
                                        size: TextSize.body_medium,
                                        weight: bloc.prefs.getString("set") ==
                                                "PROD"
                                            ? TextWeight.bold
                                            : TextWeight.medium),
                                  ),
                                ),
                              ),
                            ))
                          : Container(),
                    ],
                  ),
                  emptySpaceH(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Center(
                          child: Text(
                            "LOG",
                            style: AppTextStyle.from(
                              size: TextSize.body_medium,
                            ),
                          ),
                        ),
                      ),
                      emptySpaceW(width: 8),
                      GestureDetector(
                        onTap: () {
                          if ((bloc.prefs.getBool("log") ?? false)) {
                            bloc.prefs.setBool("log", false);
                          } else {
                            bloc.prefs.setBool("log", true);
                          }
                          mainCommon();
                        },
                        child: Container(
                          child: Center(
                            child: Text(
                              (bloc.prefs.getBool("log") ?? false)
                                  ? "ON"
                                  : "OFF",
                              style: AppTextStyle.from(
                                  size: TextSize.body_medium,
                                  weight: TextWeight.bold),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          : GestureDetector(
              onTap: () {
                touch += 1;
                if (touch > 5) {
                  setState(() {
                    setView = true;
                  });
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: resize(50),
                color: AppColors.lightGrey01,
              ),
            );
    } else {
      return Container();
    }
  }

  otherLoginOptionButton() {
    return ElevatedButton(
        onPressed: () {
          panelController.open();
        },
        style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: EdgeInsets.zero,
            primary: AppColors.white,
            side: BorderSide(color: AppColors.lightGrey04),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: resize(54),
          child: Center(
            child: Text(
              AppStrings.of(StringKey.other_login_options),
              style: AppTextStyle.from(
                  color: AppColors.black,
                  size: TextSize.caption_large,
                  weight: TextWeight.semibold),
            ),
          ),
        ));
  }

  _buildMain(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        emptySpaceH(height: 86),
        neofectLogo(context),
        emptySpaceH(height: 52),
        emailInput(context),
        emptySpaceH(height: 12),
        passwordInput(context),
        emptySpaceH(height: 40),
        forgotPassword(context),
        emptySpaceH(height: 16),
        loginButton(context),
        emptySpaceH(height: 12),
        orText(context),
        emptySpaceH(height: 12),
        otherLoginOptionButton(),
        emptySpaceH(height: 32),
        setRelease(),
        signUpText(context),
      ],
    );
  }

  appleWebPage() {
    return WebView(
      javascriptMode: JavascriptMode.unrestricted,
      initialUrl:
          "https://appleid.apple.com/auth/authorize?response_type=code%20id_token&response_mode=form_post&client_id=com.neofect.connect.service&scope=name%20email&redirect_uri=${baseUrl}uaa/apple/callbacks/sign_in_with_apple",
      onPageStarted: (url) async {
        if (url !=
            "https://appleid.apple.com/auth/authorize?response_type=code%20id_token&response_mode=form_post&client_id=com.neofect.connect.service&scope=name%20email&redirect_uri=${baseUrl}uaa/apple/callbacks/sign_in_with_apple") {
          bloc.add(AppleLoginEvent(type: 1));
        }
        if (url.contains("intent")) {
          bloc.add(StartLoadingEvent());
          String idToken = url.split("&")[1].split('#')[0].split('=')[1];

          Map<String, dynamic> decodeToken = JwtDecoder.decode(idToken);

          String appleSid = 'ap' + decodeToken['sub'];

          if (await socialUserCheck(appleSid)) {
            var res = await UserRepository.socialLogin(appleSid);

            if (res) {
              String date =
                  "${DateTime.now().year}-${DateTime.now().month.toString().length == 1 ? "0" + DateTime.now().month.toString() : DateTime.now().month}-${DateTime.now().day.toString().length == 1 ? "0" + DateTime.now().day.toString() : DateTime.now().day}";
              await DurationRepository.durationRegist(date);
              UserLogger.logEventName(eventName: EventSign.LOGIN_COMPLETE);
              bloc.add(StopLoadingEvent());
              pushNamedAndRemoveUntil(
                  context, SplashPage.ROUTE_AFTER_LOGIN_BEFORE_PROFILE);
            }
          } else {
            await socialSignUp(
                context: context,
                sid: appleSid,
                email: appleSid + "*" + decodeToken['email'],
                socialType: 'APPLE');
            bloc.add(StopLoadingEvent());
          }
        }
      },
    );
  }

  @override
  Widget blocBuilder(BuildContext context, state) {
    // TODO: implement blocBuilder
    return BlocBuilder(
      cubit: bloc,
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () {
            if (appleWeb) {
              bloc.add(AppleLoginEvent(type: 1));
            } else {
              if (Platform.isAndroid) {
                SystemChannels.platform
                    .invokeMethod<void>('SystemNavigator.pop');
              }
            }
            return null;
          },
          child: SafeArea(
              top: false,
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                    statusBarColor: AppColors.transparent,
                    statusBarIconBrightness: Brightness.dark),
                child: Scaffold(
                    resizeToAvoidBottomInset: true,
                    backgroundColor: AppColors.lightGrey01,
                    body: Stack(children: [
                      NotificationListener<OverscrollIndicatorNotification>(
                        onNotification: (notification) {
                          notification.disallowGlow();
                          return true;
                        },
                        child: GestureDetector(
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          child: SingleChildScrollView(
                            physics: ClampingScrollPhysics(),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              color: AppColors.lightGrey01,
                              padding: EdgeInsets.only(
                                  left: resize(24), right: resize(24)),
                              child: _buildMain(context),
                            ),
                          ),
                        ),
                      ),
                      SlidingUpPanel(
                        color: AppColors.white,
                        controller: panelController,
                        panel: Container(
                          padding: EdgeInsets.only(
                              left: resize(24), right: resize(24)),
                          child: Column(
                            children: [
                              emptySpaceH(height: 22),
                              Row(
                                children: [
                                  emptySpaceW(width: 8),
                                  Text(
                                    AppStrings.of(
                                        StringKey.other_login_options),
                                    style: AppTextStyle.from(
                                        color: AppColors.black,
                                        size: TextSize.caption_large,
                                        weight: TextWeight.bold),
                                  ),
                                  Expanded(child: Container()),
                                  GestureDetector(
                                    onTap: () async {
                                      await panelController.close();
                                    },
                                    child: Container(
                                      color: AppColors.white,
                                      height: resize(18),
                                      child: Text(
                                        AppStrings.of(StringKey.cancel),
                                        style: AppTextStyle.from(
                                            color: AppColors.grey,
                                            size: TextSize.caption_medium,
                                            weight: TextWeight.extrabold),
                                      ),
                                    ),
                                  ),
                                  emptySpaceW(width: 8)
                                ],
                              ),
                              emptySpaceH(height: 38),
                              loginApple(context),
                              emptySpaceH(height: 12),
                              loginGoogle(context),
                              emptySpaceH(height: 12),
                              loginFacebook(context)
                            ],
                          ),
                        ),
                        backdropTapClosesPanel: true,
                        backdropEnabled: true,
                        backdropColor: AppColors.black,
                        backdropOpacity: 0.33,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24)),
                        minHeight: panelController.isAttached
                            ? resize(panelController.isPanelClosed ? 0 : 306)
                            : 0,
                        maxHeight: resize(306),
                      ),
                      appleWeb ? appleWebPage() : Container(),
                      _buildProgress(context)
                    ])),
              )),
        );
      },
    );
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is PasswordView) {
      setState(() => passwordView = state.view);
    }

    if (state is LoginFail) {
      setState(() => error = state.error);
    }

    if (state is LoadingState) {
      setState(() => isLoading = state.loading);
    }

    if (state is GoSplashToInitService) {
      UserLogger.logEventName(eventName: EventSign.LOGIN_COMPLETE);
      pushNamedAndRemoveUntil(
          context, SplashPage.ROUTE_AFTER_LOGIN_BEFORE_PROFILE);
    }

    if (state is AppleLoginState) {
      setState(() {
        if (state.type == 0) {
          appleWeb = true;
        } else {
          appleWeb = false;
        }
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    bloc.add(StopLoadingEvent());
    super.dispose();
  }

  @override
  initBloc() {
    // TODO: implement initBloc
    return LoginBloc(context)..add(LoginInitEvent());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    appsflyer.saveLog(loginPage);
    SystemChannels.lifecycle.setMessageHandler((msg) {
      if (msg == AppLifecycleState.paused.toString()) {
        appsflyer.saveLog(switchWindowLogin);
      }
      return null;
    });
  }
}
