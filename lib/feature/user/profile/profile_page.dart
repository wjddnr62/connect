import 'package:cached_network_image/cached_network_image.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/feature/user/profile/profile_character_page.dart';
import 'package:connect/feature/user/profile/profile_text_input_page.dart';
import 'package:connect/models/profile.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:connect/utils/extensions.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:connect/widgets/pages/error_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'profile_page_bloc.dart';

class ProfilePage extends BlocStatefulWidget {
  static const String ROUTE_NAME = '/profile_page';

  static Future<Object> push(BuildContext context) =>
      Navigator.of(context).pushNamed(ROUTE_NAME);

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() => _ProfileState();
}

class _ProfileState extends BlocState<ProfilePageBloc, ProfilePage> {
  Profile profile;

  String genderValue = "";

  @override
  ProfilePageBloc initBloc() {
    return ProfilePageBloc()..add(LoadProfile());
  }

  buildProgress(BuildContext context) {
    if (!bloc.loading) return Container();

    return FullscreenDialog();
  }

  @override
  blocBuilder(BuildContext context, state) {
    var container;
    if (state is ProfileLoading) {
      container = Container();
    }

    if (state is ProfileLoadingError) {
      // container = ErrorPage(error: state.error);
    }

    if (state is ProfileLoaded) {
      imageCache.clear();
      profile = state.profile;

      if (profile != null) {
        genderValue = profile.gender.nullToEmpty();
        container = buildProfileWidget(context);
      } else {
        //TO DO
      }
    }

    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop(profile);
        return null;
      },
      child: Scaffold(
          appBar: baseAppBar(context, title: StringKey.profile.getString(),
              onLeadPressed: () {
            Navigator.of(context).pop(profile);
          }),
          resizeToAvoidBottomInset: true,
          backgroundColor: AppColors.white,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: container,
              ),
              buildProgress(context)
            ],
          )),
    );
  }

  setProfileImage(name) {
    if (name == "EMPATHY") {
      return AppImages.img_sympathy;
    } else if (name == "LOVE") {
      return AppImages.img_love;
    } else if (name == "HAPPINESS") {
      return AppImages.img_happiness;
    } else if (name == "HOPE") {
      return AppImages.img_hope;
    } else if (name == "AUTONOMY") {
      return AppImages.img_autonomy;
    }
  }

  profileImage() {
    return Container(
      height: resize(76),
      child: Stack(
        children: [
          Positioned(
            child: Align(
              alignment: Alignment.topCenter,
              child: ClipOval(
                child: Container(
                  color: AppColors.black,
                  child: profile.profileImageName == "IMAGE"
                      ? Image.network(
                          profile.image,
                          width: resize(72),
                          height: resize(72),
                          fit: BoxFit.cover,
                        )
                      : profile.profileImageName != "IMAGE"
                          ? profile.profileImageName != null
                              ? Image.asset(
                                  setProfileImage(profile.profileImageName),
                                  width: resize(72),
                                  height: resize(72),
                                )
                              : Image.asset(
                                  AppImages.ic_group_fill,
                                  width: resize(72),
                                  height: resize(72),
                                  fit: BoxFit.cover,
                                )
                          : Image.asset(
                              AppImages.ic_group_fill,
                              width: resize(72),
                              height: resize(72),
                              fit: BoxFit.cover,
                            ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: (MediaQuery.of(context).size.width / 2) - resize(78),
            child: Container(
              width: resize(36),
              height: resize(36),
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.lightGrey04),
                  borderRadius: BorderRadius.all(Radius.circular(36))),
              child: ClipOval(
                child: Material(
                  color: AppColors.lightGrey01,
                  child: InkWell(
                    onTap: () {
                      ProfileCharacterPage.push(context, profile.name, profile)
                          .then((value) {
                        bloc.add(LoadProfile());
                      });
                    },
                    splashColor: AppColors.grey,
                    child: Container(
                      width: resize(36),
                      height: resize(36),
                      child: Center(
                        child: Image.asset(
                          AppImages.ic_camera,
                          width: resize(24),
                          height: resize(24),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  profileItem(typeText) {
    return GestureDetector(
      onTap: () {
        profileEvent(typeText);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: resize(19),
            child: Text(
              typeText,
              style: AppTextStyle.from(
                  color: AppColors.grey, size: TextSize.caption_medium),
            ),
          ),
          emptySpaceH(height: 3),
          typeText == "Gender"
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    genderValue,
                    style: AppTextStyle.from(
                        size: TextSize.caption_large,
                        color: AppColors.black,
                        height: 1),
                  ),
                )
              : Container(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    profileValue(typeText),
                    style: AppTextStyle.from(
                        size: TextSize.caption_large,
                        color: profileValue(typeText) ==
                                AppStrings.of(
                                    StringKey.please_set_the_status_message)
                            ? AppColors.lightGrey03
                            : typeText == "Email"
                                ? AppColors.grey
                                : AppColors.black,
                        height: typeText == "Status message" ? 1.3 : 1),
                  ),
                ),
          emptySpaceH(height: 14),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 1,
            color: AppColors.lightGrey04,
          )
        ],
      ),
    );
  }

  profileEvent(typeText) {
    if (typeText != "Email") {
      if (typeText == "Name") {
        ProfileTextInputPage.push(context, profile, profile.name, 0)
            .then((value) {
          bloc.add(LoadProfile());
        });
      } else if (typeText == "Status message") {
        ProfileTextInputPage.push(context, profile, profile.statusMessage, 1)
            .then((value) {
          bloc.add(LoadProfile());
        });
      } else if (typeText == "Date of birth") {
        DatePicker.showDatePicker(context,
            showTitleActions: true,
            minTime: DateTime(1920, 1, 1),
            maxTime: DateTime(DateTime.now().year, 12, 31), onConfirm: (date) {
          bloc.add(ProfileUpdateEvent(
              profile: profile,
              date:
                  "${date.year}-${date.month.toString().length == 1 ? "0" + date.month.toString() : date.month}-${date.day.toString().length == 1 ? "0" + date.day.toString() : date.day}"));
        }, currentTime: DateTime.now(), locale: LocaleType.en);
      } else if (typeText == "Gender") {
        genderSelectDialog(context);
      }
    }
  }

  profileValue(type) {
    switch (type) {
      case "Name":
        return profile.name.nullToEmpty();
        break;
      case "Status message":
        return profile.statusMessage.nullToEmpty() == ""
            ? AppStrings.of(StringKey.please_set_the_status_message)
            : profile.statusMessage.nullToEmpty();
        break;
      case "Email":
        return profile.email.nullToEmpty().contains("*")
            ? profile.email.nullToEmpty().split("*")[1]
            : profile.email.nullToEmpty();
        break;
      case "Date of birth":
        return profile?.birthday?.toMonthDayCommaYear() ?? "";
        break;
      case "Gender":
        return profile.gender.nullToEmpty();
        break;
      default:
        break;
    }
  }

  Widget buildProfileWidget(context) {
    return Container(
        padding: EdgeInsets.only(
          left: resize(24),
          right: resize(24),
        ),
        color: AppColors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            emptySpaceH(height: 8),
            Align(
              alignment: Alignment.center,
              child: profileImage(),
            ),
            emptySpaceH(height: 4),
            profileItem(AppStrings.of(StringKey.name)),
            emptySpaceH(height: 14),
            profileItem(AppStrings.of(StringKey.status_message)),
            emptySpaceH(height: 14),
            profileItem(AppStrings.of(StringKey.email)),
            emptySpaceH(height: 14),
            profileItem(AppStrings.of(StringKey.data_of_birth)),
            emptySpaceH(height: 14),
            profileItem(AppStrings.of(StringKey.gender)),
            emptySpaceH(height: 14)
          ],
        ));
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is ProfileLoading) {
      showDialog(context: context, child: FullscreenDialog());
    }

    if (state is ProfileLoadingError) {
      popUntilNamed(context, ProfilePage.ROUTE_NAME);
    }

    if (state is ProfileLoaded) {
      popUntilNamed(context, ProfilePage.ROUTE_NAME);
    }

    return null;
  }

  String strokeSide(List<dynamic> sides) {
    if (sides == null || sides.isEmpty) {
      return 'N/A';
    }

    return sides.join(",");
  }

  List<String> genders = ['FEMALE', 'MALE', 'OTHER'];

  genderSelectDialog(context) {
    return showDialog(
        barrierDismissible: true,
        context: (context),
        builder: (_) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(true);
            },
            child: Dialog(
              elevation: 0,
              insetPadding: EdgeInsets.zero,
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Container(
                  width: resize(312),
                  height: resize(236),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      emptySpaceH(height: 24),
                      Padding(
                        padding: EdgeInsets.only(left: resize(20)),
                        child: Text(
                          'Select Gender',
                          style: AppTextStyle.from(
                              color: AppColors.grey,
                              size: TextSize.caption_medium,
                              weight: TextWeight.bold),
                        ),
                      ),
                      emptySpaceH(height: 16),
                      ListView.builder(
                        itemBuilder: (context, idx) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context, rootNavigator: true).pop();
                              bloc.add(ProfileUpdateEvent(
                                  profile: profile, gender: genders[idx]));
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: resize(50),
                                  color: AppColors.white,
                                  child: Center(
                                    child: Text(
                                      genders[idx],
                                      style: AppTextStyle.from(
                                          color: AppColors.black,
                                          size: TextSize.caption_large),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        shrinkWrap: true,
                        itemCount: genders.length,
                      )
                    ],
                  )),
            ),
          );
        });
  }
}
