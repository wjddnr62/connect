import 'dart:ui';

import 'package:connect/data/local/app_dao.dart';
import 'package:connect/data/remote/auth/token_refresh_service.dart';
import 'package:connect/data/remote/base_service.dart';
import 'package:connect/feature/bottom_navigation/home_navigation_bloc.dart';
import 'package:connect/feature/chat/text/text_chat_page.dart';
import 'package:connect/feature/current_status/current_status_bloc.dart';
import 'package:connect/feature/diary/diary_page.dart';
import 'package:connect/feature/payment/payment_notice_page.dart';
import 'package:connect/feature/rank/rank_page.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/utils/logger/log.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:connect/widgets/dialog/rank_dialog.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../connect_config.dart';

class CurrentStatusPage extends BlocStatefulWidget {
  static const ROUTE_NAME = '/current_status_page';

  static Future<Object> popAndPush(BuildContext context) =>
      Navigator.of(context).popAndPushNamed(ROUTE_NAME);

  static Future<Object> push(BuildContext context) =>
      Navigator.of(context).pushNamed(ROUTE_NAME);

  final bool pageMove;
  final String page;
  final HomeNavigationBloc bloc;

  CurrentStatusPage({this.pageMove, this.page, this.bloc});

  static Future<Object> pushDiary(BuildContext context,
          {bool pageMove, String page}) =>
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => CurrentStatusPage(
                pageMove: pageMove,
                page: page,
              )));

  @override
  _CurrentStatusState buildState() {
    return _CurrentStatusState();
  }
}

class _CurrentStatusState
    extends BlocState<CurrentStatusBloc, CurrentStatusPage> {
  WebViewController _controller;

  @override
  blocBuilder(BuildContext context, state) {
    return Scaffold(
        appBar: baseAppBar(context,
            title: StringKey.current_status.getString(),
            leading: IconButton(
              onPressed: () {
                if (_controller != null)
                  _controller.reload();
              },
              icon: Icon(Icons.refresh),
            )),
        body: Stack(
          children: <Widget>[_buildLoading(), _buildWebView()],
        ));
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is CurrentStatusLoadingState) {
      showDialog(context: context, child: FullscreenDialog());
    }

    if (state is CurrentStatusErrorState) {
      // if (widget.pageMove == null)
      // popUntilNamed(context, CurrentStatusPage.ROUTE_NAME);
    }

    if (state is CurrentStatusLoadComplete) {
      // if (widget.pageMove == null)
      // popUntilNamed(context, CurrentStatusPage.ROUTE_NAME);
    }
  }

  Widget _buildLoading() {
    if (_controller != null) return Container();

    return FullscreenDialog();
  }

  Widget _buildWebView() {
    if (bloc.profile == null) return Container();
    debugPrint("profile : ${bloc.profile != null}");

    String page = "";
    if (widget.pageMove != null && widget.pageMove) {
      page = 'page=${widget.page}';
    }

    final url = Uri.encodeFull(
        '${baseUrl}ui/v2/status.html?token=${bloc.token}&profile=${json.encode(bloc.profile.toJson())}&$page');

    return WebView(
      javascriptMode: JavascriptMode.unrestricted,
      javascriptChannels: <JavascriptChannel>{
        JavascriptChannel(
            name: 'ConnectApp',
            onMessageReceived: (msg) {
              Log.d("=" + runtimeType.toString() + "=", msg.message);
              if (msg.message == 'open_chat') {
                Log.d(runtimeType.toString(), 'Open Chat');
                widget.bloc.add(ChangeViewEvent(changeIndex: 2));
              } else if (msg.message == 'rank_page') {
                Log.d(runtimeType.toString(), 'Rank Page');
                RankPage.push(context);
              } else if (msg.message == 'rank_modal') {
                Log.d(runtimeType.toString(), 'Rank Modal');
                rankDialog(context);
              } else if (msg.message.contains('diary_update')) {
                Log.d(runtimeType.toString(), 'Diary Update');
                DiaryPage.push(context,
                        DateTime.parse(msg.message.split(",")[1]), true)
                    .then((value) {
                  _controller.loadUrl(url);
                });
              } else if (msg.message == 'payment') {
                PaymentNoticePage.push(
                  context,
                  closeable: true,
                  isNewHomeUser: false,
                  back: true,
                );
              } else if (msg.message.contains('payment')) {
                PaymentNoticePage.push(context,
                    closeable: true,
                    isNewHomeUser: false,
                    back: true,
                    focusImg: int.parse(msg.message.split(",")[1]));
              } else if (msg.message.contains('diary_delete')) {
                widget.bloc.diaryRemove.add(msg.message.split(",")[1]);
              }
            }),
      },
      gestureRecognizers: [
        Factory<VerticalDragGestureRecognizer>(
          () => VerticalDragGestureRecognizer()
            ..onUpdate = (_) {
              _controller.reload();
            },
        ),
      ].toSet(),
      onWebViewCreated: (controller) {
        controller.loadUrl(url);
        setState(() {
          _controller = controller;
        });
      },
    );
  }

  @override
  CurrentStatusBloc initBloc() {
    final bloc = CurrentStatusBloc();
    bloc.add(CurrentStatusLoadEvent());
    return bloc;
  }
}
