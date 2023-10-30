import 'package:connect/data/local/app_dao.dart';
import 'package:connect/data/local/app_dao.dart';
import 'package:connect/data/remote/auth/token_refresh_service.dart';
import 'package:connect/data/remote/user/get_terms_service.dart';
import 'package:connect/data/user_repository.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/feature/bottom_navigation/home_navigation.dart';
import 'package:connect/feature/home/home_calendar.dart';
import 'package:connect/feature/payment/payment_notice_bloc.dart';
import 'package:connect/feature/user/account/show_terms_page.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/utils/appsflyer/apps_flyer.dart';
import 'package:connect/utils/logger/log.dart';
import 'package:connect/widgets/base_alert_dialog.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:connect/widgets/dialog/start_evaluation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../connect_config.dart';

class _RouteArguments {
  bool closeable;
  bool isNewHomeUser;
  bool isNavMenu;
  bool back;
  String logSet;
  int focusImg;

  _RouteArguments(
      {this.closeable = false,
      this.isNewHomeUser = false,
      this.isNavMenu = false,
      this.back = false,
      this.logSet = "",
      this.focusImg = 1});
}

// ignore: must_be_immutable
class PaymentNoticePage extends BasicPage {
  static const ROUTE_NAME = '/payment_notice_page';

  var routeArguments = _RouteArguments();

  static Future<Object> pushAndRemoveUntil(BuildContext context,
      {bool isNewHomeUser = false,
      bool closeable = false,
      bool isNavMenu = false,
      bool back = false,
      String logSet = "",
      int focusImg = 1}) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
        ROUTE_NAME, (route) => false,
        arguments: _RouteArguments(
            isNewHomeUser: isNewHomeUser,
            closeable: closeable,
            isNavMenu: isNavMenu,
            back: back,
            logSet: logSet,
            focusImg: focusImg));
  }

  static Future<Object> push(BuildContext context,
          {bool isNewHomeUser = false,
          bool closeable = false,
          bool isNavMenu = false,
          bool back = false,
          String logSet = "",
          int focusImg = 1}) =>
      Navigator.of(context).pushNamed(ROUTE_NAME,
          arguments: _RouteArguments(
              isNewHomeUser: isNewHomeUser,
              closeable: closeable,
              isNavMenu: isNavMenu,
              back: back,
              logSet: logSet,
              focusImg: focusImg));

  @override
  Widget buildWidget(BuildContext context) {
    return _PaymentNoticeStatefulWidget(
        routeArguments.closeable,
        routeArguments.isNewHomeUser,
        routeArguments.isNavMenu,
        routeArguments.back,
        routeArguments.logSet,
        routeArguments.focusImg);
  }

  @override
  void handleArgument(BuildContext context) {
    routeArguments =
        (ModalRoute.of(context).settings.arguments) as _RouteArguments;
  }
}

class _PaymentNoticeStatefulWidget extends BlocStatefulWidget {
  final bool closeable;
  final bool isNewHomeUser;
  final bool isNavMenu;
  final bool back;
  final String logSet;
  final int focusImg;

  _PaymentNoticeStatefulWidget(this.closeable, this.isNewHomeUser,
      this.isNavMenu, this.back, this.logSet, this.focusImg);

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return _PaymentNoticeStatefulState();
  }
}

