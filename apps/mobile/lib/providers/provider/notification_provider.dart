import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/constants.dart';
import '../../domain/telemetry.dart';
import './api_provider.dart';
import './mqtt_provider.dart';

String _norm(String? s) => (s ?? '').trim().toLowerCase();

class NotificationItem {
  final String id;
  final String level; // 'urgent', 'warning', 'info'
  final String title;
  final String message;
  final DateTime timestamp;
  final String? kitName;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.level,
    required this.title,
    required this.message,
    required this.timestamp,
    this.kitName,
    this.isRead = false,
  });

  NotificationItem copyWith({bool? isRead}) => NotificationItem(
    id: id,
    level: level,
    title: title,
    message: message,
    timestamp: timestamp,
    kitName: kitName,
    isRead: isRead ?? this.isRead,
  );
}

class NotificationListNotifier extends StateNotifier<List<NotificationItem>> {
  NotificationListNotifier(this.ref) : super([]) {
    print('[Notification] ===== INITIALIZED =====');
    
    // Listen to current kit ID changes
    _kitIdSub = ref.listen(currentKitIdProvider, (prev, next) {
      print('[Notification] Kit changed: $prev -> $next');
      if (next != null) {
        _fetchAndEvaluate(next);
      }
    });

    // Initial evaluation
    Future.microtask(() {
      final kitId = ref.read(currentKitIdProvider);
      print('[Notification] Initial kit: $kitId');
      if (kitId != null) {
        _fetchAndEvaluate(kitId);
      }
    });

    // Periodic check every 1 minute
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      final kitId = ref.read(currentKitIdProvider);
      print('[Notification] ===== PERIODIC (1m) kit=$kitId =====');
      if (kitId != null) {
        _fetchAndEvaluate(kitId);
      }
    });
  }

  final Ref ref;
  Timer? _timer;
  ProviderSubscription? _kitIdSub;
  final Map<String, DateTime> _cooldowns = {};
  
  // Cooldown: 20 seconds between same notification type
  static const Duration _cooldown = Duration(seconds: 20);

  // Thresholds from constants
  static const double _phMin = ThresholdConst.phMin;
  static const double _phMax = ThresholdConst.phMax;
  static const double _ppmMin = ThresholdConst.ppmMin;
  static const double _ppmMax = ThresholdConst.ppmMax;
  static const double _wlMin = ThresholdConst.wlMin;
  static const double _wlMax = ThresholdConst.wlMax;
  static const double _tMin = ThresholdConst.tempMin;
  static const double _tMax = ThresholdConst.tempMax;

  /// Check if device is in auto mode
  bool _isAutoMode(String kitId) {
    try {
      return ref.read(mqttProvider).isAutoMode(kitId);
    } catch (_) {
      return false;
    }
  }

  /// Calculate deviation percentage from threshold
  double _deviation(double value, double min, double max) {
    final range = max - min;
    if (range <= 0) return 0;
    if (value < min) return ((min - value) / range) * 100;
    if (value > max) return ((value - max) / range) * 100;
    return 0;
  }

  /// Determine severity based on deviation
  /// URGENT: any deviation > 50% OR multiple deviations > 20%
  /// WARNING: any deviation > 0%
  String _determineSeverity(double phDev, double ppmDev, double tempDev, double wlDev) {
    final deviations = [phDev, ppmDev, tempDev, wlDev];
    
    // Count significant deviations
    final highCount = deviations.where((d) => d > 50).length;
    final medCount = deviations.where((d) => d > 20).length;
    
    // URGENT: any high deviation OR multiple medium deviations
    if (highCount >= 1 || medCount >= 2) {
      return 'urgent';
    }
    
    // WARNING: any deviation at all
    return 'warning';
  }

  /// Fetch telemetry from DB and evaluate
  Future<void> _fetchAndEvaluate(String kitId) async {
    try {
      final api = ref.read(apiServiceProvider);
      final t = await api.getLatestTelemetry(kitId);
      
      if (t == null) {
        print('[Notification] No telemetry for $kitId');
        return;
      }
      
      await _evaluate(kitId, t);
    } catch (e) {
      print('[Notification] Error: $e');
    }
  }

  Future<void> _evaluate(String kitId, Telemetry t) async {
    final isAuto = _isAutoMode(kitId);
    
    // Calculate deviations
    final phDev = _deviation(t.ph, _phMin, _phMax);
    final ppmDev = _deviation(t.ppm, _ppmMin, _ppmMax);
    final tempDev = _deviation(t.tempC, _tMin, _tMax);
    final wlDev = _deviation(t.waterLevel, _wlMin, _wlMax);
    
    final hasViolation = phDev > 0 || ppmDev > 0 || tempDev > 0 || wlDev > 0;
    
    print('[Notification] isAuto=$isAuto, hasViolation=$hasViolation');
    print('[Notification] Deviations: ph=${phDev.toStringAsFixed(1)}%, ppm=${ppmDev.toStringAsFixed(1)}%, temp=${tempDev.toStringAsFixed(1)}%, wl=${wlDev.toStringAsFixed(1)}%');

    // CASE 1: No violation
    if (!hasViolation) {
      // Only show "All Safe" if no recent urgent/warning (5 min)
      final now = DateTime.now();
      final hasRecentIssue = state.any((n) =>
          (n.level == 'urgent' || n.level == 'warning') &&
          now.difference(n.timestamp).inMinutes < 5);
      
      if (!hasRecentIssue) {
        _emit(kitId, 'info', 'All Parameters Within Safe Limits');
      } else {
        print('[Notification] Skip "All Safe" - recent issues exist');
      }
      return;
    }

    // CASE 2: Has violation - build message
    final violations = <String>[];
    if (t.ph < _phMin) violations.add('pH Low: ${t.ph.toStringAsFixed(2)}');
    if (t.ph > _phMax) violations.add('pH High: ${t.ph.toStringAsFixed(2)}');
    if (t.ppm < _ppmMin) violations.add('PPM Low: ${t.ppm.toStringAsFixed(0)}');
    if (t.ppm > _ppmMax) violations.add('PPM High: ${t.ppm.toStringAsFixed(0)}');
    if (t.waterLevel < _wlMin) violations.add('Water Low: ${t.waterLevel.toStringAsFixed(1)}');
    if (t.waterLevel > _wlMax) violations.add('Water High: ${t.waterLevel.toStringAsFixed(1)}');
    if (t.tempC < _tMin) violations.add('Temp Low: ${t.tempC.toStringAsFixed(1)}°C');
    if (t.tempC > _tMax) violations.add('Temp High: ${t.tempC.toStringAsFixed(1)}°C');
    
    final message = violations.join(', ');

    if (isAuto) {
      // AUTO MODE: Fetch latest actuator event and show what was done
      await _emitAutoModeNotification(kitId, message);
    } else {
      // MANUAL MODE: Determine severity based on deviation
      final severity = _determineSeverity(phDev, ppmDev, tempDev, wlDev);
      print('[Notification] MANUAL - severity=$severity');
      _emit(kitId, severity, message);
    }
  }

  /// Fetch actuator event and emit user-friendly auto mode notification
  Future<void> _emitAutoModeNotification(String kitId, String fallbackMsg) async {
    try {
      final api = ref.read(apiServiceProvider);
      final event = await api.getLatestActuatorEvent(kitId);
      
      if (event != null) {
        final actions = <String>[];
        
        // Format each action with duration
        final phUp = event['phUp'] as int? ?? 0;
        final phDown = event['phDown'] as int? ?? 0;
        final nutrient = event['nutrientAdd'] as int? ?? 0;
        final refill = event['refill'] as int? ?? 0;
        
        if (phUp > 0) actions.add('pH Up: ${phUp}s');
        if (phDown > 0) actions.add('pH Down: ${phDown}s');
        if (nutrient > 0) actions.add('Nutrient: ${nutrient}s');
        if (refill > 0) actions.add('Refill: ${refill}s');
        
        if (actions.isNotEmpty) {
          final msg = 'Auto adjustment: ${actions.join(', ')}';
          print('[Notification] AUTO - $msg');
          _emit(kitId, 'info', msg);
          return;
        }
      }
      
      // Fallback if no action found
      _emit(kitId, 'info', 'Auto mode: Monitoring $fallbackMsg');
    } catch (e) {
      print('[Notification] Error fetching actuator: $e');
      _emit(kitId, 'info', 'Auto mode active');
    }
  }

  void _emit(String kitId, String level, String message) {
    final key = '$kitId:$level';
    final now = DateTime.now();

    // Cooldown check
    final last = _cooldowns[key];
    if (last != null && now.difference(last) < _cooldown) {
      print('[Notification] Cooldown: $key');
      return;
    }
    _cooldowns[key] = now;

    final n = NotificationItem(
      id: now.millisecondsSinceEpoch.toString(),
      level: level,
      title: level == 'urgent' ? 'Urgent' : (level == 'warning' ? 'Warning' : 'Info'),
      message: message,
      timestamp: now,
      kitName: kitId,
    );

    print('[Notification] ADDED: level=$level, message=$message');
    state = [n, ...state];
  }

  void markAllRead() {
    state = [for (final n in state) n.copyWith(isRead: true)];
  }

  void markRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
  }

  void delete(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  void clearAll() {
    state = [];
  }

  @override
  void dispose() {
    _timer?.cancel();
    _kitIdSub?.close();
    super.dispose();
  }
}

// PROVIDERS
final notificationListProvider =
    StateNotifierProvider<NotificationListNotifier, List<NotificationItem>>((ref) {
      ref.keepAlive();
      return NotificationListNotifier(ref);
    });

final filteredNotificationProvider =
    Provider.family<List<NotificationItem>, String?>((ref, level) {
      final list = ref.watch(notificationListProvider);
      final key = _norm(level);

      if (level == null || key.isEmpty || key == 'all') {
        return [...list]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }

      final filtered = list.where((n) => _norm(n.level) == key).toList();
      filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return filtered;
    });

final unreadNotificationCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificationListProvider);
  return list.where((n) => !n.isRead).length;
});
