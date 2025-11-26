import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fountaine/providers/provider/api_kits_provider.dart';
import 'package:fountaine/core/constants.dart';

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
    _kitsSub = ref.listen(apiKitsProvider, (prev, next) {
      next.whenData((kits) => _evaluateAll(kits));
    });

    Future.microtask(() async {
      final kits = ref.read(apiKitsProvider).value ?? [];
      if (!_hasAnyViolationNow(kits)) {
        _emitSafeInfo();
      }
    });

    _safeTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final kits = ref.read(apiKitsProvider).value ?? [];
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

  // Threshold
  static const double _phMin = ThresholdConst.phMin;
  static const double _phMax = ThresholdConst.phMax;
  static const double _ppmMin = ThresholdConst.ppmMin;
  static const double _ppmMax = ThresholdConst.ppmMax;
  static const double _humMin = ThresholdConst.wlMinPercent;
  static const double _humMax = ThresholdConst.wlMaxPercent;
  static const double _tMin = ThresholdConst.tempMin;
  static const double _tMax = ThresholdConst.tempMax;

  // Helpers
  Map<String, dynamic>? _telemetryOf(Map<String, dynamic> kit) {
    final t = kit['telemetry'];
    if (t is Map<String, dynamic>) return t;
    return null;
  }

  double? _get(Map<String, dynamic>? t, String key) {
    if (t == null) return null;
    final v = t[key];
    if (v is num) return v.toDouble();
    return null;
  }

  bool _hasAnyViolationNow(List<Map<String, dynamic>> kits) {
    for (final kit in kits) {
      final t = _telemetryOf(kit);
      final ph = _get(t, 'ph');
      if (ph != null && (ph < _phMin || ph > _phMax)) return true;

      final ppm = _get(t, 'ppm');
      if (ppm != null && (ppm < _ppmMin || ppm > _ppmMax)) return true;

      final hum = _get(t, 'humidity');
      if (hum != null && (hum < _humMin || hum > _humMax)) return true;

      final temp = _get(t, 'tempC');
      if (temp != null && (temp < _tMin || temp > _tMax)) return true;
    }
    return false;
  }

  void _evaluateAll(List<Map<String, dynamic>> kits) {
    for (final kit in kits) {
      _checkThreshold(kit);
    }
  }

  void _checkThreshold(Map<String, dynamic> kit) {
    final name = kit['name'];
    final t = _telemetryOf(kit);
    if (t == null) return;

    final ph = _get(t, 'ph');
    final ppm = _get(t, 'ppm');
    final hum = _get(t, 'humidity');
    final temp = _get(t, 'tempC');

    if (ph != null && (ph < _phMin || ph > _phMax)) {
      _emitThreshold(
        kitName: name,
        param: 'pH',
        message:
            'pH ${ph < _phMin ? "Dropped" : "Spiked"} to ${ph.toStringAsFixed(2)}',
        dir: ph < _phMin ? 'below' : 'above',
      );
    }

    if (ppm != null && (ppm < _ppmMin || ppm > _ppmMax)) {
      _emitThreshold(
        kitName: name,
        param: 'PPM',
        message:
            'PPM ${ppm < _ppmMin ? "Dropped" : "Spiked"} to ${ppm.toStringAsFixed(0)}',
        dir: ppm < _ppmMin ? 'below' : 'above',
      );
    }

    if (hum != null && (hum < _humMin || hum > _humMax)) {
      _emitThreshold(
        kitName: name,
        param: 'Humidity',
        message: 'Humidity ${hum.toStringAsFixed(1)}%',
        dir: hum < _humMin ? 'below' : 'above',
      );
    }

    if (temp != null && (temp < _tMin || temp > _tMax)) {
      _emitThreshold(
        kitName: name,
        param: 'Temperature',
        message: 'Temperature ${temp.toStringAsFixed(1)} °C',
        dir: temp < _tMin ? 'below' : 'above',
      );
    }
  }

  void _emitThreshold({
    required String kitName,
    required String param,
    required String message,
    required String dir,
  }) {
    final key = '$kitName:$param:$dir';
    final now = DateTime.now();

    final last = _lastAlertAt[key];
    if (last != null && now.difference(last) < _cooldown) return;

    _lastAlertAt[key] = now;

    final n = NotificationItem(
      id: now.millisecondsSinceEpoch.toString(),
      level: 'warning',
      title: 'Warning',
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
        now.difference(lastInfo.first.timestamp).inSeconds < 30)
      return;

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
