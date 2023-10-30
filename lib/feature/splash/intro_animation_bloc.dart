import 'dart:ui';

import 'package:connect/data/local/app_dao.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_images.dart';
import 'package:connect/resources/app_strings.dart';
import 'package:connect/utils/appsflyer/apps_flyer.dart';
import 'package:flutter/cupertino.dart';

class IntroAnimationBloc extends BaseBloc {
  IntroAnimationBloc() : super(IntroLoadingState());

  List get splashTexts {
    return [
      StringKey.have_you_been_through_a_lot,
      StringKey.the_stroke_journey_is_hard,
      StringKey.today_you_can_start_something_new,
      StringKey.take_a_deep_breath,
      StringKey.you_re_not_alone,
//      StringKey.together,
      StringKey.together_we_not_alone,
    ].map((e) => e.getString()).toList();
  }

  List get colors {
    return [
      AppColors.missionReading,
      AppColors.missionReading,
      AppColors.missionVideo,
      AppColors.missionExerciseBasic,
      AppColors.missionExerciseBasic,
//      AppColors.missionActivity,
      AppColors.color_intro_ced
    ];
  }

  List get images {
    return [
      AppImages.img_sun_intro1,
      AppImages.img_sun_intro1,
      AppImages.img_sun_intro2,
      AppImages.img_sun_intro3,
      AppImages.img_sun_intro3,
//      AppImages.img_sun_intro4,
      AppImages.img_sun_intro5,
    ];
  }

  bool init = false;
  bool touchable = false;
  String text;
  Color color;
  String circle;
  bool end = false;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is IntroInitEvent) {
      await Future.delayed(Duration(milliseconds: 3000));
      init = true;
      final stepCount = splashTexts.length;
      for (final i in List.generate(stepCount, (index) => index)) {
        text = splashTexts[i];
        color = colors[i];
        circle = images[i];
        yield IntroLoadingState();
        await Future.delayed(Duration(milliseconds: 3000));
      }
      end = true;
      yield IntroLoadingState();
    }

    if(event is IntroEndEvent){
      // appsflyer.saveLog(strokeRehabStart);
      await AppDao.setIntroSkip(true);
      yield GoToSplashState();
    }
  }
}


class IntroInitEvent extends BaseBlocEvent {}

class IntroLoadingState extends BaseBlocState {}

class IntroLongTouchEvent extends BaseBlocEvent {}

class IntroEndEvent extends BaseBlocEvent {}

class GoToSplashState extends BaseBlocState {}
