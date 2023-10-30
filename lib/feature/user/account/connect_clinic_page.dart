import 'package:connect/feature/user/account/connect_clinic_bloc.dart';
import 'package:connect/models/clinic.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/widgets/base_alert_dialog.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/bottons/bottom_button.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:connect/widgets/itemview/icon_radio_item.dart';
import 'package:connect/widgets/pages/error_page.dart';
import 'package:flutter/material.dart';

import '../../base_bloc.dart';

class ConnectClinicPage extends BasicPage {
  static const String ROUTE_NAME = '/connect_clinic_page';

  static Future<Object> push(BuildContext context, {Clinic clinic}) =>
      Navigator.of(context).pushNamed(ROUTE_NAME, arguments: clinic);

  Clinic _clinic;

  @override
  Widget buildWidget(BuildContext context) {
    return _ConnectClinicPage(clinic: _clinic);
  }

  @override
  void handleArgument(BuildContext context) {
    _clinic = ModalRoute.of(context).settings.arguments;
  }

  @override
  _ConnectClinicState buildState() => _ConnectClinicState();
}

class _ConnectClinicPage extends BlocStatefulWidget {
  Clinic clinic;

  _ConnectClinicPage({@required this.clinic});

  @override
  _ConnectClinicState buildState() => _ConnectClinicState();
}

class _ConnectClinicState
    extends BlocState<ConnectClinicBloc, _ConnectClinicPage> {
  Clinic _selectedClinic;
  List<Clinic> clinics;

  @override
  Widget blocBuilder(BuildContext context, state) {
    return Scaffold(
        backgroundColor: AppColors.white,
        appBar: baseAppBar(context, title: AppStrings.of(StringKey.clinic)),
        body: Stack(
          children: <Widget>[
            Container(
                padding: EdgeInsets.only(bottom: resize(102)),
                child: Column(children: [
                  Container(
                      padding: EdgeInsets.all(resize(24)),
                      child: Text(AppStrings.of(StringKey.choose_clinic_desc),
                          textAlign: TextAlign.start,
                          style: AppTextStyle.from(
                              height: 1.4,
                              size: TextSize.caption_medium,
                              weight: TextWeight.semibold,
                              color: AppColors.grey))),
                  (clinics == null || clinics.isEmpty)
                      ? Expanded(child: Container())
                      : Expanded(
                          child: ListView.separated(
                              itemBuilder: (context, index) {
                                return Container(
                                    padding: EdgeInsets.only(
                                        left: resize(24), right: resize(24)),
                                    child: IconRadioListTile(
                                        title: Text(
                                          clinics[index].name,
                                          style: AppTextStyle.from(
                                              color: AppColors.black,
                                              size: TextSize.caption_large,
                                              weight: TextWeight.semibold),
                                        ),
                                        titleMargin:
                                            EdgeInsets.only(left: resize(16)),
                                        selectedIcon: Container(
                                          child: Image.asset(
                                              AppImages.radio_select),
                                          width: resize(24),
                                          height: resize(24),
                                        ),
                                        unselectedIcon: Container(
                                          child: Image.asset(
                                              AppImages.radio_default),
                                          width: resize(24),
                                          height: resize(24),
                                        ),
                                        value: clinics[index],
                                        groupValue: _selectedClinic,
                                        onChanged: (value) => setState(
                                            () => _selectedClinic = value)));
                              },
                              separatorBuilder: (context, index) {
                                return Divider(
                                    height: resize(8),
                                    color: AppColors.transparent);
                              },
                              itemCount: clinics.length)),
                ])),
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    padding: EdgeInsets.only(
                        left: resize(16),
                        right: resize(16),
                        top: resize(16),
                        bottom: resize(32)),
                    child: BottomButton(
                        onPressed: _selectedClinic?.id == widget.clinic.id
                            ? null
                            : () => bloc.add(SaveClinic(_selectedClinic)),
                        text: AppStrings.of(StringKey.save))))
          ],
        ));
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is LoadComplete) {
      popUntilNamed(context, ConnectClinicPage.ROUTE_NAME);
      clinics = state.clinics;
      _selectedClinic =
          clinics.firstWhere((element) => element.id == widget.clinic.id);
    }
    if (state is CheckToSaveClinic) {
      showDialog(
          context: context,
          child: BaseAlertDialog(
              cancelable: true,
              onConfirm: () => bloc.add(ConfirmToSave(_selectedClinic)),
              onCancel: () {},
              content:
                  'Are you sure you want to change your clinic? By confirming this message you agree to deliver your information to the clinic you choose.'));
      return;
    }

    if (state is Saving) {
      showDialog(
          barrierDismissible: true,
          context: context,
          child: BaseAlertDialog(
              cancelable: false, onConfirm: null, content: 'Saving...'));
      return;
    }

    if (state is SaveComplete) {
      pop(context);
      showDialog(
          barrierDismissible: true,
          context: context,
          child: BaseAlertDialog(
              onConfirm: () async => pop(context), content: 'Saved'));
      return;
    }

    if (state is ShowError) {
      popUntilNamed(context, ConnectClinicPage.ROUTE_NAME);
      pop(context);
      ErrorPage.push(context, params: {ErrorPage.PARAM_KEY_ERROR: state.error});
      return;
    }

    if (state is Loading) {
      showDialog(context: context, child: FullscreenDialog());
    }
  }

  @override
  ConnectClinicBloc initBloc() =>
      ConnectClinicBloc(context)..add(LoadClinics());
}
