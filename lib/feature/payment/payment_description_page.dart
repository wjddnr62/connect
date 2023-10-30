import 'package:connect/data/remote/user/get_terms_service.dart';
import 'package:connect/feature/bottom_navigation/home_navigation.dart';
import 'package:connect/feature/home/home_calendar.dart';
import 'package:connect/feature/payment/payment_description_bloc.dart';
import 'package:connect/feature/payment/payment_notice_page.dart';
import 'package:connect/feature/user/account/show_terms_page.dart';
import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_images.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/utils/appsflyer/apps_flyer.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:connect/widgets/base_alert_dialog.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/bottons/bottom_button.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:multiscreen/multiscreen.dart';

import '../../connect_config.dart';

class PaymentDescriptionPage extends BlocStatefulWidget {
  final bool isNewHomeUser;

  PaymentDescriptionPage({this.isNewHomeUser});

  static const ROUTE_NAME = '/payment_description_page';

  static Future<Object> pushAndRemoveUntil(BuildContext context,
      bool isNewHomeUser) {
    return Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) =>
                PaymentDescriptionPage(isNewHomeUser: isNewHomeUser)),
            (route) => false);
  }

  @override
  _PaymentDescriptionState buildState() => _PaymentDescriptionState();
}

class _PaymentDescriptionState
    extends BlocState<PaymentDescriptionBloc, PaymentDescriptionPage> {
  bool isLoading = false;

  List<String> priceList = ['MONTH', '3_MONTH', '6_MONTH', 'YEAR'];

  happinessImage(context) {
    return Image.asset(
      AppImages.img_happiness,
      width: resize(120),
      height: resize(120),
    );
  }

  SwiperController con = SwiperController();
  int swipeIndex = 0;

  vipDescription(type) {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
      height: resize(213),
      child: Swiper(
        itemCount: priceList.length,
        autoplay: false,
        duration: 520,
        scale: 1,
        viewportFraction: 0.915,
        loop: false,
        controller: con,
        curve: Curves.ease,
        onIndexChanged: (idx) {
          setState(() {
            swipeIndex = idx;
          });
        },
        itemBuilder: (context, index) {
          return vipService(type, priceType: priceList[index]);
        },
      ),
    );
  }

  swipeStack() {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
      height: resize(8),
      child: Center(
        child: ListView.builder(
          itemBuilder: (context, idx) {
            return Padding(
              padding: EdgeInsets.only(
                  right: priceList.length == idx ? 0 : resize(8)),
              child: ClipOval(
                child: Container(
                  width: 8,
                  height: 8,
                  color: swipeIndex == idx ? AppColors.purple : AppColors
                      .grey40,
                ),
              ),
            );
          },
          shrinkWrap: true,
          itemCount: priceList.length,
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }

  termsAndPrivacy() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            ShowTermsPage.pushViewing(context, type: TermsType.TERMS);
          },
          child: Text(
            "Terms of service",
            style: AppTextStyle.from(
                size: TextSize.caption_small,
                color: AppColors.grey,
                weight: TextWeight.semibold),
            textAlign: TextAlign.end,
          ),
        ),
        emptySpaceW(width: 4),
        Text(
          "|",
          style: AppTextStyle.from(
              size: TextSize.caption_small,
              color: AppColors.grey,
              weight: TextWeight.semibold),
        ),
        emptySpaceW(width: 4),
        GestureDetector(
          onTap: () {
            ShowTermsPage.pushViewing(context, type: TermsType.PRIVACY_POLICY);
          },
          child: Text(
            "Privacy Policy",
            style: AppTextStyle.from(
                size: TextSize.caption_small,
                color: AppColors.grey,
                weight: TextWeight.semibold),
          ),
        ),
      ],
    );
  }

  memberSelect() {
    return Padding(
      padding: EdgeInsets.only(left: resize(24), right: resize(24)),
      child: Row(
        children: [
          Flexible(
            child: ElevatedButton(
                onPressed: () {
                  appsflyer.saveLog(accountStart);
                  HomeNavigation.pushAndRemoveUntil(context);
                },
                style: ElevatedButton.styleFrom(
                    primary: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: BorderSide(color: AppColors.purple, width: 2),
                    padding: EdgeInsets.zero,
                    elevation: 0),
                child: Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  height: resize(54),
                  child: Center(
                    child: Text(
                      AppStrings.of(StringKey.free_member),
                      style: AppTextStyle.from(
                          color: AppColors.purple,
                          size: TextSize.body_small,
                          weight: TextWeight.semibold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )),
          ),
          emptySpaceW(width: 12),
          Flexible(
            child: ElevatedButton(
                onPressed: () {
                  // 결제 라이브러리 이용하여 결제 진행
                  bloc.add(PaymentSubscribe(type: swipeIndex));
                },
                style: ElevatedButton.styleFrom(
                    primary: AppColors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: EdgeInsets.zero,
                    elevation: 0),
                child: Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  height: resize(54),
                  child: Center(
                    child: Text(
                      AppStrings.of(StringKey.vip_member),
                      style: AppTextStyle.from(
                          color: AppColors.white,
                          size: TextSize.body_small,
                          weight: TextWeight.semibold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )),
          )
        ],
      ),
    );
  }

  connectUserUi(context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: welcome(AppStrings.of(StringKey.welcome_to_connect)),
            ),
            emptySpaceH(height: 24),
            defaultService(AppStrings.of(StringKey.basic_rehab_content)),
            emptySpaceH(height: 4),
            defaultService(AppStrings.of(StringKey.daily_missions)),
            emptySpaceH(height: 14),
            vipDescription(false),
            emptySpaceH(height: 16),
            swipeStack(),
            emptySpaceH(height: 12),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Column(
            children: [
              termsAndPrivacy(),
              emptySpaceH(height: 22),
              memberSelect(),
              emptySpaceH(height: 24)
            ],
          ),
        ),
      ],
    );
  }

  threeMonthFreeTrial() {
    return Container(
      width: resize(174),
      height: resize(32),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50), color: AppColors.green),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              AppImages.ic_check_circle_fill_green,
              width: resize(16),
              height: resize(16),
            ),
            emptySpaceW(width: 8),
            Text(
              AppStrings.of(StringKey.three_month_free_trial),
              style: AppTextStyle.from(
                  color: AppColors.white,
                  size: TextSize.caption_medium,
                  weight: TextWeight.semibold),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  homeUserUi(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        welcome(AppStrings.of(StringKey.welcome_warriors)),
        emptySpaceH(height: 24),
        Padding(
          padding: EdgeInsets.only(left: resize(26)),
          child: Align(
            alignment: Alignment.centerLeft,
            child: threeMonthFreeTrial(),
          ),
        ),
        emptySpaceH(height: 10),
        defaultService(AppStrings.of(StringKey.basic_rehab_content)),
        emptySpaceH(height: 4),
        defaultService(AppStrings.of(StringKey.daily_missions)),
        emptySpaceH(height: 4),
        vipService(true),
        emptySpaceH(height: 16),
        captionText(AppStrings.of(StringKey.you_can_use_all_functions)),
        emptySpaceH(height: 32),
        Padding(
          padding: EdgeInsets.only(left: resize(24), right: resize(24)),
          child: BottomButton(
            onPressed: () {
              bloc.add(HomeUserPayment());
            },
            text: AppStrings.of(StringKey.start_three_month_free_trial),
            textColor: AppColors.white,
          ),
        )
      ],
    );
  }

  welcome(text) {
    return Container(
      height: resize(26),
      child: Text(
        text,
        style: AppTextStyle.from(
            weight: TextWeight.extrabold,
            size: TextSize.title_small,
            color: AppColors.darkGrey),
        textAlign: TextAlign.center,
      ),
    );
  }

  defaultService(text) {
    return Padding(
      padding: EdgeInsets.only(left: resize(40), right: resize(40)),
      child: Container(
        height: resize(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              AppImages.ic_check_circle_fill_true,
              width: resize(16),
              height: resize(16),
            ),
            emptySpaceW(width: 8),
            Text(
              text,
              style: AppTextStyle.from(
                  color: AppColors.darkGrey, size: TextSize.caption_medium),
            )
          ],
        ),
      ),
    );
  }

  price(String priceType) {
    if (priceType == "YEAR") {
      return "\$99.99";
    } else if (priceType == "6_MONTH") {
      return "\$69.99";
    } else if (priceType == "3_MONTH") {
      return "\$49.99";
    } else if (priceType == "MONTH") {
      return "\$19.99";
    }
  }

  priceDescription(String priceType) {
    if (priceType == "YEAR") {
      return "/year (\$8.33/mo)";
    } else if (priceType == "6_MONTH") {
      return "/6months (\$11.66/mo)";
    } else if (priceType == "3_MONTH") {
      return "/3months (\$16.66/mo)";
    } else if (priceType == "MONTH") {
      return "/month";
    }
  }

  disCount(String priceType) {
    if (priceType == "YEAR") {
      return "58% off";
    } else if (priceType == "6_MONTH") {
      return "42% off";
    } else if (priceType == "3_MONTH") {
      return "17% off";
    }
  }

  vipService(type, {String priceType}) {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
      height: resize(type ? 157 : 213),
      child: Stack(
        children: [
          Positioned(
            left: resize(type ? 24 : 5),
            right: resize(type ? 24 : 5),
            top: resize(11),
            child: Container(
              width: resize(320),
              height: resize(type ? 146 : 202),
              decoration: BoxDecoration(
                gradient: type
                    ? null
                    : LinearGradient(
                    colors: [Color(0xFF878aff), Color(0xFFae94ef)]),
                borderRadius: BorderRadius.circular(16),
                color: type ? AppColors.white : null,
                border: type ? Border.all(color: AppColors.lightGrey04) : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  emptySpaceH(height: type ? 18 : 22),
                  type
                      ? Container()
                      : Padding(
                    padding: EdgeInsets.only(
                        left: resize(16), right: resize(16)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          price(priceType),
                          style: AppTextStyle.from(
                              color: AppColors.white,
                              size: TextSize.title_medium,
                              weight: TextWeight.bold),
                        ),
                        emptySpaceW(width: 4),
                        Text(
                          priceDescription(priceType),
                          style: AppTextStyle.from(
                              color: AppColors.white,
                              size: TextSize.caption_large,
                              weight: TextWeight.bold),
                        )
                      ],
                    ),
                  ),
                  type ? Container() : emptySpaceH(height: 14),
                  serviceDescription(
                      AppStrings.of(
                          StringKey.includes_a_personal_connect_coach),
                      type),
                  emptySpaceH(height: 4),
                  serviceDescription(
                      AppStrings.of(StringKey.customized_daily_missions), type),
                  emptySpaceH(height: 4),
                  serviceDescription(
                      AppStrings.of(
                          StringKey.regular_evaluations_and_progress_reports),
                      type),
                  emptySpaceH(height: 4),
                  serviceDescription(
                      AppStrings.of(StringKey.unlimited_premium_content), type),
                  emptySpaceH(height: 4),
                  type
                      ? Container()
                      : Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    padding: EdgeInsets.only(right: resize(14)),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          bloc.add(ConnectUserPayment());
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              AppStrings.of(StringKey.learn_more),
                              style: AppTextStyle.from(
                                  color: AppColors.white,
                                  weight: TextWeight.semibold,
                                  size: TextSize.caption_very_small),
                            ),
                            emptySpaceW(width: 2),
                            Image.asset(
                              AppImages.ic_chevron_right,
                              color: AppColors.white,
                              width: resize(16),
                              height: resize(16),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: type ? null : resize(16),
            right: type ? resize(40) : null,
            child: Container(
              width: resize(104),
              height: resize(22),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: type ? AppColors.white : AppColors.orange,
                  border:
                  type ? Border.all(color: AppColors.lightGrey04) : null),
              child: Center(
                child: Text(
                  AppStrings.of(StringKey.for_vip_user),
                  style: AppTextStyle.from(
                    color: type ? AppColors.grey : AppColors.white,
                    size: TextSize.caption_very_small,
                    weight: TextWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          type
              ? Container()
              : priceType == "MONTH"
              ? Container()
              : Positioned(
            top: 0,
            right: resize(16),
            child: Container(
              width: resize(65),
              height: resize(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppColors.black,
              ),
              child: Center(
                child: Text(
                  disCount(priceType),
                  style: AppTextStyle.from(
                    color: AppColors.white,
                    size: TextSize.caption_very_small,
                    weight: TextWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  serviceDescription(text, type) {
    return Padding(
      padding: EdgeInsets.only(left: resize(16), right: resize(14)),
      child: Container(
        height: resize(
            (text == AppStrings.of(StringKey.unlimited_premium_content))
                ? 40
                : 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              type
                  ? AppImages.ic_check_circle_fill_true
                  : AppImages.ic_check_circle_fill_white_2,
              width: resize(16),
              height: resize(16),
            ),
            emptySpaceW(width: 8),
            Expanded(
              child: Text(
                text,
                style: AppTextStyle.from(
                    color: type ? AppColors.darkGrey : AppColors.white,
                    size: TextSize.caption_medium,
                    height: 1.3),
              ),
            )
          ],
        ),
      ),
    );
  }

  captionText(text) {
    return Container(
      padding: EdgeInsets.only(left: resize(24), right: resize(24)),
      width: MediaQuery
          .of(context)
          .size
          .width,
      child: Text(
        text,
        style: AppTextStyle.from(
            size: TextSize.caption_small, color: AppColors.grey, height: 1.3),
      ),
    );
  }

  // 가입날짜가 오늘인 유저만 들어오게끔 해야할거같음
  _buildMain(context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        emptySpaceH(height: MediaQuery
            .of(context)
            .padding
            .top),
        emptySpaceH(height: 8),
        happinessImage(context),
        emptySpaceH(height: 12),
        (widget.isNewHomeUser != null && widget.isNewHomeUser)
            ? homeUserUi(context)
            : Expanded(
          child: connectUserUi(context),
        ),
      ],
    );
  }

  _buildProgress(BuildContext context) {
    if (!isLoading) return Container();

    return FullscreenDialog();
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
              resizeToAvoidBottomInset: true,
              backgroundColor: AppColors.white,
              body: Container(
                height: MediaQuery
                    .of(context)
                    .size
                    .height - MediaQuery.of(context).padding.top,
                child: Stack(
                  children: [
                    NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (notification) {
                        notification.disallowGlow();
                        return true;
                      },
                      child: SingleChildScrollView(
                        child: Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          height: MediaQuery
                              .of(context)
                              .size
                              .height,
                          color: AppColors.white,
                          child: _buildMain(context),
                        ),
                      ),
                    ),
                    _buildProgress(context)
                  ],
                ),
              ),
            ));
      },
    );
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is HomeUserPaymentSubscribing) {
      setState(() {
        isLoading = true;
      });
    }

    if (state is HomeUserPaymentSuccess) {
      setState(() {
        isLoading = false;
      });
      HomeNavigation.pushAndRemoveUntil(context);
    }

    if (state is HomeUserPaymentFailure) {
      setState(() {
        isLoading = false;
      });
    }

    if (state is ConnectUserPaymentState) {
      PaymentNoticePage.push(context,
          isNewHomeUser: false, closeable: true, back: true);
    }

    //결제 가능한지 체크
    if (state is PaymentCheckInProgress) {
      setState(() {
        isLoading = true;
      });
    }
    //결제 이용불가 상태
    if (state is PaymentNotAvailable || state is PaymentProductNotFound) {
      setState(() {
        isLoading = false;
      });
      showDialog(
          context: context,
          child: BaseAlertDialog(
              onConfirm: () => {},
              content: AppStrings.of(StringKey.payment_not_available)));
    }
    //결제 이용가능 상태
    if (state is PaymentAvailable) {
      setState(() {
        isLoading = false;
      });
    }

    if (state is PaymentSubscribing) {
      setState(() {
        isLoading = true;
      });
    }

    if (state is PaymentSubscribeSuccess) {
      setState(() {
        isLoading = false;
      });
      showDialog(
          context: context,
          child: BaseAlertDialog(
              onConfirm: () => {
              // HomeCalendarPage.pushAndRemoveUntil(context)
              HomeNavigation.pushAndRemoveUntil(context)
          },
              content: AppStrings.of(StringKey.subscription_completed)));
    }

    if (state is PaymentSubscribeFailure) {
      setState(() {
        isLoading = false;
      });
      showDialog(
          context: context,
          child: BaseAlertDialog(
              onConfirm: () => {},
              content: AppStrings.of(StringKey.subscription_not_completed) +
                  (isDebug ? state.errorMessage : "")));
    }
  }

  @override
  initBloc() {
    // TODO: implement initBloc
    return PaymentDescriptionBloc(context)
      ..add(PaymentDescriptionInitEvent())..add(PaymentCheck());
  }
}
