import 'package:connect/connect_config.dart';
import 'package:connect/data/user_repository.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/feature/chat/text/stroke_coach_info_page.dart';
import 'package:connect/feature/payment/payment_notice_page.dart';
import 'package:connect/feature/user/profile/profile_page.dart';
import 'package:connect/models/error.dart';
import 'package:connect/models/profile.dart';
import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_images.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/resources/app_text_style.dart';
import 'package:connect/widgets/base_alert_dialog.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:connect/widgets/pages/error_page.dart';
import 'package:flutter/material.dart';

import 'account_bloc.dart';

class AccountPage extends BlocStatefulWidget {
  static const ROUTE_NAME = '/account_page';

  static Future<Object> popAndPushNamed(BuildContext context) =>
      Navigator.of(context).popAndPushNamed(ROUTE_NAME);

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() => _AccountPageState();
}

class _AccountPageState extends BlocState<AccountBloc, AccountPage> {
  final _tag = '_AccountPageState';

  @override
  AccountBloc initBloc() => AccountBloc();

  @override
  blocBuilder(BuildContext context, state) {
    Widget dialogWidget;
    if (state is MyOTLoading) {
      return Container();
    }

    if (state is MyOTTherapistEmpty) {
      dialogWidget = BaseAlertDialog(
          content: "We'll assign stroke coach soon.\nPlease wait a moment.");
    }

    return buildWidget(context, dialogWidget);
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is MyOTLoading) {
      showDialog(context: context, child: FullscreenDialog());
    }

    if (state is MyOTLoaded) {
      popUntilNamed(context, AccountPage.ROUTE_NAME);

      StrokeCoachInfoPage.push(context,
          strokeCoach: state.strokeCoach,
          startTime: state.workingHours?.start_work_time,
          endTime: state.workingHours?.end_work_time);
    }

    if (state is UnknownError && gFlavor == Flavor.DEV) {
      popUntilNamed(context, AccountPage.ROUTE_NAME);

      showDialog(
          context: context,
          child: BaseAlertDialog(
            content: "${state.e}",
          ));
    }

    if (state is MyOTInfoNotSet) {
      popUntilNamed(context, AccountPage.ROUTE_NAME);

      showDialog(
          context: context,
          child: BaseAlertDialog(
              content: AppStrings.of(StringKey.wait_your_coach)));
    }

    return null;
  }

  Widget buildWidget(BuildContext context, Widget dialogWidget) {
    final backgroundColor = AppColors.lightGrey01;
    return Container(
        color: backgroundColor,
        child: SafeArea(
            child: Scaffold(
                backgroundColor: AppColors.white,
                appBar: baseAppBar(context,
                    title: AppStrings.of(StringKey.account), backgroundColor: AppColors.lightGrey02),
                body: (dialogWidget != null)
                    ? dialogWidget
                    : Container(
                        color: backgroundColor,
                        child: ListView(children: [
                          _createListItem(StringKey.profile.getString(), "",
                              false, () => ProfilePage.push(context)),
                          _createListItem(StringKey.subscribe.getString(), "",
                              false, () => checkSubscriptionStatus()),
                        ])))));
  }

  Widget _createListItem(item, value, divider, tap) {
    return InkWell(
        onTap: tap,
        child: Container(
            height: resize(56),
            child: Container(
                color: AppColors.white,
                padding: EdgeInsets.only(left: resize(24)),
                child: Stack(children: <Widget>[
                  Container(
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(item,
                              style: AppTextStyle.from(
                                  size: TextSize.body_small,
                                  weight: TextWeight.semibold,
                                  color: AppColors.darkGrey)))),
                  Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                          padding: EdgeInsets.only(right: resize(16)),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                    margin: EdgeInsets.only(right: resize(8)),
                                    child: Center(
                                        child: Text(value,
                                            style: AppTextStyle.from(
                                                size: TextSize.body_small,
                                                weight: TextWeight.medium,
                                                color: AppColors.darkGrey)))),
                                Container(
                                    child: Image.asset(
                                        AppImages.ic_chevron_right,
                                        width: resize(24),
                                        height: resize(24)))
                              ]))),
                  divider
                      ? Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                              margin: EdgeInsets.only(right: resize(16)),
                              height: resize(1),
                              color: AppColors.lightGrey04))
                      : Container()
                ]))));
  }

  void checkSubscriptionStatus() async{
    var res= await UserRepository.getProfile();

    if (res is ServiceError){
      ErrorPage.push(context, params: {ErrorPage.PARAM_KEY_ERROR: res});
    }

    if (res is Profile) {
        if(res?.subscription?.marketPlace?.isNotEmpty==true){
            showDialog(context: context,barrierDismissible: true,
            child:BaseAlertDialog(
                content: StringKey.subscribed_basic_product.getFormattedString([res.subscription.planName?? ""]),
                onConfirm: () => {}));
        }
        else {
          PaymentNoticePage.push(context,closeable: true, isNewHomeUser: res.isNewHomeUser ?? false, isNavMenu: true);
        }
    }
  }
}
