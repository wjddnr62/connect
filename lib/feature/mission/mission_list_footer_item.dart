import 'package:connect/data/remote/user/get_terms_service.dart';
import 'package:connect/feature/user/account/show_terms_page.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FooterItem extends BasicStatelessWidget {
  String termsAndConditions = "Terms & Conditions";
  String privacyPolicy = "Privacy Policy";

  privacyContent(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: resize(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    ShowTermsPage.pushViewing(context, type: TermsType.TERMS);
                  },
                  child: Text(
                    termsAndConditions,
                    style: AppTextStyle.from(
                        size: TextSize.caption_small, color: AppColors.purple),
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  "and ",
                  style: AppTextStyle.from(
                      size: TextSize.caption_small, color: AppColors.grey),
                  textAlign: TextAlign.center,
                ),
                GestureDetector(
                  onTap: () {
                    ShowTermsPage.pushViewing(context,
                        type: TermsType.PRIVACY_POLICY);
                  },
                  child: Text(
                    privacyPolicy,
                    style: AppTextStyle.from(
                      size: TextSize.caption_small,
                      color: AppColors.purple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(
            top: resize(20),
            bottom: resize(24),
            left: resize(24),
            right: resize(24)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          privacyContent(context),
          SizedBox(height: resize(8)),
          Text(AppStrings.of(StringKey.copyright),
              textAlign: TextAlign.start,
              style: AppTextStyle.from(
                  color: AppColors.grey,
                  size: TextSize.copy_right_text,
                  weight: TextWeight.bold))
        ]));
  }
}
