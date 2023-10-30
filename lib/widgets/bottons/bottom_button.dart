import 'package:connect/resources/app_resources.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:flutter/material.dart';

class BottomButton extends BasicStatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;
  final String icon;
  final bool lineBoxed;
  final Color lineColor;
  final Color disabledColor;

  BottomButton(
      {this.text,
      this.color,
      this.textColor,
      this.icon,
      this.lineBoxed = false,
      this.lineColor,
      @required this.onPressed,
      this.disabledColor});

  @override
  Widget buildWidget(BuildContext context) {
    Color _color = lineBoxed ? AppColors.white : color;

    return MaterialButton(
        disabledColor: disabledColor == null ? AppColors.lightGrey02 : disabledColor,
        disabledTextColor: AppColors.lightGrey04,
        elevation: 0,
        shape: lineBoxed
            ? OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(resize(AppDimen.buttonRound)),
                borderSide: BorderSide(
                    color: lineColor == null ? AppColors.purple : lineColor,
                    width: resize(2)))
            : RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(resize(AppDimen.buttonRound))),
        height: resize(54),
        color: _color == null ? AppColors.purple : color,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center, children: _build()),
        onPressed: onPressed);
  }

  List<Widget> _build() {
    if (icon == null)
      return [
        Text(text,
            style: AppTextStyle.from(
                color: this.textColor == null
                    ? (lineBoxed
                        ? (color == null ? AppColors.purple : color)
                        : AppColors.white)
                    : this.textColor,
                size: TextSize.button_medium,
                weight: TextWeight.semibold,
                height: AppTextStyle.LINE_HEIGHT_MULTI_LINE))
      ];

    return [
      Container(
          margin: EdgeInsets.all(resize(8)),
          child: Image.asset(icon, width: resize(24), height: resize(24))),
      Text(text,
          style: AppTextStyle.from(
              color: this.textColor == null
                  ? (lineBoxed
                      ? (color == null ? AppColors.purple : color)
                      : AppColors.white)
                  : this.textColor,
              size: TextSize.button_medium,
              weight: TextWeight.semibold,
              height: AppTextStyle.LINE_HEIGHT_MULTI_LINE))
    ];
  }
}
