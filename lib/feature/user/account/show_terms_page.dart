import 'package:connect/data/remote/user/get_terms_service.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/feature/splash/splash_page.dart';
import 'package:connect/feature/user/account/show_terms_bloc.dart';
import 'package:connect/feature/user/sign/password_create_page.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/utils/appsflyer/apps_flyer.dart';
import 'package:connect/utils/logger/log.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/bottons/bottom_button.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class ShowTermsPage extends BasicPage {
  static const ROUTE_NAME = '/show_terms_page';
  final _tag = "showTermPage";

  List<Map> terms;
  bool showAgree;

  static Future pushAndRemoveUntil(BuildContext context,
      {List<Map> params, bool showAgree}) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
        ROUTE_NAME, (route) => false,
        arguments: {'terms': params, 'showAgree': showAgree ?? false});
  }

  static Future popAndPush(BuildContext context,
      {List<Map> params, bool showAgree}) {
    return Navigator.of(context).popAndPushNamed(ROUTE_NAME,
        arguments: {'terms': params, 'showAgree': showAgree ?? false});
  }

  static Future pushViewing(BuildContext context, {TermsType type}) {
    return push(context,
        params: [
          {'type': type}
        ],
        showAgree: false);
  }

  static Future push(BuildContext context, {List<Map> params, bool showAgree}) {
    return Navigator.of(context).pushNamed(ROUTE_NAME,
        arguments: {'terms': params, 'showAgree': showAgree ?? false});
  }

  @override
  Widget buildWidget(BuildContext context) => _Widget(
        terms: terms,
        showAgree: showAgree,
      );

  @override
  void handleArgument(BuildContext context) {
    Map arg = ModalRoute.of(context).settings.arguments;
    terms = arg['terms'];
    showAgree = arg['showAgree'];
  }
}

class _Widget extends BlocStatefulWidget {
  final List<Map> terms;
  final bool showAgree;
  _Widget({this.terms, this.showAgree});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return _State();
  }
}

class _State extends BlocState<ShowTermsBloc, _Widget> {
  @override
  Widget blocBuilder(BuildContext context, state) {
    return Scaffold(
        appBar: baseAppBar(context),
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              (state is TermsLoading || state is WebViewShow)
                  ? FullscreenDialog()
                  : Container(),
              (state is TermsLoading)
                  ? Container()
                  : Column(
                      children: <Widget>[
                        Expanded(child: _buildHtml(state, context)),
                        _buildAgreeButton(state)
                      ],
                    )
            ],
          ),
        ));
  }

  Container _buildAgreeButton(state) {
    if (!bloc.showAgree) return Container();

    return Container(
        height: resize(80),
        alignment: Alignment.bottomCenter,
        margin: EdgeInsets.only(
            bottom: resize(32), left: resize(16), right: resize(16)),
        child: BottomButton(
            text: AppStrings.of(StringKey.agree),
            onPressed: () =>
                (state is NextTermsShow) ? bloc.add(AgreeTerms()) : null));
  }

  Widget _buildHtml(state, BuildContext context) {
    if (bloc.terms.isEmpty) return Container();

    var scrollPadding =
        EdgeInsets.only(top: resize(20), right: resize(24), left: resize(24));

    return Padding(
        padding: scrollPadding,
        child: WebView(
          onWebViewCreated: (controller) {
            bloc.add(TermsWebViewCreatedEvent(controller));
          },
          onPageFinished: (url) {
            bloc.add(FinishToLoadWebPage());
          },
          navigationDelegate: (navigation) async {
            Log.d("showTermPage", "NavigationDelegate :" + navigation.url);
            var url = navigation.url;
            if (await canLaunch(url)) {
              launch(url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ));
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is CompletedAgreeTermsOnSignup) {
      // appsflyer.saveLog(termsOfUseAndPrivacyPolicyAgree);
      PasswordCreatePage.popAndPush(context);
      return;
    }
    if (state is UpdatedAgreeTerms) {
      SplashPage.pushAndRemoveUntil(
          context, SplashPage.ROUTE_AFTER_LOGIN_BEFORE_PROFILE);
      return;
    }
  }

  @override
  ShowTermsBloc initBloc() {
    return ShowTermsBloc()
      ..add(TermsInit(terms: widget.terms, showAgree: widget.showAgree));
  }
}
