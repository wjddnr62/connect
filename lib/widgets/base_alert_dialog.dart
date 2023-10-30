import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class BaseAlertDialog extends BasicStatelessWidget {
  final String content;
  final bool cancelable;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final double width;

  BaseAlertDialog(
      {this.content = "",
      this.cancelable = false,
      this.onConfirm,
      this.onCancel,
      this.width});

  @override
  Widget buildWidget(BuildContext context) {
    var con = Container(
        width: width ?? resize(312),
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.all(Radius.circular(resize(8)))),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[createContent(), _createButtons(context)]));
    return Dialog(child: con, backgroundColor: Colors.transparent);
  }

  Widget createContent() {
    return Container(
        padding: EdgeInsets.only(
            left: resize(24),
            right: resize(24),
            top: resize(24),
            bottom: resize(32)),
        child: Text(content,
            textAlign: TextAlign.center,
            style: AppTextStyle.from(
                size: TextSize.body_small,
                weight: TextWeight.semibold,
                height: 1.6,
                color: AppColors.black)));
  }

  Widget _createButtons(BuildContext context) {
    final confirm = GestureDetector(
        onTap: () {
          pop(context);
          if (this.onConfirm != null) this.onConfirm();
        },
        child: Container(
            width: double.infinity,
            height: resize(73),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(resize(8)),
                    bottomLeft: Radius.circular(cancelable ? 0 : resize(8))),
                color: AppColors.white),
            child: Center(
                child: Text(StringKey.confirm.getString(),
                    textAlign: TextAlign.center,
                    style: AppTextStyle.from(
                        size: TextSize.body_small,
                        weight: TextWeight.semibold,
                        color: AppColors.orange)))));

    if (onConfirm == null && onCancel == null) {
      return Container(color: AppColors.transparent);
    }

    if (!cancelable) return confirm;

    final cancel = GestureDetector(
        onTap: () {
          if (this.onCancel != null) this.onCancel();
          pop(context);
        },
        child: Container(
            width: double.infinity,
            height: resize(73),
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.only(bottomLeft: Radius.circular(resize(8))),
                color: AppColors.white),
            child: Center(
                child: Text(StringKey.cancel.getString(),
                    textAlign: TextAlign.center,
                    style: AppTextStyle.from(
                        size: TextSize.body_small,
                        weight: TextWeight.semibold,
                        color: AppColors.darkGrey)))));

    if (onConfirm == null && onCancel == null) {
      return Container();
    }

    return Column(children: <Widget>[
      Container(
          width: double.infinity,
          height: resize(1),
          color: AppColors.lightGrey04),
      Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
        Flexible(flex: 1, child: cancel),
        Container(
            width: resize(1), height: resize(73), color: AppColors.lightGrey04),
        Flexible(flex: 1, child: confirm)
      ])
    ]);
  }
}
