import 'package:connect/models/missions.dart';
import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_images.dart';
import 'package:connect/resources/app_strings.dart';
import 'package:connect/resources/app_text_style.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:flutter/material.dart';
import 'package:multiscreen/multiscreen.dart';

class MissionCompleteButton extends StatelessWidget {
  final Mission mission;
  final VoidCallback onPressed;
  final bool processing;

  bool get enabled => onPressed != null;

  bool get completed => mission.completed;

  MissionCompleteButton(
      {Key key, this.mission, this.processing, this.onPressed})
      : super(key: key) {
    assert(this.mission != null && this.processing != null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onPressed: onPressed,
        padding: EdgeInsets.all(0),
        child: Container(
            height: resize(54),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(resize(4)),
                  right: Radius.circular(resize(4))),
              border: completed || !enabled
                  ? null
                  : Border.all(color: AppColors.blue7B, width: 2),
              color: enabled
                  ? completed
                      ? AppColors.blue7B
                      : AppColors.white
                  : AppColors.lightGrey02,
              shape: BoxShape.rectangle,
            ),
            child: Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                  Container(child: _createLeftIcon()),
                  emptySpaceW(width: 8),
                  Container(
                      child: Text(_getButtonString(),
                          textAlign: TextAlign.center,
                          style: AppTextStyle.from(
                            color: enabled
                                ? completed
                                    ? AppColors.white
                                    : AppColors.blue7B
                                : AppColors.lightGrey04,
                            size: TextSize.caption_large,
                            weight: TextWeight.semibold,
                            height: AppTextStyle.LINE_HEIGHT_MULTI_LINE,
                          ))),
                ]))));
  }

  String _getButtonString() {
    if (completed) return StringKey.undo.getString();

    switch (mission.type) {
      case MISSION_TYPE_ACTIVITY:
      case MISSION_TYPE_EXERCISE_BASICS:
      case MISSION_TYPE_VIDEO:
      case MISSION_TYPE_CARD_READING:
      case MISSION_TYPE_QUIZ:
        return AppStrings.of(StringKey.completed);
      default:
        return '';
    }
  }

  Widget _createLeftIcon() {
    if (processing)
      return Container(
        width: resize(24),
        height: resize(24),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              completed ? Colors.white : AppColors.blue7B),
        ),
      );

    return enabled
        ? completed
            ? Image.asset(
                AppImages.ic_check_completed,
                width: resize(24),
                height: resize(18),
              )
            : Container()
        : Container();
  }
}
