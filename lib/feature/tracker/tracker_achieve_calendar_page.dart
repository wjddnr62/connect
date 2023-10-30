import 'package:connect/feature/tracker/tracker_achieve_calendar_bloc.dart';
import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connect/utils/extensions.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class TrackerAchieveCalendarPage extends BlocStatefulWidget {
  static Future<Object> push(BuildContext context) {
    return Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => TrackerAchieveCalendarPage()));
  }

  @override
  TrackerAchieveCalendarState buildState() => TrackerAchieveCalendarState();
}

class TrackerAchieveCalendarState
    extends BlocState<TrackerAchieveCalendarBloc, TrackerAchieveCalendarPage> {
  List<String> weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget blocBuilder(BuildContext context, state) {
    // TODO: implement blocBuilder
    return BlocBuilder(
        cubit: bloc,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: baseAppBar(context,
                leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  padding: EdgeInsets.zero,
                  icon: Image.asset(
                    AppImages.ic_delete,
                    width: resize(24),
                    height: resize(24),
                    color: AppColors.black,
                  ),
                )),
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      emptySpaceH(height: 16),
                      dateSelect(),
                      emptySpaceH(height: 32),
                      Padding(
                        padding: EdgeInsets.only(
                            left: resize(12), right: resize(12)),
                        child: days(),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 250,
                        child: StaggeredGridView.countBuilder(
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 7,
                          padding: EdgeInsets.only(
                              left: resize(12), right: resize(12)),
                          itemCount: bloc.dayLength + bloc.startDay,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, index) {
                            if (index >= bloc.startDay) {
                              return Container(
                                width: resize(48),
                                height: resize(48),
                                color: AppColors.white,
                                child: Center(
                                  child: bloc.completedDay
                                          .contains(index - bloc.startDay + 1)
                                      ? Image.asset(
                                          AppImages.ic_completed,
                                          width: resize(24),
                                          height: resize(24),
                                        )
                                      : Text(
                                          (index - bloc.startDay + 1)
                                              .toString(),
                                          style: AppTextStyle.from(
                                              color: (((index -
                                                              bloc.startDay +
                                                              1) >
                                                          bloc.nowDay) ||
                                                      bloc.nowDate.month !=
                                                          DateTime.now().month)
                                                  ? AppColors.lightGrey03
                                                  : AppColors.black,
                                              weight: TextWeight.semibold,
                                              size: TextSize.caption_large),
                                        ),
                                ),
                              );
                            } else {
                              return Container(
                                width: resize(48),
                                height: resize(48),
                              );
                            }
                          },
                          staggeredTileBuilder: (index) =>
                              StaggeredTile.count(1, 1),
                          mainAxisSpacing: 0,
                          crossAxisSpacing: 0,
                        ),
                      ),
                      emptySpaceH(height: 52),
                      Padding(
                        padding: EdgeInsets.only(
                            left: resize(24), right: resize(24)),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: resize(90),
                          padding: EdgeInsets.only(
                              left: resize(24), right: resize(24)),
                          decoration: BoxDecoration(
                              color: AppColors.lightGrey01,
                              borderRadius: BorderRadius.circular(16)),
                          child: Container(
                            height: resize(44),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  AppStrings.of(StringKey.goal_achieved),
                                  style: AppTextStyle.from(
                                      color: AppColors.darkGrey,
                                      size: TextSize.caption_medium,
                                      weight: TextWeight.bold),
                                ),
                                Expanded(child: Container()),
                                Text(
                                  bloc.completedDay.length.toString() + " ",
                                  style: AppTextStyle.from(
                                      color: AppColors.black,
                                      size: TextSize.title_large,
                                      weight: TextWeight.bold),
                                ),
                                Text(
                                  "/ ${bloc.days.length}",
                                  style: AppTextStyle.from(
                                      color: AppColors.grey,
                                      size: TextSize.title_large,
                                      weight: TextWeight.bold),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                _buildProgress(context)
              ],
            ),
          );
        });
  }

  dateSelect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: resize(40),
          height: resize(40),
          child: ElevatedButton(
            onPressed: () {
              bloc.add(MonthPrevEvent());
            },
            child: Image.asset(
              AppImages.ic_arrow_left_myreport,
              width: resize(24),
              height: resize(24),
            ),
            style: ElevatedButton.styleFrom(
                primary: AppColors.lightGrey01,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0),
          ),
        ),
        Container(
          width: resize(160),
          child: Center(
            child: Text(
              bloc.nowDate.toMonthCommaYear(),
              style: AppTextStyle.from(
                  color: AppColors.black,
                  size: TextSize.caption_large,
                  weight: TextWeight.extrabold),
            ),
          ),
        ),
        Container(
          width: resize(40),
          height: resize(40),
          child: ElevatedButton(
            onPressed: () {
              bloc.add(MonthNextEvent());
            },
            child: Image.asset(
              AppImages.ic_arrow_right_myreport,
              width: resize(24),
              height: resize(24),
            ),
            style: ElevatedButton.styleFrom(
                primary: AppColors.lightGrey01,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0),
          ),
        ),
      ],
    );
  }

  days() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: resize(16),
      child: ListView.builder(
        itemBuilder: (context, idx) {
          return Container(
            width: resize(48),
            child: Center(
              child: Text(
                weekdays[idx],
                style: AppTextStyle.from(
                    size: TextSize.caption_small,
                    color: AppColors.grey,
                    weight: TextWeight.semibold),
              ),
            ),
          );
        },
        shrinkWrap: true,
        itemCount: weekdays.length,
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  _buildProgress(BuildContext context) {
    if (!bloc.isLoading) return Container();

    return FullscreenDialog();
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is ChangeMonthState) {
      bloc.add(TrackerAchieveCalendarInitEvent());
    }
  }

  @override
  TrackerAchieveCalendarBloc initBloc() {
    // TODO: implement initBloc
    return TrackerAchieveCalendarBloc(context)
      ..add(TrackerAchieveCalendarInitEvent());
  }
}
