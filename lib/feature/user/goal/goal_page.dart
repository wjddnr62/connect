import 'package:connect/feature/payment/payment_description_page.dart';
import 'package:connect/feature/user/goal/goal_bloc.dart';
import 'package:connect/feature/user/sign/sign_up_select_page.dart';
import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_images.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/bottons/bottom_button.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multiscreen/multiscreen.dart';

class GoalPage extends BlocStatefulWidget {
  static const String ROUTE_NAME = '/goal_page';

  static Future<Object> pushAndRemoveUntil(
      BuildContext context) {
    return Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => GoalPage()), (route) => false);
  }

  @override
  _GoalState buildState() => _GoalState();
}

class _GoalState extends BlocState<GoalBloc, GoalPage> {
  bool continuePassed = false;

  backButton(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: resize(44),
      child: Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          icon: Image.asset(
            AppImages.ic_chevron_left,
            width: resize(24),
            height: resize(24),
            color: AppColors.white,
          ),
          onPressed: () => goSignUpSelectPage(context),
        ),
      ),
    );
  }

  hiText(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: resize(30),
      child: Center(
        child: Text(
          "Welcome!",
          style: AppTextStyle.from(
              size: TextSize.title_medium,
              color: AppColors.white,
              weight: TextWeight.extrabold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  descriptionText(context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          // height: resize(20),
          child: Center(
            child: Text(
              AppStrings.of(StringKey.what_brings_you_to_neofect_connect),
              style: AppTextStyle.from(
                  size: TextSize.caption_large,
                  weight: TextWeight.bold,
                  color: AppColors.lightGrey01,
                  height: 1.2),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        emptySpaceH(height: 12),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.zero,
          child: Center(
            child: Text(
              AppStrings.of(StringKey.you_will_get_customized_contents_according_to_your_goal),
              style: AppTextStyle.from(
                  size: TextSize.caption_very_small, color: AppColors.lightGrey01, weight: TextWeight.medium),
            ),
          ),
        )
      ],
    );
  }

  valueData(context, type, idx) {
    return ElevatedButton(
        onPressed: () {
          setState(() {
            if (!bloc.serveys.contains(bloc.serveyData.servey[idx].title)) {
              bloc.serveys.add(bloc.serveyData.servey[idx].title);
              continuePassed = true;
            } else {
              bloc.serveys.remove(bloc.serveyData.servey[idx].title);
              if (bloc.serveys.length == 0) {
                continuePassed = false;
              }
            }
          });
        },
        style: ElevatedButton.styleFrom(
            primary: bloc.serveys.contains(bloc.serveyData.servey[idx].title)
                ? AppColors.white
                : AppColors.lightPurple,
            side: BorderSide(color: AppColors.white, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
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
                  valueTextAndImage(true, type, idx),
                  width: resize(28),
                  height: resize(28),
                  color:
                      bloc.serveys.contains(bloc.serveyData.servey[idx].title)
                          ? AppColors.purple
                          : null,
                ),
                emptySpaceW(width: 16),
                Text(
                  valueTextAndImage(false, type, idx),
                  style: AppTextStyle.from(
                      color: bloc.serveys
                              .contains(bloc.serveyData.servey[idx].title)
                          ? AppColors.purple
                          : AppColors.white,
                      size: TextSize.caption_medium,
                      weight: TextWeight.semibold,
                      height: 1.4),
                  textAlign: TextAlign.left,
                )
              ],
            ),
          ),
        ));
  }

  valueTextAndImage(type, value, idx) {
    switch (value) {
      case "PROFESSIONAL":
        if (type) {
          return AppImages.ic_book;
        } else {
          return bloc.serveyData.servey[idx].data;
        }
        break;
      case "SELF":
        if (type) {
          return AppImages.ic_self;
        } else {
          return bloc.serveyData.servey[idx].data;
        }
        break;
      case "MENTAL":
        if (type) {
          return AppImages.ic_mental;
        } else {
          return bloc.serveyData.servey[idx].data;
        }
        break;
      case "DAILY":
        if (type) {
          return AppImages.ic_life;
        } else {
          return bloc.serveyData.servey[idx].data;
        }
        break;
      case "TIPS":
        if (type) {
          return AppImages.ic_advice;
        } else {
          return bloc.serveyData.servey[idx].data;
        }
        break;
    }
  }

  _buildMain(context) {
    return Container(
      decoration: BoxDecoration(
        gradient:
            LinearGradient(colors: [Color(0xFF9887ff), Color(0xFF80a0eb)]),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              emptySpaceH(height: MediaQuery.of(context).padding.top + 10),
              backButton(context),
              Padding(
                padding: EdgeInsets.only(left: resize(24), right: resize(24)),
                child: Column(
                  children: [
                    hiText(context),
                    emptySpaceH(height: 12),
                    descriptionText(context),
                    emptySpaceH(height: 20),
                    bloc.serveyData != null &&
                            bloc.serveyData.servey.length != 0
                        ? ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, idx) {
                              return Column(
                                children: [
                                  valueData(context,
                                      bloc.serveyData.servey[idx].title, idx),
                                  emptySpaceH(height: 16)
                                ],
                              );
                            },
                            shrinkWrap: true,
                            itemCount: bloc.serveyData.servey.length,
                          )
                        : Container(),
                    emptySpaceH(height: 16),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.zero,
                      child: Center(
                        child: Text(
                          AppStrings.of(StringKey.you_can_select_multiple),
                          style: AppTextStyle.from(
                              size: TextSize.caption_small, color: AppColors.lightGrey01, weight: TextWeight.medium),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          Positioned(
              bottom: resize(24),
              left: resize(24),
              right: resize(24),
              child: BottomButton(
                onPressed: continuePassed
                    ? () {
                        bloc.add(GoalDataSaveUserEvent());
                      }
                    : null,
                text: AppStrings.of(StringKey.continue_text),
                color: AppColors.white,
                disabledColor: AppColors.white40,
                textColor: continuePassed
                    ? AppColors.purple
                    : Color.fromRGBO(123, 126, 210, 0.2),
              ))
        ],
      ),
    );
  }

  goSignUpSelectPage(context) {
    SignUpSelectPage.pushAndRemoveUntil(context);
  }

  Widget _buildProgress(BuildContext context) {
    if (!bloc.loading) return Container();

    return FullscreenDialog();
  }

  @override
  Widget blocBuilder(BuildContext context, state) {
    // TODO: implement blocBuilder
    return BlocBuilder(
        cubit: bloc,
        builder: (context, state) {
          return WillPopScope(
            onWillPop: () => goSignUpSelectPage(context),
            child: Scaffold(
              body: Stack(
                children: [_buildMain(context), _buildProgress(context)],
              ),
            ),
          );
        });
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is GoalInitState) {
      bloc.add(GoalDataGetEvent());
    }

    if (state is GoalDataSaveUserState) {
      goSignUpSelectPage(context);
    }
  }

  @override
  GoalBloc initBloc() {
    // TODO: implement initBloc
    return GoalBloc(context)..add(GoalInitEvent());
  }
}
