import 'package:connect/feature/user/account/show_terms_page.dart';
import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/utils/appsflyer/apps_flyer.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/common_widgets.dart';
import 'package:flutter/material.dart';

import '../../base_bloc.dart';
import '../sign_info.dart';
import 'sign_verifying_email_bloc.dart';

class SignVerifyingEmailPage extends BlocStatefulWidget {
  static const String ROUTE_NAME = '/verifying_email_page';

  @override
  _SignVerifyingEmailPageState buildState() => _SignVerifyingEmailPageState();

  static Future<Object> push(BuildContext context) {
    return Navigator.of(context).pushNamed(ROUTE_NAME);
  }
}

class _SignVerifyingEmailPageState
    extends BlocState<SignVerifyingEmailBloc, SignVerifyingEmailPage> {
  @override
  blocBuilder(BuildContext context, state) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
            margin: EdgeInsets.only(top: resize(60)),
            child: Column(children: <Widget>[
              Container(
                  margin: EdgeInsets.only(
                      top: resize(16),
                      left: resize(24),
                      right: resize(24),
                      bottom: resize(24)),
                  child: Text(AppStrings.of(StringKey.check_email_verification),
                      textAlign: TextAlign.start,
                      style: AppTextStyle.from(
                          color: AppColors.black,
                          size: TextSize.title_large,
                          weight: TextWeight.extrabold,
                          height: AppTextStyle.LINE_HEIGHT_MULTI_LINE,
                          letterSpacing: -.4))),
              Container(
                  margin: EdgeInsets.only(right: resize(24), left: resize(24)),
                  child: RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: AppStrings.of(
                            StringKey.description_check_email_part1),
                        style: AppTextStyle.from(
                            color: AppColors.darkGrey,
                            size: TextSize.body_medium,
                            weight: TextWeight.medium,
                            height: AppTextStyle.LINE_HEIGHT_MULTI_LINE)),
                    TextSpan(
                        text: SignInfo.instance.emailId,
                        style: AppTextStyle.from(
                            color: AppColors.orange,
                            size: TextSize.body_medium,
                            weight: TextWeight.medium,
                            height: AppTextStyle.LINE_HEIGHT_MULTI_LINE)),
                    TextSpan(
                        text: AppStrings.of(
                            StringKey.description_check_email_part2),
                        style: AppTextStyle.from(
                            color: AppColors.darkGrey,
                            size: TextSize.body_medium,
                            weight: TextWeight.medium,
                            height: AppTextStyle.LINE_HEIGHT_MULTI_LINE))
                  ]))),
              Expanded(
                  child: Column(children: <Widget>[
                Container(
                    margin:
                        EdgeInsets.only(top: resize(80), bottom: resize(32)),
                    child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                        strokeWidth: resize(4),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.orange))),
                Text(AppStrings.of(StringKey.verifying_email),
                    style: AppTextStyle.from(
                        color: Colors.grey,
                        size: TextSize.caption_large,
                        weight: TextWeight.medium))
              ])),
              Container(
                  color: AppColors.disable,
                  width: double.maxFinite,
                  margin: EdgeInsets.only(
                      bottom: resize(32), left: resize(16), right: resize(16)),
                  child: BottomButton(
                      text: AppStrings.of(StringKey.retype_email),
                      onPressed: () => bloc.add(CancelVerifyingEmail()),
                      color: AppColors.disable,
                      textColor: AppColors.darkGrey,
                      icon: AppImages.ic_arrow_left))
            ])));
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is VerifiedEmail) {
      // appsflyer.saveLog(verificationComplete);
      ShowTermsPage.popAndPush(context, showAgree: true);
      return;
    }

    if (state is ShowError) {
      return;
    }

    if (state is CanceledVerifyingEmail) {
      pop(context);
      return;
    }
  }

  @override
  SignVerifyingEmailBloc initBloc() =>
      SignVerifyingEmailBloc()..add(RequestVerifyEmail());
}
