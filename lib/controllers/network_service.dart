import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  NetworkService({Connectivity? connectivity}) : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> ensureConnected() async {
    if (!await isConnected) {
      throw const SocketException('No internet connection');
    }
  }
}
