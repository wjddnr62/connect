import 'package:connect/resources/app_resources.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:flutter/material.dart';

class DrawerMenuItem extends BasicStatelessWidget {
  final icon;
  final title;
  final onTap;

  DrawerMenuItem({this.icon, this.title, this.onTap})
      : assert(icon != null || title != null);

  @override
  Widget buildWidget(BuildContext context) {
    List<Widget> widgets = [];
    if (icon != null) {
      widgets.add(Container(
          child: Image.asset(
        icon,
        width: resize(24),
        height: resize(24),
      )));

      widgets.add(SizedBox(
        width: resize(16),
      ));
    }

    if (title != null) {
      widgets.add(Flexible(
          child: Container(
        child: Text(
          title,
          style: AppTextStyle.from(
              color: AppColors.darkGrey,
              size: TextSize.caption_large,
              weight: TextWeight.semibold,
              height: null),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      )));
    }

    if (widgets.length < 1) {
      throw Exception();
    }

    return Container(
        padding: EdgeInsets.only(left: resize(24), right: resize(12)),
        width: double.infinity,
        height: resize(52),
        child: MaterialButton(
            elevation: 0,
            padding: EdgeInsets.all(0),
            onPressed: onTap,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: widgets,
            )));
  }
}
