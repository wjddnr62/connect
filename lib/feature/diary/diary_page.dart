import 'package:cached_network_image/cached_network_image.dart';
import 'package:connect/feature/diary/diary_bloc.dart';
import 'package:connect/feature/payment/payment_notice_page.dart';
import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:connect/widgets/base_alert_dialog.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/bottons/bottom_button.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class DiaryPage extends BlocStatefulWidget {
  static const String ROUTE_NAME = '/diary_page';

  final DateTime selectDate;
  final bool modify;

  DiaryPage({this.selectDate, this.modify});

  static Future<Object> push(
      BuildContext context, DateTime selectDate, bool modify) {
    return Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => DiaryPage(
              selectDate: selectDate,
              modify: modify,
            )));
  }

  @override
  DiaryState buildState() => DiaryState();
}

class DiaryState extends BlocState<DiaryBloc, DiaryPage> {
  final timeToSleepText = TextEditingController();
  final wakeUpTimeText = TextEditingController();
  final diaryText = TextEditingController();

  final diaryFocus = FocusNode();

  List<String> weathers = [
    AppImages.weather_sunny,
    AppImages.weather_cloudy,
    AppImages.weather_clear,
    AppImages.weather_rain,
    AppImages.weather_thunder,
    AppImages.weather_rainbow,
    AppImages.weather_snow,
    AppImages.weather_wind
  ];

  List<String> feelings = [
    AppImages.feeling_good,
    AppImages.feeling_normal,
    AppImages.feeling_angry,
    AppImages.feeling_depressed,
    AppImages.feeling_lovely,
    AppImages.feeling_wink,
    AppImages.feeling_joy,
    AppImages.feeling_sadness,
    AppImages.feeling_headache,
    AppImages.feeling_surprise,
    AppImages.feeling_happiness,
    AppImages.feeling_mentalbreakdown
  ];

  List<Asset> imageList = List<Asset>();
  List<Asset> selectList = List<Asset>();

  bool sleepPass = false;
  bool wakePass = false;

  selectTimePicker(type) {
    DateTime setDate;
    if (type) {
      setDate = DateTime(widget.selectDate.year, widget.selectDate.month,
          widget.selectDate.day - 1, 21, 00);
    } else {
      setDate = DateTime(widget.selectDate.year, widget.selectDate.month,
          widget.selectDate.day, 06, 00);
    }
    DatePicker.showTime12hPicker(context, showTitleActions: true,
        onConfirm: (date) {
      if (type) {
        if (date.hour > 12) {
          timeToSleepText.text =
              "${date.hour - 12.toString().length == 1 ? "0${date.hour - 12}" : "${date.hour - 12}"}:${date.minute.toString().length == 1 ? "0${date.minute}" : "${date.minute}"}" +
                  " pm";
        } else {
          timeToSleepText.text =
              "${date.hour.toString().length == 1 ? "0${date.hour}" : "${date.hour}"}:${date.minute.toString().length == 1 ? "0${date.minute}" : "${date.minute}"}" +
                  " am";
        }
        bloc.sleepTime = date.toIso8601String();
        sleepPass = true;
      } else {
        if (date.hour > 12) {
          wakeUpTimeText.text =
              "${date.hour - 12.toString().length == 1 ? "0${date.hour - 12}" : "${date.hour - 12}"}:${date.minute.toString().length == 1 ? "0${date.minute}" : "${date.minute}"}" +
                  " pm";
        } else {
          wakeUpTimeText.text =
              "${date.hour.toString().length == 1 ? "0${date.hour}" : "${date.hour}"}:${date.minute.toString().length == 1 ? "0${date.minute}" : "${date.minute}"}" +
                  " am";
        }
        bloc.wakeTime = date.toIso8601String();
        wakePass = true;
      }
      setState(() {});
    }, currentTime: setDate, locale: LocaleType.en);
  }

