import 'package:connect/data/share_repository.dart';
import 'package:connect/feature/payment/payment_notice_page.dart';
import 'package:connect/feature/rank/rank_page.dart';
import 'package:connect/feature/settings/settings_page.dart';
import 'package:connect/feature/user/profile/profile_page.dart';
import 'package:connect/feature/user/profile/user_profile_bloc.dart';
import 'package:connect/models/profile.dart';
import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_images.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:multiscreen/multiscreen.dart';
import 'package:share/share.dart';

class UserProfilePage extends BlocStatefulWidget {
  final Profile profile;

  UserProfilePage({this.profile});

  static Future<Object> push(BuildContext context, Profile profile) {
    return Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => UserProfilePage(
              profile: profile,
            )));
  }

  @override
  _UserProfilePage buildState() => _UserProfilePage();
}

class _UserProfilePage extends BlocState<UserProfileBloc, UserProfilePage> {
  Profile profile;
  var numberFormat = new NumberFormat("#,###");

  setProfileImage(name) {
    if (name == "EMPATHY") {
      return AppImages.img_sympathy;
    } else if (name == "LOVE") {
      return AppImages.img_love;
    } else if (name == "HAPPINESS") {
      return AppImages.img_happiness;
    } else if (name == "HOPE") {
      return AppImages.img_hope;
    } else if (name == "AUTONOMY") {
      return AppImages.img_autonomy;
    }
  }

  vipLogo(usePadding) {
    return Padding(
      padding: EdgeInsets.only(right: resize(usePadding ? 10 : 0)),
      child: profile == null
          ? Container()
          : (profile.subscription.marketPlace != 'Free' &&
                  profile.subscription.marketPlace != "" &&
                  profile.subscription.marketPlace != null)
              ? Image.asset(
                  AppImages.vip_with_stroke,
                  width: resize(32),
                  height: resize(18),
                )
              : Container(),
    );
  }

