class SettingList {
  final List<dynamic> settingScaleInfo;
  final List<dynamic> settingScaleDetailInfo;

  SettingList({this.settingScaleInfo, this.settingScaleDetailInfo});

  factory SettingList.fromJson(Map<String, dynamic> data) {
    return SettingList(
        settingScaleInfo: data['settingScaleInfo'] as List,
        settingScaleDetailInfo: data['settingScaleDetailInfo'] as List);
  }
}
