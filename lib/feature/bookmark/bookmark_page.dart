import 'package:connect/feature/base_bloc.dart';
import 'package:connect/feature/bookmark/bookmark_bloc.dart';
import 'package:connect/feature/home/home_bloc.dart';
import 'package:connect/feature/mission/common_mission_item.dart';
import 'package:connect/models/profile.dart';
import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/resources/app_strings.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multiscreen/multiscreen.dart';

class BookmarkPage extends BlocStatefulWidget {
  final HomeBloc bloc;
  final String userType;
  final Profile profile;

  BookmarkPage({this.bloc, this.userType, this.profile});

  static Future<Object> push(BuildContext context,
      {HomeBloc bloc, String userType, Profile profile}) {
    return Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => BookmarkPage(
          bloc: bloc,
          userType: userType,
          profile: profile,
        )));
  }

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() => BookmarkState();
}

class BookmarkState extends BlocState<BookmarkBloc, BookmarkPage> {
  List<String> tapItemString = ['Reading', 'Exercise', ''];

  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
        cubit: bloc,
        builder: (context, idx) {
          return Scaffold(
            backgroundColor: AppColors.lightGrey01,
            appBar: baseAppBar(
              context,
              title: AppStrings.of(StringKey.bookmark),
              centerTitle: true,
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      emptySpaceH(height: 78),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: contentView(),
                      ),
                    ],
                  ),
                ),
                selectTap(),
                _buildProgress(context)
              ],
            ),
          );
        });
  }

  selectTap() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: resize(54),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24))),
      padding: EdgeInsets.only(left: resize(48), right: resize(48)),
      child: Row(
        children: [
          selectTapItem(0),
          emptySpaceW(width: 40),
          selectTapItem(1),
          emptySpaceW(width: 40),
          selectTapItem(2)
        ],
      ),
    );
  }

  selectTapItem(int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index != 2) {
            bloc.add(TapSelectEvent(selectIndex: index));
          }
        },
        child: Container(
          height: resize(54),
          color: AppColors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: resize(18),
                child: Text(
                  tapItemString[index],
                  maxLines: 1,
                  style: AppTextStyle.from(
                      color: bloc.selectTap == index
                          ? AppColors.black
                          : AppColors.grey,
                      size: TextSize.caption_medium,
                      weight: TextWeight.bold),
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.center,
                ),
              ),
              bloc.selectTap == index
                  ? emptySpaceH(height: 13)
                  : emptySpaceH(height: 16),
              bloc.selectTap == index
                  ? Container(
                width: MediaQuery.of(context).size.width,
                height: resize(3),
                decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(1)),
              )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }

  contentView() {
    if (bloc.selectTap == 0) {
      return bloc.readingMissions != null && bloc.readingMissions.isNotEmpty
          ? Container(
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
          itemBuilder: (context, idx) {
            return CommonMissionItem(
              mission: bloc.readingMissions[idx],
              homeBloc: widget.bloc,
              userType: widget.userType,
              day1Check: false,
              profile: widget.profile,
              bookmark: true,
              bookmarkBloc: bloc,
            );
          },
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemCount: bloc.readingMissions.length,
        ),
      )
          : emptyView();
    } else if (bloc.selectTap == 1) {
      return bloc.exerciseMissions != null && bloc.exerciseMissions.isNotEmpty
          ? ListView.builder(
        itemBuilder: (context, idx) {
          return CommonMissionItem(
            mission: bloc.exerciseMissions[idx],
            homeBloc: widget.bloc,
            userType: widget.userType,
            day1Check: false,
            profile: widget.profile,
            bookmark: true,
            bookmarkBloc: bloc,
          );
        },
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: bloc.exerciseMissions.length,
      )
          : emptyView();
    } else {
      return emptyView();
    }
  }

  emptyView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        emptySpaceH(height: 170),
        Image.asset(
          AppImages.ic_bookmark_disable,
          width: resize(56),
          height: resize(56),
        ),
        emptySpaceH(height: 16),
        Text(
          AppStrings.of(StringKey.no_content_yet),
          style: AppTextStyle.from(
              color: AppColors.darkGrey,
              size: TextSize.caption_large,
              weight: TextWeight.semibold),
        ),
      ],
    );
  }

  Widget _buildProgress(BuildContext context) {
    if (!bloc.isLoading) return Container();

    return FullscreenDialog();
  }

  @override
  blocListener(BuildContext context, state) {}

  @override
  BookmarkBloc initBloc() {
    return BookmarkBloc(context)..add(BookmarkInitEvent());
  }
}
