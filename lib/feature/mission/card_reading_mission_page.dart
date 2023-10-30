import 'dart:async';

import 'package:connect/feature/mission/common_mission_bloc.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import 'card_reading_mission_item.dart';

// ignore: must_be_immutable
class CardReadingMissionPage extends BasicPage {
  static const ROUTE_NAME = '/card_reading_mission_page';

  static Future<Object> push(BuildContext context,
          {CommonMissionBloc bloc, bool bookmark}) =>
      Navigator.of(context).pushNamed(ROUTE_NAME, arguments: [bloc, bookmark]);

  // ignore: close_sinks
  CommonMissionBloc _bloc;
  bool bookmark;

  @override
  Widget buildWidget(BuildContext context) {
    return _CardReadingMissionPage(
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

class _CardReadingMissionPage extends BlocStatefulWidget {
  final CommonMissionBloc bloc;
  bool bookmark;

  _CardReadingMissionPage({this.bloc, this.bookmark});

  @override
  _CardReadingMissionState buildState() =>
      _CardReadingMissionState(bloc: bloc, bookmark: bookmark);
}

class _CardReadingMissionState
    extends BlocState<CommonMissionBloc, _CardReadingMissionPage> {
  final CommonMissionBloc bloc;
  bool bookmark;
  final List<Html> htmlList = new List();
  int _currentIndex = 0;
  Timer _exitTimer;

  PageController _pageController = PageController(initialPage: 0);

  _CardReadingMissionState({this.bloc, this.bookmark});

  @override
  Widget blocBuilder(BuildContext context, state) {
    return WillPopScope(
      onWillPop: () async {
        return Future(() => !isExitTimerRunning());
      },
      child: Scaffold(
          appBar: bloc.isLoading
              ? null
              : baseAppBar(context, title: '', onLeadPressed: () {
                  if (!isExitTimerRunning()) pop(context);
                }, actions: [
                  (widget.bloc.missionDetail != null &&
                          widget.bloc.missionDetail.shareLink != null &&
                          widget.bloc.missionDetail.shareLink != "")
                      ? GestureDetector(
                          onTap: () {
                            Share.share(widget.bloc.missionDetail.shareLink);
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
          body: bloc.isLoading
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: FullscreenDialog(),
                  ),
                )
              : _contentWidget(state)),
    );
  }

  bool isExitTimerRunning() {
    return _exitTimer?.isActive == true;
  }

  @override
  blocListener(BuildContext context, state) {
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
  }

  @override
  CommonMissionBloc initBloc() => bloc;

  Widget _contentWidget(state) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraint) {
          return PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: createItems(state, constraint));
        },
      ),
    );
  }

  List<Widget> createItems(state, BoxConstraints constraint) {
    List<Widget> list = [];

    if (bloc.missionDetail != null) {
      for (int i = 0; i < bloc.missionDetail.meta.links.length; i++) {
        String html = bloc.missionDetail.meta.links[i];

        if (html == null || html.isEmpty) continue;
        if (htmlList.length <= i) {
          htmlList.add(Html(
              padding: EdgeInsets.only(
                  top: resize(16),
                  bottom: resize(16),
                  left: resize(24),
                  right: resize(24)),
              data: html,
              useRichText: true,
              onLinkTap: (url) async {
                if (await canLaunch(url)) {
                  await launch(url);
                }
              },
              customTextStyle: (n, te) {
                final attr = n.attributes['style'];
                if (attr == null) return te;
                final keyValue = attr.split(":");
                return te.copyWith(
                    color: getHtmlColor(keyValue, 'color'),
                    backgroundColor: getHtmlColor(keyValue, 'background-color'),
                    fontSize: getHtmlFontSize(keyValue));
              },
              defaultTextStyle: AppTextStyle.from(
                  color: AppColors.darkGrey,
                  size: TextSize.body_medium,
                  weight: TextWeight.medium,
                  height: 1.6)));
        }

        final isLast = i == (bloc.missionDetail.meta.links.length - 1);
        list.add(CardReadingMissionItem(
          parentHeight: constraint.maxHeight,
          mission: bloc.mission,
          missionDetail: bloc.missionDetail,
          isFirst: i == 0,
          isLast: isLast,
          html: htmlList[i],
          bookmark: bookmark ?? false,
          onNext: () {
            _pageController.animateToPage(++_currentIndex,
                duration: Duration(milliseconds: 300), curve: Curves.ease);
          },
          onPrev: () {
            if (_currentIndex > 0)
              _pageController.animateToPage(--_currentIndex,
                  duration: Duration(milliseconds: 300), curve: Curves.ease);
          },
          onComplete: () =>
              bloc.add(bloc.mission.completed ? EventUndo() : EventComplete()),
          onBookmark: () => bloc.add(bloc.missionDetail.isBookmark
              ? MissionBookmarkRemoveEvent(id: bloc.mission.id)
              : MissionBookmarkAddEvent(id: bloc.mission.id)),
          completed: bloc.mission.completed,
          processing: state is StateProcessing,
        ));
      }
    }

    return list;
  }

  Color getHtmlColor(List<String> keyValue, String key) {
    if (keyValue.isEmpty || keyValue.first != key) return null;

    var hexCode = keyValue[1].replaceAll(' #', '0xFF').toLowerCase();
    hexCode = hexCode.replaceAll(';', '');
    if (hexCode.length > 10) {
      hexCode = hexCode.substring(0, 10);
    }
    return Color(int.parse(hexCode));
  }

  double getHtmlFontSize(List<String> keyValue) {
    if (keyValue.isEmpty || keyValue.first != 'font-size') return null;

    var sizeStr = keyValue[1].replaceAll('pt;', '').trim();
    return resize(double.parse(sizeStr));
  }

  @override
  void initState() {
    super.initState();
    bloc.add(MissionPageEnter());
    bloc.add(GetMissionDetailEvent(context));
  }

  @override
  void dispose() {
    // bloc.add(MissionPageExit());
    super.dispose();
  }
}
