import 'package:connect/data/remote/base_service.dart';
import 'package:connect/resources/app_images.dart';
import 'package:intl/intl.dart';

enum HomeLevel {
  legend,
  hall_of_fame,
  ultimate_champion,
  all_star,
  aspiring_pro,
  go_getter,
  rookie_warrior
}

extension HomeLevelEx on HomeLevel {
  String get visibleName {
    final words = describeEnum(this).split('_');
    return words.map((s) => "${s[0].toUpperCase()}${s.substring(1)}").join(" ");
  }

  String get levelValue {
    if (this == HomeLevel.rookie_warrior) return '-';

    return NumberFormat().format(this.value);
  }

  int get value {
    switch (this) {
      case HomeLevel.legend:
        return 5000;
      case HomeLevel.hall_of_fame:
        return 2000;

      case HomeLevel.ultimate_champion:
        return 1000;

      case HomeLevel.all_star:
        return 500;

      case HomeLevel.aspiring_pro:
        return 100;

      case HomeLevel.go_getter:
        return 30;

      case HomeLevel.rookie_warrior:
        return 0;
      default:
        return -1;
    }
  }

  String get madalImage {
    switch (this) {
      case HomeLevel.legend:
        return AppImages.madal_neo_crown;
      case HomeLevel.hall_of_fame:
        return AppImages.madal_neo_double;
      case HomeLevel.ultimate_champion:
        return AppImages.madal_neo_single;
      case HomeLevel.all_star:
        return AppImages.madal_platinum;
      case HomeLevel.aspiring_pro:
        return AppImages.madal_gold;
      case HomeLevel.go_getter:
        return AppImages.madal_silver;
      case HomeLevel.rookie_warrior:
        return AppImages.madal_bronze;
      default:
        return '';
    }
  }
}

HomeLevel findHomeLevel(int star) {
  final values = HomeLevel.values.toList();

  values.sort((a, b) {
    return -a.value.compareTo(b.value);
  });

  return values.firstWhere((e) {
    return star >= e.value;
  }, orElse: () {
    return HomeLevel.rookie_warrior;
  });
}
