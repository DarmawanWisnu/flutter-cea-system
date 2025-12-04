import 'dart:math' as math;

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
    if (x <= a || x >= d) return 0.0;
    if (x >= b && x <= c) return 1.0;
    if (x > a && x < b) return (x - a) / (b - a);
    return (d - x) / (d - c);
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
  // Ideal ranges
  static const double _phIdealMin = 5.5;
  static const double _phIdealMax = 6.5;
  static const double _ppmIdealMin = 560.0;
  static const double _ppmIdealMax = 840.0;
  static const double _tempIdealMin = 18.0;
  static const double _tempIdealMax = 24.0;
  static const double _waterIdealMin = 1.2;
  static const double _waterIdealMax = 2.5;

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

    // Count how many parameters have significant deviations
    int mediumCount = 0;
    for (final dev in deviations) {
      if (dev >= 20 && dev < 50) mediumCount++;
    }

    // Decision logic
    // If any parameter is highly deviated → urgent
    if (maxHigh > 0.5) {
      return 'urgent';
    }

    // If multiple parameters have medium deviation → urgent
    if (mediumCount >= 2) {
      return 'urgent';
    }

    // If any parameter has medium deviation → warning
    if (maxMedium > 0.5) {
      return 'warning';
    }

    // All parameters are within acceptable range → info
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
