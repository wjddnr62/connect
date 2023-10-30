import 'dart:math';

import 'package:connect/feature/feedback/feedback_bloc.dart';
import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/resources/app_strings.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:connect/utils/toast/toast.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/bottons/bottom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackPage extends BlocStatefulWidget {
  static Future<Object> push(BuildContext context) {
    return Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => FeedbackPage()));
  }

  @override
  FeedbackState buildState() => FeedbackState();
}

class FeedbackState extends BlocState<FeedbackBloc, FeedbackPage> {
  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
        cubit: bloc,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: baseAppBar(context,
                centerTitle: true, title: AppStrings.of(StringKey.feedback)),
            body: Padding(
              padding: EdgeInsets.only(left: resize(24), right: resize(24)),
              child: Column(
                children: [
                  emptySpaceH(height: 62),
                  Text(
                    AppStrings.of(
                        StringKey.rehabit_is_waiting_for_your_feedback),
                    style: AppTextStyle.from(
                        color: AppColors.black,
                        weight: TextWeight.semibold,
                        size: TextSize.caption_large),
                  ),
                  emptySpaceH(height: 32),
                  BottomButton(
                    onPressed: () {
                      launch("mailto:rehabit.support@neofect.com");
                    },
                    text: AppStrings.of(StringKey.send_feedback),
                  ),
                  emptySpaceH(height: 44),
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: resize(0.8),
                        color: AppColors.lightGrey04,
                      )),
                      emptySpaceW(width: 8),
                      Text(
                        AppStrings.of(StringKey.or),
                        style: AppTextStyle.from(
                            color: AppColors.grey,
                            weight: TextWeight.semibold,
                            size: TextSize.caption_large),
                      ),
                      emptySpaceW(width: 8),
                      Expanded(
                          child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: resize(0.8),
                        color: AppColors.lightGrey04,
                      ))
                    ],
                  ),
                  emptySpaceH(height: 44),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.rotate(
                          angle: 135 * pi / 180,
                          child: Icon(
                            Icons.link,
                            color: AppColors.black,
                          )),
                      emptySpaceW(width: 4),
                      Text(
                        AppStrings.of(StringKey.copy_link),
                        style: AppTextStyle.from(
                            color: AppColors.darkGrey,
                            weight: TextWeight.semibold,
                            size: TextSize.caption_medium),
                      )
                    ],
                  ),
                  emptySpaceH(height: 4),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(
                              text: "rehabit.support@neofect.com"))
                          .then((value) {
                        showToast("Email address copied",
                            custom: true, context: context);
                      });
                    },
                    child: Container(
                      height: resize(28),
                      child: Text(
                        "rehabit.support@neofect.com",
                        style: AppTextStyle.from(
                            color: AppColors.blue01,
                            size: TextSize.caption_large,
                            weight: TextWeight.semibold,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  blocListener(BuildContext context, state) {}

  @override
  FeedbackBloc initBloc() {
    return FeedbackBloc(context)..add(FeedBackInitEvent());
  }
}
