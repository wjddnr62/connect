import 'package:connect/resources/app_resources.dart';
import 'package:connect/user_log/events.dart';
import 'package:connect/user_log/user_logger.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/bottons/bottom_button.dart';
import 'package:flutter/material.dart';
import 'package:open_appstore/open_appstore.dart';

class ForceUpdateGuidePage extends BasicStatelessWidget {
  static const String ROUTE_NAME = '/force_update_page';

  static Future<Object> pushAndRemoveUntil(BuildContext context) {
    return Navigator.of(context)
        .pushNamedAndRemoveUntil(ROUTE_NAME, (route) => false);
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.white,
        body: Column(children: [
          Expanded(
              child: Center(
                  child: Container(
                      padding: EdgeInsets.all(resize(32)),
                      child: Text(AppStrings.of(StringKey.please_update),
                          textAlign: TextAlign.center,
                          style: AppTextStyle.from(
                              size: TextSize.title_small,
                              weight: TextWeight.semibold,
                              height: 1.6,
                              color: AppColors.black))))),
          Container(
              margin: EdgeInsets.only(
                  right: resize(16), left: resize(16), bottom: resize(32)),
              child: BottomButton(
                  text: AppStrings.of(StringKey.update),
                  onPressed: () {
                    UserLogger.logEventName(
                        eventName: EventCommon.OPEN_APP_STORE);
                    OpenAppstore.launch(
                        androidAppId: "com.neofect.connect",
                        iOSAppId: "1473561369");
                  }))
        ]));
  }
}
