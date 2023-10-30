import 'package:connect/data/local/app_dao.dart';
import 'package:connect/data/remote/user/get_terms_service.dart';
import 'package:connect/feature/user/account/show_terms_page.dart';
import 'package:connect/feature/user/goal/goal_page.dart';
import 'package:connect/feature/user/login/login_page.dart';
import 'package:connect/feature/user/sign/sign_up_select_page.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/utils/appsflyer/apps_flyer.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

import 'intro_bloc.dart';

class IntroPage extends BlocStatefulWidget {
  static const String ROUTE_NAME = '/intro_page';

  static Future<Object> pushAndRemoveUntil(BuildContext context) {
    return Navigator.of(context)
        .pushNamedAndRemoveUntil(ROUTE_NAME, (route) => false);
  }

  @override
  _IntroState buildState() => _IntroState();
}

class _IntroState extends BlocState<IntroBloc, IntroPage> {
  SwiperController swiperController = SwiperController();

  String privacyText = "By continuing,You agree to Rehabit’s";
  String termsAndConditions = "Terms & Conditions";
  String privacyPolicy = "Privacy Policy";

  List<String> introTexts = [
    AppStrings.of(
        StringKey.holistic_wellness_program_developed_by_stroke_rehab_experts),
    AppStrings.of(StringKey
        .stay_on_track_with_daily_missions_and_over_500_custom_contents),
    AppStrings.of(
        StringKey.neofect_connect_will_give_you_the_tools_to_change_your_life),
    AppStrings.of(StringKey.look_forward_to_a_happier_healthier_you)
  ];

  privacyContent(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: resize(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            privacyText,
            style: AppTextStyle.from(
                size: TextSize.caption_small, color: AppColors.white),
            textAlign: TextAlign.center,
          ),
          emptySpaceH(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  ShowTermsPage.pushViewing(context, type: TermsType.TERMS);
                },
                child: Text(
                  termsAndConditions,
                  style: AppTextStyle.from(
                      size: TextSize.caption_small,
                      color: AppColors.white,
                      decoration: TextDecoration.underline),
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                "and ",
                style: AppTextStyle.from(
                    size: TextSize.caption_small, color: AppColors.white),
                textAlign: TextAlign.center,
              ),
              GestureDetector(
                onTap: () {
                  ShowTermsPage.pushViewing(context,
                      type: TermsType.PRIVACY_POLICY);
                },
                child: Text(
                  privacyPolicy,
                  style: AppTextStyle.from(
                      size: TextSize.caption_small,
                      color: AppColors.white,
                      decoration: TextDecoration.underline),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  setIntroSkip() async {
    await AppDao.setIntroSkip(true);
  }

  introSwipe() {
    return Swiper(
      itemCount: 4,
      autoplay: true,
      autoplayDelay: 3000,
      duration: 520,
      curve: Curves.ease,
      controller: swiperController,
      physics: NeverScrollableScrollPhysics(),
      onIndexChanged: (index) {
        bloc.add(SwipeIndexChangeEvent(index: index));
      },
      itemBuilder: (context, index) {
        return Stack(
          children: [
            Positioned(
              top: resize(140),
              left: resize(24),
              right: resize(24),
              child: Container(
                width: resize(312),
                child: Center(
                  child: descriptionContent(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  wordMark() {
    return Image.asset(
      AppImages.img_logo_rehabit_white,
      width: resize(146),
      height: resize(32),
      fit: BoxFit.contain,
    );
  }

  descriptionContent() {
    return Text(
      introTexts[bloc.swipeIndex],
      style: AppTextStyle.from(
          color: AppColors.white,
          size: TextSize.title_medium_high,
          weight: TextWeight.extrabold,
          height: 1.5),
      textAlign: TextAlign.center,
    );
  }

  pagination(context) {
    List<Widget> progress = List();
    for (int i = 0; i < 4; i++) {
      progress.add(ClipOval(
        child: Container(
          width: 10,
          height: 10,
          color: bloc.swipeIndex == i ? AppColors.white : AppColors.white40,
        ),
      ));
    }

    return ListView.builder(
      itemBuilder: (context, idx) {
        if (idx != progress.length) {
          return Padding(
            padding: EdgeInsets.only(right: resize(8)),
            child: progress[idx],
          );
        } else {
          return progress[idx];
        }
      },
      scrollDirection: Axis.horizontal,
      itemCount: progress.length,
      shrinkWrap: true,
    );
  }

  startButton(context) {
    return ElevatedButton(
        onPressed: () async {
          await setIntroSkip();
          appsflyer.saveLog(appStart);
          GoalPage.pushAndRemoveUntil(context);
        },
        style: ElevatedButton.styleFrom(
            primary: AppColors.purple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            elevation: 0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 56,
          child: Center(
            child: Text(
              AppStrings.of(StringKey.start),
              style: AppTextStyle.from(
                  color: AppColors.white,
                  size: TextSize.body_medium,
                  weight: TextWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ));
  }

  footerLogin(context) {
    return GestureDetector(
      onTap: () async {
        await setIntroSkip();
        LoginPage.pushAndRemoveUntil(context);
      },
      child: Container(
        height: resize(18),
        child: Text(
          AppStrings.of(StringKey.have_a_neofect_account),
          style: AppTextStyle.from(
            size: TextSize.caption_medium,
            color: AppColors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  _buildMain(context) {
    return Stack(
      children: [
        Positioned.fill(
            child: Image.asset(
          AppImages.img_intro,
          fit: BoxFit.fill,
        )),
        Positioned.fill(
            child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: AppColors.blackA40,
        )),
        Positioned.fill(child: introSwipe()),
        Positioned(
          child: wordMark(),
          top: resize(54),
          left: 0,
          right: 0,
        ),
        Positioned(
          child: privacyContent(context),
          bottom: resize(192),
        ),
        // Positioned(
        //   child: Container(
        //     width: MediaQuery.of(context).size.width,
        //     height: 10,
        //     child: Center(
        //       child: pagination(context),
        //     ),
        //   ),
        //   bottom: resize(146),
        // ),
        Positioned(
          child: startButton(context),
          bottom: resize(66),
          left: resize(20),
          right: resize(20),
        ),
        Positioned(
          child: footerLogin(context),
          bottom: resize(32),
          left: resize(32),
          right: resize(32),
        )
      ],
    );
  }

  @override
  Widget blocBuilder(BuildContext context, state) {
    // TODO: implement blocBuilder
    return BlocBuilder(
      cubit: bloc,
      builder: (context, state) {
        return SafeArea(
          top: false,
          child: Scaffold(
            backgroundColor: AppColors.white,
            body: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: _buildMain(context)),
          ),
        );
      },
    );
  }

  @override
  blocListener(BuildContext context, state) {}

  @override
  initBloc() {
    // TODO: implement initBloc
    return IntroBloc(context)..add(IntroInitEvent());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    appsflyer.saveLog(introPage);
    SystemChannels.lifecycle.setMessageHandler((msg) {
      if (msg == AppLifecycleState.paused.toString()) {
        appsflyer.saveLog(switchWindowIntro);
      }
      return null;
    });
  }
}
