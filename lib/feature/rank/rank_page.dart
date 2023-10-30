import 'package:cached_network_image/cached_network_image.dart';
import 'package:connect/feature/rank/rank_bloc.dart';
import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:connect/widgets/base_alert_dialog.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:connect/widgets/dialog/rank_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class RankPage extends BlocStatefulWidget {
  static Future<Object> push(BuildContext context) {
    return Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => RankPage()));
  }

  @override
  RankState buildState() => RankState();
}

class RankState extends BlocState<RankBloc, RankPage> {
  var numberFormat = new NumberFormat("#,###");

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

  rankStatus() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: resize(204),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Color(0xFF878aff), Color(0xFFf2a5d3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
      ),
      child: bloc.rankData != null
          ? Column(
              children: [
                emptySpaceH(height: 32),
                Row(
                  children: [
                    emptySpaceW(width: 24),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bloc.rankData.userName ?? "",
                          style: AppTextStyle.from(
                              color: AppColors.white,
                              size: TextSize.caption_medium,
                              weight: TextWeight.bold),
                        ),
                        emptySpaceH(height: 6),
                        Text(
                          (bloc.marketPlace == "TWO_WEEKS_FREE"
                                  ? 'Free'
                                  : (bloc.marketPlace != 'Free' &&
                                          bloc.marketPlace != "" &&
                                          bloc.marketPlace != null)
                                      ? 'VIP'
                                      : 'Free') +
                              " (+${bloc.serviceDate ?? 0} Days)",
                          style: AppTextStyle.from(
                              color: AppColors.white,
                              size: TextSize.caption_small),
                        )
                      ],
                    ),
                    Expanded(child: Container()),
                    bloc.rankData != null
                        ? GestureDetector(
                            onTap: () {
                              rankDialog(context);
                            },
                            child: Image.asset(
                              rankImage(false),
                              width: resize(100),
                              height: resize(54),
                            ),
                          )
                        : Container()
                  ],
                ),
                emptySpaceH(height: 20),
                scoreAndRanking()
              ],
            )
          : Container(),
    );
  }

  scoreAndRanking() {
    return Padding(
      padding: EdgeInsets.only(left: resize(24), right: resize(32)),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    AppStrings.of(StringKey.total),
                    style: AppTextStyle.from(
                        color: AppColors.white, size: TextSize.caption_medium),
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
                      color: AppColors.white,
                    ),
                  ),
                  // Expanded(child: Container()),
                ],
              ),
              emptySpaceH(height: 6),
              Row(
                children: [
                  Text(
                    numberFormat.format(bloc.rankData.totalScore ?? 0),
                    style: AppTextStyle.from(
                        color: AppColors.white,
                        weight: TextWeight.bold,
                        size: TextSize.title_large),
                  ),
                ],
              )
            ],
          ),
          Expanded(child: Container()),
          Padding(
            padding: EdgeInsets.only(top: resize(16)),
            child: Container(
              width: 1,
              height: resize(44),
              color: AppColors.white,
            ),
          ),
          Expanded(child: Container()),
          Column(
            children: [
              Text(
                AppStrings.of(StringKey.ranking),
                style: AppTextStyle.from(
                    color: AppColors.white, size: TextSize.caption_medium),
              ),
              emptySpaceH(height: 16),
              Container(
                child: Center(
                  child: Text(
                    (bloc.rankData.rank ?? 0).toString(),
                    style: AppTextStyle.from(
                        color: AppColors.white,
                        weight: TextWeight.bold,
                        size: TextSize.title_large),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  searchUser() {
    return Padding(
      padding: EdgeInsets.only(left: resize(24), right: resize(24)),
      child: TextFormField(
          cursorColor: AppColors.black,
          maxLines: 1,
          onFieldSubmitted: (value) {},
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          style: AppTextStyle.from(
              size: TextSize.body_small, color: AppColors.black),
          decoration: InputDecoration(
              suffixIcon: Padding(
                padding: EdgeInsets.only(
                    right: resize(16), top: resize(12), bottom: resize(12)),
                child: GestureDetector(
                  onTap: () {},
                  child: Image.asset(
                    AppImages.ic_search,
                    width: resize(24),
                    height: resize(24),
                  ),
                ),
              ),
              hintText:
                  AppStrings.of(StringKey.tap_here_to_search_for_your_name),
              hintStyle: AppTextStyle.from(
                  size: TextSize.caption_medium, color: AppColors.lightGrey03),
              border: OutlineInputBorder(
                borderSide:
                    BorderSide(width: resize(1), color: AppColors.lightGrey04),
              ),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      width: resize(1), color: AppColors.lightGrey04)),
              focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(width: resize(1), color: AppColors.purple)),
              contentPadding: EdgeInsets.only(
                left: resize(16),
                right: resize(8),
              ))),
    );
  }

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

  userName(String name) {
    if (name == null || name == "") {
      return "";
    } else if (name.length <= 4) {
      return name.substring(0, name.length - 1) + "*";
    } else {
      String star = "";
      for (int i = 0; i < name.length - 4; i++) {
        star = star + "*";
      }
      return name.substring(0, 4) + star;
    }
  }

  rankList() {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, idx) {
        return Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(top: resize(16), bottom: resize(16)),
          color: AppColors.white,
          child: Row(
            children: [
              emptySpaceW(width: 24),
              Text(
                (idx + 1).toString(),
                style: AppTextStyle.from(
                    color: AppColors.darkGrey,
                    size: TextSize.title_medium,
                    weight: TextWeight.bold),
                textAlign: TextAlign.center,
              ),
              emptySpaceW(width: 24),
              Container(
                width: resize(64),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: (bloc.rankList.rankData[idx].profileImageName !=
                                  null &&
                              bloc.rankList.rankData[idx].profileImageName ==
                                  "IMAGE")
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(48),
                              child: CachedNetworkImage(
                                imageUrl: bloc
                                    .rankList.rankData[idx].profileImagePath,
                                width: resize(48),
                                height: resize(48),
                                fit: BoxFit.cover,
                              ),
                            )
                          : bloc.rankList.rankData[idx].profileImageName == null
                              ? ClipOval(
                                  child: Image.asset(
                                    AppImages.img_sympathy,
                                    width: resize(48),
                                    height: resize(48),
                                  ),
                                )
                              : ClipOval(
                                  child: Image.asset(
                                    setProfileImage(bloc.rankList.rankData[idx]
                                            .profileImageName) ??
                                        AppImages.img_sympathy,
                                    width: resize(48),
                                    height: resize(48),
                                  ),
                                ),
                    ),
                    bloc.rankList.rankData[idx].isVip
                        ? Positioned(
                            right: 0,
                            bottom: 0,
                            child: Image.asset(
                              AppImages.vip_with_stroke,
                              width: resize(32),
                              height: resize(18),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
              emptySpaceW(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName(bloc.rankList.rankData[idx].userName),
                      style: AppTextStyle.from(
                          color: AppColors.darkGrey,
                          size: TextSize.caption_medium,
                          weight: TextWeight.bold),
                    ),
                    emptySpaceH(height: 4),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        "(+${bloc.rankList.rankData[idx].startDate != null ? DateTime.now().difference(DateTime.parse(bloc.rankList.rankData[idx].startDate)).inDays ?? 0 : 0} days)\n${numberFormat.format(bloc.rankList.rankData[idx].totalScore ?? 0)}",
                        style: AppTextStyle.from(
                            color: AppColors.grey,
                            size: TextSize.caption_large,
                            height: 1.5),
                      ),
                    )
                  ],
                ),
              ),
              Image.asset(
                rankImage(true, rankTier: bloc.rankList.rankData[idx].rankTier),
                width: resize(56),
                height: resize(30),
              ),
              emptySpaceW(width: 24)
            ],
          ),
        );
      },
      shrinkWrap: true,
      itemCount: bloc.rankList != null ? bloc.rankList.rankData.length ?? 0 : 0,
    );
  }

  Widget _buildProgress(BuildContext context) {
    if (!bloc.loading) return Container();

    return FullscreenDialog();
  }

  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
      cubit: bloc,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: baseAppBar(context,
              title: AppStrings.of(StringKey.ranking), centerTitle: true),
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    rankStatus(),
                    emptySpaceH(height: 16),
                    // searchUser(), user rank search
                    // emptySpaceH(height: 4),
                    bloc.rankList != null ? rankList() : Container(),
                    emptySpaceH(height: 30)
                  ],
                ),
              ),
              _buildProgress(context)
            ],
          ),
        );
      },
    );
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is RankDataError) {
      Navigator.of(context).pop();

      showDialog(
          context: context,
          child: BaseAlertDialog(
            content: "Generating ranking. Please log back on in a few minutes.",
            onConfirm: () => null,
          ));
    }
  }

  @override
  RankBloc initBloc() {
    return RankBloc(context)..add(RankInitEvent());
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
}
