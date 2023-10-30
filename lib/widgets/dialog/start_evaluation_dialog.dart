import 'package:connect/feature/evaluation/evaluation_page.dart';
import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_images.dart';
import 'package:connect/resources/app_strings.dart';
import 'package:connect/resources/app_text_style.dart';
import 'package:connect/utils/appsflyer/apps_flyer.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multiscreen/multiscreen.dart';

import '../base_alert_dialog.dart';

startEvaluationDialog(context) {
  return showDialog(
      barrierDismissible: true,
      context: (context),
      builder: (_) {
        return WillPopScope(
          onWillPop: () {
            showDialog(
                context: context,
                child: BaseAlertDialog(
                  content: AppStrings.of(StringKey.are_you_sure_you_want_to_exit),
                  cancelable: true,
                  onConfirm: () {
                    SystemNavigator.pop();
                  },
                ));
            return null;
          },
          child: Dialog(
            elevation: 0,
            insetPadding: EdgeInsets.zero,
            backgroundColor: AppColors.transparent,
            child: Container(
              width: resize(328),
              height: resize(590),
              padding: EdgeInsets.zero,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: resize(66),
                    bottom: resize(29),
                    child: Container(
                      width: resize(328),
                      height: resize(590),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius:
                            BorderRadius.all(Radius.circular(resize(32))),
                      ),
                    ),
                  ),
                  Positioned(
                    left: resize(24),
                    right: resize(24),
                    child: Image.asset(
                      AppImages.img_mindfulness,
                      width: resize(210),
                      height: resize(195),
                    ),
                  ),
                  Positioned(
                    top: resize(210),
                    left: resize(8),
                    right: resize(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: resize(280),
                          height: resize(44),
                          color: AppColors.white,
                          child: Text(
                            AppStrings.of(StringKey.congratulations),
                            style: AppTextStyle.from(
                                color: AppColors.darkGrey,
                                size: TextSize.title_medium_bigger_than,
                                weight: TextWeight.extrabold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        emptySpaceH(height: 16),
                        Container(
                          width: resize(280),
                          // height: resize(52),
                          color: AppColors.white,
                          child: Center(
                            child: Text(
                              AppStrings.of(
                                  StringKey.you_become_vip_at_connect),
                              style: AppTextStyle.from(
                                color: AppColors.darkGrey,
                                size: TextSize.caption_medium,
                                weight: TextWeight.bold,
                              ),
                              strutStyle: StrutStyle(leading: 0.65),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        emptySpaceH(height: 24),
                        serviceDescription(AppStrings.of(
                            StringKey.one_personal_neofect_specialist)),
                        emptySpaceH(height: 4),
                        serviceDescription(
                            AppStrings.of(StringKey.customized_daily_missions)),
                        emptySpaceH(height: 4),
                        serviceDescription(AppStrings.of(StringKey
                            .regular_evaluations_and_progress_reports)),
                        emptySpaceH(height: 4),
                        serviceDescription(
                            AppStrings.of(StringKey.unlimited_premium_content)),
                      ],
                    ),
                  ),
                  Positioned(
                    left: resize(0),
                    right: resize(0),
                    bottom: resize(24),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: resize(72),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(resize(32)),
                            bottomRight: Radius.circular(resize(32))),
                        child: RaisedButton(
                          onPressed: () {
                            appsflyer.saveLog(evalStart);
                            EvaluationPage.push(context, 0);
                          },
                          elevation: 0.0,
                          color: AppColors.lightPurple,
                          child: Center(
                            child: Container(
                              width: resize(160),
                              height: resize(23.6),
                              child: Center(
                                child: Text(
                                  AppStrings.of(StringKey.start_evaluation),
                                  style: AppTextStyle.from(
                                      color: AppColors.white,
                                      size: TextSize.body_small,
                                      weight: TextWeight.semibold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      });
}

serviceDescription(text) {
  return Padding(
    padding: EdgeInsets.only(left: resize(16), right: resize(14)),
    child: Container(
      height: resize((text ==
              AppStrings.of(
                  StringKey.unlimited_premium_content))
          ? 40
          : 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            AppImages.ic_check_circle_fill_true,
            width: resize(16),
            height: resize(16),
          ),
          emptySpaceW(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyle.from(
                  color: AppColors.darkGrey,
                  size: TextSize.caption_medium,
                  height: 1.3),
            ),
          )
        ],
      ),
    ),
  );
}
