import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connect/feature/user/profile/profile_character_bloc.dart';
import 'package:connect/models/profile.dart';
import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_images.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/resources/app_strings.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:connect/widgets/base_alert_dialog.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/bottons/bottom_button.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multiscreen/multiscreen.dart';

class ProfileCharacterPage extends BlocStatefulWidget {
  final String name;
  final Profile profile;

  ProfileCharacterPage({this.name, this.profile});

  static Future<Object> push(
          BuildContext context, String name, Profile profile) =>
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ProfileCharacterPage(
                name: name,
                profile: profile,
              )));

  @override
  ProfileCharacterState buildState() => ProfileCharacterState();
}

class ProfileCharacterState
    extends BlocState<ProfileCharacterBloc, ProfileCharacterPage> {
  String selectCharacter = AppImages.img_sympathy;
  int selectIndex = 0;
  int firstIndex;

  File selectImage;
  final picker = ImagePicker();

  bool initCheck = false;

  List<String> texts = [
    AppStrings.of(StringKey.sympathy),
    AppStrings.of(StringKey.love),
    AppStrings.of(StringKey.happiness),
    AppStrings.of(StringKey.hope),
    AppStrings.of(StringKey.autonomy),
    AppStrings.of(StringKey.my_photo)
  ];

  List<String> characters = [
    AppImages.img_sympathy,
    AppImages.img_love,
    AppImages.img_happiness,
    AppImages.img_hope,
    AppImages.img_autonomy
  ];

  mainCharacter() {
    return Container(
      width: resize(140),
      height: resize(140),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(140),
        child: (selectIndex == 5 &&
                widget.profile.profileImageName == "IMAGE" &&
                widget.profile.image != null &&
                selectImage == null)
            ? ClipOval(
                child: Image.network(
                  widget.profile.image,
                  width: resize(72),
                  height: resize(72),
                  fit: BoxFit.cover,
                ),
              )
            : selectIndex == 5 && selectImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(140),
                    child: Image.file(
                      selectImage,
                      width: resize(140),
                      height: resize(140),
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    selectCharacter,
                    width: resize(140),
                    height: resize(140),
                  ),
      ),
    );
  }

  userName() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: resize(20),
      child: Center(
        child: Text(
          widget.name,
          style: AppTextStyle.from(
              size: TextSize.body_small,
              weight: TextWeight.bold,
              color: AppColors.darkGrey),
        ),
      ),
    );
  }

  Future getImage(index) async {
    final pickedImage = await picker.getImage(
        source: ImageSource.gallery, imageQuality: 30);

    setState(() {
      if (pickedImage != null) {
        selectImage = File(pickedImage.path);
        if (!selectImage.path.contains('heic') &&
            !selectImage.path.contains('HEIC')) {
          selectIndex = index;
          firstIndex = null;
        } else {
          showDialog(
              context: context,
              child: BaseAlertDialog(
                content:
                    "Only files in JPG, JPEG, GIF, or BMP formats can be attached.",
                onCancel: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ));
        }
      }
    });
  }

  characterList(context) {
    return StaggeredGridView.countBuilder(
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      itemCount: 6,
      shrinkWrap: true,
      padding: EdgeInsets.only(left: resize(24), right: resize(24)),
      itemBuilder: (BuildContext context, index) => Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  width: resize(80),
                  height: resize(80),
                  child: index == 5
                      ? GestureDetector(
                          onTap: () {
                            if (selectImage == null &&
                                widget.profile.profileImageName != "IMAGE") {
                              getImage(index);
                            } else {
                              setState(() {
                                selectIndex = index;
                              });
                            }
                          },
                          child: selectImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(72),
                                  child: Image.file(
                                    selectImage,
                                    width: resize(72),
                                    height: resize(72),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : widget.profile.profileImageName == "IMAGE"
                                  ? ClipOval(
                                      child: Image.network(
                                        widget.profile.image,
                                        width: resize(72),
                                        height: resize(72),
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.asset(
                                      AppImages.ic_camera,
                                      width: resize(24),
                                      height: resize(24),
                                      scale: 2,
                                    ),
                        )
                      : IconButton(
                          padding: EdgeInsets.zero,
                          icon: Image.asset(
                            characters[index],
                            width: resize(72),
                            height: resize(72),
                          ),
                          onPressed: () {
                            setState(() {
                              selectCharacter = characters[index];
                              selectIndex = index;
                            });
                          }),
                  decoration: selectIndex == index
                      ? BoxDecoration(
                          border: Border.all(width: 4, color: AppColors.orange),
                          borderRadius: BorderRadius.circular(80))
                      : index == 5
                          ? BoxDecoration(
                              color: AppColors.lightGrey01,
                              border: Border.all(
                                  color: selectImage != null
                                      ? AppColors.white
                                      : AppColors.lightGrey04,
                                  width: selectImage != null ? 4 : 1),
                              borderRadius: BorderRadius.circular(80))
                          : null,
                ),
                emptySpaceH(height: 4),
                Container(
                  height: resize(19),
                  child: Text(
                    texts[index],
                    style: AppTextStyle.from(
                        size: TextSize.caption_medium,
                        weight: TextWeight.semibold,
                        color: AppColors.grey),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
          index == 5 &&
                  (widget.profile.profileImageName == "IMAGE" ||
                      selectImage != null)
              ? Positioned(
                  bottom: resize(23),
                  right: 0,
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
                            getImage(index);
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
              : Container()
        ],
      ),
      staggeredTileBuilder: (index) => StaggeredTile.count(1, 1.1),
      mainAxisSpacing: 22,
      crossAxisSpacing: 18,
    );
  }

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
          appBar: baseAppBar(context, title: "Profile character"),
          backgroundColor: AppColors.white,
          body: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height -
                    44 -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        emptySpaceH(height: 8),
                        mainCharacter(),
                        emptySpaceH(height: 16),
                        userName(),
                        emptySpaceH(height: 30),
                        characterList(context)
                      ],
                    ),
                    Positioned(
                        left: resize(24),
                        right: resize(24),
                        bottom: resize(24),
                        child: BottomButton(
                          onPressed: firstIndex != selectIndex
                              ? () {
                                  String imageName;
                                  if (selectCharacter ==
                                      AppImages.img_sympathy) {
                                    imageName = "EMPATHY";
                                  } else if (selectCharacter ==
                                      AppImages.img_love) {
                                    imageName = "LOVE";
                                  } else if (selectCharacter ==
                                      AppImages.img_happiness) {
                                    imageName = "HAPPINESS";
                                  } else if (selectCharacter ==
                                      AppImages.img_hope) {
                                    imageName = "HOPE";
                                  } else if (selectCharacter ==
                                      AppImages.img_autonomy) {
                                    imageName = "AUTONOMY";
                                  }

                                  bloc.add(SaveEvent(
                                      imageFile: selectImage,
                                      profile: widget.profile,
                                      profileImageName: selectIndex == 5
                                          ? "IMAGE"
                                          : imageName));
                                }
                              : null,
                          text: AppStrings.of(StringKey.save),
                          textColor: AppColors.white,
                        ))
                  ],
                ),
              ),
              buildProgress(context)
            ],
          ),
        );
      },
    );
  }

  setImage() {
    if (widget.profile.profileImageName == "EMPATHY") {
      selectCharacter = AppImages.img_sympathy;
      return 0;
    } else if (widget.profile.profileImageName == "LOVE") {
      selectCharacter = AppImages.img_love;
      return 1;
    } else if (widget.profile.profileImageName == "HAPPINESS") {
      selectCharacter = AppImages.img_happiness;
      return 2;
    } else if (widget.profile.profileImageName == "HOPE") {
      selectCharacter = AppImages.img_hope;
      return 3;
    } else if (widget.profile.profileImageName == "AUTONOMY") {
      selectCharacter = AppImages.img_autonomy;
      return 4;
    }
  }

  @override
  blocListener(BuildContext context, state) {
    setState(() {
      if (state is ProfileCharacterInitState) {
        if (!initCheck) {
          if (widget.profile.image != null &&
              widget.profile.profileImageName == "IMAGE") {
            selectIndex = 5;
          } else {
            selectIndex = setImage();
          }
          if (firstIndex == null) {
            firstIndex = selectIndex;
          }
          initCheck = true;
        }
      }

      if (state is SaveState) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  ProfileCharacterBloc initBloc() {
    // TODO: implement initBloc
    return ProfileCharacterBloc(context)..add(ProfileCharacterInitEvent());
  }
}
