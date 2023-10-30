import 'dart:async';
import 'dart:math';

import 'package:connect/feature/mission/quiz_mission_bloc.dart';
import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_images.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/bottons/bottom_button.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multiscreen/multiscreen.dart';
import 'package:share/share.dart';

import 'common_mission_bloc.dart';
import 'mission_complete_button.dart';

class QuizMissionPage extends BlocStatefulWidget {
  final CommonMissionBloc commonMissionBloc;
  final DateTime date;

  QuizMissionPage({this.commonMissionBloc, this.date});

  static Future<Object> push(BuildContext context,
          {CommonMissionBloc bloc, DateTime date}) =>
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => QuizMissionPage(
                commonMissionBloc: bloc,
              )));

  @override
  QuizMissionState buildState() => QuizMissionState();
}

class QuizMissionState extends BlocState<QuizMissionBloc, QuizMissionPage> {
  final textInputController = TextEditingController();

  Timer _exitTimer;

  List<String> answerText = [
    AppStrings.of(StringKey.that_s_right),
    AppStrings.of(StringKey.you_did_it),
    AppStrings.of(StringKey.well_done),
    AppStrings.of(StringKey.yes_good_job),
    AppStrings.of(StringKey.great_good_job),
    AppStrings.of(StringKey.congrats_you_did_it),
    AppStrings.of(StringKey.yes_that_s_right),
    AppStrings.of(StringKey.you_did_a_great_job),
    AppStrings.of(StringKey.your_answer_is_correct)
  ];

