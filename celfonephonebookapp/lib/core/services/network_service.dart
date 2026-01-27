import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  static Future<bool> hasInternet() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      return false;
    }

    // Extra safety: DNS lookup
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty;
    } on SocketException {
      return false;
    }
  }
}
