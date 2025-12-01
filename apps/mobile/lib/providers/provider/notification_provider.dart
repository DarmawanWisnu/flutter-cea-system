import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/constants.dart';
import '../../core/fuzzy.dart';
import './api_provider.dart';

String _norm(String? s) => (s ?? '').trim().toLowerCase();

class NotificationItem {
  final String id;
  final String level;
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
    // listen perubahan kit list
    _kitsSub = ref.listen(apiKitsListProvider, (prev, next) {
      next.whenData((kits) => _evaluateAll(kits));
    });

    // evaluasi awal setelah app load
    Future.microtask(() {
      final kits = ref.read(apiKitsListProvider).value ?? [];
      if (!_hasAnyViolationNow(kits)) {
        _emitSafeInfo();
      }
    });

    // periodic safety check
    _safeTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final kits = ref.read(apiKitsListProvider).value ?? [];
      final now = DateTime.now();
      final last1m = now.subtract(const Duration(minutes: 1));

      final hasRecentWarning = state.any(
        (n) => _norm(n.level) != 'info' && n.timestamp.isAfter(last1m),
      );

      if (!hasRecentWarning && !_hasAnyViolationNow(kits)) {
        _emitSafeInfo();
      }
    });
  }

  final Ref ref;
  Timer? _safeTimer;
  ProviderSubscription? _kitsSub;
  final Map<String, DateTime> _lastAlertAt = {};
  static const Duration _cooldown = Duration(seconds: 20);

  // Fuzzy logic service for severity determination
  final _fuzzyService = NotificationSeverityService();

  // Threshold - Warning levels (still used for detection)
  static const double _phMin = ThresholdConst.phMin;
  static const double _phMax = ThresholdConst.phMax;
  static const double _ppmMin = ThresholdConst.ppmMin;
  static const double _ppmMax = ThresholdConst.ppmMax;
  static const double _wlMin = ThresholdConst.wlMin;
  static const double _wlMax = ThresholdConst.wlMax;
  static const double _tMin = ThresholdConst.tempMin;
  static const double _tMax = ThresholdConst.tempMax;

  // helpers
  Map<String, dynamic>? _telemetryOf(Map<String, dynamic> kit) {
    final t = kit["telemetry"];
    if (t is Map<String, dynamic>) return t;
    return null;
  }

  double? _get(Map<String, dynamic>? t, String key) {
    if (t == null) return null;
    final v = t[key];
    if (v is num) return v.toDouble();
    return null;
  }

  // cek apakah ada pelanggaran threshold
  bool _hasAnyViolationNow(List<Map<String, dynamic>> kits) {
    for (final kit in kits) {
      final t = _telemetryOf(kit);
      final ph = _get(t, 'ph');
      if (ph != null && (ph < _phMin || ph > _phMax)) return true;

      final ppm = _get(t, 'ppm');
      if (ppm != null && (ppm < _ppmMin || ppm > _ppmMax)) return true;

      final wl = _get(t, 'waterLevel');
      if (wl != null && (wl < _wlMin || wl > _wlMax)) return true;

      final temp = _get(t, 'tempC');
      if (temp != null && (temp < _tMin || temp > _tMax)) return true;
    }
    return false;
  }

  // evaluate semua kit
  void _evaluateAll(List<Map<String, dynamic>> kits) {
    for (final kit in kits) {
      _checkThreshold(kit);
    }
  }

  void _checkThreshold(Map<String, dynamic> kit) {
    final name = kit['name'];
    final t = _telemetryOf(kit);
    if (t == null) return;

    final ph = _get(t, 'ph') ?? 6.0;
    final ppm = _get(t, 'ppm') ?? 700.0;
    final wl = _get(t, 'waterLevel') ?? 1.8;
    final temp = _get(t, 'tempC') ?? 21.0;

    // Check if any parameter is out of ideal range
    final hasViolation =
        (ph < _phMin || ph > _phMax) ||
        (ppm < _ppmMin || ppm > _ppmMax) ||
        (wl < _wlMin || wl > _wlMax) ||
        (temp < _tMin || temp > _tMax);

    if (!hasViolation) {
      // All parameters normal - emit info notification periodically
      _emitThreshold(
        kitName: name,
        param: 'System',
        message: 'All Parameters Within Safe Limits',
        dir: 'normal',
        level: 'info',
      );
      return;
    }

    // Use fuzzy logic to determine severity
    final severity = _fuzzyService.evaluateSeverity(
      ph: ph,
      ppm: ppm,
      temp: temp,
      waterLevel: wl,
    );

    // Build detailed message
    final violations = <String>[];
    if (ph < _phMin) violations.add('pH Low: ${ph.toStringAsFixed(2)}');
    if (ph > _phMax) violations.add('pH High: ${ph.toStringAsFixed(2)}');
    if (ppm < _ppmMin) violations.add('PPM Low: ${ppm.toStringAsFixed(0)}');
    if (ppm > _ppmMax) violations.add('PPM High: ${ppm.toStringAsFixed(0)}');
    if (wl < _wlMin) violations.add('Water Low: ${wl.toStringAsFixed(1)}');
    if (wl > _wlMax) violations.add('Water High: ${wl.toStringAsFixed(1)}');
    if (temp < _tMin) violations.add('Temp Low: ${temp.toStringAsFixed(1)}°C');
    if (temp > _tMax) violations.add('Temp High: ${temp.toStringAsFixed(1)}°C');

    final message = violations.join(', ');

    _emitThreshold(
      kitName: name,
      param: 'Telemetry',
      message: message,
      dir: 'deviation',
      level: severity,
    );
  }

  void _emitThreshold({
    required String kitName,
    required String param,
    required String message,
    required String dir,
    required String level,
  }) {
    final key = '$kitName:$param:$dir';
    final now = DateTime.now();

    // Cooldown check - prevents notification spam
    final last = _lastAlertAt[key];
    if (last != null && now.difference(last) < _cooldown) return;

    _lastAlertAt[key] = now;

    final n = NotificationItem(
      id: now.millisecondsSinceEpoch.toString(),
      level: level,
      title: level == 'urgent'
          ? 'Urgent'
          : (level == 'warning' ? 'Warning' : 'Info'),
      message: message,
      timestamp: now,
      kitName: kitName,
    );

    add(n);
  }

  void _emitSafeInfo() {
    final now = DateTime.now();

    final lastInfo = state.where((n) => n.level == 'info').toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (lastInfo.isNotEmpty &&
        now.difference(lastInfo.first.timestamp).inSeconds < 30) {
      return;
    }

    final n = NotificationItem(
      id: 'safe_${now.millisecondsSinceEpoch}',
      level: 'info',
      title: 'Info',
      message: 'All Parameters Are Within Safe Limits',
      timestamp: now,
    );

    add(n);
  }

  void add(NotificationItem n) {
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
    _safeTimer?.cancel();
    _kitsSub?.close();
    super.dispose();
  }
}

// PROVIDERS
final notificationListProvider =
    StateNotifierProvider.autoDispose<
      NotificationListNotifier,
      List<NotificationItem>
    >((ref) {
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
