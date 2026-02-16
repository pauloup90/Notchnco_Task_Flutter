import 'package:connectivity_plus/connectivity_plus.dart';


class NetworkInfo {
  final Connectivity connectivity;
  
  NetworkInfo(this.connectivity);
  
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return result.any((status) => 
      status == ConnectivityResult.mobile || 
      status == ConnectivityResult.wifi || 
      status == ConnectivityResult.ethernet
    );
  }
  
  Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return connectivity.onConnectivityChanged;
  }
}
