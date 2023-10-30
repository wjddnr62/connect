import 'dart:ui' as BaseUI;

import 'package:connect/connect_firebase.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/feature/bottom_navigation/home_navigation_bloc.dart';
import 'package:connect/feature/chat/text/chat_model.dart';
import 'package:connect/feature/chat/text/chat_state.dart';
import 'package:connect/feature/chat/text/stroke_coach_info_page.dart';
import 'package:connect/feature/chat/text/text_chat_bloc.dart';
import 'package:connect/feature/home/home_calendar.dart';
import 'package:connect/feature/payment/payment_notice_page.dart';
import 'package:connect/feature/user/account/account_bloc.dart';
import 'package:connect/resources/app_images.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/utils/date_format.dart';
import 'package:connect/utils/logger/log.dart';
import 'package:connect/utils/regular_expressions.dart';
import 'package:connect/widgets/base_alert_dialog.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TextChatPage extends BlocStatefulWidget {
  static const ROUTE_NAME = '/text_chat_page';

  static Future<Object> push(BuildContext context) =>
      Navigator.of(context).pushNamedAndRemoveUntil(
          ROUTE_NAME, ModalRoute.withName(HomeCalendarPage.ROUTE_NAME));

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return TextChatState();
  }

  final HomeNavigationBloc bloc;

  TextChatPage({this.bloc});
}

