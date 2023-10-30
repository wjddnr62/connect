import 'dart:async';
import 'dart:math';

import 'package:connect/feature/bottom_navigation/home_navigation.dart';
import 'package:connect/feature/home/home_calendar.dart';
import 'package:connect/feature/mission/common_mission_bloc.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/bottons/bottom_button.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:connect/widgets/video/connect_flutube.dart';
import 'package:connect/widgets/video/connect_flutube_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share/share.dart';

import 'mission_complete_button.dart';

// ignore: must_be_immutable
class VideoMissionPage extends BasicPage {
  static const ROUTE_NAME = '/video_mission_page';

  static Future<Object> push(BuildContext context,
          {CommonMissionBloc bloc, bool bookmark}) =>
      Navigator.of(context).pushNamed(ROUTE_NAME, arguments: [bloc, bookmark]);

  // ignore: close_sinks
  CommonMissionBloc _bloc;
  bool bookmark;

  @override
  Widget buildWidget(BuildContext context) {
    return _VideoMissionPage(
      bloc: _bloc,
      bookmark: bookmark,
    );
  }

  @override
  void handleArgument(BuildContext context) {
    List<dynamic> args = ModalRoute.of(context).settings.arguments;
    _bloc = args[0];
    bookmark = args[1] ?? false;
  }
}

class _VideoMissionPage extends BasicStatefulWidget {
  final CommonMissionBloc bloc;
  bool bookmark;

  _VideoMissionPage({this.bloc, this.bookmark}) : assert(bloc != null);

  @override
  BasicState<BasicStatefulWidget> buildState() => _VideoMissionPageState();
}

class _VideoMissionPageState extends BasicState<_VideoMissionPage> {
  bool _viewingComplete;
  bool _expand = true;
  ConnectFlutubeController controller;

  _VideoMissionPageState();

  @override
  void initState() {
    super.initState();
    controller = ConnectFlutubeController(onEnd: () {
      setState(() {
        _viewingComplete = true;
      });
    });
    widget.bloc.add(MissionPageEnter());
    widget.bloc.add(GetMissionDetailEvent(context));
  }

