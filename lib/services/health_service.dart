import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthService {
  final Health _health = Health();

  // Define data types we want to read
  final List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.DISTANCE_DELTA,
  ];

  // Request permissions
  Future<bool> requestPermissions() async {
    try {
      // Check activity recognition permission first (Android specific)
      var status = await Permission.activityRecognition.status;
      if (status.isDenied) {
        await Permission.activityRecognition.request();
      }

      bool requested = await _health.requestAuthorization(_types);
      return requested;
    } catch (e) {
      print('Error requesting health permissions: $e');
      return false;
    }
  }

  // Get steps for today
  Future<int> getTodaySteps() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      int? steps = await _health.getTotalStepsInInterval(midnight, now);
      return steps ?? 0;
    } catch (e) {
      print('Error getting steps: $e');
      return 0;
    }
  }

  // Get calories burned today (Active Energy)
  Future<int> getTodayCalories() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      // Fetch active energy burned
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        startTime: midnight,
        endTime: now,
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
      );

      // Sum up the values
      double totalCalories = 0;
      for (var point in healthData) {
        if (point.value is NumericHealthValue) {
          totalCalories += (point.value as NumericHealthValue).numericValue;
        }
      }
      return totalCalories.round();
    } catch (e) {
      print('Error getting calories: $e');
      return 0;
    }
  }

  // Get distance for today (in meters)
  Future<double> getTodayDistance() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      // Fetch distance delta
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        startTime: midnight,
        endTime: now,
        types: [HealthDataType.DISTANCE_DELTA],
      );

      // Sum up the values
      double totalDistance = 0;
      for (var point in healthData) {
        if (point.value is NumericHealthValue) {
          totalDistance += (point.value as NumericHealthValue).numericValue;
        }
      }
      return totalDistance;
    } catch (e) {
      print('Error getting distance: $e');
      return 0.0;
    }
  }

  // Debug method to check raw data
  Future<void> debugPrintHealthData() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
      startTime: midnight,
      endTime: now,
      types: _types,
    );

    print('--- HEALTH DATA DEBUG ---');
    print('Found ${healthData.length} data points today');
    for (var point in healthData) {
      print('${point.type}: ${point.value}');
    }
    print('-------------------------');
  }
}
