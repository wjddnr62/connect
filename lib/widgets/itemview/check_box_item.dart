import 'package:connect/resources/app_resources.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppCheckBoxListTile extends BasicStatelessWidget {
  final double width;
  final double height;
  final EdgeInsets margin;
  final Color inactiveColor;
  final String image;
  final String selectedImage;

  const AppCheckBoxListTile({
    Key key,
    @required this.value,
    @required this.onChanged,
    this.width,
    this.height,
    this.margin,
    this.inactiveColor,
    this.activeColor,
    this.title,
    this.selectedImage,
    this.image,
    this.subtitle,
    this.isThreeLine = false,
    this.dense,
    this.secondary,
    this.selected = false,
    this.controlAffinity = ListTileControlAffinity.platform,
  })  : assert(isThreeLine != null),
        assert(!isThreeLine || subtitle != null),
        assert(selected != null),
        assert(controlAffinity != null),
        super(key: key);

  final bool value;

  final ValueChanged<bool> onChanged;

  final Color activeColor;

  final String title;

  final Widget subtitle;

  final Widget secondary;

  final bool isThreeLine;

  final bool dense;

  final bool selected;

  final ListTileControlAffinity controlAffinity;

  @override
  Widget buildWidget(BuildContext context) {
    final Widget control = Checkbox(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
    Widget leading, trailing;
    switch (controlAffinity) {
      case ListTileControlAffinity.leading:
      case ListTileControlAffinity.platform:
        leading = control;
        trailing = secondary;
        break;
      case ListTileControlAffinity.trailing:
        leading = secondary;
        trailing = control;
        break;
    }
    return MergeSemantics(
      child: _buildOutline(selected, context, leading, trailing),
    );
  }

  Widget _buildOutline(
      bool selected, BuildContext context, Widget leading, Widget trailing) {
    List<Widget> stacks = [];
    if (selectedImage != null && image != null) {
      stacks.add(
        Image.asset(
          selected ? selectedImage : image,
          fit: BoxFit.contain,
          width: width,
          height: height,
        ),
      );
    }
    stacks.add(
      Container(
        padding: EdgeInsets.all(resize(8)),
        alignment: Alignment.topRight,
        child: Image.asset(
          selected
              ? AppImages.ic_checkbox_select
              : AppImages.ic_checkbox_default,
          width: resize(24),
          height: resize(24),
        ),
      ),
    );
    stacks.add(_build(context, leading, trailing));

    return Container(
      decoration: BoxDecoration(
        color: selected ? AppColors.orangeA08 : AppColors.white,
        borderRadius: new BorderRadius.circular(
          resize(AppDimen.buttonRound),
        ),
        border: selected
            ? Border.all(
                color: AppColors.orange,
                width: resize(2),
              )
            : Border.all(
                color: AppColors.border,
                width: resize(2),
              ),
      ),
      height: height,
      width: width,
      margin: margin,
      child: Stack(
        children: stacks,
      ),
    );
  }

  Widget _build(BuildContext context, Widget leading, Widget trailing) {
    return ListTileTheme.merge(
      selectedColor: activeColor ?? Theme.of(context).accentColor,
      child: ListTile(
        contentPadding: EdgeInsets.only(
          top: resize(4),
          left: resize(8),
        ),
        title: Align(
          alignment: (image == null || selectedImage == null)
              ? Alignment.center
              : Alignment.topLeft,
          child: Text(
            title,
            style: AppTextStyle.from(
              color: selected ? AppColors.orange : AppColors.darkGrey,
              size: (image == null || selectedImage == null)
                  ? TextSize.button_large
                  : TextSize.body_small,
              weight: (image == null || selectedImage == null)
                  ? TextWeight.bold
                  : TextWeight.semibold,
            ),
          ),
        ),
        isThreeLine: isThreeLine,
        dense: dense,
        enabled: onChanged != null,
        onTap: onChanged != null
            ? () {
                onChanged(!value);
              }
            : null,
        selected: selected,
      ),
    );
  }
}
