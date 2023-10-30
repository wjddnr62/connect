import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_resources.dart';

import 'package:connect/resources/app_strings.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:multiscreen/multiscreen.dart';

showToast(String text, {BuildContext context, bool custom = false}) {
  if (custom) {
    FToast fToast = FToast();
    fToast.init(context);
    Widget toast = Container(
      width: resize(198),
      height: resize(36),
      decoration: BoxDecoration(
          color: AppColors.black, borderRadius: BorderRadius.circular(26)),
      child: Center(
        child: Text(
          AppStrings.of(StringKey.email_address_copied),
          style: AppTextStyle.from(
              size: TextSize.caption_large,
              color: AppColors.white,
              weight: TextWeight.semibold),
        ),
      ),
    );
    fToast.showToast(
        child: toast,
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: 2));
  } else {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors.black,
        textColor: AppColors.white,
        fontSize: 12.0);
  }
}
