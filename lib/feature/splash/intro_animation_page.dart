import 'package:connect/feature/base_bloc.dart';
import 'package:connect/feature/splash/intro_animation_bloc.dart';
import 'package:connect/feature/splash/splash_page.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/bottons/bottom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class IntroAnimationPage extends BasicPage {
  static const String ROUTE_NAME = '/intro_animation_page';

  @override
  Widget buildWidget(BuildContext context) {
    return _IntroAnimationWidget();
  }

  @override
  void handleArgument(BuildContext context) {}

  static Future<Object> pushAndRemoveUntil(BuildContext context) {
    return Navigator.of(context)
        .pushNamedAndRemoveUntil(ROUTE_NAME, (route) => false);
  }
}

class _IntroAnimationWidget extends BlocStatefulWidget {
  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return _State();
  }
}

class _State extends BlocState<IntroAnimationBloc, _IntroAnimationWidget> {
  Duration get aniDuration => Duration(milliseconds: 1000);

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  void blocListener(BuildContext context, state) {
    if (state is GoToSplashState) {
      SplashPage.pushAndRemoveUntil(context, SplashPage.ROUTE_BEFORE_LOGIN);
    }
  }

  Widget blocBuilder(BuildContext context, state) {
    return Scaffold(
      body: AnimatedSwitcher(
        child: _buildStep(context, state),
        duration: aniDuration,
      ),
    );
  }

  Widget _buildStep(BuildContext context, state) {
    if (!bloc.init) return _buildOnlyLogo();
    if (bloc.end) return _buildLastLogo();
    return _buildSplashLoading(state, context);
  }

  Widget _buildOnlyLogo() {
    return Center(
      child: FractionallySizedBox(
          widthFactor: 0.561, child: Image.asset(AppImages.img_logo_connect)),
    );
  }

  Widget _buildLastLogo() {
    return Container(
      margin: EdgeInsets.only(
          top: resize(193),
          left: resize(16),
          right: resize(16),
          bottom: resize(32)),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Expanded(
              child: Image.asset(
            AppImages.img_logo_connect,
            width: resize(202),
          )),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: resize(8)),
            child: Text(
              AppStrings.of(
                  StringKey.make_neofect_rehabilitation_partner_today),
              textAlign: TextAlign.center,
              style: AppTextStyle.from(
                  color: AppColors.blueGrey,
                  size: TextSize.body_medium,
                  height: 1.5),
            ),
          ),
          SizedBox(
            height: resize(64),
          ),
          BottomButton(
            text: 'Stroke Rehab Start',
            onPressed: () {
              bloc.add(IntroEndEvent());
            },
            color: AppColors.purple,
            textColor: AppColors.white,
          )
        ],
      ),
    );
  }

  Stack _buildSplashLoading(state, BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        _buildBg(state),
        _buildCircle(context, state),
        _buildText(state),
        _buildTouch()
      ],
    );
  }

  Widget _buildBg(state) {
    return AnimatedContainer(
      width: double.infinity,
      height: double.infinity,
      color: bloc.color,
      duration: aniDuration,
    );
  }

  Widget _buildText(state) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(resize(24)),
        child: AnimatedSwitcher(
          child: Text(
            bloc.text,
            key: ValueKey(bloc.text),
            textAlign: TextAlign.center,
            style: AppTextStyle.from(
                color: AppColors.white,
                height: 1.2,
                size: TextSize.intro,
                weight: TextWeight.bold),
          ),
          reverseDuration:
              Duration(milliseconds: (aniDuration.inMilliseconds / 2).round()),
          duration: aniDuration,
        ),
      ),
    );
  }

  Widget _buildCircle(BuildContext context, state) {
    if (state is! IntroLoadingState) return Container();
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: AnimatedSwitcher(
            duration: aniDuration,
            child: Container(
                key: ValueKey(bloc.circle),
                alignment: Alignment.topRight,
                child: Image.asset(
                  bloc.circle,
                  fit: BoxFit.fitWidth,
                ))),
      ),
    );
  }

  Widget _buildTouch() {
    return AnimatedSwitcher(
      child: bloc.touchable
          ? Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                widthFactor: 0.647,
                child: GestureDetector(
                    onTap: () {
                      bloc.add(IntroLongTouchEvent());
                    },
                    child: Image.asset(AppImages.img_hand_mark)),
              ),
            )
          : Container(),
      duration: aniDuration,
    );
  }

  @override
  IntroAnimationBloc initBloc() {
    return IntroAnimationBloc()..add(IntroInitEvent());
  }
}
