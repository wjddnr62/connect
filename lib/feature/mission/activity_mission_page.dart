import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connect/feature/home/home_calendar.dart';
import 'package:connect/feature/mission/common_mission_bloc.dart';
import 'package:connect/feature/mission/mission_complete_button.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share/share.dart';

// ignore: must_be_immutable
class ActivityMissionPage extends BasicPage {
  static const ROUTE_NAME = '/activity_mission_page';

  static Future<Object> push(BuildContext context, {CommonMissionBloc bloc}) =>
      Navigator.of(context).pushNamed(ROUTE_NAME, arguments: bloc);

  // ignore: close_sinks
  CommonMissionBloc _bloc;

  @override
  Widget buildWidget(BuildContext context) {
    return _ActivityMissionPage(bloc: _bloc);
  }

  @override
  void handleArgument(BuildContext context) {
    _bloc = ModalRoute.of(context).settings.arguments;
  }
}

class _ActivityMissionPage extends BasicStatefulWidget {
  final CommonMissionBloc bloc;

  _ActivityMissionPage({this.bloc});

  @override
  _ActivityMissionState buildState() => _ActivityMissionState(bloc: bloc);
}

class _ActivityMissionState extends BasicState<_ActivityMissionPage> {
  final CommonMissionBloc bloc;
  Timer _exitTimer;

  _ActivityMissionState({this.bloc});

  @override
  Widget buildWidget(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future(() => !isExitTimerRunning());
      },
      child: BlocConsumer(
          cubit: bloc,
          listener: (context, state) {
            if (state is StateComplete) {
              _exitTimer = Timer(Duration(milliseconds: 500), () {
                if (mounted) {
                  popWithResult(context, true);
                }
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
            return bloc.isLoading || bloc.missionDetail == null ? Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: AppColors.white,
              child: Center(
                child: FullscreenDialog(),
              ),
            ) : Scaffold(
                appBar: bloc.isLoading ? null : bloc.missionDetail == null ? null : baseAppBar(context, title: '', onLeadPressed: () {
                  if (!isExitTimerRunning()) pop(context);
                }, actions: [
                  (bloc.missionDetail.shareLink != null && bloc.missionDetail.shareLink != "")
                      ? GestureDetector(
                          onTap: () {
                            Share.share(bloc.missionDetail.shareLink);
                          },
                          child: Container(
                            height: resize(24),
                            padding: EdgeInsets.only(right: resize(12)),
                            child: Image.asset(
                              AppImages.ic_share,
                              width: resize(24),
                              height: resize(24),
                              color: AppColors.black,
                            ),
                          ),
                        )
                      : Container(),
                ]),
                backgroundColor: AppColors.white,
                body: _contentWidget(state));
          }),
    );
  }

  bool isExitTimerRunning() {
    return _exitTimer?.isActive == true;
  }

  Widget _contentWidget(state) {
    List<Widget> list = [];

    list.add(CachedNetworkImage(
        imageUrl: bloc.missionDetail.image,
        placeholder: (context, url) => Image.asset(AppImages.bg_image_default,
            width: resize(360), height: resize(240), fit: BoxFit.cover),
        errorWidget: (context, url, error) => Image.asset(
            AppImages.bg_image_default,
            width: resize(360),
            height: resize(240),
            fit: BoxFit.cover),
        imageBuilder: (context, imageProvider) => Container(
            width: resize(64),
            height: resize(240),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: imageProvider, fit: BoxFit.cover)))));

    list.add(Container(
        margin: EdgeInsets.only(
            top: resize(24), left: resize(24), right: resize(24)),
        child: Text(bloc.mission.title ?? '',
            textAlign: TextAlign.left,
            style: AppTextStyle.from(
                size: TextSize.title_large,
                color: AppColors.black,
                weight: TextWeight.extrabold,
                letterSpacing: -0.4,
                height: AppTextStyle.LINE_HEIGHT_MULTI_LINE))));

    if (bloc.missionDetail.tags != null && bloc.missionDetail.tags.isNotEmpty) {
      List<Widget> tagWidgets = [];

      for (String tag in bloc.missionDetail.tags) {
        if (tag == null || tag.isEmpty) {
          continue;
        }

        tagWidgets.add(Container(
            margin: EdgeInsets.only(
                top: resize(12), left: resize(8), bottom: resize(16)),
            decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(resize(2))),
            padding: EdgeInsets.only(
                top: resize(4),
                bottom: resize(4),
                left: resize(8),
                right: resize(8)),
            child: Text(tag,
                maxLines: 1,
                style: AppTextStyle.from(
                    color: AppColors.white,
                    size: TextSize.caption_medium,
                    weight: TextWeight.bold,
                    height: AppTextStyle.LINE_HEIGHT_MULTI_LINE))));
      }
      list.add(Container(
          margin: EdgeInsets.only(left: resize(16)),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(children: tagWidgets))));
    } else {
      list.add(SizedBox(height: resize(24)));
    }

    list.add(Container(
        margin: EdgeInsets.only(left: resize(24), right: resize(24)),
        child: Text(bloc.mission.description ?? '',
            textAlign: TextAlign.left,
            style: AppTextStyle.from(
                size: TextSize.body_medium,
                color: AppColors.darkGrey,
                weight: TextWeight.medium,
                height: 1.6))));

    list.add(
      (widget.bloc.missionDetail.shareLink != null && widget.bloc.missionDetail.shareLink != "")
          ? GestureDetector(
              onTap: () {
                Share.share(widget.bloc.missionDetail.shareLink);
              },
              child: Container(
                height: resize(24),
                padding: EdgeInsets.only(left: resize(24)),
                child: Row(
                  children: [
                    Image.asset(
                      AppImages.ic_share,
                      width: resize(24),
                      height: resize(24),
                      color: AppColors.orange,
                    ),
                    emptySpaceW(width: 8),
                    Text(
                      AppStrings.of(StringKey.share),
                      style: AppTextStyle.from(
                          color: AppColors.orange,
                          size: TextSize.caption_medium,
                          weight: TextWeight.semibold),
                    )
                  ],
                ),
              ),
            )
          : Container(),
    );

    list.add(Container(
        margin: EdgeInsets.only(top: resize(48), bottom: resize(24), left: resize(16), right: resize(16)),
        child: MissionCompleteButton(
            processing: state is StateProcessing,
            mission: bloc.mission,
            onPressed: () => bloc
                .add(bloc.mission.completed ? EventUndo() : EventComplete()))));

    return ListView(children: list);
  }

  @override
  void initState() {
    super.initState();
    bloc.add(MissionPageEnter());
    bloc.add(GetMissionDetailEvent(context));
  }

  @override
  void dispose() {
    bloc.add(MissionPageExit());
    super.dispose();
  }
}
