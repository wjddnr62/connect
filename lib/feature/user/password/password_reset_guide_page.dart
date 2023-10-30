import 'package:connect/data/user_repository.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/common_widgets.dart';
import 'package:flutter/material.dart';

class PasswordResetGuidePage extends BasicStatelessWidget {
  static const String ROUTE_NAME = '/password_reset_guide_page';

  static Future<Object> push(BuildContext context, String email) =>
      Navigator.of(context).pushNamed(ROUTE_NAME, arguments: email);

  @override
  Widget buildWidget(BuildContext context) {
    final String email = ModalRoute.of(context).settings.arguments;
    return FutureBuilder(
        future: UserRepository.requestPasswordReset(email),
        builder: (context, snapshot) => Scaffold(
            backgroundColor: Colors.white,
            body: Stack(children: [
              Container(
                  margin: EdgeInsets.only(bottom: resize(100)),
                  child: ListView(children: <Widget>[
                    SizedBox(height: resize(180)),
                    Image.asset(AppImages.ic_mail,
                        width: resize(56), height: resize(56)),
                    Container(
                        margin: EdgeInsets.only(
                            top: resize(32),
                            left: resize(24),
                            right: resize(24)),
                        child: RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              text: AppStrings.of(
                                  StringKey.desc_reset_password_part1),
                              style: AppTextStyle.from(
                                  color: AppColors.darkGrey,
                                  size: TextSize.body_medium,
                                  weight: TextWeight.medium,
                                  height: AppTextStyle.LINE_HEIGHT_MULTI_LINE)),
                          TextSpan(
                              text: email,
                              style: AppTextStyle.from(
                                  color: AppColors.orange,
                                  size: TextSize.body_medium,
                                  weight: TextWeight.medium,
                                  height: AppTextStyle.LINE_HEIGHT_MULTI_LINE)),
                          TextSpan(
                              text: AppStrings.of(
                                  StringKey.desc_reset_password_part2),
                              style: AppTextStyle.from(
                                  color: AppColors.darkGrey,
                                  size: TextSize.body_medium,
                                  weight: TextWeight.medium,
                                  height: AppTextStyle.LINE_HEIGHT_MULTI_LINE))
                        ])))
                  ])),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      width: double.maxFinite,
                      margin: EdgeInsets.only(
                          bottom: resize(32),
                          left: resize(16),
                          right: resize(16)),
                      child: BottomButton(
                          text: AppStrings.of(StringKey.back_to_login),
                          onPressed: () => pop(context),
                          color: AppColors.purple)))
            ])));
  }
}
