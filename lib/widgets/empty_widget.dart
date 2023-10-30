import 'package:connect/resources/app_resources.dart';
import 'package:connect/widgets/base_widget.dart';

class EmptyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          Image.asset(AppImages.illust_empty,
              width: resize(230), height: resize(186)),
          Text(AppStrings.of(StringKey.empty),
              style: AppTextStyle.from(
                  color: AppColors.darkGrey,
                  size: TextSize.caption_large,
                  weight: TextWeight.semibold))
        ]));
  }
}
