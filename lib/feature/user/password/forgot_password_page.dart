import 'package:connect/feature/user/password/password_reset_guide_page.dart';
import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_images.dart';
import 'package:connect/resources/app_strings.dart';
import 'package:connect/resources/app_text_style.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:connect/utils/regular_expressions.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/bottons/bottom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multiscreen/multiscreen.dart';

import 'forgot_password_bloc.dart';

class ForgotPasswordPage extends BlocStatefulWidget {
  static const String ROUTE_NAME = '/forgot_password_page';

  static void popUntil(BuildContext context) {
    Navigator.of(context).popUntil((predicate) {
      if (predicate.settings.name == ROUTE_NAME) {
        return true;
      }
      return false;
    });
  }

  static Future<Object> push(BuildContext context) {
    return Navigator.of(context).pushNamed(ROUTE_NAME);
  }

  @override
  _ForgotPasswordState buildState() => _ForgotPasswordState();
}

class _ForgotPasswordState
    extends BlocState<ForgotPasswordBloc, ForgotPasswordPage> {
  final emailInputController = TextEditingController();

  bool emailPassed = false;

  forgotPasswordText() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: resize(30),
      padding: EdgeInsets.only(left: resize(20), right: resize(20)),
      child: Text(
        AppStrings.of(StringKey.forgot_password),
        style: AppTextStyle.from(
            color: AppColors.black,
            size: TextSize.title_medium,
            weight: TextWeight.extrabold),
      ),
    );
  }

  emailText() {
    return Container(
      padding: EdgeInsets.only(left: resize(24)),
      child: Text(
        AppStrings.of(StringKey.email),
        style: AppTextStyle.from(
            weight: TextWeight.bold,
            size: TextSize.caption_small,
            color: AppColors.darkGrey),
        textAlign: TextAlign.left,
      ),
    );
  }

  emailInput(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: resize(24), right: resize(24)),
      child: TextFormField(
          onChanged: (text) {
            setState(() {
              if (validateEmailFormat(text)) {
                emailPassed = true;
              } else {
                emailPassed = false;
              }
            });
          },
          cursorColor: AppColors.black,
          maxLines: 1,
          controller: emailInputController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          style: AppTextStyle.from(
              size: TextSize.body_small, color: AppColors.black),
          decoration: InputDecoration(
              hintText: AppStrings.of(StringKey.type_your_email),
              hintStyle: AppTextStyle.from(
                  size: TextSize.caption_large, color: AppColors.lightGrey03),
              border: OutlineInputBorder(
                  borderSide:
                      BorderSide(width: resize(1), color: AppColors.grey)),
              enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(width: resize(1), color: AppColors.grey)),
              focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(width: resize(1), color: AppColors.purple)),
              contentPadding: EdgeInsets.only(
                left: resize(16),
                right: resize(8),
              ))),
    );
  }

  resetPasswordButton(context) {
    return BottomButton(
      onPressed: emailPassed
          ? () {
              Navigator.pop(context);
              PasswordResetGuidePage.push(context, emailInputController.text);
            }
          : null,
      text: AppStrings.of(StringKey.reset_password),
      textColor: emailPassed ? AppColors.white : AppColors.lightGrey03,
    );
  }

  _buildMain(context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            emptySpaceH(height: 16),
            forgotPasswordText(),
            emptySpaceH(height: 16),
            emailText(),
            emptySpaceH(height: 8),
            emailInput(context)
          ],
        ),
        Positioned(
            left: resize(24),
            right: resize(24),
            bottom: resize(24),
            child: resetPasswordButton(context))
      ],
    );
  }

  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
        cubit: bloc,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: baseAppBar(context,
                backgroundColor: AppColors.white,
                elevation: 0.0,
                leading: IconButton(
                    icon: Image.asset(AppImages.ic_chevron_left),
                    onPressed: () {
                      Navigator.of(context).pop();
                    })),
            resizeToAvoidBottomInset: true,
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: _buildMain(context),
            ),
          );
        });
  }

  @override
  blocListener(BuildContext context, state) {}

  @override
  ForgotPasswordBloc initBloc() {
    // TODO: implement initBloc
    return ForgotPasswordBloc(context)..add(ForgotPasswordInitEvent());
  }
}
