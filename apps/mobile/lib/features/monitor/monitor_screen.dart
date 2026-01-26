import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/providers/provider/monitor_provider.dart';
import 'package:fountaine/providers/provider/api_provider.dart';
import 'package:fountaine/providers/provider/mqtt_provider.dart';
import 'package:fountaine/providers/provider/auth_provider.dart';
import 'package:fountaine/l10n/app_localizations.dart';
import '../../domain/telemetry.dart';
import '../../core/constants.dart';

// Semantic colors for sensor status
const Color _kGreen = Color(0xFF2E7D32); // Normal
const Color _kYellow = Color(0xFFFFB300); // Warning
const Color _kRed = Color(0xFFE53935); // Urgent

IconData _iconFor(String title) {
  switch (title.toLowerCase()) {
    case 'ph':
      return Icons.science_outlined;
    case 'ppm':
    case 'tds':
      return Icons.bubble_chart_outlined;
    case 'humidity':
      return Icons.water_drop_outlined;
    case 'air temp':
    case 'temperature':
      return Icons.thermostat_outlined;
    case 'water temp':
      return Icons.waves_outlined;
    case 'water level':
      return Icons.straighten_outlined;
    default:
      return Icons.sensors_outlined;
  }
}

/// Determine color based on value severity using ThresholdConst
Color _severityColor(String key, double value) {
  switch (key.toLowerCase()) {
    case 'ph':
      if (value >= ThresholdConst.phMin && value <= ThresholdConst.phMax) {
        return _kGreen;
      } else if (value >= ThresholdConst.phMin - 0.5 &&
          value <= ThresholdConst.phMax + 0.5) {
        return _kYellow;
      }
      return _kRed;
    case 'ppm':
    case 'tds':
      if (value >= ThresholdConst.ppmMin && value <= ThresholdConst.ppmMax) {
        return _kGreen;
      } else if (value >= ThresholdConst.ppmMin - 100 &&
          value <= ThresholdConst.ppmMax + 100) {
        return _kYellow;
      }
      return _kRed;
    case 'air temp':
    case 'temperature':
      if (value >= ThresholdConst.tempMin && value <= ThresholdConst.tempMax) {
        return _kGreen;
      } else if (value >= ThresholdConst.tempMin - 3 &&
          value <= ThresholdConst.tempMax + 3) {
        return _kYellow;
      }
      return _kRed;
    case 'water temp':
      if (value >= 18 && value <= 26) {
        return _kGreen;
      } else if (value >= 15 && value <= 30) {
        return _kYellow;
      }
      return _kRed;
    case 'water level':
      if (value >= ThresholdConst.wlMin && value <= ThresholdConst.wlMax) {
        return _kGreen;
      } else if (value >= ThresholdConst.wlMin - 0.3 &&
          value <= ThresholdConst.wlMax + 0.3) {
        return _kYellow;
      }
      return _kRed;
    case 'humidity':
      if (value >= 50 && value <= 80) {
        return _kGreen;
      } else if (value >= 40 && value <= 90) {
        return _kYellow;
      }
      return _kRed;
    default:
      return _kGreen;
  }
}

class MonitorScreen extends ConsumerStatefulWidget {
  final String? selectedKit;

  const MonitorScreen({super.key, this.selectedKit});

