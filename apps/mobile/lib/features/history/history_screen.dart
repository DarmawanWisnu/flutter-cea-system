import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/provider/notification_provider.dart';
import '../../providers/provider/api_provider.dart';
import '../../providers/provider/auth_provider.dart';
import '../../domain/telemetry.dart';
import '../../models/nav_args.dart';
import '../../l10n/app_localizations.dart';

// Time filter options (within selected day)
enum TimeFilter { all, hour1, hour6 }

class HistoryScreen extends ConsumerStatefulWidget {
  final String? kitId;
  final DateTime? targetTime;
  final bool embedded;
  const HistoryScreen({
    super.key,
    this.kitId,
    this.targetTime,
    this.embedded = false,
  });

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  DateTime? selectedDate;
  TimeFilter _timeFilter = TimeFilter.all;
  bool _sortDesc = true;
  bool _inited = false;

  final ScrollController _scroll = ScrollController();
  final Map<int, GlobalKey> _itemKeys = {};
  DateTime? _pendingTargetTime;

  List<Map<String, dynamic>> _entries = [];
  bool _isLoading = false;
  Timer? _refreshTimer;

  int _displayCount = 10;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;
    _inited = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is HistoryRouteArgs && args.kitId != null) {
        await _loadData(args.kitId!, days: 7);
        if (widget.targetTime != null || args.targetTime != null) {
          _pendingTargetTime = widget.targetTime ?? args.targetTime;
          selectedDate = DateTime(
            _pendingTargetTime!.year,
            _pendingTargetTime!.month,
            _pendingTargetTime!.day,
          );
        }
      } else {
        String? kitToLoad = ref.read(currentKitIdProvider);

        if (kitToLoad == null) {
          final api = ref.read(apiServiceProvider);
          final user = ref.read(authProvider);

          List<Map<String, dynamic>> userKits = [];
          try {
            userKits = await ref.read(apiKitsListProvider.future);
          } catch (_) {}

          final kitIds = userKits.map((k) => k["id"] as String).toList();

          if (user != null && kitIds.isNotEmpty) {
            try {
              final savedKit = await api.getUserPreference(userId: user.uid);
              if (savedKit != null && kitIds.contains(savedKit)) {
                kitToLoad = savedKit;
                ref.read(currentKitIdProvider.notifier).state = savedKit;
              }
            } catch (_) {}
          }

          if (kitToLoad == null && kitIds.isNotEmpty) {
            kitToLoad = kitIds.first;
            ref.read(currentKitIdProvider.notifier).state = kitToLoad;
          }
        }

        if (kitToLoad != null) {
          await _loadData(kitToLoad, days: 1);
        }
      }

      if (mounted) setState(() {});

      _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        if (mounted && selectedDate == null) {
          final currentKit = ref.read(currentKitIdProvider);
          if (currentKit != null) {
            _loadData(currentKit, days: 1);
          }
        }
      });
    });
  }

  void _resetScroll() {
    if (_scroll.hasClients) {
      _scroll.jumpTo(0);
    }
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;

    if (_scroll.position.atEdge && _scroll.position.pixels != 0) {
      final filtered = _getFiltered();
      if (_displayCount < filtered.length) {
        setState(() {
          _displayCount += _pageSize;
        });
      }
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadData(String kitId, {int days = 1}) async {
    setState(() {
      _isLoading = true;
      _displayCount = _pageSize;
    });

    final limit = days == 1 ? 2880 : 20160;

    try {
      final api = ref.read(apiServiceProvider);
      final res = await api.getJson(
        "/telemetry/history?deviceId=$kitId&days=$days&limit=$limit",
      );

      final List items = res["items"] ?? [];
      _entries = items.map((e) {
        final t = Telemetry.fromJson(e["data"]);
        final ts = e["ingestTime"] as int;
        return {"t": t, "ts": ts};
      }).toList();
    } catch (_) {
      _entries = [];
    }

    if (mounted) {
      setState(() => _isLoading = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resetScroll();
      });
    }
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return l10n.commonToday;
    if (dateOnly == yesterday) return l10n.commonYesterday;
    return DateFormat('EEE, d MMM').format(date);
  }

  List<Map<String, dynamic>> _getFiltered() {
    final now = DateTime.now();
    final targetDate = selectedDate ?? DateTime(now.year, now.month, now.day);

    var filtered = _entries.where((e) {
      final ts = e['ts'] as int;
      final d = DateTime.fromMillisecondsSinceEpoch(ts);
      return d.year == targetDate.year &&
          d.month == targetDate.month &&
          d.day == targetDate.day;
    }).toList();

    if (selectedDate == null && _timeFilter != TimeFilter.all) {
      final hoursBack = _timeFilter == TimeFilter.hour1 ? 1 : 6;
      final cutoff = now.subtract(Duration(hours: hoursBack));
      filtered = filtered.where((e) {
        final ts = e['ts'] as int;
        final d = DateTime.fromMillisecondsSinceEpoch(ts);
        return d.isAfter(cutoff);
      }).toList();
    }

    filtered.sort(
      (a, b) => _sortDesc
          ? (b['ts'] as int).compareTo(a['ts'] as int)
          : (a['ts'] as int).compareTo(b['ts'] as int),
    );

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final currentKit = ref.watch(currentKitIdProvider);
    final unread = ref.watch(unreadNotificationCountProvider);
    final filtered = _getFiltered();
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pendingTargetTime != null && filtered.isNotEmpty) {
        _jumpToTarget(_pendingTargetTime!, filtered);
        _pendingTargetTime = null;
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        primary: !widget.embedded,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.historyTitle,
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: .2,
          ),
        ),
        centerTitle: true,
        actions: [
          if (currentKit != null)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  currentKit,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              ),
            )
          else
            IconButton(
              icon: Icon(Icons.refresh, color: colorScheme.primary),
              onPressed: () {
                if (currentKit != null) {
                  _loadData(currentKit, days: selectedDate != null ? 7 : 1);
                }
              },
            ),
        ],
      ),
      body: currentKit == null
          ? _buildNoKit(context, l10n)
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showDatePicker(currentKit, colorScheme),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 18,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  selectedDate == null
                                      ? l10n.commonToday
                                      : _formatDate(selectedDate!, l10n),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: colorScheme.primary.withValues(alpha: 0.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (selectedDate != null) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            setState(() {
                              selectedDate = null;
                              _timeFilter = TimeFilter.all;
                            });
                            await _loadData(currentKit, days: 1);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.red[400],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (selectedDate == null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      children: [
                        _filterChip(context, l10n.commonAll, TimeFilter.all),
                        const SizedBox(width: 8),
                        _filterChip(context, '1h', TimeFilter.hour1),
                        const SizedBox(width: 8),
                        _filterChip(context, '6h', TimeFilter.hour6),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => setState(() => _sortDesc = !_sortDesc),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _sortDesc
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  size: 14,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _sortDesc ? l10n.commonNew : l10n.commonOld,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: filtered.isEmpty
                      ? _buildEmpty(context, l10n)
                      : _buildList(context, filtered, currentKit, l10n),
                ),
              ],
            ),
      floatingActionButton: widget.embedded
          ? null
          : FloatingActionButton(
              backgroundColor: colorScheme.primary,
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/notifications',
                  arguments: const NotificationRouteArgs(initialFilter: 'info'),
                );
              },
              child: Badge(
                isLabelVisible: unread > 0,
                label: Text(unread > 9 ? '9+' : '$unread'),
                child: Icon(
                  Icons.notifications_outlined,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
    );
  }

  void _showDatePicker(String currentKit, ColorScheme colorScheme) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final today = DateTime.now();
      final isToday =
          picked.year == today.year &&
          picked.month == today.month &&
          picked.day == today.day;

      setState(() {
        selectedDate = isToday ? null : picked;
        _timeFilter = TimeFilter.all;
      });
      await _loadData(currentKit, days: isToday ? 1 : 7);
    }
  }

  Widget _filterChip(BuildContext context, String label, TimeFilter filter) {
    final isSelected = _timeFilter == filter;
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _timeFilter = filter;
          _displayCount = _pageSize;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _resetScroll();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildNoKit(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sensors_off, size: 48, color: colorScheme.primary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            l10n.historyNoKitSelected,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.historySelectKitFirst,
            style: TextStyle(fontSize: 14, color: colorScheme.primary.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: colorScheme.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.historyNoData,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.historyNoReadings,
            style: TextStyle(fontSize: 14, color: colorScheme.primary.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Map<String, dynamic>> data, String kitId, AppLocalizations l10n) {
    final displayData = data.take(_displayCount).toList();
    final hasMore = data.length > _displayCount;
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () async {
        await _loadData(kitId, days: selectedDate != null ? 7 : 1);
      },
      color: colorScheme.primary,
      backgroundColor: colorScheme.surface,
      child: Scrollbar(
        controller: _scroll,
        thumbVisibility: true,
        interactive: true,
        child: ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          itemCount: displayData.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == displayData.length && hasMore) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    l10n.historyScrollMore(data.length - _displayCount),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.primary.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              );
            }

            final item = displayData[index];
            final Telemetry t = item['t'];
            final ts = item['ts'] as int;
            final date = DateTime.fromMillisecondsSinceEpoch(ts);
            final key = _itemKeys.putIfAbsent(ts, () => GlobalKey());

            return Container(
              key: key,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: colorScheme.primary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('HH:mm:ss').format(date),
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.primary.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _sensorValue(context, l10n.sensorPh, t.ph.toStringAsFixed(2)),
                      _sensorValue(context, l10n.sensorTds, '${t.ppm.toInt()} ppm'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _sensorValue(
                        context,
                        l10n.sensorHumidity,
                        '${t.humidity.toStringAsFixed(1)}%',
                      ),
                      _sensorValue(context, l10n.sensorTemp, '${t.tempC.toStringAsFixed(1)}°C'),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _sensorValue(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Expanded(
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 13, color: colorScheme.primary.withValues(alpha: 0.6)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _jumpToTarget(DateTime target, List<Map<String, dynamic>> data) {
    int? keyTs;
    Duration best = const Duration(days: 9999);

    for (final it in data) {
      final ts = it['ts'] as int;
      final diff = DateTime.fromMillisecondsSinceEpoch(
        ts,
      ).difference(target).abs();
      if (diff < best) {
        best = diff;
        keyTs = ts;
      }
    }

    if (keyTs == null) return;

    final ctx = _itemKeys[keyTs]?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
  }
}
