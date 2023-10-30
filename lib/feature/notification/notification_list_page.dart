import 'package:connect/data/share_repository.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/feature/bottom_navigation/home_navigation.dart';
import 'package:connect/feature/bottom_navigation/home_navigation_bloc.dart';
import 'package:connect/feature/current_status/current_status_page.dart';
import 'package:connect/feature/home/home_calendar.dart';
import 'package:connect/feature/notification/notification_bloc.dart';
import 'package:connect/feature/user/profile/profile_page.dart';
import 'package:connect/models/push_history.dart';
import 'package:connect/models/push_notification.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/utils/date_format.dart';
import 'package:connect/widgets/base_alert_dialog.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

class NotificationListPage extends BlocStatefulWidget {
  static const ROUTE_NAME = '/notification_list_page';

  final HomeNavigationBloc bloc;

  NotificationListPage({this.bloc});

  static Future<Object> push(BuildContext context, bloc) {
    return Navigator.of(context).push(MaterialPageRoute(builder: (context) => NotificationListPage(bloc: bloc,)));
  }

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return _NotificationState();
  }
}

class _NotificationState extends BlocState<NotificationBloc, NotificationListPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollChange);
  }

  @override
  blocBuilder(BuildContext context, state) {
    return WillPopScope(
        onWillPop: () => _onBackPress(context),
        child: Scaffold(
            backgroundColor: AppColors.white,
            appBar: baseAppBar(context,
                title: AppStrings.of(StringKey.notifications),
                onLeadPressed: () => _onBackPress(context)),
            body: SafeArea(
                child: state is PageInitState
                    ? Container()
                    : bloc.notifies.isEmpty
                        ? Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                Image.asset(AppImages.illust_no_noti,
                                    width: resize(134), height: resize(130)),
                                SizedBox(height: resize(28)),
                                Text(AppStrings.of(StringKey.no_notifications),
                                    style: AppTextStyle.from(
                                        color: AppColors.darkGrey,
                                        size: TextSize.caption_large,
                                        weight: TextWeight.semibold))
                              ]))
                        : ListView.builder(
                            controller: _scrollController,
                            itemBuilder: _createNotifyTile,
                            itemCount: bloc.notifies.length))));
  }

  Widget _createNotifyTile(BuildContext context, int index) {
    final history = bloc.notifies[index];
    final date = history.created;
    final double iconSize = 24;

    return GestureDetector(
        onTap: () => _notifyClick(context, history, ),
        child: Container(
            color: history.isRead
                ? Colors.transparent
                : AppColors.orange.withOpacity(0.1),
            padding: EdgeInsets.only(
                top: resize(19), left: resize(24), right: resize(24)),
            child: Stack(children: <Widget>[
              Column(children: <Widget>[
                Image.asset(AppImages.ic_bell,
                    width: resize(iconSize),
                    height: resize(iconSize),
                    color: AppColors.orange)
              ]),
              Container(
                  margin: EdgeInsets.only(
                      left: resize(16 + iconSize), right: resize(56)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('${history.notify.title.toUpperCase()}',
                            style: AppTextStyle.from(
                                height: 1.4,
                                weight: TextWeight.bold,
                                size: TextSize.body_small,
                                color: AppColors.black)),
                        SizedBox(
                          height: resize(4),
                        ),
                        Text(history.notify.contents,
                            style: AppTextStyle.from(
                                height: 1.5,
                                size: TextSize.body_small,
                                color: AppColors.darkGrey)),
                        Container(
                            margin: EdgeInsets.only(
                                top: resize(8), bottom: resize(20)),
                            child: Text(_parseDateStr(date),
                                style: AppTextStyle.from(
                                    height: 1.3,
                                    size: TextSize.caption_medium,
                                    color: AppColors.blueGrey)))
                      ])),
              Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                      margin: EdgeInsets.only(top: resize(20)),
                      child: _notifyClickable(history.notify)
                          ? Image.asset(AppImages.ic_arrow_right,
                              width: resize(16), height: resize(16))
                          : Container())),
              Positioned.fill(
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: _createDivider(index)))
            ])));
  }

  Widget _createDivider(int index) {
    if (index == bloc.notifies.length - 1) return Container();

    return Container(
        width: double.infinity,
        height: resize(1),
        margin: EdgeInsets.only(left: resize(24), right: resize(24)),
        color: AppColors.lightGrey04);
  }

  bool _notifyClickable(PushNotification notify) {
    final whiteList = [
      NotificationType.connect_share,
    ];

    return whiteList.contains(notify.type);
  }

  _parseDateStr(DateTime date) {
    return DateFormat.notificationString(date);
  }

  _notifyClick(BuildContext context, PushHistory history) {
    if (!history.isRead) bloc.add(ReadHistoryEvent(history));

    if (history.notify.type == null) {
      return;
    }

    switch (history.notify.type) {
      case NotificationType.connect_advice_msg_arrive:
      case NotificationType.connect_mission_advice_daily:
      case NotificationType.connect_mission_current_status_daily:
        // CurrentStatusPage.popAndPush(context);
    widget.bloc.add(ChangeViewEvent(changeIndex: 1));
        break;
      case NotificationType.connect_mission_arrived_daily:
      case NotificationType.connect_recommend_diary:
        // HomeCalendarPage.popUntil(context);
        HomeNavigation.popUntil(context);
        break;
      case NotificationType.portal_patient_assign:
        ProfilePage.push(context);
        break;
      case NotificationType.mission_post_daily:
        popWithResult(
            context,
            NotificationPageResult(
                type: history.notify.type, isReadBeforeClick: history.isRead));
        break;
      case NotificationType.connect_share:
        shareConnect();
        break;
    }
  }

  shareConnect() async {
    String shareContent = await ShareRepository.getShareContent();
    Share.share(
        shareContent);
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is PageInitState)
      showDialog(context: context, child: FullscreenDialog());
    // else
      // popUntilNamed(context, NotificationListPage.ROUTE_NAME);

    if (state is ErrorOccurState) {
      showDialog(
          context: context,
          child: BaseAlertDialog(
              content:
                  "error code : [${state.e.code}]\nerror message: ${state.e.message}"));
      return;
    }
  }

  @override
  NotificationBloc get bloc => super.bloc as NotificationBloc;

  @override
  NotificationBloc initBloc() {
    return NotificationBloc()..add(LoadNextPageEvent());
  }

  _onBackPress(context) {
    bloc.add(AllReadHistoryEvent());
    pop(context);
  }

  _scrollChange() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent)
      bloc.add(LoadNextPageEvent());
  }
}
