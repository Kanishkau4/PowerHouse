import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService extends ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  late StreamSubscription<List<ConnectivityResult>> _subscription;

  ConnectivityService() {
    _checkInitialConnectivity();
    _subscription = Connectivity().onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final List<ConnectivityResult> result = await Connectivity()
          .checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking connectivity: $e');
      }
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    bool previousStatus = _isOnline;

    // If any result is not 'none', we consider it online
    _isOnline = result.any((r) => r != ConnectivityResult.none);

    if (previousStatus != _isOnline) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