  selectTime(context, type) {
    return TextFormField(
        onTap: () {
          selectTimePicker(type);
        },
        controller: type ? timeToSleepText : wakeUpTimeText,
        cursorColor: AppColors.black,
        readOnly: true,
        maxLines: 1,
        style: AppTextStyle.from(
            size: TextSize.body_small, color: AppColors.black),
        decoration: InputDecoration(
            hintText: type ? "9:00 pm" : "9:00 am",
            hintStyle: AppTextStyle.from(
                size: TextSize.caption_large, color: AppColors.lightGrey03),
            border: OutlineInputBorder(
                borderSide:
                    BorderSide(width: resize(1), color: AppColors.lightGrey04)),
            enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(width: resize(1), color: AppColors.lightGrey04)),
            focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(width: resize(1), color: AppColors.purple)),
            contentPadding: EdgeInsets.only(
              left: resize(16),
              right: resize(8),
            )));
  }

  sleepAndWake(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: resize(252),
      color: AppColors.white,
      padding: EdgeInsets.all(resize(24)),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                AppImages.ic_diary_time,
                width: resize(24),
                height: resize(24),
              ),
              emptySpaceW(width: 8),
              Text(
                AppStrings.of(StringKey.time_to_sleep),
                style: AppTextStyle.from(
                    weight: TextWeight.semibold,
                    size: TextSize.caption_large,
                    color: AppColors.darkGrey),
              )
            ],
          ),
          emptySpaceH(height: 15),
          selectTime(context, true),
          emptySpaceH(height: 30),
          Row(
            children: [
              Image.asset(
                AppImages.ic_alarm,
                width: resize(24),
                height: resize(24),
              ),
              emptySpaceW(width: 8),
              Text(
                AppStrings.of(StringKey.wake_up_time),
                style: AppTextStyle.from(
                    weight: TextWeight.semibold,
                    size: TextSize.caption_large,
                    color: AppColors.darkGrey),
              )
            ],
          ),
          emptySpaceH(height: 15),
          selectTime(context, false),
        ],
      ),
    );
  }

  chooseTheWeather(context) {
    return Container(
      color: AppColors.white,
      padding:
          EdgeInsets.only(top: resize(24), left: resize(24), right: resize(24)),
      height: resize(238),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.of(StringKey.choose_the_weather),
            style: AppTextStyle.from(
                color: AppColors.darkGrey,
                size: TextSize.caption_large,
                weight: TextWeight.semibold),
          ),
          emptySpaceH(height: 24),
          Container(
            height: resize(144),
            child: StaggeredGridView.countBuilder(
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              padding: EdgeInsets.only(left: resize(4), right: resize(4)),
              itemCount: 8,
              // shrinkWrap: true,
              itemBuilder: (BuildContext context, index) => Stack(
                children: [
                  Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Image.asset(
                        weathers[index],
                        width: resize(64),
                        height: resize(64),
                      )),
                  Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () {
                          bloc.add(WeatherSelectEvent(select: index));
                        },
                        child: Container(
                          width: resize(64),
                          height: resize(64),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: bloc.selectWeather == index
                                  ? Border.all(
                                      width: 2, color: AppColors.orange)
                                  : null),
                        ),
                      )),
                ],
              ),
              staggeredTileBuilder: (index) => StaggeredTile.count(1, 1),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
          )
        ],
      ),
    );
  }

  chooseYourFeeling(context) {
    return Container(
      color: AppColors.white,
      padding:
          EdgeInsets.only(top: resize(24), left: resize(24), right: resize(24)),
      height: resize(318),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.of(StringKey.choose_your_feeling),
            style: AppTextStyle.from(
                color: AppColors.darkGrey,
                size: TextSize.caption_large,
                weight: TextWeight.semibold),
          ),
          emptySpaceH(height: 24),
          Container(
            child: StaggeredGridView.countBuilder(
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              padding: EdgeInsets.only(left: resize(4), right: resize(4)),
              itemCount: 12,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, index) => GestureDetector(
                onTap: () {
                  if (bloc.userType == "VIP" && index >= 4) {
                    bloc.add(FeelingSelectEvent(select: index));
                  } else if (index >= 4) {
                    PaymentNoticePage.push(context,
                        back: true,
                        closeable: true,
                        focusImg: 3,
                        logSet: 'emoji');
                  } else {
                    bloc.add(FeelingSelectEvent(select: index));
                  }
                },
                child: Stack(
                  children: [
                    Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Image.asset(
                          feelings[index],
                          width: resize(64),
                          height: resize(64),
                        )),
                    Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: resize(64),
                          height: resize(64),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: bloc.selectFeeling == index
                                  ? Border.all(
                                      width: 2, color: AppColors.orange)
                                  : null),
                        )),
                    index >= 4
                        ? Positioned(
                            top: resize(4),
                            left: resize(4),
                            child: Image.asset(
                              AppImages.img_vip,
                              width: resize(32),
                              height: resize(18),
                            ))
                        : Container()
                  ],
                ),
              ),
              staggeredTileBuilder: (index) => StaggeredTile.count(1, 1),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
          )
        ],
      ),
    );
  }

  writeDiary(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: resize(262),
      color: AppColors.white,
      padding: EdgeInsets.all(resize(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.of(StringKey.tell_me_what_happened_today),
            style: AppTextStyle.from(
                color: AppColors.darkGrey,
                size: TextSize.caption_large,
                weight: TextWeight.semibold),
          ),
          emptySpaceH(height: 4),
          Text(
            "(${AppStrings.of(StringKey.optional)})",
            style: AppTextStyle.from(
                size: TextSize.caption_small, color: AppColors.grey),
          ),
          emptySpaceH(height: 12),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: resize(160),
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.lightGrey04),
                  borderRadius: BorderRadius.circular(4),
                  color: AppColors.white),
              padding: EdgeInsets.only(
                  top: resize(14),
                  bottom: resize(14),
                  left: resize(16),
                  right: resize(16)),
              child: TextFormField(
                  controller: diaryText,
                  focusNode: diaryFocus,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  style: AppTextStyle.from(
                      size: TextSize.caption_large, color: AppColors.black),
                  decoration: InputDecoration(
                      hintText: AppStrings.of(StringKey.please_write_a_diary),
                      hintStyle: AppTextStyle.from(
                          size: TextSize.caption_large,
                          color: AppColors.lightGrey03),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero)),
            ),
          )
        ],
      ),
    );
  }

  privateSet() {
    return Row(
      children: [
        SizedBox(
          width: resize(32),
          height: resize(32),
          child: IconButton(
              padding: EdgeInsets.zero,
              icon: Image.asset(
                bloc.privateCheck
                    ? AppImages.ic_check_select
                    : AppImages.ic_check_unselect,
                width: resize(32),
                height: resize(32),
              ),
              onPressed: () {
                bloc.add(PrivateCheckEvent());
              }),
        ),
        emptySpaceW(width: 12),
        Text(
          AppStrings.of(StringKey.this_diary_is_private),
          style: AppTextStyle.from(
              size: TextSize.caption_large,
              color: AppColors.darkGrey,
              weight: TextWeight.semibold),
        )
      ],
    );
  }

  footer(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: AppColors.white,
      padding: EdgeInsets.all(resize(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.of(StringKey.upload_photos),
            style: AppTextStyle.from(
                color: AppColors.darkGrey,
                size: TextSize.caption_large,
                weight: TextWeight.semibold),
          ),
          emptySpaceH(height: 24),
          Row(
            children: [
              (widget.modify &&
                      bloc.diaryData != null &&
                      bloc.diaryData.contentImages != null &&
                      bloc.diaryData.contentImages.length != 0)
                  ? Container(
                      height: resize(64),
                      child: ListView.builder(
                        itemBuilder: (context, idx) {
                          return Padding(
                            padding: EdgeInsets.only(right: resize(8)),
                            child: (bloc.diaryData.contentImages.length > idx &&
                                    bloc.diaryData.contentImages.isNotEmpty &&
                                    bloc.diaryData.contentImages[idx] != null)
                                ? GestureDetector(
                                    onTap: () {
                                      bloc.diaryData.contentImages
                                          .removeAt(idx);
                                      bloc.add(ImageRemoveEvent());
                                      imageCache.clear();
                                    },
                                    child: Container(
                                      width: resize(64),
                                      height: resize(64),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              bloc.diaryData.contentImages[idx]
                                                  .imagePath,
                                              width: 64,
                                              height: 64,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                              top: resize(2),
                                              right: resize(2),
                                              child: Image.asset(
                                                AppImages
                                                    .ic_delete_circle_diary,
                                                width: resize(24),
                                                height: resize(24),
                                              ))
                                        ],
                                      ),
                                    ),
                                  )
                                : DottedBorder(
                                    strokeWidth: 1,
                                    borderType: BorderType.RRect,
                                    dashPattern: [4, 4],
                                    color: AppColors.lightGrey04,
                                    radius: Radius.circular(8),
                                    child: Container(
                                      width: resize(60),
                                      height: resize(60),
                                      child: Center(
                                        child: Image.asset(
                                          AppImages.ic_upload,
                                          width: resize(24),
                                          height: resize(24),
                                        ),
                                      ),
                                    ),
                                  ),
                          );
                        },
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: 1,
                        // bloc.diaryData.contentImages.length,
                      ),
                    )
                  : Container(),
              Container(
                height: 64,
                child: ListView.builder(
                  itemBuilder: (context, idx) {
                    return GestureDetector(
                      onTap: () async {
                        imageCache.clear();
                        selectList.clear();
                        if (1 -
                                (widget.modify
                                    ? bloc.diaryData.contentImages != null
                                        ? bloc.diaryData.contentImages.length
                                        : 0
                                    : imageList.length) !=
                            0) {
                          selectList = await MultiImagePicker.pickImages(
                            maxImages: 1 -
                                (widget.modify
                                    ? bloc.diaryData.contentImages != null
                                        ? bloc.diaryData.contentImages.length
                                        : 0
                                    : imageList.length),
                            enableCamera: true,
                            selectedAssets: selectList,
                          );
                          for (int i = 0; i < selectList.length; i++) {
                            if (!selectList[i]
                                    .name
                                    .toLowerCase()
                                    .contains('heic') &&
                                !selectList[i].name.contains('HEIC')) {
                              imageList.add(selectList[i]);
                            } else {
                              showDialog(
                                  context: context,
                                  child: BaseAlertDialog(
                                    content:
                                        "Only files in JPG, JPEG, GIF, or BMP formats can be attached.",
                                    onCancel: () {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                    },
                                  ));
                              break;
                            }
                          }
                        }
                        bloc.add(MultiImageSelectEvent());
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: resize(8)),
                        child: (imageList.length > idx &&
                                imageList.isNotEmpty &&
                                imageList[idx] != null)
                            ? GestureDetector(
                                onTap: () {
                                  imageList.removeAt(idx);
                                  bloc.add(ImageRemoveEvent());
                                  imageCache.clear();
                                },
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: AssetThumb(
                                          asset: imageList[idx],
                                          width: 64,
                                          height: 64,
                                          spinner: Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        ),
                                      ),
                                      Positioned(
                                          top: resize(2),
                                          right: resize(2),
                                          child: Image.asset(
                                            AppImages.ic_delete_circle_diary,
                                            width: resize(24),
                                            height: resize(24),
                                          ))
                                    ],
                                  ),
                                ),
                              )
                            : DottedBorder(
                                strokeWidth: 1,
                                borderType: BorderType.RRect,
                                dashPattern: [4, 4],
                                color: AppColors.lightGrey04,
                                radius: Radius.circular(8),
                                child: Container(
                                  width: resize(60),
                                  height: resize(60),
                                  child: Center(
                                    child: Image.asset(
                                      AppImages.ic_upload,
                                      width: resize(24),
                                      height: resize(24),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    );
                  },
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.modify
                      ? bloc.diaryData != null &&
                              bloc.diaryData.contentImages != null
                          ? 1 - bloc.diaryData.contentImages.length
                          : 1
                      : 1,
                ),
              ),
            ],
          ),
          emptySpaceH(height: 32),
          privateSet(),
          emptySpaceH(height: 32),
          BottomButton(
            onPressed: (sleepPass && wakePass)
                ? () {
                    bloc.contentMessage = diaryText.text;
                    bloc.add(ImageGetUrlEvent(
                        imageList: imageList, type: widget.modify));
                  }
                : null,
            text: "Complete",
            textColor: (sleepPass && wakePass)
                ? AppColors.white
                : AppColors.lightGrey03,
          )
        ],
      ),
    );
  }

  Widget _buildProgress(BuildContext context) {
    if (!bloc.loading) return Container();

    return FullscreenDialog();
  }

  @override
  Widget blocBuilder(BuildContext context, state) {
    bloc.writeTime = widget.selectDate.toIso8601String();
    return BlocBuilder(
        cubit: bloc,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.lightGrey01,
            appBar: baseAppBar(context,
                title: AppStrings.of(
                    StringKey.how_was_your_day_today_write_a_diary),
                centerTitle: false,
                automaticallyImplyLeading: false),
            body: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        sleepAndWake(context),
                        emptySpaceH(height: 12),
                        chooseTheWeather(context),
                        emptySpaceH(height: 12),
                        chooseYourFeeling(context),
                        emptySpaceH(height: 12),
                        writeDiary(context),
                        emptySpaceH(height: 12),
                        footer(context)
                      ],
                    ),
                  ),
                ),
                _buildProgress(context)
              ],
            ),
          );
        });
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is DiaryInitState) {
      if (widget.modify) {
        DateTime sleepDate = DateTime.parse(bloc.diaryData.sleepDateTime);
        DateTime wakeDate = DateTime.parse(bloc.diaryData.wakeDateTime);

        if (sleepDate.hour > 12) {
          timeToSleepText.text =
              "${sleepDate.hour - 12.toString().length == 1 ? "0${sleepDate.hour - 12}" : "${sleepDate.hour - 12}"}:${sleepDate.minute.toString().length == 1 ? "0${sleepDate.minute}" : "${sleepDate.minute}"}" +
                  " pm";
        } else {
          timeToSleepText.text =
              "${sleepDate.hour.toString().length == 1 ? "0${sleepDate.hour}" : "${sleepDate.hour}"}:${sleepDate.minute.toString().length == 1 ? "0${sleepDate.minute}" : "${sleepDate.minute}"}" +
                  " am";
        }
        bloc.sleepTime = sleepDate.toIso8601String();
        sleepPass = true;

        if (wakeDate.hour > 12) {
          wakeUpTimeText.text =
              "${wakeDate.hour - 12.toString().length == 1 ? "0${wakeDate.hour - 12}" : "${wakeDate.hour - 12}"}:${wakeDate.minute.toString().length == 1 ? "0${wakeDate.minute}" : "${wakeDate.minute}"}" +
                  " pm";
        } else {
          wakeUpTimeText.text =
              "${wakeDate.hour.toString().length == 1 ? "0${wakeDate.hour}" : "${wakeDate.hour}"}:${wakeDate.minute.toString().length == 1 ? "0${wakeDate.minute}" : "${wakeDate.minute}"}" +
                  " am";
        }
        bloc.wakeTime = wakeDate.toIso8601String();
        wakePass = true;

        diaryText.text = bloc.diaryData.contentMessage;
      } else {
        // DateTime sleepTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 21, 00);
        // DateTime wakeTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 6, 00);
        //
        // if (sleepTime.hour > 12) {
        //   timeToSleepText.text =
        //       "${sleepTime.hour - 12.toString().length == 1 ? "0${sleepTime.hour - 12}" : "${sleepTime.hour - 12}"}:${sleepTime.minute.toString().length == 1 ? "0${sleepTime.minute}" : "${sleepTime.minute}"}" +
        //           " pm";
        // } else {
        //   timeToSleepText.text =
        //       "${sleepTime.hour.toString().length == 1 ? "0${sleepTime.hour}" : "${sleepTime.hour}"}:${sleepTime.minute.toString().length == 1 ? "0${sleepTime.minute}" : "${sleepTime.minute}"}" +
        //           " am";
        // }
        // bloc.sleepTime = sleepTime.toIso8601String();
        // sleepPass = true;
        //
        // if (wakeTime.hour > 12) {
        //   wakeUpTimeText.text =
        //       "${wakeTime.hour - 12.toString().length == 1 ? "0${wakeTime.hour - 12}" : "${wakeTime.hour - 12}"}:${wakeTime.minute.toString().length == 1 ? "0${wakeTime.minute}" : "${wakeTime.minute}"}" +
        //           " pm";
        // } else {
        //   wakeUpTimeText.text =
        //       "${wakeTime.hour.toString().length == 1 ? "0${wakeTime.hour}" : "${wakeTime.hour}"}:${wakeTime.minute.toString().length == 1 ? "0${wakeTime.minute}" : "${wakeTime.minute}"}" +
        //           " am";
        // }
        // bloc.wakeTime = wakeTime.toIso8601String();
        // wakePass = true;
      }
      setState(() {});
    }

    if (state is ImageGetUrlState) {
      bloc.add(DiarySaveEvent(image: state.image, type: widget.modify));
    }

    if (state is DiarySaveState) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  DiaryBloc initBloc() {
    return DiaryBloc(context)
      ..add(DiaryInitEvent(type: widget.modify, selectDate: widget.selectDate));
  }
}