class TextChatState extends BlocState<TextChatBloc, TextChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController(keepScrollOffset: true);
  final _focus = FocusNode();
  var _textEmpty = true;

  TextChatState() {
    debugPrint("create $runtimeType !!");
    _focus.addListener(() {
      setState(() {
        debugPrint("$runtimeType focus Change!!!");
      });
    });
    _textController.addListener(_inputChange);
    _scrollController.addListener(_scrollChange);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  blocBuilder(BuildContext context, state) {
    debugPrint("${this.runtimeType} build! $state");
    var res = Scaffold(
        appBar: baseAppBar(
          context,
          title: bloc.strokeCoach?.name ?? "Rehabit",
          backgroundColor: AppColors.lightGrey01,
          leading: Container(),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Stack(
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Flexible(
                    child: _createListView(),
                    flex: 1,
                  ),
                  Flexible(
                    child: _buildTextField(),
                    flex: 0,
                  )
                ],
              ),
              (state is ChatUIRefreshState) ? FullscreenDialog() : Container(),
              (state is ChatConnectingState) ? FullscreenDialog() : Container(),
            ],
          ),
        ));
    return Container(
        color: AppColors.lightGrey01,
        child: SafeArea(
          child: res,
        ));
  }

  @override
  blocListener(BuildContext context, state) {
    debugPrint("${this.runtimeType} / event ! $state");

    if (state is ChatMoveToTherapistInfoState) {
      _focus.unfocus();
      StrokeCoachInfoPage.push(context,
          strokeCoach: bloc.strokeCoach,
          startTime: bloc.workingHours.start_work_time,
          endTime: bloc.workingHours.end_work_time);
    }

    if (state is MyOTInfoNotSet) {
      // pop(context);
      // PaymentNoticePage.push(context, focusImg: 4, back: true, closeable: true);
      showDialog(
          context: context,
          child: BaseAlertDialog(
              content: AppStrings.of(StringKey.wait_your_coach),
              onConfirm: () async =>
                  widget.bloc.add(ChangeViewEvent(changeIndex: 0))));
    }

    if (state is ChatErrorState) {
      showDialog(
          context: context,
          barrierDismissible: false,
          child: BaseAlertDialog(
            content: state.errorMessage,
            onConfirm: () => widget.bloc.add(ChangeViewEvent(changeIndex: 0)),
          ));
    }

    return;
  }

  @override
  TextChatBloc initBloc() {
    TextChatBloc bloc = TextChatBloc();
    bloc.add(ChatJoinRequestEvent(gFcmId));
    return bloc;
  }

  Widget _createListView() {
    var cnt = bloc.getListTileCount();

    debugPrint("tile count : $cnt");

    final listView = ListView.builder(
        itemCount: cnt,
        reverse: true,
        controller: _scrollController,
        itemBuilder: (BuildContext ctx, int index) =>
            createListTile(ctx, index, cnt));

    return Container(child: listView, color: Color(0xfff4f5f7));
  }

  Widget createListTile(BuildContext context, int index, int definedMaxSize) {
    final item = bloc.getListTileItem(index, definedMaxSize);

    if (item is DateTime) {
      return _createDateTile(context, item);
    }

    if (!(item is Chat)) {
      throw Exception(
          "$runtimeType / createListTile[$index] is Not DateTime or Chat !!! : ${item.runtimeType}");
    }

    return item.isTherapist(bloc.ownId)
        ? _createTherapistChat(context, item)
        : _createPatientChat(context, item);
  }

  Widget _createDateTile(BuildContext context, DateTime date) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: resize(8)),
        padding: EdgeInsets.only(
            top: resize(1),
            left: resize(12),
            right: resize(11),
            bottom: resize(1)),
        decoration: BoxDecoration(
            color: AppColors.lightGrey04,
            borderRadius: BorderRadius.all(Radius.circular(resize(9)))),
        child: Text(
          DateFormat.formatDate("mmddyyyy", date),
          textAlign: TextAlign.center,
          style: AppTextStyle.from(
            color: AppColors.grey,
            size: TextSize.caption_small,
          ),
        ),
      ),
    );
  }

  Widget _createTherapistChat(BuildContext context, Chat chat) {
    final imageEnable = bloc.strokeCoach.image != null;
    final face = GestureDetector(
      onTap: () => bloc.add(ChatMoveToTherapistInfoEvent()),
      child: Container(
        width: resize(36),
        height: resize(36),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: imageEnable
                  ? NetworkImage(bloc.strokeCoach.image)
                  : AssetImage(AppImages.img_therapist_photo),
              fit: BoxFit.fill,
            )),
        margin: EdgeInsets.only(right: resize(8)),
      ),
    );
    final name = Text(bloc.strokeCoach?.name ?? "",
        style: AppTextStyle.from(
          size: TextSize.caption_medium,
          color: AppColors.darkGrey,
        ));
    final message = Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
        margin: EdgeInsets.only(top: resize(8), right: resize(8)),
        padding: EdgeInsets.only(
            left: resize(16),
            right: resize(16),
            top: resize(10),
            bottom: resize(10)),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(resize(5)),
              topRight: Radius.circular(resize(20)),
              bottomLeft: Radius.circular(resize(20)),
              bottomRight: Radius.circular(resize(20)),
            ),
            color: Colors.white),
        child: _widgetUrlLinkText(
            chat.msg,
            AppTextStyle.from(
                size: TextSize.caption_large,
                color: AppColors.black,
                height: AppTextStyle.LINE_HEIGHT_MULTI_LINE),
            AppTextStyle.from(
                size: TextSize.caption_large,
                color: AppColors.blue01,
                decoration: TextDecoration.underline,
                height: AppTextStyle.LINE_HEIGHT_MULTI_LINE)));
    final faceMessageRow = Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          face,
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[name, message],
          ),
        ]);
    final inputTime = Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: _createChatStatus(chat),
    );
    return Container(
      margin: EdgeInsets.only(
          left: resize(16), top: resize(12), bottom: resize(12)),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[faceMessageRow, inputTime],
      ),
    );
  }

  Widget _createPatientChat(BuildContext context, Chat chat) {
    final message = Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.6,
            minHeight: resize(44)),
        margin: EdgeInsets.only(left: resize(8)),
        padding: EdgeInsets.only(
            left: resize(16),
            right: resize(16),
            top: resize(10),
            bottom: resize(10)),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(resize(20)),
              topRight: Radius.circular(resize(5)),
              bottomLeft: Radius.circular(resize(20)),
              bottomRight: Radius.circular(resize(20)),
            ),
            color: chat.state != ChatState.ERROR
                ? AppColors.purple
                : AppColors.blueGrey),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _widgetUrlLinkText(
                chat.msg,
                AppTextStyle.from(
                    size: TextSize.caption_large,
                    color: AppColors.white,
                    height: AppTextStyle.LINE_HEIGHT_MULTI_LINE),
                AppTextStyle.from(
                    size: TextSize.caption_large,
                    color: AppColors.blue01,
                    decoration: TextDecoration.underline,
                    height: AppTextStyle.LINE_HEIGHT_MULTI_LINE))
          ],
        ));
    final status = Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: _createChatStatus(chat),
    );

    return Container(
      margin: EdgeInsets.only(
          right: resize(16), top: resize(12), bottom: resize(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[status, message],
          )
        ],
      ),
    );
  }

  RichText _widgetUrlLinkText(
      String text, TextStyle defaultTextSpan, TextStyle urlTextSpan) {
    RegExp exp = new RegExp(urlRegexString());
    Iterable<RegExpMatch> matches = exp.allMatches(text);

    var startIndex = 0;
    var textSpans = List<TextSpan>();

    if (matches.isNotEmpty) {
      matches.forEach((match) {
        var urlText = text.substring(match.start, match.end);
        textSpans.add(TextSpan(text: text.substring(startIndex, match.start)));
        textSpans.add(TextSpan(
            text: urlText,
            style: urlTextSpan,
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                if (await canLaunch(urlText)) {
                  await launch(urlText);
                }
              }));
        startIndex = match.end;
      });
    } else {
      textSpans.add(TextSpan(text: text));
    }
    return RichText(
        text: TextSpan(
      style: defaultTextSpan,
      children: textSpans,
    ));
  }

  List<Widget> _createChatStatus(Chat chat) {
    if (chat.state == ChatState.SUCCESS)
      return <Widget>[
        Text(
          chat.getTimeString(),
          style: AppTextStyle.from(
              color: AppColors.grey, size: TextSize.caption_small),
        )
      ];
    else if (chat.state == ChatState.PENDING)
      return [];
    else // ERROR
      return <Widget>[
        GestureDetector(
          onTap: () => bloc.add(ChatResendEvent(chat)),
          child: Container(
            width: resize(48),
            height: resize(36),
            decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.all(Radius.circular(resize(4)))),
            child: Center(
              child: Image.asset(AppImages.ic_redo),
            ),
          ),
        )
      ];
  }

  Widget _buildTextField() {
    var containerDecoration = BoxDecoration(
        border: Border.all(color: Color(0xffdcdfe6)),
        borderRadius: BorderRadius.circular(resize(20)),
        color: Color(0x80f4f5f7));

    var inputDecoration = InputDecoration(
        hintText: null,
        border: InputBorder.none,
        contentPadding: EdgeInsets.only(
            left: resize(16),
            top: resize(7),
            bottom: resize(7),
            right: resize(16)));

    final textField = TextField(
      maxLines: null,
      decoration: inputDecoration,
      focusNode: _focus,
      controller: _textController,
      style: AppTextStyle.from(
          size: TextSize.caption_large, color: AppColors.black),
    );

    final btn = GestureDetector(
        onTap: () {
          if (!_textEmpty) _inputEnter(_textController.text);
        },
        child: Container(
          width: resize(32.0),
          height: resize(32.0),
          margin: EdgeInsets.all(resize(4.0)),
          padding: EdgeInsets.only(
              top: resize(7.1),
              left: resize(6.1),
              right: resize(6.9),
              bottom: resize(7.9)),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(_textEmpty ? 0xffebecf0 : 0xFF7B7ED2)),
          child: Image.asset(AppImages.ic_arrow_up,
              width: resize(19),
              height: resize(17),
              color: _textEmpty ? null : Colors.white),
        ));

    final widgets = <Widget>[
      Flexible(
        child: textField,
      )
    ];

    if (_focus.hasFocus) widgets.add(btn);

    return Container(
      color: Colors.white,
      height: resize(56),
      padding: EdgeInsets.only(
          left: resize(16),
          right: resize(16),
          top: resize(8),
          bottom: resize(8)),
      child: Container(
        decoration: containerDecoration,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: widgets,
        ),
      ),
    );
  }

  void _inputEnter(String value) {
    _textController.clear();
    final bloc = this.bloc;
    bloc.add(ChatSendEvent(value));
    bloc.endTyping();
  }

  void _inputChange() {
    final textEmpty = _textController.text.isEmpty;
    if (textEmpty != this._textEmpty) {
      textEmpty ? bloc.endTyping() : bloc.startTyping();
      setState(() {
        debugPrint("$runtimeType input change!!!");
        this._textEmpty = textEmpty;
      });
    }
  }

  void _scrollChange() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      bloc.add(ChatMaxScrollEvent());
    }
  }

  @override
  void dispose() {
    super.dispose();
    bloc.dispose();
  }

  @override
  void didChangeLocales(List<BaseUI.Locale> locale) {}

  @override
  void didChangeMetrics() {}

  @override
  void didChangePlatformBrightness() {}

  @override
  void didChangeTextScaleFactor() {}

  @override
  void didHaveMemoryPressure() {}

  @override
  Future<bool> didPopRoute() {
    return null;
  }

  @override
  Future<bool> didPushRoute(String route) {
    return null;
  }
}
