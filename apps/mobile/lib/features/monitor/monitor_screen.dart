import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/providers/provider/monitor_provider.dart';
import 'package:fountaine/providers/provider/api_provider.dart';
import 'package:fountaine/providers/provider/mqtt_provider.dart';
import '../../domain/telemetry.dart';
import '../../core/constants.dart';

// Color scheme - human-like, minimal
const Color _kPrimary = Color(0xFF0E5A2A);
const Color _kBg = Color(0xFFF3F9F4);
const Color _kCardBg = Colors.white;
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
      // Water temp ideal: 18-26°C
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
      // Humidity ideal: 50-80%
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

  @override
  void initState() {
    super.initState();

    // INITIALIZE MQTT CONNECTION
    Future.microtask(() async {
      try {
        // Start MQTT connection (may fail in tests)
        await ref.read(mqttProvider.notifier).init();
      } catch (e) {
        print("[Monitor] MQTT init error (continuing without MQTT): $e");
      }

      // Load kits regardless of MQTT status
      try {
        final kits = await ref.read(apiKitsListProvider.future);

        if (kits.isEmpty) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, "/addkit");
          }
          return;
        }

        final initial = widget.selectedKit ?? (kits.first["id"] as String);

        if (mounted) {
          setState(() => kitId = initial);
          // Update shared kit ID for notifications
          ref.read(currentKitIdProvider.notifier).state = initial;
        }
      } catch (e) {
        print("[Monitor] Kit loading error: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final _kitId = kitId;

    final size = MediaQuery.of(context).size;
    final s = size.width / 375.0;

    if (_kitId == null) {
      return Scaffold(
        backgroundColor: _kBg,
        appBar: _buildAppBar(s),
        body: const Center(child: CircularProgressIndicator(color: _kPrimary)),
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
      backgroundColor: _kBg,
      appBar: _buildAppBar(s),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16 * s, 10 * s, 16 * s, 16 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  _sensorCard(
                    s,
                    'pH',
                    safe(t?.ph),
                    '',
                    frac('ph', safe(t?.ph)),
                    _severityColor('ph', safe(t?.ph)),
                  ),
                  _sensorCard(
                    s,
                    'TDS',
                    safe(t?.ppm),
                    'ppm',
                    frac('ppm', safe(t?.ppm)),
                    _severityColor('ppm', safe(t?.ppm)),
                  ),
                  _sensorCard(
                    s,
                    'Humidity',
                    safe(t?.humidity),
                    '%',
                    frac('humidity', safe(t?.humidity)),
                    _severityColor('humidity', safe(t?.humidity)),
                  ),
                  _sensorCard(
                    s,
                    'Air Temp',
                    safe(t?.tempC),
                    '°C',
                    frac('temperature', safe(t?.tempC)),
                    _severityColor('air temp', safe(t?.tempC)),
                  ),
                  _sensorCard(
                    s,
                    'Water Temp',
                    safe(t?.waterTemp),
                    '°C',
                    frac('waterTemp', safe(t?.waterTemp)),
                    _severityColor('water temp', safe(t?.waterTemp)),
                  ),
                  _sensorCard(
                    s,
                    'Water Level',
                    safe(t?.waterLevel),
                    '',
                    frac('waterLevel', safe(t?.waterLevel)),
                    _severityColor('water level', safe(t?.waterLevel)),
                  ),
                ],
              ),

              SizedBox(height: 20 * s),

              Text(
                'Your Kit',
                style: TextStyle(
                  fontSize: 16 * s,
                  fontWeight: FontWeight.w700,
                  color: _kPrimary,
                ),
              ),
              SizedBox(height: 8 * s),

              // YOUR KIT CARD
              Container(
                padding: EdgeInsets.all(14 * s),
                decoration: BoxDecoration(
                  color: _kCardBg,
                  borderRadius: BorderRadius.circular(12 * s),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // STATUS DOT
                    Container(
                      width: 10 * s,
                      height: 10 * s,
                      decoration: BoxDecoration(
                        color: t == null ? Colors.grey : _kGreen,
                        shape: BoxShape.circle,
                      ),
                    ),

                    SizedBox(width: 12 * s),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // DROPDOWN
                          _kitSelector(s),

                          SizedBox(height: 4 * s),

                          Text(
                            'Last: ${format(last)}',
                            style: TextStyle(
                              fontSize: 11 * s,
                              color: _kPrimary.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20 * s),

              _modeSection(context, s, _kitId),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(double s) {
    return AppBar(
      backgroundColor: _kBg,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: _kPrimary),
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
                Icon(Icons.eco, color: _kPrimary, size: 24 * s),
          ),
          SizedBox(width: 8 * s),
          Text(
            'Fountaine',
            style: TextStyle(
              color: _kPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18 * s,
            ),
          ),
        ],
      ),
      iconTheme: const IconThemeData(color: _kPrimary),
    );
  }

  // KIT DROPDOWN SELECTOR
  Widget _kitSelector(double s) {
    final kitsAsync = ref.watch(apiKitsListProvider);

    return kitsAsync.when(
      loading: () => SizedBox(
        height: 20 * s,
        width: 20 * s,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          color: _kPrimary,
        ),
      ),
      error: (e, _) => Text("Failed: $e", style: TextStyle(fontSize: 12 * s)),
      data: (kits) {
        if (kits.isEmpty)
          return Text("No kits", style: TextStyle(fontSize: 12 * s));

        return DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isDense: true,
            value: kitId,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _kPrimary,
              size: 20 * s,
            ),
            items: kits.map<DropdownMenuItem<String>>((k) {
              final id = k["id"] as String;
              return DropdownMenuItem(
                value: id,
                child: Text(
                  id,
                  style: TextStyle(
                    fontSize: 14 * s,
                    fontWeight: FontWeight.w600,
                    color: _kPrimary,
                  ),
                ),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null && v != kitId) {
                setState(() => kitId = v);
                // Update shared kit ID for notifications
                ref.read(currentKitIdProvider.notifier).state = v;
              }
            },
          ),
        );
      },
    );
  }

  // NEW SENSOR CARD with loading bar
  Widget _sensorCard(
    double s,
    String title,
    double value,
    String unit,
    double fraction,
    Color barColor,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: fraction),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, fr, _) {
        return Container(
          padding: EdgeInsets.all(10 * s),
          decoration: BoxDecoration(
            color: _kCardBg,
            borderRadius: BorderRadius.circular(12 * s),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon + Title row - centered
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _iconFor(title),
                    size: 12 * s,
                    color: _kPrimary.withOpacity(0.6),
                  ),
                  SizedBox(width: 4 * s),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11 * s,
                      fontWeight: FontWeight.w500,
                      color: _kPrimary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 6 * s),

              // Value
              Text(
                unit.isEmpty
                    ? value.toStringAsFixed(2)
                    : '${value.toStringAsFixed(1)} $unit',
                style: TextStyle(
                  fontSize: 16 * s,
                  fontWeight: FontWeight.w800,
                  color: _kPrimary,
                ),
              ),

              SizedBox(height: 6 * s),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(3 * s),
                child: LinearProgressIndicator(
                  value: fr,
                  minHeight: 5 * s,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // MODE SECTION - simplified
  Widget _modeSection(BuildContext context, double s, String currentKitId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mode',
          style: TextStyle(
            fontSize: 16 * s,
            fontWeight: FontWeight.w700,
            color: _kPrimary,
          ),
        ),
        SizedBox(height: 10 * s),

        // Sliding pill toggle with centered circle
        Container(
          height: 48 * s,
          padding: EdgeInsets.all(4 * s),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(50 * s),
          ),
          child: Stack(
            children: [
              // Animated sliding pill
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
                      color: _kPrimary,
                      borderRadius: BorderRadius.circular(50 * s),
                      boxShadow: [
                        BoxShadow(
                          color: _kPrimary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Text labels
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
                                  ? Colors.white
                                  : _kPrimary.withOpacity(0.5),
                            ),
                            child: const Text("AUTO"),
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
                                  ? Colors.white
                                  : _kPrimary.withOpacity(0.5),
                            ),
                            child: const Text("MANUAL"),
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

        // Actuator buttons - only show in manual mode
        if (!isAuto)
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _actionBtn(s, "PH UP", () {
                      ref
                          .read(monitorTelemetryProvider(currentKitId).notifier)
                          .phUp();
                    }),
                  ),
                  SizedBox(width: 10 * s),
                  Expanded(
                    child: _actionBtn(s, "PH DOWN", () {
                      ref
                          .read(monitorTelemetryProvider(currentKitId).notifier)
                          .phDown();
                    }),
                  ),
                ],
              ),
              SizedBox(height: 10 * s),
              Row(
                children: [
                  Expanded(
                    child: _actionBtn(s, "NUTRIENT", () {
                      ref
                          .read(monitorTelemetryProvider(currentKitId).notifier)
                          .nutrientAdd();
                    }),
                  ),
                  SizedBox(width: 10 * s),
                  Expanded(
                    child: _actionBtn(s, "REFILL", () {
                      ref
                          .read(monitorTelemetryProvider(currentKitId).notifier)
                          .refill();
                    }),
                  ),
                ],
              ),
              SizedBox(height: 20 * s),
            ],
          ),
      ],
    );
  }

  // Simple action button
  Widget _actionBtn(double s, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10 * s),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14 * s),
        decoration: BoxDecoration(
          color: _kCardBg,
          borderRadius: BorderRadius.circular(10 * s),
          border: Border.all(color: _kPrimary.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13 * s,
              fontWeight: FontWeight.w700,
              color: _kPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
