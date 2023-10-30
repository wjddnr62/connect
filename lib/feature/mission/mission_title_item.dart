import 'package:connect/data/local/app_dao.dart';
import 'package:connect/feature/payment/payment_notice_page.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/utils/appsflyer/apps_flyer.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MissionTitleItem extends BasicStatelessWidget {
  bool dateNow = false;
  String userType = "";
  bool enableBanner = false;

  MissionTitleItem({this.dateNow, this.userType, this.enableBanner});

  @override
  Widget buildWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        (userType == "" && dateNow && enableBanner)
            ? Padding(
                padding: EdgeInsets.only(
                    top: resize(24), left: resize(24), right: resize(24)),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: resize(70),
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                      color: AppColors.lightPurple,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x6643457c),
                          blurRadius: 10,
                        )
                      ],
                      image: DecorationImage(
                        image: AssetImage(AppImages.img_customized_sun),
                        alignment: Alignment.centerRight,
                        fit: BoxFit.contain,
                      )),
                  child: RaisedButton(
                    onPressed: () {
                      appsflyer.saveLog(getEvaluation);
                      PaymentNoticePage.push(context,
                          back: true, closeable: true, focusImg: 2);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.only(left: resize(24)),
                    color: AppColors.transparent,
                    elevation: 0.0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppImages.img_customized,
                          width: resize(32),
                          height: resize(32),
                        ),
                        emptySpaceW(width: 24),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.of(StringKey.get_evaluation),
                              style: AppTextStyle.from(
                                  color: AppColors.white,
                                  size: TextSize.caption_large,
                                  weight: TextWeight.bold),
                            ),
                            emptySpaceH(height: 4),
                            Text(
                              AppStrings.of(StringKey.for_customized_contents),
                              style: AppTextStyle.from(
                                color: AppColors.white,
                                size: TextSize.caption_small,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ))
            : Container(),
        Container(
          height: resize(18),
          margin: EdgeInsets.only(
            top: resize(16),
            left: resize(24),
            right: resize(16),
          ),
          child: Container(
            height: resize(18),
            child: Text(
              AppStrings.of(dateNow ? StringKey.today_mission : StringKey.mission),
              style: AppTextStyle.from(
                color: AppColors.darkGrey,
                size: TextSize.body_very_small,
                weight: TextWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        )
      ],
    );
  }
}
