import 'package:connect/widgets/base_widget.dart';
import 'package:flutter/material.dart';

class IconRadioListTile<T> extends RadioListTile {
  final Widget selectedIcon;
  final Widget unselectedIcon;
  final EdgeInsets titleMargin;

  const IconRadioListTile({
    Key key,
    @required value,
    @required onChanged,
    @required this.selectedIcon,
    @required this.unselectedIcon,
    title,
    this.titleMargin,
    groupValue,
  })  : assert(value != null),
        assert(onChanged != null),
        assert(selectedIcon != null),
        assert(unselectedIcon != null),
        super(
            key: key,
            value: value,
            onChanged: onChanged,
            title: title,
            groupValue: groupValue);

  @override
  Widget build(BuildContext context) {
    final Widget control = IconRadio<T>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      selectedIcon: selectedIcon,
      unselectedIcon: unselectedIcon,
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
      child: ListTileTheme.merge(
        selectedColor: activeColor ?? Theme.of(context).accentColor,
        child: ListTile(
          leading: leading,
          title: Container(
            child: title,
            margin: titleMargin,
            transform: Matrix4.translationValues(-30.0, 2.0, 0.0),
          ),
          subtitle: subtitle,
          trailing: trailing,
          isThreeLine: isThreeLine,
          dense: dense,
          enabled: onChanged != null,
          onTap: onChanged != null && !checked
              ? () {
                  onChanged(value);
                }
              : null,
          selected: selected,
        ),
      ),
    );
  }
}

class IconRadio<T> extends StatefulWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final Widget selectedIcon;
  final Widget unselectedIcon;

  const IconRadio(
      {Key key,
      @required this.value,
      @required this.groupValue,
      @required this.onChanged,
      @required this.selectedIcon,
      @required this.unselectedIcon})
      : super(key: key);

  @override
  IconRadioState<T> createState() {
    return IconRadioState<T>();
  }
}

class IconRadioState<T> extends State<IconRadio<T>> {
  @override
  Widget build(BuildContext context) {
    return widget.value == widget.groupValue
        ? widget.selectedIcon
        : widget.unselectedIcon;
  }
}