  @override
  Widget buildWidget(BuildContext context) {
    _viewingComplete ??= widget.bloc.mission.completed;
    return BlocConsumer(
        cubit: widget.bloc,
        listener: (context, state) {
          if (state is StateComplete) {
            Timer(Duration(milliseconds: 500), () {
              if (mounted) popWithResult(context, true);
            });
          }

          if (state is GetMissionDetailState) {
            setState(() {});
          }

          if (state is MissionBookmarkAddState) {
            setState(() {});
          }

          if (state is MissionBookmarkRemoveState) {
            setState(() {});
          }
        },
        builder: (context, state) {
          return widget.bloc.isLoading
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: AppColors.white,
                  child: Center(
                    child: FullscreenDialog(),
                  ),
                )
              : OrientationBuilder(builder: (context, or) {
                  return SafeArea(
                      bottom: false,
                      child: Scaffold(
                          backgroundColor: AppColors.white,
                          body:
                              Column(mainAxisSize: MainAxisSize.max, children: <
                                  Widget>[
                            Container(
                              color: Colors.black,
                              constraints: BoxConstraints(
                                maxHeight: (MediaQuery.of(context).size.height -
                                        MediaQuery.of(context).padding.top) /
                                    2,
                              ),
                              child: ConnectFlutube(
                                  videoUrl:
                                      widget.bloc.missionDetail.meta.links[0],
                                  title: widget.bloc.mission.title,
                                  controller: controller,
                                  aspectRatio: 16 / 9,
                                  autoPlay: true,
                                  onBackButtonPressed: () {
                                    Navigator.of(context).pop();
                                  }),
                            ),
                            _createTitle(),
                            emptySpaceH(height: 16),
                            Expanded(child: _createDescription()),
                            emptySpaceH(height: 16),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: resize(24), right: resize(24)),
                              child: Row(
                                children: [
                                  Container(
                                    width: resize(128),
                                    height: resize(44),
                                    decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: [
                                          BoxShadow(
                                              color: AppColors.blackA40,
                                              blurRadius: 10,
                                              offset: Offset(1, 1))
                                        ]),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        widget.bloc.add(widget
                                            .bloc.missionDetail.isBookmark
                                            ? MissionBookmarkRemoveEvent(
                                            id: widget.bloc.mission.id)
                                            : MissionBookmarkAddEvent(
                                            id: widget.bloc.mission.id));
                                      },
                                      style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          primary: AppColors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          elevation: 0),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              widget.bloc.missionDetail
                                                  .isBookmark
                                                  ? AppImages.ic_bookmark_fill
                                                  : AppImages.ic_bookmark,
                                              width: resize(24),
                                              height: resize(24),
                                            ),
                                            emptySpaceW(width: 8),
                                            Text(
                                              AppStrings.of(StringKey.bookmark),
                                              style: AppTextStyle.from(
                                                  color: AppColors.darkGrey,
                                                  weight: TextWeight.semibold,
                                                  size:
                                                      TextSize.caption_medium),
                                              textAlign: TextAlign.center,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(child: Container()),
                                  (widget.bloc.missionDetail.shareLink !=
                                              null &&
                                          widget.bloc.missionDetail.shareLink !=
                                              "")
                                      ? GestureDetector(
                                          onTap: () {
                                            Share.share(widget
                                                .bloc.missionDetail.shareLink);
                                          },
                                          child: Container(
                                            height: resize(24),
                                            child: Image.asset(
                                              AppImages.ic_share,
                                              width: resize(24),
                                              height: resize(24),
                                              color: AppColors.black,
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                            emptySpaceH(height: 16),
                            Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(
                                    top: resize(8),
                                    bottom: resize(32),
                                    left: resize(24),
                                    right: resize(24)),
                                child: widget.bookmark ?? false
                                    ? BottomButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        color: AppColors.white,
                                        textColor: AppColors.purple,
                                        lineColor: AppColors.purple,
                                        lineBoxed: true,
                                        text: AppStrings.of(
                                            StringKey.bookmark_list),
                                      )
                                    : MissionCompleteButton(
                                        mission: widget.bloc.mission,
                                        onPressed: !_viewingComplete
                                            ? null
                                            : () {
                                                widget.bloc.add(widget
                                                        .bloc.mission.completed
                                                    ? EventUndo()
                                                    : EventComplete());
                                              },
                                        processing: state is StateProcessing))
                          ])));
                });
        });
  }

  Widget _createTitle() {
    return Container(
        margin: EdgeInsets.only(
            top: resize(16), left: resize(24), right: resize(24)),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                  child: Text(widget.bloc.mission.title,
                      style: AppTextStyle.from(
                          height: 1.6,
                          color: AppColors.black,
                          size: TextSize.body_medium,
                          weight: TextWeight.bold))),
              GestureDetector(
                  onTap: () => setState(() {
                        _expand = !_expand;
                      }),
                  child: Container(
                      width: resize(24),
                      height: resize(24),
                      margin: EdgeInsets.only(top: resize(2), left: resize(8)),
                      child: Transform.rotate(
                          angle: _expand ? 0 : pi,
                          child: Image.asset(AppImages.ic_arrow_down))))
            ]));
  }

  Widget _createAuthor() {
    return Container(
        width: double.infinity,
        margin: EdgeInsets.only(
            top: resize(16), left: resize(16), right: resize(16)),
        child: Text("By  | ",
            style: AppTextStyle.from(
                size: TextSize.caption_small,
                color: AppColors.grey,
                weight: TextWeight.extrabold)));
  }

  Widget _createDescription() {
    if (!_expand) return Container();

    return ListView(children: [
      Container(
          width: double.infinity,
          margin: EdgeInsets.only(
              left: resize(24),
              right: resize(24),
              top: resize(24),
              bottom: resize(24)),
          child: Text(widget.bloc.mission.description ?? "",
              style: AppTextStyle.from(
                  height: 1.6,
                  size: TextSize.caption_large,
                  weight: TextWeight.medium,
                  color: AppColors.darkGrey)))
    ]);
  }

  @override
  void dispose() {
    widget.bloc.add(MissionPageExit());
    super.dispose();
  }
}
