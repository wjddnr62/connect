import 'package:cached_network_image/cached_network_image.dart';
import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_images.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/resources/app_strings.dart';
import 'package:connect/resources/app_text_style.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/bottons/bottom_button.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import 'evaluation_bloc.dart';

class EvaluationPage extends BlocStatefulWidget {
  final checkStatus;

  EvaluationPage({this.checkStatus});

  static const String ROUTE_NAME = '/evaluation_page';

  static Future<Object> pushAndRemoveUntil(BuildContext context) {
    return Navigator.of(context)
        .pushNamedAndRemoveUntil(ROUTE_NAME, (route) => false);
  }

  static Future<Object> push(BuildContext context, int checkStatus) =>
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => EvaluationPage(checkStatus: checkStatus)));

  @override
  _EvaluationState buildState() => _EvaluationState();
}

class _EvaluationState extends BlocState<EvaluationBloc, EvaluationPage>
    with SingleTickerProviderStateMixin {
  PreferredSize appbar;
  ScrollController evaluationListController = ScrollController();

  List<String> genders = ['Male', 'Female', 'Other'];

  final textController = TextEditingController();

  _scrollListener() {
    if (evaluationListController.offset > 0 &&
        !evaluationListController.position.outOfRange) {
      bloc.add(EvaluationScrollChangeEvent(type: 1));
    } else if (evaluationListController.offset <=
            evaluationListController.position.minScrollExtent &&
        !evaluationListController.position.outOfRange) {
      bloc.add(EvaluationScrollChangeEvent(type: 2));
    }
  }

  initState() {
    evaluationListController.addListener(_scrollListener);
    super.initState();
  }

  PreferredSize _buildAppBar(BuildContext context) {
    return baseAppBar(context,
        title: AppStrings.of(StringKey.stroke_evaluation),
        backgroundColor: AppColors.white,
        elevation: 0,
        onLeadPressed: () => evaluationBackMove());
  }

  Widget _buildMainWidget(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        evaluationBackMove();
        return;
      },
      child: SafeArea(
        child: Container(
          color: AppColors.white,
          height: MediaQuery.of(context).size.height -
              appbar.preferredSize.height -
              MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
          child: !bloc.evaluationCheckFinish
              ? evaluationView()
              : !bloc.genderSelectFinish
                  ? genderSelectView()
                  : aboutYouWrite(),
        ),
      ),
    );
  }

  aboutYouWrite() {
    return Stack(
      children: [
        Positioned(
            top: resize(24),
            left: resize(24),
            right: resize(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: resize(27),
                  child: Text(
                    AppStrings.of(StringKey.about_you),
                    style: AppTextStyle.from(
                        size: TextSize.body_large,
                        color: AppColors.purple,
                        weight: TextWeight.extrabold),
                  ),
                ),
                emptySpaceH(height: 9),
                Container(
                  height: resize(54),
                  child: Text(
                    AppStrings.of(StringKey
                        .please_write_the_things_you_want_to_say_to_your_coach),
                    style: AppTextStyle.from(
                        size: TextSize.body_medium,
                        color: AppColors.darkGrey,
                        weight: TextWeight.extrabold,
                        height: 1.4),
                  ),
                ),
                emptySpaceH(height: 20),
                // Container(
                //   height: resize(16),
                //   child: Text(
                //     "(${AppStrings.of(StringKey.optional)})",
                //     style: AppTextStyle.from(
                //         size: TextSize.caption_small, color: AppColors.grey),
                //   ),
                // ),
                // emptySpaceH(height: 8),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: resize(160),
                  padding: EdgeInsets.only(
                      left: resize(16),
                      right: resize(16),
                      top: resize(14),
                      bottom: resize(14)),
                  decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: textController.text.length > 250
                              ? AppColors.error
                              : AppColors.lightGrey04)),
                  child: TextFormField(
                      controller: textController,
                      minLines: 1,
                      maxLines: null,
                      onChanged: (value) {
                        setState(() {});
                      },
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      style: AppTextStyle.from(
                          size: TextSize.caption_large, color: AppColors.black),
                      cursorColor: AppColors.purple,
                      decoration: InputDecoration(
                          hintText: AppStrings.of(StringKey.place_your_text),
                          hintStyle: AppTextStyle.from(
                              size: TextSize.caption_large,
                              color: AppColors.lightGrey03),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero)),
                ),
                emptySpaceH(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    height: resize(16),
                    child: Text(
                      "${textController.text.length}/250",
                      style: AppTextStyle.from(
                          size: TextSize.caption_small,
                          color: textController.text.length > 250
                              ? AppColors.error
                              : AppColors.grey),
                    ),
                  ),
                )
              ],
            )),
        Positioned(
            bottom: resize(24),
            left: resize(24),
            right: resize(24),
            child: BottomButton(
              onPressed: textController.text.length == 0 ||
                      textController.text.length > 250
                  ? null
                  : () {
                      completedDialog();
                    },
              text: AppStrings.of(StringKey.submit),
              textColor: AppColors.white,
            ))
      ],
    );
  }

  genderSelectView() {
    return Stack(
      children: [
        Positioned(
            top: resize(28),
            left: resize(20),
            right: resize(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: resize(24),
                  child: Text(
                    AppStrings.of(StringKey.what_is_your_gender),
                    style: AppTextStyle.from(
                        color: AppColors.darkGrey,
                        size: TextSize.body_medium,
                        weight: TextWeight.extrabold),
                    textAlign: TextAlign.center,
                  ),
                ),
                emptySpaceH(height: 24),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, idx) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              bloc.add(GenderSelectEvent(selectGender: idx));
                            },
                            style: ElevatedButton.styleFrom(
                                primary: bloc.selectGender == idx
                                    ? AppColors.darkGrey
                                    : AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                side: bloc.selectGender == idx
                                    ? null
                                    : BorderSide(color: AppColors.lightGrey04),
                                padding: EdgeInsets.zero,
                                elevation: 0),
                            child: Container(
                              width: genderWidth(genders[idx]),
                              height: resize(48),
                              child: Center(
                                child: Text(
                                  genders[idx],
                                  style: AppTextStyle.from(
                                      color: bloc.selectGender == idx
                                          ? AppColors.white
                                          : AppColors.darkGrey,
                                      size: TextSize.body_small,
                                      weight: TextWeight.semibold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )),
                        emptySpaceH(height: 16)
                      ],
                    );
                  },
                  shrinkWrap: true,
                  itemCount: genders.length,
                )
              ],
            )),
        Positioned(
            bottom: resize(24),
            left: resize(24),
            right: resize(24),
            child: BottomButton(
              onPressed: bloc.genderSelect
                  ? () {
                      bloc.add(GenderSelectFinishEvent());
                    }
                  : null,
              text: AppStrings.of(StringKey.continue_text),
              textColor:
                  bloc.genderSelect ? AppColors.white : AppColors.lightGrey03,
            ))
      ],
    );
  }

  genderWidth(text) {
    if (text == "Male") {
      return resize(90);
    } else if (text == "Female") {
      return resize(106);
    } else if (text == "Other") {
      return resize(96);
    }
  }

  evaluationView() {
    return Stack(
      children: <Widget>[
        topImage(),
        // evaluationProgress(),
        AnimatedPositioned(
          duration: Duration(milliseconds: 300),
          top: resize(bloc.scrollAnimationDataListTopHeight),
          left: resize(0),
          right: resize(0),
          child: AnimatedContainer(
            duration: Duration(seconds: 0),
            height: resize(MediaQuery.of(context).size.height -
                bloc.scrollAnimationDataListTopHeight -
                appbar.preferredSize.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: evaluationList(),
                ),
                Container(
                  height: resize(51),
                )
              ],
            ),
          ),
        ),
        Positioned(bottom: 0, child: footer())
      ],
    );
  }

  void evaluationBackMove() {
    if (bloc.scoreSave.length == 0 && bloc.progress == 0 && bloc.index == 1) {
      Navigator.of(context).pop();
    } else if (bloc.evaluationCheckFinish) {
      Navigator.of(context).pop();
    } else {
      bloc.add(EvaluationBackMoveEvent());
      evaluationListController.animateTo(0.0,
          duration: Duration(milliseconds: 100), curve: Curves.easeInOut);
    }
  }

  Widget topImage() {
    Widget imageWidget;
    if (bloc.evaluationData != null && bloc.evaluationData.length != 0) {
      switch (bloc.type) {
        case "Function":
          return imageWidget = image(bloc.evaluationData[bloc.progress].image);
        case "Life Style":
          return imageWidget = image(bloc.evaluationData[bloc.progress].image);
        case "General Healthcare":
          return imageWidget = image(bloc.evaluationData[bloc.progress].image);
        case "Social Activity":
          return imageWidget = image(bloc.evaluationData[bloc.progress].image);
        case "":
          return imageWidget = Container();
      }
    } else {
      imageWidget = Container();
    }

    return imageWidget;
  }

  Widget image(url) {
    return CachedNetworkImage(
      imageUrl: url,
      placeholder: (context, url) => Container(
        width: double.infinity,
        height: resize(200),
        color: AppColors.lightGrey02,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
          ),
        ),
      ),
      width: resize(MediaQuery.of(context).size.width),
      height: resize(200),
      fit: BoxFit.cover,
    );
  }

  Widget evaluationProgress() {
    return Container(
      width: double.infinity,
      height: resize(52),
      padding: EdgeInsets.only(left: resize(12), right: resize(12)),
      child: Center(
          child: ListView.builder(
        itemBuilder: (context, idx) {
          if (idx == 0) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[progressCircle(idx)],
            );
          } else {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[progressLine(idx), progressCircle(idx)],
            );
          }
        },
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: bloc.evaluationData.length,
      )),
    );
  }

  Widget progressCircle(num) {
    return ClipOval(
      child: Container(
        width: resize(20),
        height: resize(20),
        color: bloc.progress >= num ? AppColors.white : AppColors.white40,
        child: bloc.progress >= num
            ? Center(
                child: ClipOval(
                  child: Container(
                    width: resize(8),
                    height: resize(8),
                    color: AppColors.purple,
                  ),
                ),
              )
            : Container(),
      ),
    );
  }

  Widget progressLine(num) {
    return Container(
      width: resize(64),
      height: resize(2),
      color: bloc.progress >= num ? AppColors.white : AppColors.white40,
    );
  }

  Widget evaluationList() {
    return Container(
      width: resize(360),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(resize(24)),
              topRight: Radius.circular(resize(24)))),
      child: evaluationListData(),
    );
  }

  Widget evaluationListData() {
    return Stack(
      children: [
        Positioned.fill(
          top: resize(32),
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (notification) {
              notification.disallowGlow();
              return true;
            },
            child: ListView.builder(
              physics: ClampingScrollPhysics(),
              controller: evaluationListController,
              itemBuilder: (context, idx) {
                if (bloc.progress == idx) {
                  return Container(
                    padding: EdgeInsets.only(
                        left: resize(32),
                        right: resize(32),
                        top: resize(24),
                        bottom: resize(30)),
                    width: resize(MediaQuery.of(context).size.width),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        emptySpaceH(height: 12),
                        Container(
                          width: resize(296),
                          color: AppColors.white,
                          child: Text(
                            bloc.evaluationData[idx].question[bloc.index - 1]
                                .text,
                            style: AppTextStyle.from(
                                color: AppColors.blueGrey,
                                size: TextSize.body_medium,
                                weight: TextWeight.extrabold),
                            strutStyle: StrutStyle(leading: 0.65),
                          ),
                        ),
                        emptySpaceH(height: 24),
                        evaluationAnswerData(),
                        emptySpaceH(
                            height: MediaQuery.of(context).size.height / 5)
                      ],
                    ),
                  );
                }
                return Container();
              },
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: bloc.evaluationData.length,
            ),
          ),
        ),
        bloc.evaluationData.isEmpty
            ? Container()
            : Positioned(
                child: Column(
                  children: [
                    Container(
                      height: resize(56),
                      padding:
                          EdgeInsets.only(left: resize(32), right: resize(32)),
                      decoration: BoxDecoration(
                          color: AppColors.lightGrey01,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(resize(24)),
                              topRight: Radius.circular(resize(24)))),
                      child: Row(
                        children: [
                          Container(
                            child: Center(
                              child: Text(
                                bloc.evaluationData[bloc.progress].type ?? "",
                                style: AppTextStyle.from(
                                    color: AppColors.purple,
                                    size: TextSize.body_large,
                                    weight: TextWeight.extrabold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Expanded(child: Container()),
                          Container(
                            width: resize(26),
                            height: resize(20),
                            child: Center(
                              child: Text(
                                "${bloc.progress + 1}/${bloc.evaluationData.length}",
                                style: AppTextStyle.from(
                                    color: AppColors.grey,
                                    size: TextSize.caption_medium),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: resize(0.5),
                      color: AppColors.lightGrey04,
                    )
                  ],
                ),
              )
      ],
    );
  }

  int selectIdx;

  Widget evaluationAnswerData() {
    return ListView.builder(
      itemBuilder: (context, idx) {
        var span = TextSpan(
          text: bloc.evaluationData[bloc.progress].question[bloc.index - 1]
              .answer[idx].label,
          style: AppTextStyle.from(
              size: TextSize.body_small, weight: TextWeight.semibold),
        );

        var tp = TextPainter(
            maxLines: 1,
            textAlign: TextAlign.start,
            textDirection: TextDirection.ltr,
            text: span);

        tp.layout(maxWidth: resize(248));

        var exceeded = tp.didExceedMaxLines;

        Color color = AppColors.darkGrey;
        if (selectIdx == null) {
          color = AppColors.darkGrey;
        } else if (selectIdx == idx) {
          color = AppColors.white;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: resize(exceeded ? 66 : 44),
              child: RaisedButton(
                onPressed: () {
                  nextQuestion(
                    bloc.evaluationData[bloc.progress].question.length,
                    type: bloc.evaluationData[bloc.progress].type,
                    selectIdx: idx,
                  );
                },
                onHighlightChanged: (value) {
                  setState(() {
                    if (value) {
                      selectIdx = idx;
                    } else {
                      selectIdx = null;
                    }
                  });
                },
                child: Center(
                  child: Container(
                    width: resize(248),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        bloc.evaluationData[bloc.progress]
                            .question[bloc.index - 1].answer[idx].label,
                        style: AppTextStyle.from(
                            color: color,
                            size: TextSize.body_small,
                            weight: TextWeight.semibold),
                        textAlign: TextAlign.left,
                        strutStyle: StrutStyle(leading: 0.4),
                      ),
                    ),
                  ),
                ),
                elevation: 0.0,
                highlightColor: AppColors.purple,
                highlightElevation: 0.0,
                color: AppColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        exceeded ? resize(24) : resize(50)),
                    side: BorderSide(width: 1, color: AppColors.lightGrey04)),
              ),
            ),
            emptySpaceH(height: 14)
          ],
        );
      },
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: bloc
          .evaluationData[bloc.progress].question[bloc.index - 1].answer.length,
    );
  }

  void nextQuestion(length, {type, selectIdx}) {
    if (bloc.progress == 0 && bloc.index == 1) {
      bloc.userLevel = bloc.evaluationData[bloc.progress]
          .question[bloc.index - 1].answer[selectIdx].type;
    } else if (bloc.progress == 0 && bloc.index == 2) {
      bloc.userMobility = bloc.evaluationData[bloc.progress]
          .question[bloc.index - 1].answer[selectIdx].type;
    }
    saveEvaluationScore(type, selectIdx);
    if (length == bloc.index) {
      if (bloc.evaluationData.length == bloc.progress + 1) {
        if (widget.checkStatus == 1) {
          completedDialog();
        } else {
          bloc.add(EvaluationFinishEvent());
        }
      } else {
        bloc.add(EvaluationProgressChangeEvent());
        evaluationListController.animateTo(0.0,
            duration: Duration(milliseconds: 100), curve: Curves.easeInOut);
      }
    } else {
      bloc.add(EvaluationAnswerSelectEvent());
      evaluationListController.animateTo(0.0,
          duration: Duration(milliseconds: 100), curve: Curves.easeInOut);
    }
  }

  void saveEvaluationScore(type, selectIdx) {
    double score = getScore(selectIdx);

    bloc.scoreSave.add(score);

    if (bloc.evaluationSelectAnswer[bloc.progress].typeSelect == type) {
      bloc.evaluationSelectAnswer[bloc.progress].scoreSum += score;
      bloc.typeIndex[bloc.progress] += 1;
    }
  }

  getScore(selectIdx) {
    switch (selectIdx) {
      case 0:
        return 1.0;
      case 1:
        return 2.0;
      case 2:
        return 3.0;
      case 3:
        return 4.0;
      case 4:
        return 5.0;
    }
  }

  Widget footer() {
    return Container(
      width: resize(MediaQuery.of(context).size.width),
      height: resize(51),
      color: AppColors.white,
      child: Column(
        children: <Widget>[
          Container(
            width: resize(MediaQuery.of(context).size.width),
            height: resize(1),
            color: AppColors.lightGrey04,
          ),
          Container(
            width: resize(MediaQuery.of(context).size.width),
            height: resize(50),
            padding: EdgeInsets.only(left: resize(32), right: resize(32)),
            color: AppColors.white,
            child: Row(
              children: <Widget>[
                Container(
                    width: resize(260),
                    height: resize(8),
                    child: LinearPercentIndicator(
                      width: resize(260),
                      lineHeight: resize(8),
                      percent: (bloc.evaluationData.length == 0
                              ? 0.0
                              : bloc.index /
                                  bloc.evaluationData[bloc.progress].question
                                      .length)
                          .toDouble(),
                      linearStrokeCap: LinearStrokeCap.roundAll,
                      animation: true,
                      animateFromLastPercent: true,
                      backgroundColor: AppColors.lightGrey02,
                      progressColor: AppColors.purple,
                      animationDuration: 200,
                    )),
                emptySpaceW(width: 10),
                Container(
                  width: resize(26),
                  height: resize(20),
                  color: AppColors.white,
                  child: Center(
                    child: Text(
                        bloc.evaluationData.length == 0
                            ? ""
                            : "${bloc.index}/${bloc.evaluationData[bloc.progress].question.length}",
                        style: AppTextStyle.from(
                            color: AppColors.black,
                            size: TextSize.caption_medium,
                            weight: TextWeight.medium)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  completedDialog() {
    showDialog(
        barrierDismissible: false,
        context: (context),
        builder: (_) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: Dialog(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(resize(32)),
                    topRight: Radius.circular(resize(32)),
                    bottomLeft: Radius.circular(resize(40)),
                    bottomRight: Radius.circular(resize(40))),
              ),
              backgroundColor: AppColors.white,
              child: Container(
                width: resize(312),
                height: resize(272),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    emptySpaceH(height: 32),
                    Image.asset(
                      AppImages.ic_check_circle_green,
                      width: resize(64),
                      height: resize(64),
                    ),
                    emptySpaceH(height: 16),
                    Container(
                      width: resize(264),
                      height: resize(54),
                      color: AppColors.white,
                      child: Center(
                        child: Text(
                          AppStrings.of(StringKey.stroke_evaluation_complete),
                          style: AppTextStyle.from(
                              size: TextSize.body_large,
                              color: AppColors.darkGrey,
                              weight: TextWeight.bold),
                          textAlign: TextAlign.center,
                          strutStyle: StrutStyle(leading: 0.55),
                        ),
                      ),
                    ),
                    emptySpaceH(height: 34),
                    Container(
                      width: resize(MediaQuery.of(context).size.width),
                      height: resize(72),
                      child: RaisedButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                            bloc.add(DataInputEvent(
                                context: context,
                                checkStatus: widget.checkStatus,
                                wishMessage: textController.text));
                          },
                          color: AppColors.lightPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(resize(32)),
                                bottomRight: Radius.circular(resize(32))),
                          ),
                          elevation: 0,
                          child: Center(
                            child: Container(
                              width: resize(160),
                              height: resize(23.6),
                              child: Center(
                                child: Text(
                                  AppStrings.of(StringKey.confirm),
                                  style: AppTextStyle.from(
                                      color: AppColors.white,
                                      size: TextSize.body_small,
                                      weight: TextWeight.semibold),
                                ),
                              ),
                            ),
                          )),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _buildProgress(BuildContext context) {
    if (!bloc.isLoading && !bloc.loading) return Container();

    return FullscreenDialog();
  }

  void blocListener(BuildContext context, state) {}

  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
      cubit: bloc,
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: AppColors.white,
          appBar: appbar = _buildAppBar(context),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Stack(
              children: <Widget>[
                SingleChildScrollView(child: _buildMainWidget(context)),
                _buildProgress(context)
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  EvaluationBloc initBloc() {
    // TODO: implement initBloc
    return EvaluationBloc(context)..add(EvaluationInitEvent());
  }
}