  @override
  ConsumerState<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends ConsumerState<MonitorScreen> {
  String? kitId;
  bool isAuto = false;
  
  // Live clock state
  DateTime _currentTime = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    
    // Start timer for live clock
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });

    Future.microtask(() async {
      try {
        await ref.read(mqttProvider.notifier).init();
      } catch (_) {}

      try {
        final kits = await ref.read(apiKitsListProvider.future);

        if (kits.isEmpty) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, "/addkit");
          }
          return;
        }

        final kitIds = kits.map((k) => k["id"] as String).toList();
        final api = ref.read(apiServiceProvider);
        final user = ref.read(authProvider);
        final userId = user?.uid;
        
        String initial;
        bool shouldSavePreference = false;
        
        if (userId != null) {
          final savedKitFromBackend = await api.getUserPreference(userId: userId);
          if (savedKitFromBackend != null && kitIds.contains(savedKitFromBackend)) {
            initial = savedKitFromBackend;
          } else if (widget.selectedKit != null && kitIds.contains(widget.selectedKit)) {
            initial = widget.selectedKit!;
            shouldSavePreference = true;
          } else {
            initial = kitIds.first;
            shouldSavePreference = true;
          }
        } else {
          final savedKit = ref.read(currentKitIdProvider);
          if (savedKit != null && kitIds.contains(savedKit)) {
            initial = savedKit;
          } else if (widget.selectedKit != null && kitIds.contains(widget.selectedKit)) {
            initial = widget.selectedKit!;
          } else {
            initial = kitIds.first;
          }
        }

        if (mounted) {
          setState(() {
            kitId = initial;
          });
          
          final loadedAutoMode = await ref
              .read(mqttProvider.notifier)
              .loadAutoModeFromBackend(initial);
          
          if (mounted) {
            setState(() {
              isAuto = loadedAutoMode;
            });
          }
          
          ref.read(currentKitIdProvider.notifier).state = initial;
          
          if (shouldSavePreference && userId != null) {
            await api.setUserPreference(userId: userId, selectedKitId: initial);
          }
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _kitId = kitId;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final size = MediaQuery.of(context).size;
    final s = size.width / 375.0;

    if (_kitId == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _buildAppBar(context, s),
        body: Center(child: CircularProgressIndicator(color: colorScheme.primary)),
      );
    }

    final state = ref.watch(monitorTelemetryProvider(_kitId));

    Telemetry? t = state.data;
    final last = state.lastUpdated;

    double safe(double? v) => v ?? 0;

    double frac(String key, double v) {
      switch (key) {
        case 'ph':
          return (v / 14).clamp(0.0, 1.0);
        case 'ppm':
          return (v / 3000).clamp(0.0, 1.0);
        case 'humidity':
          return (v / 100).clamp(0.0, 1.0);
        case 'temperature':
          return ((v + 10) / 60).clamp(0.0, 1.0);
        case 'waterTemp':
          return (v / 50).clamp(0.0, 1.0);
        case 'waterLevel':
          return (v / 3).clamp(0.0, 1.0);
      }
      return 0.0;
    }

    String format(DateTime? dt) {
      if (dt == null) return '--';
      final d = dt.toLocal();
      String two(int v) => v.toString().padLeft(2, '0');
      return '${d.year}-${two(d.month)}-${two(d.day)} '
          '${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context, s),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16 * s, 10 * s, 16 * s, 16 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LIVE TIME DISPLAY
              _buildLiveTimeRow(context, s, l10n),
              SizedBox(height: 12 * s),
              
              // GRID GAUGES - 3x2 for 6 sensors
              GridView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8 * s,
                  mainAxisSpacing: 20 * s,
                  childAspectRatio: 1.0,
                ),
                children: [
                  _sensorCard(context, s, l10n.sensorPh, safe(t?.ph), '', frac('ph', safe(t?.ph)), _severityColor('ph', safe(t?.ph))),
                  _sensorCard(context, s, l10n.sensorTds, safe(t?.ppm), 'ppm', frac('ppm', safe(t?.ppm)), _severityColor('ppm', safe(t?.ppm))),
                  _sensorCard(context, s, l10n.sensorHumidity, safe(t?.humidity), '%', frac('humidity', safe(t?.humidity)), _severityColor('humidity', safe(t?.humidity))),
                  _sensorCard(context, s, l10n.sensorAirTemp, safe(t?.tempC), '°C', frac('temperature', safe(t?.tempC)), _severityColor('air temp', safe(t?.tempC))),
                  _sensorCard(context, s, l10n.sensorWaterTemp, safe(t?.waterTemp), '°C', frac('waterTemp', safe(t?.waterTemp)), _severityColor('water temp', safe(t?.waterTemp))),
                  _sensorCard(context, s, l10n.sensorWaterLevel, safe(t?.waterLevel), '', frac('waterLevel', safe(t?.waterLevel)), _severityColor('water level', safe(t?.waterLevel))),
                ],
              ),

              SizedBox(height: 20 * s),

              Text(
                l10n.monitorYourKit,
                style: TextStyle(
                  fontSize: 16 * s,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(height: 8 * s),

              // YOUR KIT CARD
              Container(
                padding: EdgeInsets.all(14 * s),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12 * s),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10 * s,
                      height: 10 * s,
                      decoration: BoxDecoration(
                        color: t == null ? _kRed.withValues(alpha: 0.7) : _kGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 12 * s),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _kitSelector(context, s, l10n)),
                          Text(
                            t == null ? l10n.monitorStatusOffline : l10n.monitorStatusOnline,
                            style: TextStyle(
                              fontSize: 11 * s,
                              fontWeight: FontWeight.w500,
                              color: t == null 
                                  ? _kRed.withValues(alpha: 0.7) 
                                  : _kGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20 * s),

              _modeSection(context, s, _kitId, l10n),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the live time display row showing real-time clock
  Widget _buildLiveTimeRow(BuildContext context, double s, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final time = _currentTime;
    
    String two(int v) => v.toString().padLeft(2, '0');
    final timeStr = '${two(time.hour)}:${two(time.minute)}:${two(time.second)}';
    
    return Row(
      children: [
        Text(
          '${l10n.monitorLiveTime} • ',
          style: TextStyle(
            fontSize: 12 * s,
            fontWeight: FontWeight.w400,
            color: colorScheme.primary.withValues(alpha: 0.7),
          ),
        ),
        Text(
          timeStr,
          style: TextStyle(
            fontSize: 12 * s,
            fontWeight: FontWeight.w500,
            color: colorScheme.primary.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, double s) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: colorScheme.primary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 24 * s,
            height: 24 * s,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.eco, color: colorScheme.primary, size: 24 * s),
          ),
          SizedBox(width: 8 * s),
          Text(
            'Fountaine',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
              fontSize: 18 * s,
            ),
          ),
        ],
      ),
      iconTheme: IconThemeData(color: colorScheme.primary),
    );
  }

  Widget _kitSelector(BuildContext context, double s, AppLocalizations l10n) {
    final kitsAsync = ref.watch(apiKitsListProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return kitsAsync.when(
      loading: () => SizedBox(
        height: 20 * s,
        width: 20 * s,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: colorScheme.primary,
        ),
      ),
      error: (e, _) => Text("Failed: $e", style: TextStyle(fontSize: 12 * s)),
      data: (kits) {
        if (kits.isEmpty)
          return Text("No kits", style: TextStyle(fontSize: 12 * s));

        return GestureDetector(
          onTap: () => _showKitSelector(context, s, kits, l10n),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                kitId ?? l10n.monitorSelectKit,
                style: TextStyle(
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(width: 4 * s),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: colorScheme.primary,
                size: 20 * s,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showKitSelector(BuildContext context, double s, List<Map<String, dynamic>> kits, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20 * s)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16 * s),
              child: Row(
                children: [
                  Text(
                    l10n.monitorSelectKit,
                    style: TextStyle(
                      fontSize: 18 * s,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    l10n.monitorLongPressDelete,
                    style: TextStyle(
                      fontSize: 11 * s,
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colorScheme.outlineVariant),
            
            ...kits.map((k) {
              final id = k["id"] as String;
              final isSelected = id == kitId;
              
              return InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  _selectKit(id);
                },
                onLongPress: () {
                  Navigator.pop(ctx);
                  _confirmDeleteKit(context, s, id, l10n);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 14 * s),
                  decoration: BoxDecoration(
                    color: isSelected ? colorScheme.primary.withValues(alpha: 0.1) : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10 * s,
                        height: 10 * s,
                        decoration: BoxDecoration(
                          color: isSelected ? _kGreen : colorScheme.outlineVariant,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12 * s),
                      Text(
                        id,
                        style: TextStyle(
                          fontSize: 15 * s,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: colorScheme.primary,
                        ),
                      ),
                      if (isSelected) ...[
                        const Spacer(),
                        Icon(Icons.check, color: _kGreen, size: 20 * s),
                      ],
                    ],
                  ),
                ),
              );
            }),
            SizedBox(height: 16 * s),
          ],
        ),
      ),
    );
  }

  Future<void> _selectKit(String v) async {
    if (v != kitId) {
      setState(() {
        kitId = v;
      });
      
      final loadedAutoMode = await ref
          .read(mqttProvider.notifier)
          .loadAutoModeFromBackend(v);
      
      if (mounted) {
        setState(() {
          isAuto = loadedAutoMode;
        });
      }
      
      ref.read(currentKitIdProvider.notifier).state = v;
      
      final user = ref.read(authProvider);
      if (user != null) {
        final api = ref.read(apiServiceProvider);
        await api.setUserPreference(
          userId: user.uid,
          selectedKitId: v,
        );
      }
    }
  }

  void _confirmDeleteKit(BuildContext context, double s, String id, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(l10n.monitorDeleteKit),
        content: Text(l10n.monitorDeleteKitConfirm(id)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteKit(id, l10n);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteKit(String id, AppLocalizations l10n) async {
    final user = ref.read(authProvider);
    if (user == null) return;
    
    try {
      final kitsApi = ref.read(apiKitsProvider);
      await kitsApi.deleteKit(id: id, userId: user.uid);
      
      ref.invalidate(apiKitsListProvider);
      
      if (id == kitId) {
        final kits = await ref.read(apiKitsListProvider.future);
        if (kits.isNotEmpty) {
          await _selectKit(kits.first["id"] as String);
        } else {
          if (mounted) {
            Navigator.pushReplacementNamed(context, "/addkit");
          }
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.monitorKitRemoved(id))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete kit: $e')),
        );
      }
    }
  }

  Widget _sensorCard(
    BuildContext context,
    double s,
    String title,
    double value,
    String unit,
    double fraction,
    Color barColor,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: fraction),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, fr, _) {
        return Container(
          padding: EdgeInsets.all(10 * s),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12 * s),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _iconFor(title),
                    size: 12 * s,
                    color: colorScheme.primary.withValues(alpha: 0.6),
                  ),
                  SizedBox(width: 4 * s),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11 * s,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.primary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6 * s),
              Text(
                unit.isEmpty
                    ? value.toStringAsFixed(2)
                    : '${value.toStringAsFixed(1)} $unit',
                style: TextStyle(
                  fontSize: 16 * s,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(height: 6 * s),
              ClipRRect(
                borderRadius: BorderRadius.circular(3 * s),
                child: LinearProgressIndicator(
                  value: fr,
                  minHeight: 5 * s,
                  backgroundColor: colorScheme.outlineVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _modeSection(BuildContext context, double s, String currentKitId, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.monitorMode,
          style: TextStyle(
            fontSize: 16 * s,
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
          ),
        ),
        SizedBox(height: 10 * s),

        Container(
          height: 48 * s,
          padding: EdgeInsets.all(4 * s),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(50 * s),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: isAuto
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(50 * s),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => isAuto = true);
                        ref
                            .read(
                              monitorTelemetryProvider(currentKitId).notifier,
                            )
                            .setAuto();
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 13 * s,
                              fontWeight: FontWeight.w700,
                              color: isAuto
                                  ? colorScheme.onPrimary
                                  : colorScheme.primary.withValues(alpha: 0.5),
                            ),
                            child: Text(l10n.monitorAuto),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => isAuto = false);
                        ref
                            .read(
                              monitorTelemetryProvider(currentKitId).notifier,
                            )
                            .setManual();
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 13 * s,
                              fontWeight: FontWeight.w700,
                              color: !isAuto
                                  ? colorScheme.onPrimary
                                  : colorScheme.primary.withValues(alpha: 0.5),
                            ),
                            child: Text(l10n.monitorManual),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 16 * s),

        if (!isAuto)
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _actionBtn(context, s, l10n.actionPhUp, () {
                      ref
                          .read(monitorTelemetryProvider(currentKitId).notifier)
                          .phUp();
                      _showCommandSnackBar(context, l10n.actionPhUpSent);
                    }),
                  ),
                  SizedBox(width: 10 * s),
                  Expanded(
                    child: _actionBtn(context, s, l10n.actionPhDown, () {
                      ref
                          .read(monitorTelemetryProvider(currentKitId).notifier)
                          .phDown();
                      _showCommandSnackBar(context, l10n.actionPhDownSent);
                    }),
                  ),
                ],
              ),
              SizedBox(height: 10 * s),
              Row(
                children: [
                  Expanded(
                    child: _actionBtn(context, s, l10n.actionNutrient, () {
                      ref
                          .read(monitorTelemetryProvider(currentKitId).notifier)
                          .nutrientAdd();
                      _showCommandSnackBar(context, l10n.actionNutrientSent);
                    }),
                  ),
                  SizedBox(width: 10 * s),
                  Expanded(
                    child: _actionBtn(context, s, l10n.actionRefill, () {
                      ref
                          .read(monitorTelemetryProvider(currentKitId).notifier)
                          .refill();
                      _showCommandSnackBar(context, l10n.actionRefillSent);
                    }),
                  ),
                ],
              ),
              SizedBox(height: 20 * s),
            ],
          )
        else
          _buildAutoModeInfo(context, s, currentKitId, l10n),
      ],
    );
  }

  Widget _buildAutoModeInfo(BuildContext context, double s, String kitId, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return FutureBuilder<Map<String, dynamic>?>(
      future: ref.read(apiServiceProvider).getLatestActuatorEvent(kitId),
      builder: (context, snapshot) {
        final event = snapshot.data;
        final hasActions = event != null && (
          (event['phUp'] as int? ?? 0) > 0 ||
          (event['phDown'] as int? ?? 0) > 0 ||
          (event['nutrientAdd'] as int? ?? 0) > 0 ||
          (event['refill'] as int? ?? 0) > 0
        );

        String timeStr = '--:--:--';
        if (event != null) {
          final rawTime = event['createdAt'] ?? event['created_at'] ?? event['timestamp'] ?? event['ingestTime'];
          if (rawTime != null) {
            DateTime? dt;
            if (rawTime is int) {
              dt = DateTime.fromMillisecondsSinceEpoch(rawTime);
            } else {
              dt = DateTime.tryParse(rawTime.toString());
            }
            if (dt != null) {
              final local = dt.toLocal();
              timeStr = '${local.hour.toString().padLeft(2, '0')}:'
                  '${local.minute.toString().padLeft(2, '0')}:'
                  '${local.second.toString().padLeft(2, '0')}';
            }
          }
        }

        return Container(
          padding: EdgeInsets.all(16 * s),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary.withValues(alpha: 0.08),
                colorScheme.primary.withValues(alpha: 0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(16 * s),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8 * s),
                    decoration: BoxDecoration(
                      color: hasActions ? colorScheme.primary : _kGreen,
                      borderRadius: BorderRadius.circular(10 * s),
                    ),
                    child: Icon(
                      hasActions ? Icons.smart_toy_rounded : Icons.check_circle,
                      color: Colors.white,
                      size: 20 * s,
                    ),
                  ),
                  SizedBox(width: 12 * s),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasActions ? l10n.monitorAutoControlActive : l10n.monitorAllParametersSafe,
                          style: TextStyle(
                            fontSize: 14 * s,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 2 * s),
                        Text(
                          hasActions ? l10n.monitorLatestAdjustment : l10n.monitorNoAdjustmentNeeded,
                          style: TextStyle(
                            fontSize: 11 * s,
                            color: colorScheme.primary.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (hasActions) ...[
                SizedBox(height: 14 * s),
                Wrap(
                  spacing: 8 * s,
                  runSpacing: 8 * s,
                  children: [
                    if ((event!['phUp'] as int? ?? 0) > 0)
                      _actionChip(context, s, 'pH Up', '${event['phUp']}s', Icons.arrow_upward),
                    if ((event['phDown'] as int? ?? 0) > 0)
                      _actionChip(context, s, 'pH Down', '${event['phDown']}s', Icons.arrow_downward),
                    if ((event['nutrientAdd'] as int? ?? 0) > 0)
                      _actionChip(context, s, 'Nutrient', '${event['nutrientAdd']}s', Icons.water_drop),
                    if ((event['refill'] as int? ?? 0) > 0)
                      _actionChip(context, s, 'Refill', '${event['refill']}s', Icons.refresh),
                  ],
                ),
              ],

              SizedBox(height: 12 * s),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14 * s,
                    color: colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  SizedBox(width: 4 * s),
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.primary.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _actionChip(BuildContext context, double s, String label, String value, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 8 * s),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20 * s),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14 * s, color: colorScheme.primary),
          SizedBox(width: 6 * s),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11 * s,
              color: colorScheme.primary.withValues(alpha: 0.7),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12 * s,
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(BuildContext context, double s, String label, VoidCallback onTap) {
    return _PressableActionButton(
      label: label,
      scaleFactor: s,
      onTap: onTap,
    );
  }

  void _showCommandSnackBar(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Both themes: use primary color from theme
    final bgColor = colorScheme.primary;
    final textColor = colorScheme.onPrimary;
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 0.2,
            ),
          ),
        ),
        backgroundColor: bgColor.withValues(alpha: 0.95),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        elevation: 8,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        width: null,
        margin: EdgeInsets.only(
          left: screenWidth * 0.18,
          right: screenWidth * 0.18,
          bottom: 24,
        ),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }
}

class _PressableActionButton extends StatefulWidget {
  final String label;
  final double scaleFactor;
  final VoidCallback onTap;

  const _PressableActionButton({
    required this.label,
    required this.scaleFactor,
    required this.onTap,
  });

  @override
  State<_PressableActionButton> createState() => _PressableActionButtonState();
}

class _PressableActionButtonState extends State<_PressableActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final s = widget.scaleFactor;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: EdgeInsets.symmetric(vertical: 14 * s),
          decoration: BoxDecoration(
            color: _isPressed 
                ? colorScheme.primary.withValues(alpha: 0.15) 
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(10 * s),
            border: Border.all(
              color: _isPressed 
                  ? colorScheme.primary 
                  : colorScheme.primary.withValues(alpha: 0.2), 
              width: _isPressed ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isPressed 
                    ? colorScheme.primary.withValues(alpha: 0.2) 
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: _isPressed ? 10 : 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 13 * s,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
