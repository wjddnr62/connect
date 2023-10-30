import 'dart:math';

import 'package:connect/feature/mission/mission_complete_button.dart';
import 'package:connect/models/missions.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/bottons/bottom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share/share.dart';

class CardReadingMissionItem extends BasicStatelessWidget {
  final Mission mission;
  final MissionDetail missionDetail;
  final Html html;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final VoidCallback onComplete;
  final VoidCallback onBookmark;
  final bool isLast;
  final bool isFirst;
  final bool bookmark;

  final bool completed;
  final bool processing;
  final double parentHeight;

  CardReadingMissionItem(
      {this.mission,
      this.missionDetail,
      this.html,
      this.onNext,
      this.onPrev,
      this.onComplete,
      this.onBookmark,
      this.isFirst = false,
      this.isLast = false,
      this.bookmark = false,
      this.completed,
      this.processing,
      this.parentHeight});

  @override
  Widget buildWidget(BuildContext context) {
    List<Widget> list = [
      ConstrainedBox(
          constraints: BoxConstraints(minHeight: parentHeight - resize(90)),
          child: Container(
              width: MediaQuery.of(context).size.width,
              child: Container(child: html))),
    ];

    if (isLast) {
      list.add(Padding(
        padding: EdgeInsets.only(left: resize(24)),
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
                onPressed: onBookmark,
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    primary: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        missionDetail
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
                            size: TextSize.caption_medium),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(child: Container())
          ],
        ),
      ));
      list.add(Container(
          margin: EdgeInsets.all(resize(24)),
          child: Row(children: <Widget>[
            isFirst ? Container() : prevButton(onPrev),
            isFirst ? Container() : emptySpaceW(width: 12),
            Expanded(
                child: bookmark ?? false
                    ? BottomButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        color: AppColors.white,
                        textColor: AppColors.purple,
                        lineColor: AppColors.purple,
                        lineBoxed: true,
                        text: AppStrings.of(StringKey.bookmark_list),
                      )
                    : MissionCompleteButton(
                        processing: processing,
                        mission: mission,
                        onPressed: onComplete))
          ])));
    } else if (isFirst) {
      list.add(Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(child: Container()),
            nextButton(onNext),
          ],
        ),
      ));
    } else {
      list.add(Container(
          margin: EdgeInsets.all(resize(24)),
          child: Row(children: <Widget>[
            prevButton(onPrev),
            Expanded(child: Container()),
            nextButton(onNext)
          ])));
    }

    return ListView(
      children: list,
      physics: ClampingScrollPhysics(),
    );
  }

  prevButton(function) {
    return Container(
      width: resize(54),
      height: resize(54),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(4)),
      child: ElevatedButton(
        onPressed: function,
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            primary: AppColors.white,
            side: BorderSide(color: AppColors.purple, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            elevation: 0),
        child: Center(
          child: Image.asset(
            AppImages.ic_arrow,
            width: resize(24),
            height: resize(24),
            color: AppColors.purple,
          ),
        ),
      ),
    );
  }

  nextButton(function) {
    return Container(
      width: resize(54),
      height: resize(54),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(4)),
      child: ElevatedButton(
        onPressed: function,
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            primary: AppColors.white,
            side: BorderSide(color: AppColors.purple, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            elevation: 0),
        child: Center(
          child: Transform.rotate(
            angle: 180 * pi / 180,
            child: Image.asset(
              AppImages.ic_arrow,
              width: resize(24),
              height: resize(24),
              color: AppColors.purple,
            ),
          ),
        ),
      ),
    );
  }
}
