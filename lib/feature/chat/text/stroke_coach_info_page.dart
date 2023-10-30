import 'package:connect/models/stroke_coach.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/utils/date_format.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class StrokeCoachInfoPage extends BasicPage {
  static const ROUTE_NAME = '/stroke_coach_info_page';

  StrokeCoachInfoPage({this.strokeCoach, this.startTime, this.endTime});

  static Future<Object> push(BuildContext context,
      {StrokeCoach strokeCoach, String startTime, String endTime}) {
    Map<String, dynamic> arguments = {
      'stroke_coach': strokeCoach,
      'start': startTime,
      'end': endTime
    };
    return Navigator.of(context).pushNamed(ROUTE_NAME, arguments: arguments);
  }

  StrokeCoach strokeCoach;
  String startTime;
  String endTime;

  @override
  void handleArgument(BuildContext context) {
    strokeCoach =
        (ModalRoute.of(context).settings.arguments as Map)['stroke_coach'];
    startTime = (ModalRoute.of(context).settings.arguments as Map)['start'];
    endTime = (ModalRoute.of(context).settings.arguments as Map)['end'];
  }

  @override
  Widget buildWidget(BuildContext context) {
    var singleChildScrollView = SingleChildScrollView(
        child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
          _createTop(context),
          _createImage(),
          _createName(),
          _createIntroduction(),
          _createAvailableTime()
        ]));
    return Container(
        color: Colors.white,
        child: SafeArea(child: Scaffold(body: singleChildScrollView)));
  }

  Widget _createTop(BuildContext context) {
    var btn = GestureDetector(
        onTap: () => pop(context),
        child: Container(
            width: resize(24),
            height: resize(24),
            margin: EdgeInsets.only(
                top: resize(10), bottom: resize(10), left: resize(16)),
            child: Image.asset(AppImages.ic_delete,
                width: resize(24), height: resize(24))));
    return Container(
        width: double.infinity,
        height: resize(44),
        child: Row(children: <Widget>[btn]));
  }

  Widget _createImage() {
    var imageEnable = strokeCoach.image != null;
    return Container(
        width: resize(116),
        height: resize(116),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: imageEnable
                ? DecorationImage(
                    image: NetworkImage(strokeCoach.image), fit: BoxFit.fill)
                : null,
            color: imageEnable ? null : AppColors.darkGrey),
        margin: EdgeInsets.only(top: resize(10)));
  }

  Widget _createName() {
    return Container(
        margin: EdgeInsets.only(top: resize(16)),
        child: Text(strokeCoach.name,
            style: AppTextStyle.from(
                color: AppColors.black,
                weight: TextWeight.bold,
                size: TextSize.title_medium)));
  }

  Widget _createIntroduction() {
    final introduction = Container(
        margin: EdgeInsets.only(
            top: resize(40), left: resize(24), right: resize(24)),
        child: Align(
            alignment: Alignment.topLeft,
            child: Text(AppStrings.of(StringKey.introduction),
                style: AppTextStyle.from(
                    color: AppColors.black,
                    weight: TextWeight.bold,
                    size: TextSize.caption_large))));

    final content = Container(
        height: resize(140),
        margin: EdgeInsets.only(
            top: resize(14), left: resize(24), right: resize(24)),
        child: Align(
            alignment: Alignment.topLeft,
            child: Text(strokeCoach.introduction ?? "",
                style: AppTextStyle.from(
                    height: 1.6,
                    color: AppColors.darkGrey,
                    weight: TextWeight.medium,
                    size: TextSize.caption_large))));
    return Column(children: <Widget>[introduction, content]);
  }

  Widget _createAvailableTime() {
    final introduction = Container(
        margin: EdgeInsets.only(
            top: resize(24), left: resize(24), right: resize(24)),
        child: Align(
            alignment: Alignment.topLeft,
            child: Text(AppStrings.of(StringKey.available_time),
                style: AppTextStyle.from(
                    color: AppColors.black,
                    weight: TextWeight.bold,
                    size: TextSize.caption_large))));
    final content = Container(
        margin: EdgeInsets.only(
            top: resize(13), left: resize(24), right: resize(24)),
        child: Align(
            alignment: Alignment.topLeft,
            child: (startTime != null && endTime != null)
                ? Text("${_timeParse(startTime)} ~ ${_timeParse(endTime)}",
                    style: AppTextStyle.from(
                        color: AppColors.darkGrey,
                        weight: TextWeight.medium,
                        size: TextSize.caption_large))
                : Container()));
    return Container(child: Column(children: <Widget>[introduction, content]));
  }

  _timeParse(String str) {
    var split = str.split(':');
    final hour = int.parse(split[0]);
    final minute = int.parse(split[1]);
    final now = DateTime.now();
    final date = DateTime(now.year, now.month, now.day, hour, minute);
    return DateFormat.formatIntl("hh:mm a", date);
  }
}
