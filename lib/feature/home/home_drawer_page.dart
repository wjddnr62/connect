import 'package:cached_network_image/cached_network_image.dart';
import 'package:connect/data/local/app_dao.dart';
import 'package:connect/data/remote/base_service.dart';
import 'package:connect/data/share_repository.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/feature/bottom_navigation/home_navigation_bloc.dart';
import 'package:connect/feature/current_status/current_status_page.dart';
import 'package:connect/feature/home/home_calendar.dart';
import 'package:connect/feature/settings/settings_page.dart';
import 'package:connect/feature/user/account/account_page.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/menu_item.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

import '../../connect_config.dart';

// ignore: must_be_immutable
class HomeDrawerPage extends BlocStatefulWidget {
  final bloc;
  final HomeNavigationBloc navigationBloc;

  HomeDrawerPage({this.bloc, this.navigationBloc});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() => _HomeDrawerState();
}

class _HomeDrawerState extends BlocState<_HomeDrawerBloc, HomeDrawerPage> {
  @override
  blocBuilder(BuildContext context, state) {
    final menus = <Widget>[
      DrawerMenuItem(
        icon: AppImages.ic_result,
        title: StringKey.current_status.getString(),
        onTap: () {
          // CurrentStatusPage.popAndPush(context).then((value) {
          //   refresh(widget.bloc);
          // });
          widget.navigationBloc.add(ChangeViewEvent(changeIndex: 1));
        },
      ),
      DrawerMenuItem(
        icon: AppImages.ic_share,
        title: AppStrings.of(StringKey.share),
        onTap: () async {
          String shareContent = await ShareRepository.getShareContent();
          Share.share(shareContent);
        },
      ),
      DrawerMenuItem(
        icon: AppImages.ic_setting,
        title: AppStrings.of(StringKey.settings),
        onTap: () async {
          pop(context);
          SettingsPage.push(context);
        },
      )
    ];

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

    var widgets = [
      Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: resize(46),
          bottom: resize(32),
        ),
        color: AppColors.purple,
        child: GestureDetector(
          onTap: () {
            AccountPage.popAndPushNamed(context);
          },
          child: Column(
            children: <Widget>[
              Stack(
                children: [
                  ClipOval(
                    child: Container(
                      height: resize(52),
                      width: resize(52),
                      decoration: BoxDecoration(
                        color: AppColors.white70,
                      ),
                      child: Center(
                        child: (state is _LoadedState)
                            ? state.profileImageName == "IMAGE"
                                ? ClipOval(
                                    child: Image.network(
                                      state.profileImage,
                                      width: resize(72),
                                      height: resize(72),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : (state.profileImageName == null ||
                                        (state.profileImage == "" ||
                                            state.profileImage == null))
                                    ? Image.asset(AppImages.img_sympathy,
                                        width: resize(48), height: resize(48))
                                    : Image.asset(
                                        setProfileImage(state.profileImageName),
                                        width: resize(48),
                                        height: resize(48),
                                      )
                            : Image.asset(AppImages.img_sympathy,
                                width: resize(48), height: resize(48)),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: (state is _LoadedState)
                        ? state.vip == "VIP"
                            ? Image.asset(
                                AppImages.vip_with_stroke,
                                width: resize(32),
                                height: resize(18),
                              )
                            : Container()
                        : Container(),
                  )
                ],
              ),
              SizedBox(
                height: resize(16),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: resize(41), right: resize(41)),
                          child: Text(
                            (state is _LoadedState) ? state.name ?? '' : '',
                            style: AppTextStyle.from(
                              size: TextSize.title_small,
                              color: AppColors.white,
                              weight: TextWeight.extrabold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(
                          height: resize(8),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: resize(36), right: resize(36)),
                          child: Text(
                            (state is _LoadedState)
                                ? state.email.contains("*")
                                    ? state.email.split("*")[1]
                                    : state.email ?? ''
                                : '',
                            style: AppTextStyle.from(
                              size: TextSize.caption_medium,
                              color: AppColors.white,
                              weight: TextWeight.medium,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      bottom: 0,
                      right: resize(24),
                      child: Image.asset(
                        AppImages.ic_chevron_right,
                        width: resize(24),
                        height: resize(24),
                        color: AppColors.white,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      Expanded(
        child: Container(
          color: AppColors.white,
          child: ListView(
            padding: EdgeInsets.only(top: resize(20)),
            children: menus,
          ),
        ),
      ),
    ];

    if (gFlavor != Flavor.PROD) {
      widgets.add(
        Container(
          color: AppColors.white,
          padding: EdgeInsets.only(left: resize(16), bottom: resize(32)),
          alignment: Alignment.bottomLeft,
          child: Text(
            'Production       : $gProduction\nVersion Name : $gVersion\nVersion Code  : $gBuildNumber',
            textAlign: TextAlign.left,
            style: AppTextStyle.from(
              height: 1.3,
              color: AppColors.grey,
              size: TextSize.caption_small,
              weight: TextWeight.extrabold,
            ),
          ),
        ),
      );
    }

    return SizedBox(width: resize(280), child: Column(children: widgets));
  }

  @override
  blocListener(BuildContext context, state) {}

  @override
  _HomeDrawerBloc initBloc() => _HomeDrawerBloc();

  @override
  void initState() {
    super.initState();
    bloc.add(_LoadEvent());
  }
}

class _HomeDrawerBloc extends BaseBloc {
  _HomeDrawerBloc() : super(_InitState());

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is _LoadEvent) {
      yield _LoadedState(
          name: await AppDao.nickname,
          email: await AppDao.email,
          profileImage: await AppDao.profileImage,
          profileImageName: await AppDao.profileImageName,
          vip: await AppDao.marketPlace);
    }
  }
}

class _LoadEvent extends BaseBlocEvent {}

class _InitState extends BaseBlocState {}

class _LoadedState extends BaseBlocState {
  final String email;
  final String name;
  final String profileImage;
  final String profileImageName;
  final String vip;

  _LoadedState(
      {this.email,
      this.name,
      this.profileImage,
      this.profileImageName,
      this.vip});
}
