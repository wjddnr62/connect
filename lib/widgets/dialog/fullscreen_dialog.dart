import 'package:connect/resources/app_colors.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:flutter/material.dart';
import 'package:multiscreen/multiscreen.dart';

class FullscreenDialog extends BasicStatelessWidget {
  final Widget child;

  FullscreenDialog({this.child});

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: Center(
        child: child == null
            ? ClipOval(
                child: Container(
                  width: resize(56),
                  height: resize(56),
                  color: AppColors.black.withOpacity(0.6),
                  padding: EdgeInsets.all(resize(13)),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 4.5,
                      backgroundColor: AppColors.transparent,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.orange),
                    ),
                  ),
                ),
              )
            : child,
      ),
    );
  }
}
