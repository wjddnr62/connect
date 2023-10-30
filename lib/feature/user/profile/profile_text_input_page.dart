import 'package:connect/feature/user/profile/profile_text_input_bloc.dart';
import 'package:connect/models/profile.dart';
import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/resources/app_strings.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileTextInputPage extends BlocStatefulWidget {
  static const String ROUTE_NAME = '/profile_text_input_page';

  final Profile profile;
  final String text;
  final int type;

  ProfileTextInputPage({this.profile, this.text, this.type});

  static Future<Object> push(BuildContext context, profile, text, type) =>
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ProfileTextInputPage(
                profile: profile,
                text: text,
                type: type,
              )));

  @override
  ProfileTextInputState buildState() => ProfileTextInputState();
}

class ProfileTextInputState
    extends BlocState<ProfileTextInputBloc, ProfileTextInputPage> {
  final textInputController = TextEditingController();
  String saveText;

  buildProgress(BuildContext context) {
    if (!bloc.loading) return Container();

    return FullscreenDialog();
  }

  @override
  Widget blocBuilder(BuildContext context, state) {
    // TODO: implement blocBuilder
    return BlocBuilder(
        cubit: bloc,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
                automaticallyImplyLeading: true,
                leadingWidth: 100,
                elevation: 0.0,
                backgroundColor: AppColors.white,
                leading: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Center(
                    child: Text(
                      AppStrings.of(StringKey.cancel),
                      style: AppTextStyle.from(
                          color: AppColors.darkGrey,
                          size: TextSize.caption_medium,
                          weight: TextWeight.semibold),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: EdgeInsets.only(right: resize(16)),
                    child: Center(
                      child: InkWell(
                        onTap: () {
                          if (textInputController.text.length <= 60) {
                            if (widget.type == 0) {
                              if (textInputController.text.length > 0)
                              bloc.add(ProfileUpdateEvent(
                                  profile: widget.profile,
                                  name: textInputController.text ?? ""));
                            } else {
                              bloc.add(ProfileUpdateEvent(
                                  profile: widget.profile,
                                  statusMessage: textInputController.text ?? ""));
                            }
                          }
                        },
                        child: Text(
                          AppStrings.of(StringKey.confirm),
                          style: AppTextStyle.from(
                              color: AppColors.darkGrey,
                              size: TextSize.caption_medium,
                              weight: TextWeight.semibold),
                        ),
                      ),
                    ),
                  )
                ]),
            resizeToAvoidBottomInset: true,
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      color: AppColors.white,
                      padding: EdgeInsets.only(
                          left: resize(24),
                          right: resize(24),
                          top: resize(MediaQuery.of(context).size.height / 3),
                          bottom:
                              resize(MediaQuery.of(context).size.height / 3)),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                                    height: 1.3),
                                decoration: InputDecoration(
                                    counterText: "",
                                    suffixIconConstraints: BoxConstraints(
                                        maxWidth: 40, maxHeight: 40),
                                    suffixIcon: Padding(
                                      padding: EdgeInsets.zero,
                                      child: IconButton(
                                        onPressed: () {
                                          textInputController.clear();
                                          setState(() {});
                                        },
                                        icon: Image.asset(
                                          AppImages.ic_delete_circle,
                                        ),
                                      ),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: (widget.type == 0 && textInputController.text.length == 0) || textInputController
                                                        .text.length >
                                                    60
                                                ? AppColors.error
                                                : AppColors.lightGrey04)),
                                    border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: (widget.type == 0 && textInputController.text.length == 0) || textInputController
                                                        .text.length >
                                                    60
                                                ? AppColors.error
                                                : AppColors.lightGrey04)),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                            (widget.type == 0 && textInputController.text.length == 0) || textInputController.text.length >
                                                        60
                                                    ? AppColors.error
                                                    : AppColors.purple)),
                                    isDense: true,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 8))),
                            emptySpaceH(height: 8),
                            Container(
                              height: resize(16),
                              child: Center(
                                child: Text(
                                  "${textInputController.text.length}/60",
                                  style: AppTextStyle.from(
                                      size: TextSize.caption_small,
                                      color:
                                          textInputController.text.length > 60
                                              ? AppColors.error
                                              : AppColors.grey),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                buildProgress(context)
              ],
            ),
          );
        });
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is TextSetState) {
      textInputController.text = widget.text;
    }

    if (state is ProfileUpdateState) {
      Navigator.of(context).pop();
    }
  }

  @override
  ProfileTextInputBloc initBloc() {
    // TODO: implement initBloc
    return ProfileTextInputBloc(context)..add(ProfileTextInputInitEvent());
  }
}
