import 'package:flutter/foundation.dart';

import 'connect_app.dart';
import 'connect_config.dart';

/// This entry file Production live
void main() async {
  gFlavor = Flavor.PROD;
  if (kReleaseMode) {
    gProduction = 'prod-release';
  } else {
    gProduction = 'prod-debug';
  }
  mainCommon();
}
