import 'package:connect/resources/app_resources.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../utils/calendar_utils.dart' as calendar;

class HomeCalendarDayItem extends BasicStatelessWidget {
  final Function onPressed;
  final DateTime date;
  final bool isSelected;
  final DateTime joinedDate;

  bool get selectable =>
      calendar.isToday(date) ||
      (DateTime.now().difference(date).inDays > 0) &&
          (joinedDate.difference(date).inDays <= 0);

  /// how many mission's completed.
  final double progressed;

  HomeCalendarDayItem(this.date,
      {this.onPressed,
      this.isSelected,
      this.progressed = 0.0,
      this.joinedDate});

  @override
  Widget buildWidget(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        height: resize(78),
        width: (MediaQuery.of(context).size.width - resize(16)) / 7,
        child: MaterialButton(
            onPressed: selectable ? onPressed : null,
            padding: EdgeInsets.all(0),
            child: Column(
              children: <Widget>[
                emptySpaceH(height: 4),
                Text(
                  '${calendar.weekDayString(date.weekday).substring(0, 1)}',
                  style: AppTextStyle.from(
                    color: AppColors.blueGrey,
                    size: TextSize.caption_small,
                    weight: TextWeight.semibold,
                  ),
                ),
                emptySpaceH(height: 10),
                Center(child: _createDateContainer()),
                Expanded(
                  child: Container(),
                ),
                isSelected
                    ? Container(
                        width: resize(36),
                        height: resize(3),
                        decoration: BoxDecoration(
                            color: AppColors.black,
                            borderRadius: BorderRadius.circular(1)),
                      )
                    : Container()
              ],
            )));
  }

  Widget _createDateContainer() {
    final text = Padding(
        padding:
            !selectable ? EdgeInsets.only(top: resize(4)) : EdgeInsets.zero,
        child: CircleAvatar(
          radius: resize(14),
          backgroundColor: _getDayBackgroundColor(),
          child: Text('${date.day}',
              style: AppTextStyle.from(
                  size: TextSize.caption_large,
                  weight: TextWeight.semibold,
                  color: _getDayTextColor(),
                  height: 1.3)),
        ));
    if (selectable) {
      return CircularPercentIndicator(
        radius: resize(34),
        lineWidth: resize(2),
        percent: progressed,
        center: text,
        progressColor: AppColors.orange,
        backgroundColor: AppColors.lightGrey02,
      );
    }

    return text;
  }

  Color _getDayTextColor() {
    if (isSelected) {
      if (calendar.isToday(date)) {
        return AppColors.white;
      }
      return AppColors.black;
    }

    if (calendar.isToday(date)) {
      return AppColors.white;
    }

    return selectable
        ? AppColors.darkGrey
        : AppColors.darkGrey.withOpacity(0.4);
  }

  Color _getDayBackgroundColor() {
    if (isSelected) {
      if (calendar.isToday(date)) {
        return AppColors.black;
      }
      return AppColors.white;
    }

    if (calendar.isToday(date)) {
      return AppColors.black;
    }

    return AppColors.transparent;
  }
}
