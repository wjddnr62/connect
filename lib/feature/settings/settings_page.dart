import 'dart:io';

import 'package:connect/connect_config.dart';
import 'package:connect/data/remote/user/get_terms_service.dart';
import 'package:connect/data/share_repository.dart';
import 'package:connect/data/user_repository.dart';
import 'package:connect/feature/feedback/feedback_page.dart';
import 'package:connect/feature/settings/contributor_page.dart';
import 'package:connect/feature/splash/splash_bloc.dart';
import 'package:connect/feature/user/account/show_terms_page.dart';
import 'package:connect/feature/user/login/login_page.dart';
import 'package:connect/feature/user/profile_info.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:connect/utils/foreground_service.dart';
import 'package:connect/utils/logger/log.dart';
import 'package:connect/widgets/base_alert_dialog.dart';
import 'package:connect/widgets/base_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sendbird_plugin/flutter_sendbird_plugin.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends BasicStatelessWidget {
  static const ROUTE_NAME = '/settings_page';
  final String _tag = 'SettingsPage';

  static Future<Object> push(BuildContext context) {
    return Navigator.of(context).pushNamed(ROUTE_NAME);
  }

  InAppReview inAppReview = InAppReview.instance;

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.lightGrey02,
        appBar: baseAppBar(context,
            title: AppStrings.of(StringKey.settings),
            backgroundColor: AppColors.lightGrey02),
        body: ListView(children: <Widget>[
          _Title(title: 'Service Information'),
          _Item(
              title: StringKey.terms_of_use.getString(),
              onTap: () async =>
                  ShowTermsPage.pushViewing(context, type: TermsType.TERMS)),
          Container(
              padding: EdgeInsets.only(left: resize(16), right: resize(16)),
              height: resize(1),
              color: AppColors.white,
              child: Container(color: AppColors.lightGrey02)),
          Container(
              width: double.maxFinite,
              color: AppColors.white,
              padding: EdgeInsets.only(
                  left: resize(24),
                  top: resize(18),
                  bottom: resize(20),
                  right: resize(17)),
              child: Row(
                children: <Widget>[
                  Text(
                    'App Version',
                    style: AppTextStyle.from(
                        color: AppColors.darkGrey,
                        size: TextSize.caption_large,
                        weight: TextWeight.semibold),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Text(
                    'ver.$gVersion',
                    style: AppTextStyle.from(
                        color: AppColors.grey,
                        size: TextSize.caption_large,
                        weight: TextWeight.medium),
                  )
                ],
              )),
          Container(
              padding: EdgeInsets.only(left: resize(16), right: resize(16)),
              height: resize(1),
              color: AppColors.white,
              child: Container(color: AppColors.lightGrey02)),
          _Item(
              title: AppStrings.of(StringKey.contributors),
              onTap: () async => ContributorPage.push(context)),
          emptySpaceH(height: 12),
          _Title(title: AppStrings.of(StringKey.feedback)),
          _Item(
              title: StringKey.give_us_feedback.getString(),
              onTap: () {
                FeedbackPage.push(context);
              }),
          Container(
              padding: EdgeInsets.only(left: resize(16), right: resize(16)),
              height: resize(1),
              color: AppColors.white,
              child: Container(color: AppColors.lightGrey02)),
          _Item(
              title: StringKey.rate_the_app.getString(),
              onTap: () async {
                inAppReview.openStoreListing(
                    appStoreId: '1473561369',
                    microsoftStoreId: 'com.neofect.connect');
              }),
          _ItemLogout(onTap: () {
            showDialog(
                context: context,
                child: BaseAlertDialog(
                    content: StringKey.ask_logout.getString(),
                    cancelable: true,
                    onCancel: () => {},
                    onConfirm: () async {
                      stopForegroundService();
                      if (ProfileInfo.chatEnable) {
                        gSendBirdMessagingController.disconnect((result) {
                          if (result.state ==
                              SendBirdMessagingState.Disconnected) {
                            Log.d(_tag, 'logout success');
                          } else {
                            Log.d(_tag, 'logout failed');
                          }
                          gSendBirdMessagingController.dispose();
                        });
                      }
                      await UserRepository.logout();
                      // await SignInputEmailPage.pushAndRemoveUntil(context);
                      await LoginPage.pushAndRemoveUntil(context);
                    }));
          })
        ]));
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('$path');

    Directory tempDir = await getTemporaryDirectory();

    String tempPath = tempDir.path;

    final file = File(tempPath + "connect.png");
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }
}

class _Title extends StatelessWidget {
  final String title;

  const _Title({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
      color: AppColors.lightGrey02,
      padding: EdgeInsets.only(
          left: resize(24),
          top: resize(16),
          bottom: resize(8),
          right: resize(24)),
      child: Text(
        title,
        style: AppTextStyle.from(
            color: AppColors.grey,
            size: TextSize.caption_small,
            weight: TextWeight.medium),
      ));
}

class _Item extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _Item({Key key, this.title, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialButton(
        padding: EdgeInsets.all(0),
        child: Container(
            width: double.maxFinite,
            color: AppColors.white,
            padding: EdgeInsets.only(
                left: resize(24),
                top: resize(18),
                bottom: resize(20),
                right: resize(17)),
            child: Text(
              title,
              style: AppTextStyle.from(
                  color: AppColors.darkGrey,
                  size: TextSize.caption_large,
                  weight: TextWeight.medium),
            )),
        onPressed: onTap,
      );
}

class _ItemLogout extends StatelessWidget {
  final VoidCallback onTap;

  const _ItemLogout({Key key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Container(
            margin: EdgeInsets.only(top: resize(16)),
            height: resize(56),
            child: Container(
                color: AppColors.white,
                child: Row(children: <Widget>[
                  Container(
                      margin:
                          EdgeInsets.only(left: resize(23), right: resize(16)),
                      child: Image.asset(AppImages.ic_logout,
                          width: resize(24), height: resize(24))),
                  Text(StringKey.logout.getString(),
                      style: AppTextStyle.from(
                          size: TextSize.body_small,
                          weight: TextWeight.medium,
                          color: AppColors.darkGrey))
                ]))));
  }
}