class _PaymentNoticeStatefulState
    extends BlocState<PaymentNoticeBloc, _PaymentNoticeStatefulWidget> {
  WebViewController _webViewController;

  @override
  PaymentNoticeBloc initBloc() {
    return PaymentNoticeBloc(isNewHomeUser: widget.isNewHomeUser ?? false)
      ..add(PaymentCheck());
  }

  @override
  void dispose() {
    bloc.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.dispose();
  }

  @override
  Widget blocBuilder(BuildContext context, state) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.back) {
          Navigator.of(context).pop();
          return null;
        }
        var bool = await _webViewController?.canGoBack();
        if (bool == true) {
          await _webViewController.goBack();
          return false;
        }
        return _onBackPressed();
      },
      child: Scaffold(
        body: Stack(
          children: [
            WebView(
              javascriptMode: JavascriptMode.unrestricted,
              javascriptChannels: <JavascriptChannel>{
                JavascriptChannel(
                    name: 'ConnectApp',
                    onMessageReceived: (msg) async {
                      Log.d(runtimeType.toString(), msg.message);
                      if (msg.message == 'close') {
                        Log.d(runtimeType.toString(), 'Close Button Click');
                        if (_onBackPressed()) pop(context);
                      } else if (msg.message.contains('mailto')) {
                        Log.d(runtimeType.toString(), 'mailto');
                        await launch(msg.message);
                      } else if (msg.message == 'accept1') {
                        Log.d(runtimeType.toString(), 'Accept1 Button Click');
                        bloc.add(
                            PaymentSubscribe(widget.isNewHomeUser, type: 3));
                      } else if (msg.message == 'accept3') {
                        Log.d(runtimeType.toString(), 'Accept3 Button Click');
                        bloc.add(
                            PaymentSubscribe(widget.isNewHomeUser, type: 2));
                      } else if (msg.message == 'accept6') {
                        Log.d(runtimeType.toString(), 'Accept6 Button Click');
                        bloc.add(
                            PaymentSubscribe(widget.isNewHomeUser, type: 1));
                      } else if (msg.message == 'accept12') {
                        Log.d(runtimeType.toString(), 'Accept12 Button Click');
                        bloc.add(
                            PaymentSubscribe(widget.isNewHomeUser, type: 0));
                      } else if (msg.message == 'terms_of_service') {
                        Log.d(runtimeType.toString(), 'Terms of Service Click');
                        ShowTermsPage.pushViewing(context,
                            type: TermsType.TERMS);
                      } else if (msg.message == 'privacy_policy') {
                        Log.d(runtimeType.toString(), 'Privacy Policy Click');
                        ShowTermsPage.pushViewing(context,
                            type: TermsType.PRIVACY_POLICY);
                      } else {
                        final Map<String, Object> jsonMap =
                            jsonDecode(msg.message);
                        if (jsonMap?.isNotEmpty == true) {
                          String code = jsonMap['code'];
                          String message = jsonMap['message'];
                          if (code?.isNotEmpty == true &&
                              message?.isNotEmpty == true) {
                            _showDialogForCouponResult(code, message);
                          }
                        }
                      }
                    }),
              },
              onWebViewCreated: (controller) async {
                _webViewController = controller;
                var accessToken = await AppDao.accessToken;
                controller.loadUrl(
                    "${baseUrl}ui/v2/payment.html?closeable=${widget.closeable.toString()}&isHome=${widget.isNewHomeUser.toString()}&token=$accessToken&focusImg=${widget.focusImg}");
              },
              onPageStarted: (url) {
                Log.d(runtimeType.toString(), "pageStarted : $url");
                SystemChannels.textInput.invokeMethod('TextInput.hide');
              },
            ),
            if (state is PaymentCheckInProgress ||
                state is PaymentSubscribing ||
                state is PaymentSubscribePending)
              FullscreenDialog()
          ],
        ),
      ),
    );
  }

  bool _onBackPressed() {
    final closeable = (widget?.closeable == true);
    if (closeable && widget.back) {
      Navigator.of(context).pop();
      return false;
    }

    if (closeable && widget.isNavMenu == false) {
      showDialog(
          context: context,
          child: BaseAlertDialog(
              content: AppStrings.of(StringKey.are_you_sure_you_want_to_exit),
              cancelable: true,
              onConfirm: () {
                SystemNavigator.pop();
              }));
      return false;
    }
    return closeable;
  }

  @override
  blocListener(BuildContext context, state) {
    //결제 이용불가 상태
    if (state is PaymentNotAvailable || state is PaymentProductNotFound) {
      // popUntilNamed(context, PaymentNoticePage.ROUTE_NAME);
      showDialog(
          context: context,
          child: BaseAlertDialog(
              onConfirm: () => {},
              content: AppStrings.of(StringKey.payment_not_available)));
    }

    if (state is PaymentSubscribeSuccess) {
      // popUntilNamed(context, PaymentNoticePage.ROUTE_NAME);
      showDialog(
          context: context,
          child: BaseAlertDialog(
              onConfirm: () {
                // HomeCalendarPage.pushAndRemoveUntil(context)
                if (widget.logSet == "vip_content") {
                  appsflyer.saveLog(paymentVipcontents);
                } else if (widget.logSet == "profile") {
                  appsflyer.saveLog(paymentProfile);
                } else if (widget.logSet == "emoji") {
                  appsflyer.saveLog(paymentEmoji);
                } else if (widget.logSet == "advice") {
                  appsflyer.saveLog(paymentAdvice);
                } else if (widget.logSet == "geteval") {
                  appsflyer.saveLog(paymentGeteval);
                } else if (widget.logSet == "evaltrend") {
                  appsflyer.saveLog(paymentEvalutaion);
                }
                HomeNavigation.pushAndRemoveUntil(context);
              },
              content: AppStrings.of(StringKey.subscription_completed)));
    }

    if (state is PaymentSubscribeFailure) {
      // popUntilNamed(context, PaymentNoticePage.ROUTE_NAME);
      showDialog(
          context: context,
          child: BaseAlertDialog(
              onConfirm: () => {},
              content: AppStrings.of(StringKey.subscription_not_completed) +
                  (isDebug ? state.errorMessage : "")));
    }
  }

  void _showDialogForCouponResult(String code, String message) async {
    final success = code == 'success';

    if (success) {
      await UserRepository.getProfile();
    }

    showDialog(
        context: context,
        child: BaseAlertDialog(
            onConfirm: () => success
                ?
                // HomeCalendarPage.pushAndRemoveUntil(context)
                HomeNavigation.pushAndRemoveUntil(context)
                : null,
            content:
                success ? StringKey.coupon_registered.getString() : message));
  }
}
