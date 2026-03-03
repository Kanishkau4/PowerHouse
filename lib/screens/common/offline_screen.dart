import 'package:flutter/material.dart';
import 'package:powerhouse/widgets/offline_error_widget.dart';

import 'package:provider/provider.dart';
import 'package:powerhouse/services/connectivity_service.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back button from closing it while offline
      child: Scaffold(
        body: OfflineErrorWidget(
          onRetry: () {
            final connectivity = Provider.of<ConnectivityService>(
              context,
              listen: false,
            );
            if (connectivity.isOnline) {
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Still offline. Please check your connection."),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
