import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  Future<bool> checkInternetConnection() async {
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      return true;
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      // When both mobile and Wi-Fi are turned on system will return Wi-Fi only as active network type
      return true;
    } else {
      return false;
    }
  }
}