  upgradeButton() {
    return Container(
      width: resize(76),
      height: resize(32),
      child: RaisedButton(
        elevation: 0,
        onPressed: () {
          PaymentNoticePage.push(context,
              closeable: true,
              isNewHomeUser: false,
              back: true,
              logSet: 'profile');
        },
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        color: AppColors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.lightGrey04),
          ),
          child: Center(
            child: Text(
              AppStrings.of(StringKey.upgrade),
              style: AppTextStyle.from(
                  color: AppColors.darkGrey,
                  size: TextSize.caption_medium,
                  weight: TextWeight.semibold),
            ),
          ),
        ),
      ),
    );
  }

  rankImage(type, {rankTier}) {
    switch (type ? rankTier : bloc.rankData.rankTier) {
      case "KING":
        return AppImages.img_ranking_king;
      case "PLATINUM":
        return AppImages.img_ranking_platinum;
      case "DIAMOND":
        return AppImages.img_ranking_diamond;
      case "GOLD":
        return AppImages.img_ranking_topaz;
      case "SILVER":
        return AppImages.img_ranking_emerald;
      case "BRONZE":
        return AppImages.img_ranking_amethyst;
      case "ORANGE":
        return AppImages.img_ranking_orange;
      case "STONE":
        return AppImages.img_ranking_stone;
    }
  }

  Widget _buildProgress(BuildContext context) {
    if (!bloc.loading) return Container();

    return FullscreenDialog();
  }

  List<String> scoreText = [
    AppStrings.of(StringKey.daily_access),
    AppStrings.of(StringKey.mission_complete),
    AppStrings.of(StringKey.all_mission_complete),
    AppStrings.of(StringKey.quiz_mission_complete),
    AppStrings.of(StringKey.write_a_diary),
    AppStrings.of(StringKey.train_by_watching_exercise_video_for_a_long_time)
  ];

  scoreDialog(context) {
    return showDialog(
        barrierDismissible: true,
        context: (context),
        builder: (_) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(true);
            },
            child: Dialog(
              elevation: 0,
              insetPadding: EdgeInsets.zero,
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Container(
                  width: resize(312),
                  height: resize(278),
                  padding: EdgeInsets.only(left: resize(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      emptySpaceH(height: 24),
                      Text(
                        AppStrings.of(
                            StringKey.you_can_get_points_when_you_are_active),
                        style: AppTextStyle.from(
                            color: AppColors.black,
                            size: TextSize.caption_medium,
                            weight: TextWeight.bold),
                      ),
                      emptySpaceH(height: 16),
                      ListView.builder(
                        itemBuilder: (context, idx) {
                          return Padding(
                            padding: EdgeInsets.only(
                                left: resize(0), right: resize(20)),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    ClipOval(
                                      child: Container(
                                        width: resize(4),
                                        height: resize(4),
                                        color: AppColors.black,
                                      ),
                                    ),
                                    emptySpaceW(width: 12),
                                    Expanded(
                                        child: Text(
                                      scoreText[idx],
                                      style: AppTextStyle.from(
                                          color: AppColors.darkGrey,
                                          size: TextSize.caption_medium,
                                          weight: TextWeight.semibold,
                                          height: 1.3),
                                    ))
                                  ],
                                ),
                                emptySpaceH(height: 12),
                              ],
                            ),
                          );
                        },
                        shrinkWrap: true,
                        itemCount: scoreText.length,
                      ),
                      Text(
                        AppStrings.of(StringKey.ranking_is_reset_every_month),
                        style: AppTextStyle.from(
                          color: AppColors.grey,
                          size: TextSize.caption_medium,
                        ),
                      )
                    ],
                  )),
            ),
          );
        });
  }

  @override
  Widget blocBuilder(BuildContext context, state) {
    // TODO: implement blocBuilder
    return BlocBuilder(
        cubit: bloc,
        builder: (context, state) {
          return WillPopScope(
            onWillPop: () {
              Navigator.of(context).pop(profile);
              return null;
            },
            child: Scaffold(
              backgroundColor: AppColors.white,
              body: Stack(
                children: [
                  SafeArea(
                    child: SingleChildScrollView(
                      physics: ClampingScrollPhysics(),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF878aff),
                                      Color(0xFF70d6bc)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    height: resize(44),
                                    padding: EdgeInsets.only(
                                        left: resize(12), right: resize(12)),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: resize(24),
                                          height: resize(24),
                                          child: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: Image.asset(
                                                AppImages.ic_chevron_left,
                                                width: resize(24),
                                                height: resize(24),
                                                color: AppColors.white,
                                              ),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(profile);
                                              }),
                                        ),
                                        Expanded(child: Container()),
                                        Container(
                                          width: resize(24),
                                          height: resize(24),
                                          child: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: Image.asset(
                                                AppImages.ic_share,
                                                width: resize(24),
                                                height: resize(24),
                                                color: AppColors.white,
                                              ),
                                              onPressed: () async {
                                                String shareContent =
                                                    await ShareRepository
                                                        .getShareContent();
                                                Share.share(shareContent);
                                              }),
                                        ),
                                        emptySpaceW(width: 16),
                                        Container(
                                          width: resize(24),
                                          height: resize(24),
                                          child: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: Image.asset(
                                                AppImages.ic_setting,
                                                width: resize(24),
                                                height: resize(24),
                                                color: AppColors.white,
                                              ),
                                              onPressed: () {
                                                SettingsPage.push(context);
                                              }),
                                        ),
                                      ],
                                    ),
                                  ),
                                  emptySpaceH(height: 8),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: resize(24), right: resize(24)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            ClipOval(
                                              child: Container(
                                                height: resize(64),
                                                width: resize(64),
                                                decoration: BoxDecoration(
                                                  color: AppColors.white70,
                                                ),
                                                child: Center(
                                                  child: profile == null
                                                      ? Image.asset(
                                                          AppImages
                                                              .img_sympathy,
                                                          width: resize(60),
                                                          height: resize(60))
                                                      : profile.profileImageName ==
                                                              "IMAGE"
                                                          ? ClipOval(
                                                              child:
                                                                  Image.network(
                                                                profile.image,
                                                                width:
                                                                    resize(60),
                                                                height:
                                                                    resize(60),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            )
                                                          : (profile.profileImageName ==
                                                                      null ||
                                                                  (profile.image ==
                                                                          "" ||
                                                                      profile.image ==
                                                                          null))
                                                              ? Image.asset(
                                                                  AppImages
                                                                      .img_sympathy,
                                                                  width: resize(
                                                                      60),
                                                                  height:
                                                                      resize(
                                                                          60))
                                                              : Image.asset(
                                                                  setProfileImage(
                                                                      profile
                                                                          .profileImageName),
                                                                  width: resize(
                                                                      60),
                                                                  height:
                                                                      resize(
                                                                          60),
                                                                ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: vipLogo(false),
                                            )
                                          ],
                                        ),
                                        emptySpaceW(width: 24),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                height: resize(20),
                                                child: Text(
                                                  profile == null
                                                      ? ""
                                                      : profile.name,
                                                  style: AppTextStyle.from(
                                                      color: AppColors.white,
                                                      size: TextSize
                                                          .caption_large,
                                                      weight: TextWeight.bold),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              emptySpaceH(height: 1),
                                              Container(
                                                height: resize(16),
                                                child: Text(
                                                  profile == null
                                                      ? ""
                                                      : profile.email
                                                              .contains("*")
                                                          ? profile.email
                                                              .split("*")[1]
                                                          : profile.email,
                                                  style: AppTextStyle.from(
                                                    color: AppColors.white,
                                                    size:
                                                        TextSize.caption_small,
                                                  ),
                                                  overflow:
                                                      TextOverflow.visible,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  emptySpaceH(height: 16),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          left: resize(24), right: resize(24)),
                                      child: Text(
                                        profile == null
                                            ? ""
                                            : profile.statusMessage ?? "",
                                        style: AppTextStyle.from(
                                            color: AppColors.white,
                                            size: TextSize.caption_medium,
                                            weight: TextWeight.semibold,
                                            height: 1.3),
                                      ),
                                    ),
                                  ),
                                  emptySpaceH(height: 24),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding:
                                          EdgeInsets.only(left: resize(24)),
                                      child: Container(
                                        width: resize(64),
                                        height: resize(32),
                                        child: RaisedButton(
                                          onPressed: () {
                                            ProfilePage.push(context)
                                                .then((value) {
                                              setState(() {
                                                profile = value;
                                              });
                                            });
                                          },
                                          elevation: 0,
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          color: AppColors.transparent,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                border: Border.all(
                                                    color: AppColors.white)),
                                            child: Center(
                                              child: Text(
                                                AppStrings.of(StringKey.edit),
                                                style: AppTextStyle.from(
                                                    color: AppColors.white,
                                                    size:
                                                        TextSize.caption_medium,
                                                    weight:
                                                        TextWeight.semibold),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  emptySpaceH(height: 24)
                                ],
                              ),
                            ),
                            emptySpaceH(height: 24),
                            Container(
                              height: resize(32),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  emptySpaceW(width: 24),
                                  profile == null
                                      ? Container()
                                      : (profile.subscription
                                                      .marketPlace !=
                                                  'Free' &&
                                              profile.subscription
                                                      .marketPlace !=
                                                  "" &&
                                              profile.subscription
                                                      .marketPlace !=
                                                  null)
                                          ? vipLogo(true)
                                          : vipLogo(false),
                                  profile == null
                                      ? Container()
                                      : Text(
                                          (profile.subscription.marketPlace ==
                                                      "TWO_WEEKS_FREE"
                                                  ? 'Free'
                                                  : (profile.subscription
                                                                  .marketPlace !=
                                                              'Free' &&
                                                          profile.subscription
                                                                  .marketPlace !=
                                                              "" &&
                                                          profile.subscription
                                                                  .marketPlace !=
                                                              null)
                                                      ? 'VIP'
                                                      : 'Free') +
                                              " (+${profile.subscription.daysJoined ?? 0} Days)",
                                          style: AppTextStyle.from(
                                              color: AppColors.black,
                                              size: TextSize.caption_large,
                                              weight: TextWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                  emptySpaceW(width: 24),
                                  profile == null
                                      ? Container()
                                      : (profile.subscription.marketPlace ==
                                              "TWO_WEEKS_FREE"
                                          ? upgradeButton()
                                          : (profile.subscription.marketPlace !=
                                                      'Free' &&
                                                  profile.subscription
                                                          .marketPlace !=
                                                      "" &&
                                                  profile.subscription
                                                          .marketPlace !=
                                                      null)
                                              ? Container()
                                              : upgradeButton()),
                                ],
                              ),
                            ),
                            emptySpaceH(height: 32),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: resize(24), right: resize(24)),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        bloc.rankData == null
                                            ? ""
                                            : bloc.rankData.rankTier,
                                        style: AppTextStyle.from(
                                            color: AppColors.darkGrey,
                                            size: TextSize.title_medium,
                                            weight: TextWeight.extrabold),
                                      ),
                                      emptySpaceH(height: 8),
                                      Text(
                                        AppStrings.of(StringKey.cheer_up_level),
                                        style: AppTextStyle.from(
                                            color: AppColors.grey,
                                            size: TextSize.caption_small),
                                      )
                                    ],
                                  ),
                                  Expanded(child: Container()),
                                  bloc.rankData == null
                                      ? Container()
                                      : Image.asset(
                                          rankImage(true,
                                              rankTier: bloc.rankData.rankTier),
                                          width: resize(100),
                                          height: resize(54),
                                          fit: BoxFit.contain,
                                        ),
                                ],
                              ),
                            ),
                            emptySpaceH(height: 30),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: resize(24), right: resize(24)),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: resize(194),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: AppColors.white,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Color(0x1e000000),
                                          blurRadius: 20,
                                          offset: Offset(0, 0))
                                    ]),
                                padding: EdgeInsets.only(
                                    top: resize(24),
                                    bottom: resize(24),
                                    left: resize(24),
                                    right: resize(24)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: resize(44),
                                          child: Center(
                                            child: Text(
                                              AppStrings.of(StringKey.ranking),
                                              style: AppTextStyle.from(
                                                  color: AppColors.darkGrey,
                                                  size:
                                                      TextSize.caption_medium),
                                            ),
                                          ),
                                        ),
                                        Expanded(child: Container()),
                                        bloc.rankData == null
                                            ? Container()
                                            : Container(
                                                height: resize(44),
                                                child: Center(
                                                  child: Text(
                                                    bloc.rankData.rank
                                                        .toString(),
                                                    style: AppTextStyle.from(
                                                        color: AppColors.black,
                                                        size: TextSize
                                                            .title_large,
                                                        weight:
                                                            TextWeight.bold),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          AppStrings.of(StringKey.total),
                                          style: AppTextStyle.from(
                                              color: AppColors.darkGrey,
                                              size: TextSize.caption_medium),
                                        ),
                                        emptySpaceW(width: 8),
                                        GestureDetector(
                                          onTap: () {
                                            scoreDialog(context);
                                          },
                                          child: Image.asset(
                                            AppImages.ic_info_circle,
                                            width: resize(18),
                                            height: resize(18),
                                            color: AppColors.darkGrey,
                                          ),
                                        ),
                                        Expanded(child: Container()),
                                        bloc.rankData == null
                                            ? Container()
                                            : Container(
                                                height: resize(30),
                                                child: Center(
                                                  child: Text(
                                                    numberFormat.format(bloc
                                                        .rankData.totalScore),
                                                    style: AppTextStyle.from(
                                                        color: AppColors.black,
                                                        size: TextSize
                                                            .title_medium,
                                                        weight:
                                                            TextWeight.bold),
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                    Expanded(child: Container()),
                                    Center(
                                      child: Container(
                                        width: resize(124),
                                        height: resize(32),
                                        child: RaisedButton(
                                          elevation: 0,
                                          onPressed: () {
                                            RankPage.push(context);
                                          },
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          color: AppColors.transparent,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              border: Border.all(
                                                  color: AppColors.lightGrey04),
                                            ),
                                            child: Center(
                                              child: Text(
                                                AppStrings.of(
                                                    StringKey.connect_rank),
                                                style: AppTextStyle.from(
                                                    color: AppColors.darkGrey,
                                                    size:
                                                        TextSize.caption_medium,
                                                    weight:
                                                        TextWeight.semibold),
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
                            emptySpaceH(height: 34)
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildProgress(context)
                ],
              ),
            ),
          );
        });
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is UserProfileInitState) {
      profile = widget.profile;
    }
  }

  @override
  UserProfileBloc initBloc() {
    // TODO: implement initBloc
    return UserProfileBloc(context)
      ..add(UserProfileInitEvent(profile: profile));
  }
}