  customTabBar(context, safeTop) {
    return Container(
      height: resize(100),
      decoration: BoxDecoration(
          image: DecorationImage(
              image: ExactAssetImage(AppImages.img_quiz_bg_top),
              fit: BoxFit.cover)),
      child: Stack(
        children: [
          // Positioned(
          //   top: 0,
          //   left: 0,
          //   right: 0,
          //   child: Image.asset(
          //     AppImages.img_quiz_bg_top,
          //     width: MediaQuery.of(context).size.width,
          //     height: resize(100),
          //   ),
          // ),
          Positioned(
              top: resize(safeTop + 10),
              left: resize(12),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Image.asset(
                  AppImages.ic_chevron_left,
                  width: resize(24),
                  height: resize(24),
                  color: AppColors.white,
                ),
              )),
          Positioned(
            top: resize(safeTop + 10),
            right: resize(12),
            child: (bloc.missionDetail.shareLink != null &&
                    bloc.missionDetail.shareLink != "")
                ? GestureDetector(
                    onTap: () {
                      Share.share(bloc.missionDetail.shareLink);
                    },
                    child: Container(
                      height: resize(24),
                      child: Image.asset(
                        AppImages.ic_share,
                        width: resize(24),
                        height: resize(24),
                        color: AppColors.black,
                      ),
                    ),
                  )
                : Container(),
          ),
          Positioned(
              left: 0,
              right: 0,
              top: resize(safeTop + 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    // width: resize(80),
                    height: resize(44),
                    child: Center(
                      child: Text(
                        AppStrings.of(StringKey.quiz),
                        style: AppTextStyle.from(
                            color: AppColors.white,
                            weight: TextWeight.extrabold,
                            size: TextSize.title_large),
                      ),
                    ),
                  ),
                  emptySpaceW(width: 5),
                  Image.asset(
                    AppImages.img_quiz_question,
                    width: resize(27),
                  )
                ],
              ))
        ],
      ),
    );
  }

  topImage(image) {
    return Image.asset(
      image,
      width: resize(160),
      height: resize(178),
    );
  }

  oxQuiz(context) {
    return Column(
      children: [
        bloc.answerDialog
            ? Container()
            : ListView.builder(
                itemBuilder: (context, idx) {
                  return Container(
                    child: bloc.htmlList[idx],
                  );
                },
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: bloc.htmlList.length,
              ),
        emptySpaceH(height: 38),
        Padding(
          padding: EdgeInsets.only(left: resize(24), right: resize(24)),
          child: Row(
            children: [oxButton(0), emptySpaceW(width: 20), oxButton(1)],
          ),
        ),
        emptySpaceH(height: 32)
      ],
    );
  }

  oxButton(type) {
    return Container(
      width: resize(146),
      height: resize(188),
      child: Stack(
        children: [
          ElevatedButton(
              onPressed: () {
                if (bloc.selectAnswer == null) {
                  bloc.add(OXButtonSelectEvent(selectAnswer: type));
                }
              },
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  primary: buttonColor(type),
                  side: type == bloc.selectAnswer
                      ? null
                      : BorderSide(color: AppColors.purple, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0),
              child: Center(
                child: Image.asset(
                  oxButtonImage(type),
                  width: resize(78),
                  height: resize(78),
                ),
              )),
        ],
      ),
    );
  }

  oxButtonImage(type) {
    if (type != bloc.selectAnswer) {
      if (type == 0) {
        return AppImages.img_o;
      } else if (type == 1) {
        return AppImages.img_x;
      }
    } else if (type == bloc.selectAnswer && bloc.selectAnswer == bloc.answer) {
      if (type == 0) {
        return AppImages.img_o_white;
      } else if (type == 1) {
        return AppImages.img_x_white;
      }
    } else if (type == bloc.selectAnswer && bloc.selectAnswer != bloc.answer) {
      if (type == 0) {
        return AppImages.img_o_white;
      } else if (type == 1) {
        return AppImages.img_x_white;
      }
    }
  }

  buttonColor(type) {
    if (type != bloc.selectAnswer) {
      return AppColors.white;
    } else if (type == bloc.selectAnswer && bloc.selectAnswer == bloc.answer) {
      return AppColors.green;
    } else if (type == bloc.selectAnswer && bloc.selectAnswer != bloc.answer) {
      return AppColors.error;
    }
  }

  multipleQuiz(context) {
    return Column(
      children: [
        emptySpaceH(height: 24),
        bloc.answerDialog
            ? Container()
            : ListView.builder(
                itemBuilder: (context, idx) {
                  return Container(
                    child: bloc.htmlList[idx],
                  );
                },
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: bloc.htmlList.length,
              ),
        emptySpaceH(height: 24),
        multipleButton(0),
        emptySpaceH(height: 14),
        multipleButton(1),
        emptySpaceH(height: 14),
        multipleButton(2),
        emptySpaceH(height: 14),
        multipleButton(3),
        emptySpaceH(height: 32),
      ],
    );
  }

  multipleTextColor(type) {
    if (type != bloc.selectAnswer) {
      return AppColors.purple;
    } else if (type == bloc.selectAnswer && bloc.selectAnswer == bloc.answer) {
      return AppColors.white;
    } else if (type == bloc.selectAnswer && bloc.selectAnswer != bloc.answer) {
      return AppColors.white;
    }
  }

  multipleBubble(type) {
    if (type == bloc.selectAnswer && bloc.selectAnswer == bloc.answer) {
      return Positioned(
        top: resize(18),
        bottom: resize(18),
        right: resize(16),
        child: Image.asset(
          AppImages.ic_check_circle_fill_quiz,
          width: resize(24),
          height: resize(24),
        ),
      );
    } else if (type == bloc.selectAnswer && bloc.selectAnswer != bloc.answer) {
      return Positioned(
        top: resize(18),
        bottom: resize(18),
        right: resize(16),
        child: Image.asset(
          AppImages.ic_delete_circle_quiz,
          width: resize(24),
          height: resize(24),
        ),
      );
    } else {
      return Container();
    }
  }

  multipleButton(type) {
    return Padding(
        padding: EdgeInsets.only(left: resize(24), right: resize(24)),
        child: Stack(
          children: [
            ElevatedButton(
                onPressed: () {
                  if (bloc.selectAnswer == null) {
                    bloc.add(MultipleButtonSelectEvent(selectAnswer: type));
                  }
                },
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    primary: buttonColor(type),
                    side: type == bloc.selectAnswer
                        ? null
                        : BorderSide(color: AppColors.purple, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    padding: EdgeInsets.only(
                        left: resize(24),
                        right: resize(24),
                        top: resize(15),
                        bottom: resize(15)),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        bloc.answerDialog
                            ? ""
                            : bloc.quiz[bloc.quizNum].answerList != null
                                ? bloc.quiz[bloc.quizNum].answerList.length <
                                        type
                                    ? ""
                                    : bloc.quiz[bloc.quizNum].answerList[type]
                                            .text ??
                                        ""
                                : "",
                        style: AppTextStyle.from(
                            color: multipleTextColor(type),
                            size: TextSize.body_small,
                            weight: TextWeight.bold,
                            height: 1.3),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                )),
            multipleBubble(type)
          ],
        ));
  }

  descriptiveQuiz(context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height -
            resize(100) -
            MediaQuery.of(context).padding.bottom,
        color: AppColors.white,
        child: Stack(
          children: [
            Positioned(
                top: 0,
                left: resize(32),
                right: resize(32),
                bottom: resize(100),
                child: NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (notification) {
                      notification.disallowGlow();
                      return true;
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          emptySpaceH(height: 24),
                          Center(
                            child: topImage(AppImages.img_right_answer),
                          ),
                          emptySpaceH(height: 24),
                          Text(
                            "What is cause of stroke?",
                            style: AppTextStyle.from(
                                color: AppColors.black,
                                size: TextSize.body_medium,
                                weight: TextWeight.semibold,
                                height: 1.3),
                          ),
                          emptySpaceH(height: 32),
                          TextFormField(
                              onChanged: (value) {
                                setState(() {});
                              },
                              controller: textInputController,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
                              minLines: 1,
                              maxLines: null,
                              style: AppTextStyle.from(
                                  color: AppColors.black,
                                  size: TextSize.caption_large,
                                  height: 1.6),
                              decoration: InputDecoration(
                                  hintText: AppStrings.of(
                                      StringKey.please_enter_your_answer),
                                  hintStyle: AppTextStyle.from(
                                      color: AppColors.lightGrey02,
                                      size: TextSize.caption_large,
                                      height: 1.6),
                                  counterText: "",
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              textInputController.text.length > 100
                                                  ? AppColors.error
                                                  : AppColors.lightGrey04)),
                                  border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              textInputController.text.length > 100
                                                  ? AppColors.error
                                                  : AppColors.lightGrey04)),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: textInputController.text.length > 100 ? AppColors.error : AppColors.purple)),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 8))),
                          emptySpaceH(height: 8),
                          Container(
                            height: resize(16),
                            child: Center(
                              child: Text(
                                "${textInputController.text.length}/100",
                                style: AppTextStyle.from(
                                    size: TextSize.caption_small,
                                    color: textInputController.text.length > 100
                                        ? AppColors.error
                                        : AppColors.grey),
                              ),
                            ),
                          )
                        ],
                      ),
                    ))),
            Positioned(
                bottom: resize(32),
                left: resize(24),
                right: resize(24),
                child: BottomButton(
                  onPressed: (textInputController.text.length > 100 ||
                          textInputController.text.length == 0)
                      ? null
                      : () {
                          bloc.add(DescriptiveSubmitEvent(
                              answer: textInputController.text));
                        },
                  text: AppStrings.of(StringKey.submit),
                  textColor: textInputController.text.length > 100
                      ? AppColors.lightGrey03
                      : AppColors.white,
                ))
          ],
        ));
  }

  descriptionPage(context, state) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height -
          resize(100) -
          MediaQuery.of(context).padding.bottom,
      color: AppColors.white,
      child: Stack(
        children: [
          Positioned(
              top: 0,
              left: resize(32),
              right: resize(32),
              bottom: resize(76),
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (notification) {
                  notification.disallowGlow();
                  return true;
                },
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      emptySpaceH(height: 40),
                      Image.asset(
                        AppImages.img_answer,
                        width: resize(104),
                        height: resize(98),
                      ),
                      emptySpaceH(height: 16),
                      ListView.builder(
                        itemBuilder: (context, idx) {
                          return Container(
                            child: bloc.htmlList[idx],
                          );
                        },
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: bloc.htmlList.length,
                      ),
                      emptySpaceH(height: 24)
                    ],
                  ),
                ),
              )),
          bloc.finishPage &&
                  (bloc.missionDetail.shareLink != null &&
                      bloc.missionDetail.shareLink != "")
              ? Positioned(
                  child: GestureDetector(
                    onTap: () {
                      Share.share(bloc.missionDetail.shareLink);
                    },
                    child: Container(
                      height: resize(24),
                      padding: EdgeInsets.only(left: resize(24)),
                      child: Row(
                        children: [
                          Image.asset(
                            AppImages.ic_share,
                            width: resize(24),
                            height: resize(24),
                            color: AppColors.orange,
                          ),
                          emptySpaceW(width: 8),
                          Text(
                            AppStrings.of(StringKey.share),
                            style: AppTextStyle.from(
                                color: AppColors.orange,
                                size: TextSize.caption_medium,
                                weight: TextWeight.semibold),
                          )
                        ],
                      ),
                    ),
                  ),
                  bottom: resize(110),
                )
              : Container(),
          bloc.finishPage
              ? Positioned(
                  bottom: resize(24),
                  left: resize(24),
                  right: resize(24),
                  child: bloc.isLoading
                      ? Container()
                      : MissionCompleteButton(
                          processing: state is StateProcessingQuiz,
                          mission: widget.commonMissionBloc.mission,
                          onPressed: () {
                            bloc.add(bloc.commonBloc.mission.completed
                                ? EventUndoQuiz()
                                : EventCompleteQuiz());
                          }))
              : Positioned(
                  bottom: resize(24),
                  left: resize(24),
                  right: resize(24),
                  child: BottomButton(
                    onPressed: () {
                      bloc.add(NextButtonClickEvent());
                    },
                    text: AppStrings.of(StringKey.next),
                  ))
        ],
      ),
    );
  }

  viewQuiz({state}) {
    if (bloc.quizType == "OX") {
      return oxQuiz(context);
    } else if (bloc.quizType == "CHOICE") {
      return multipleQuiz(context);
    } else if (bloc.quizType == "SUBJECTIVE") {
      return descriptiveQuiz(context);
    } else if (bloc.quizType == "description") {
      return descriptionPage(context, state);
    }
  }

  buildProgress(BuildContext context) {
    // if (!bloc.isLoading) return Container();

    return FullscreenDialog();
  }

  @override
  Widget blocBuilder(BuildContext context, state) {
    double safeTop = MediaQuery.of(context).padding.top;
    return BlocConsumer(
        listener: (context, state) {
          if (state is StateCompleteQuiz) {
            _exitTimer = Timer(Duration(milliseconds: 500), () {
              if (mounted) {
                popWithResult(context, true);
              }
            });
          }
        },
        cubit: bloc,
        builder: (context, state) {
          return bloc.isLoading
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: AppColors.white,
                  child: Center(
                    child: FullscreenDialog(),
                  ),
                )
              : Scaffold(
                  resizeToAvoidBottomInset: true,
                  backgroundColor: AppColors.white,
                  body: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      children: [
                        Positioned(
                          top: resize(100),
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [viewQuiz(state: state)],
                            ),
                          ),
                        ),
                        Positioned(
                            left: 0,
                            right: 0,
                            top: resize(0),
                            child: customTabBar(context, safeTop)),
                      ],
                    ),
                  ),
                );
        });
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is AnswerState) {
      answerDialog(context);
      if (state.next) {
        Timer(Duration(milliseconds: 2000), () {
          Navigator.of(context, rootNavigator: true).pop();
          bloc.answerDialog = false;
          bloc.htmlAdd(bloc.descriptionText);
          bloc.add(QuizTypeChangeEvent(type: bloc.nextQuizType));
        });
      } else {
        Timer(Duration(milliseconds: 2000), () {
          Navigator.of(context, rootNavigator: true).pop();
          bloc.answerDialog = false;
          bloc.add(widget.commonMissionBloc.mission.completed
              ? EventUndoQuiz()
              : EventCompleteQuiz());
        });
      }
    }

    if (state is WrongAnswerState) {
      wrongAnswerDialog(context);
    }
  }

  answerDialog(context) {
    var random = Random();
    String answerText = this.answerText[random.nextInt(9)];

    return showDialog(
        barrierDismissible: true,
        context: (context),
        builder: (_) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: Dialog(
              elevation: 0,
              insetPadding: EdgeInsets.zero,
              backgroundColor: AppColors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: resize(288),
                padding: EdgeInsets.only(left: resize(24), right: resize(24)),
                child: Stack(
                  children: [
                    Positioned(
                        top: resize(16),
                        left: 0,
                        right: 0,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: resize(272),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              color: AppColors.white),
                        )),
                    Positioned(
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            Image.asset(
                              AppImages.img_right_answer,
                              width: resize(260),
                              height: resize(204),
                            ),
                            emptySpaceH(height: 20),
                            Text(
                              answerText,
                              style: AppTextStyle.from(
                                  color: AppColors.purple,
                                  size: TextSize.title_medium,
                                  weight: TextWeight.bold),
                            )
                          ],
                        ))
                  ],
                ),
              ),
            ),
          );
        });
  }

  wrongAnswerDialog(context) {
    return showDialog(
        barrierDismissible: true,
        context: (context),
        builder: (_) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: Dialog(
              elevation: 0,
              insetPadding: EdgeInsets.zero,
              backgroundColor: AppColors.transparent,
              child: Padding(
                padding: EdgeInsets.only(left: resize(24), right: resize(24)),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: resize(272),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: AppColors.white),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          emptySpaceH(height: 32),
                          Image.asset(
                            AppImages.ic_redo_quiz,
                            width: resize(64),
                            height: resize(64),
                          ),
                          emptySpaceH(height: 16),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: resize(54),
                            padding: EdgeInsets.only(
                                left: resize(24), right: resize(24)),
                            child: Text(
                              AppStrings.of(
                                  StringKey.why_dont_we_think_about_it_again),
                              style: AppTextStyle.from(
                                  size: TextSize.body_large,
                                  color: AppColors.black,
                                  weight: TextWeight.bold,
                                  height: 1.3),
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                            bloc.add(TryAgainEvent());
                          },
                          child: Container(
                            height: resize(72),
                            child: Center(
                              child: Text(
                                AppStrings.of(StringKey.try_again),
                                style: AppTextStyle.from(
                                    color: AppColors.white,
                                    size: TextSize.body_small,
                                    weight: TextWeight.semibold),
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              primary: AppColors.lightPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(32),
                                    bottomRight: Radius.circular(32)),
                              ),
                              elevation: 0),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  @override
  QuizMissionBloc initBloc() {
    return QuizMissionBloc(context, widget.commonMissionBloc)
      ..add(QuizMissionInitEvent(
          bloc: widget.commonMissionBloc, context: context));
  }
}
