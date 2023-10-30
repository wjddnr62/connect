import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_images.dart';
import 'package:connect/resources/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:multiscreen/multiscreen.dart';

import 'base_widget.dart';

PreferredSize baseAppBar(context,
    {final String title,
    final Color backgroundColor,
    final Color textColor,
    final bool centerTitle,
    final bool automaticallyImplyLeading,
    final double elevation = 0,
    final Function() onLeadPressed,
    final List<Widget> actions,
    final PreferredSizeWidget bottom,
    final Widget leading}) {
  return PreferredSize(
      preferredSize: Size.fromHeight(resize(44)),
      child: AppBar(
          actions: actions,
          elevation: elevation,
          centerTitle: centerTitle ?? true,
          automaticallyImplyLeading: automaticallyImplyLeading ?? true,
          bottom: bottom,
          leading: leading ??
              IconButton(
                icon: Image.asset(
                  AppImages.ic_chevron_left,
                  width: resize(24),
                  height: resize(24),
                ),
                onPressed: onLeadPressed ?? () => pop(context),
              ),
          backgroundColor: backgroundColor ?? AppColors.white,
          title: Text(
            title ?? '',
            style: AppTextStyle.from(
                color: textColor ?? AppColors.black,
                size: TextSize.body_small,
                weight: TextWeight.extrabold,
                height: null),
          )));
}
