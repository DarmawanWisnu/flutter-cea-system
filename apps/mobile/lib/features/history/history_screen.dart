import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/provider/notification_provider.dart';
import '../../providers/provider/api_provider.dart';
import '../../domain/telemetry.dart';
import '../../models/nav_args.dart';

// Match color scheme from other screens
const Color _kPrimary = Color(0xFF0E5A2A);
const Color _kBg = Color(0xFFF3F9F4);
const Color _kChipBg = Color(0xFFE8F2EC);

// Time filter options (within selected day)
enum TimeFilter { all, hour1, hour6 }

class HistoryScreen extends ConsumerStatefulWidget {
  final String? kitId;
  final DateTime? targetTime;
  const HistoryScreen({super.key, this.kitId, this.targetTime});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  DateTime? selectedDate; // null = today
  TimeFilter _timeFilter = TimeFilter.all;
  bool _sortDesc = true; // true = newest first, false = oldest first
  bool _inited = false;

  final ScrollController _scroll = ScrollController();
  final Map<int, GlobalKey> _itemKeys = {};
  DateTime? _pendingTargetTime;

  List<Map<String, dynamic>> _entries = [];
  bool _isLoading = false;
  Timer? _refreshTimer;

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
        final currentKit = ref.read(currentKitIdProvider);
        if (currentKit != null) {
          await _loadData(currentKit, days: 1);
        }
      }

      if (mounted) setState(() {});

      // Auto-refresh every 30 seconds (only for today)
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

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadData(String kitId, {int days = 1}) async {
    setState(() => _isLoading = true);
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
    } catch (e) {
      _entries = [];
    }

    if (mounted) setState(() => _isLoading = false);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == yesterday) return 'Yesterday';
    return DateFormat('EEE, d MMM').format(date);
  }

  // Filter entries by selected date AND time filter
  List<Map<String, dynamic>> _getFiltered() {
    final now = DateTime.now();
    final targetDate = selectedDate ?? DateTime(now.year, now.month, now.day);

    // First filter by date
    var filtered = _entries.where((e) {
      final ts = e['ts'] as int;
      final d = DateTime.fromMillisecondsSinceEpoch(ts);
      return d.year == targetDate.year &&
          d.month == targetDate.month &&
          d.day == targetDate.day;
    }).toList();

    // Then filter by time (only for today)
    if (selectedDate == null && _timeFilter != TimeFilter.all) {
      final hoursBack = _timeFilter == TimeFilter.hour1 ? 1 : 6;
      final cutoff = now.subtract(Duration(hours: hoursBack));
      filtered = filtered.where((e) {
        final ts = e['ts'] as int;
        final d = DateTime.fromMillisecondsSinceEpoch(ts);
        return d.isAfter(cutoff);
      }).toList();
    }

    // Apply sort order
    if (_sortDesc) {
      filtered.sort((a, b) => (b['ts'] as int).compareTo(a['ts'] as int));
    } else {
      filtered.sort((a, b) => (a['ts'] as int).compareTo(b['ts'] as int));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final currentKit = ref.watch(currentKitIdProvider);
    final unread = ref.watch(unreadNotificationCountProvider);
    final filtered = _getFiltered();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pendingTargetTime != null && filtered.isNotEmpty) {
        _jumpToTarget(_pendingTargetTime!, filtered);
        _pendingTargetTime = null;
      }
    });

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _kPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'History',
          style: TextStyle(
            color: _kPrimary,
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _kChipBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  currentKit,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kPrimary,
                  ),
                ),
              ),
            ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: _kPrimary),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh, color: _kPrimary),
              onPressed: () {
                if (currentKit != null) {
                  _loadData(currentKit, days: selectedDate != null ? 7 : 1);
                }
              },
            ),
        ],
      ),
      body: currentKit == null
          ? _buildNoKit()
          : Column(
              children: [
                // Date picker row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      // Date picker button
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showDatePicker(currentKit),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: _kChipBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 18,
                                  color: _kPrimary,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  selectedDate == null
                                      ? 'Today'
                                      : _formatDate(selectedDate!),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _kPrimary,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: _kPrimary.withOpacity(0.5),
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

                // Time filter chips (only for today)
                if (selectedDate == null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      children: [
                        _filterChip('All', TimeFilter.all),
                        const SizedBox(width: 8),
                        _filterChip('1h', TimeFilter.hour1),
                        const SizedBox(width: 8),
                        _filterChip('6h', TimeFilter.hour6),
                        const Spacer(),
                        // Sort toggle
                        GestureDetector(
                          onTap: () => setState(() => _sortDesc = !_sortDesc),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _kChipBg,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _sortDesc ? Icons.arrow_downward : Icons.arrow_upward,
                                  size: 14,
                                  color: _kPrimary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _sortDesc ? 'New' : 'Old',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _kPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Content
                Expanded(
                  child: filtered.isEmpty
                      ? _buildEmpty()
                      : _buildList(filtered, currentKit),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _kPrimary,
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
          child: const Icon(Icons.notifications_outlined, color: Colors.white),
        ),
      ),
    );
  }

  void _showDatePicker(String currentKit) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: _kPrimary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final today = DateTime.now();
      final isToday = picked.year == today.year &&
          picked.month == today.month &&
          picked.day == today.day;

      setState(() {
        selectedDate = isToday ? null : picked;
        _timeFilter = TimeFilter.all;
      });
      await _loadData(currentKit, days: isToday ? 1 : 7);
    }
  }

  Widget _filterChip(String label, TimeFilter filter) {
    final isSelected = _timeFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _timeFilter = filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _kPrimary : _kChipBg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : _kPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildNoKit() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sensors_off, size: 48, color: _kPrimary.withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text(
            'No kit selected',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _kPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a kit from Monitor first',
            style: TextStyle(fontSize: 14, color: _kPrimary.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: _kPrimary.withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text(
            'No data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _kPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No readings for this period',
            style: TextStyle(fontSize: 14, color: _kPrimary.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> data, String kitId) {
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        final Telemetry t = item['t'];
        final ts = item['ts'] as int;
        final date = DateTime.fromMillisecondsSinceEpoch(ts);

        final key = _itemKeys.putIfAbsent(ts, () => GlobalKey());

        return Container(
          key: key,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: _kPrimary.withOpacity(0.5)),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('HH:mm:ss').format(date),
                    style: TextStyle(
                      fontSize: 12,
                      color: _kPrimary.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Sensor values
              Row(
                children: [
                  _sensorValue('pH', t.ph.toStringAsFixed(2)),
                  _sensorValue('TDS', '${t.ppm.toInt()} ppm'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _sensorValue('Humidity', '${t.humidity.toStringAsFixed(1)}%'),
                  _sensorValue('Temp', '${t.tempC.toStringAsFixed(1)}°C'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sensorValue(String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: _kPrimary.withOpacity(0.6),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _kPrimary,
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
      final diff = DateTime.fromMillisecondsSinceEpoch(ts).difference(target).abs();
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
