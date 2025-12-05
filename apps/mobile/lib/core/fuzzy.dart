import 'dart:math' as math;
import 'constants.dart';

abstract class MembershipFunction {
  double mu(double x);
}

class TriangularMF implements MembershipFunction {
  final double a, b, c;
  const TriangularMF(this.a, this.b, this.c);

  @override
  double mu(double x) {
    if (x <= a || x >= c) return 0.0;
    if (x == b) return 1.0;
    if (x > a && x < b) return (x - a) / (b - a);
    return (c - x) / (c - b);
  }
}

class TrapezoidalMF implements MembershipFunction {
  final double a, b, c, d;
  const TrapezoidalMF(this.a, this.b, this.c, this.d);

  @override
  double mu(double x) {
    if (x <= a) return 0.0;
    if (x >= b && x <= c) return 1.0;
    if (x > a && x < b) return (x - a) / (b - a);
    if (x > c && x < d) return (d - x) / (d - c);
    // For open-ended trapezoid (c == d), stay at 1.0 for x >= c
    if (c == d && x >= c) return 1.0;
    if (x >= d) return 0.0;
    return 0.0;
  }
}

// FUZZY VARIABLES

class FuzzyVariable {
  final String name;
  final double minX;
  final double maxX;
  final Map<String, MembershipFunction> terms;

  const FuzzyVariable({
    required this.name,
    required this.minX,
    required this.maxX,
    required this.terms,
  });
}

// NOTIFICATION SEVERITY FUZZY SYSTEM

class NotificationSeverityService {
  // Ideal ranges - using ThresholdConst for consistency
  static const double _phIdealMin = ThresholdConst.phMin;
  static const double _phIdealMax = ThresholdConst.phMax;
  static const double _ppmIdealMin = ThresholdConst.ppmMin;
  static const double _ppmIdealMax = ThresholdConst.ppmMax;
  static const double _tempIdealMin = ThresholdConst.tempMin;
  static const double _tempIdealMax = ThresholdConst.tempMax;
  static const double _waterIdealMin = ThresholdConst.wlMin;
  static const double _waterIdealMax = ThresholdConst.wlMax;

  /// Calculate deviation percentage from ideal range
  double _calculateDeviation(double value, double idealMin, double idealMax) {
    if (value >= idealMin && value <= idealMax) {
      return 0.0; // Within ideal range
    }

    if (value < idealMin) {
      // Below ideal - calculate how far below as percentage
      final range = idealMax - idealMin;
      final deviation = idealMin - value;
      return (deviation / range) * 100.0;
    } else {
      // Above ideal - calculate how far above as percentage
      final range = idealMax - idealMin;
      final deviation = value - idealMax;
      return (deviation / range) * 100.0;
    }
  }

  /// Evaluate severity level based on telemetry values
  /// Returns: 'info', 'warning', or 'urgent'
  String evaluateSeverity({
    required double ph,
    required double ppm,
    required double temp,
    required double waterLevel,
  }) {
    // Calculate deviations (0-100+)
    final phDev = _calculateDeviation(ph, _phIdealMin, _phIdealMax);
    final ppmDev = _calculateDeviation(ppm, _ppmIdealMin, _ppmIdealMax);
    final tempDev = _calculateDeviation(temp, _tempIdealMin, _tempIdealMax);
    final waterDev = _calculateDeviation(
      waterLevel,
      _waterIdealMin,
      _waterIdealMax,
    );

    print('[Fuzzy] Deviations: ph=$phDev%, ppm=$ppmDev%, temp=$tempDev%, water=$waterDev%');

    // Fuzzy membership functions for deviation
    // low: 0-20%, medium: 15-50%, high: 45%+
    final lowMF = TrapezoidalMF(0, 0, 10, 20);
    final mediumMF = TriangularMF(15, 30, 50);
    final highMF = TrapezoidalMF(45, 60, 200, 200);

    // Calculate max deviation membership for each level
    final deviations = [phDev, ppmDev, tempDev, waterDev];

    double maxLow = 0.0;
    double maxMedium = 0.0;
    double maxHigh = 0.0;

    for (final dev in deviations) {
      maxLow = math.max(maxLow, lowMF.mu(dev));
      maxMedium = math.max(maxMedium, mediumMF.mu(dev));
      maxHigh = math.max(maxHigh, highMF.mu(dev));
    }

    print('[Fuzzy] Memberships: maxLow=$maxLow, maxMedium=$maxMedium, maxHigh=$maxHigh');

    // Count how many parameters have significant deviations
    int mediumCount = 0;
    for (final dev in deviations) {
      if (dev >= 20 && dev < 50) mediumCount++;
    }

    // Decision logic
    // If any parameter is highly deviated → urgent
    if (maxHigh > 0.5) {
      print('[Fuzzy] Result: urgent (maxHigh > 0.5)');
      return 'urgent';
    }

    // If multiple parameters have medium deviation → urgent
    if (mediumCount >= 2) {
      print('[Fuzzy] Result: urgent (mediumCount >= 2)');
      return 'urgent';
    }

    // If any parameter has medium deviation → warning
    if (maxMedium > 0.5) {
      print('[Fuzzy] Result: warning (maxMedium > 0.5)');
      return 'warning';
    }

    // All parameters are within acceptable range → info
    print('[Fuzzy] Result: info (no significant deviation)');
    return 'info';
  }

  /// severity analysis
  Map<String, dynamic> analyzeDetailed({
    required double ph,
    required double ppm,
    required double temp,
    required double waterLevel,
  }) {
    final phDev = _calculateDeviation(ph, _phIdealMin, _phIdealMax);
    final ppmDev = _calculateDeviation(ppm, _ppmIdealMin, _ppmIdealMax);
    final tempDev = _calculateDeviation(temp, _tempIdealMin, _tempIdealMax);
    final waterDev = _calculateDeviation(
      waterLevel,
      _waterIdealMin,
      _waterIdealMax,
    );

    final severity = evaluateSeverity(
      ph: ph,
      ppm: ppm,
      temp: temp,
      waterLevel: waterLevel,
    );

    return {
      'severity': severity,
      'deviations': {
        'ph': phDev.toStringAsFixed(1),
        'ppm': ppmDev.toStringAsFixed(1),
        'temp': tempDev.toStringAsFixed(1),
        'water': waterDev.toStringAsFixed(1),
      },
      'maxDeviation': math
          .max(math.max(phDev, ppmDev), math.max(tempDev, waterDev))
          .toStringAsFixed(1),
    };
  }
}
