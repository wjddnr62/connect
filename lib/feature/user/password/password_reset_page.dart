import 'package:connect/feature/user/password/password_reset_guide_page.dart';
import 'package:connect/feature/user/password/password_reset_input_email_page.dart';
import 'package:connect/feature/user/password/reset_password_bloc.dart';
import 'package:connect/utils/logger/log.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:connect/widgets/pages/error_page.dart';
import 'package:flutter/material.dart';

import '../../base_bloc.dart';

class PasswordResetPage extends BlocStatefulWidget {
  final email;

  PasswordResetPage({this.email});

  @override
  BlocState<ResetPasswordBloc, PasswordResetPage> buildState() {
    return _PasswordResetState(email: email);
  }
}

class _PasswordResetState
    extends BlocState<ResetPasswordBloc, PasswordResetPage> {
  var currentWidget;
  final String email;

  _PasswordResetState({this.email});

  @override
  ResetPasswordBloc initBloc() {
    ResetPasswordBloc ret = ResetPasswordBloc(email: email);
    if (email != null) {
      ret.add(RequestSendMail());
    }
    return ret;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  blocListener(BuildContext context, state) {
    if (prevState is Loading) {
      _dismissDialog(context);
    }

    if (state is Loading) {
      _showDialog(context);
    }

    if (state is Finish) {
      pop(context);
    }
  }

  @override
  blocBuilder(BuildContext context, state) {
    return WillPopScope(
      onWillPop: () async {
        Log.d('_PasswordResetState', "prevState = $prevState");
        Log.d('_PasswordResetState', "currState = $currState");
        if (prevState == null) {
          return true;
        }

        if (currState is InputtingEmail) {
          return true;
        }

        if (currState is ShowingGuide) {
          if (email != null) {
            return true;
          }

          bloc.add(InputEmail());
          return false;
        }

        if (currState is UnknownError) {
          bloc.add(currState.backTo);
          return false;
        }

        return true;
      },
      child: _route(context, state),
    );
  }

  Widget _route(BuildContext context, state) {
    if (state is InputtingEmail) {
      currentWidget = PasswordResetInputEmailPage();
    }

    if (state is ShowingGuide) {
      currentWidget = PasswordResetGuidePage();
    }

    if (state is UnknownError) {
      currentWidget = ErrorPage(error: state.error);
    }

    return currentWidget;
  }

  _showDialog(context) {
    showDialog(
      context: context,
      builder: (context) => FullscreenDialog(),
      barrierDismissible: false,
    );
  }

  _dismissDialog(context) {
    pop(context);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
