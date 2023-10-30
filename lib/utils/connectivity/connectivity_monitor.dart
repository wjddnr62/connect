import 'package:connect/data/remote/base_service.dart';
import 'package:connectivity/connectivity.dart';

enum Network {
  wifi,
  mobile,
  none,
}

class ConnectivityMonitor extends ChangeNotifier {
  bool online;
  Network network;

  ConnectivityMonitor() {
    Connectivity().onConnectivityChanged.listen((onData) {
      if (onData is ConnectivityResult) {
        switch (onData) {
          case ConnectivityResult.wifi:
            online = true;
            network = Network.wifi;
            break;
          case ConnectivityResult.mobile:
            online = true;
            network = Network.mobile;
            break;
          case ConnectivityResult.none:
            online = false;
            network = Network.none;
            break;
        }
      } else {
        online = false;
        network = Network.none;
      }

      notifyListeners();
    });
  }

  static Future<bool> get isOnline async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    } else {
      return true;
    }
  }
}
