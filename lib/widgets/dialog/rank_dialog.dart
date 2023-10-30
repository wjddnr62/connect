import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_images.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/resources/app_strings.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:multiscreen/multiscreen.dart';

List<String> rankIcon = [
  AppImages.img_ranking_king,
  AppImages.img_ranking_platinum,
  AppImages.img_ranking_diamond,
  AppImages.img_ranking_gold,
  AppImages.img_ranking_silver,
  AppImages.img_ranking_bronze,
  AppImages.img_ranking_orange,
  AppImages.img_ranking_stone
];

List<String> rankName = [
  AppStrings.of(StringKey.king),
  AppStrings.of(StringKey.platinum),
  AppStrings.of(StringKey.diamond),
  AppStrings.of(StringKey.gold),
  AppStrings.of(StringKey.silver),
  AppStrings.of(StringKey.bronze),
  AppStrings.of(StringKey.orange),
  AppStrings.of(StringKey.stone)
];

rankDialog(context) {
  return showDialog(
      barrierDismissible: true,
      context: (context),
      builder: (_) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(true);
          },
          child: Dialog(
            elevation: 0,
            insetPadding: EdgeInsets.zero,
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
                width: resize(288),
                height: resize(484),
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    emptySpaceH(height: 16),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: resize(16)),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          child: Image.asset(
                            AppImages.ic_delete,
                            width: resize(24),
                            height: resize(24),
                          ),
                        ),
                      ),
                    ),
                    emptySpaceH(height: 4),
                    StaggeredGridView.countBuilder(
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      padding:
                          EdgeInsets.only(left: resize(28), right: resize(28)),
                      itemCount: rankIcon.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, index) => Column(
                        children: [
                          Image.asset(
                            rankIcon[index],
                            width: resize(100),
                            height: resize(54),
                          ),
                          emptySpaceH(height: 8),
                          Text(
                            rankName[index],
                            style: AppTextStyle.from(
                                color: AppColors.grey,
                                size: TextSize.caption_medium,
                                weight: TextWeight.semibold),
                          )
                        ],
                      ),
                      staggeredTileBuilder: (index) =>
                          StaggeredTile.count(1, 1),
                      mainAxisSpacing: resize(0),
                      crossAxisSpacing: resize(24),
                    ),
                  ],
                )),
          ),
        );
      });
}
