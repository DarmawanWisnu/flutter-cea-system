import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/providers/provider/monitor_provider.dart';
import 'package:fountaine/providers/provider/api_provider.dart';
import 'package:fountaine/providers/provider/mqtt_provider.dart';
import '../../domain/telemetry.dart';
import 'dart:ui';
import 'dart:math' as math;

IconData _iconFor(String title) {
  switch (title.toLowerCase()) {
    case 'pH':
    case 'ph':
      return Icons.science_rounded;
    case 'ppm':
      return Icons.bubble_chart_rounded;
    case 'humidity':
      return Icons.water_drop_rounded;
    case 'temperature':
      return Icons.thermostat_rounded;
    default:
      return Icons.circle;
  }
}

class _ArcPainter extends CustomPainter {
  final Color color;
  final double fraction;
  final double strokeFactor;

  _ArcPainter({
    required this.color,
    required this.fraction,
    this.strokeFactor = 0.1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final minSide = math.min(size.width, size.height);
    final stroke = minSide * strokeFactor;

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = const Color(0xFFF0F0F0);

    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;

    final rect = Rect.fromLTWH(
      (size.width - minSide) / 2 + stroke / 2,
      (size.height - minSide) / 2 + stroke / 2,
      minSide - stroke,
      minSide - stroke,
    );

    canvas.drawArc(rect, 0, math.pi * 2, false, bg);

    final start = math.pi * 0.75;
    final sweepMax = math.pi * 0.9;

    canvas.drawArc(rect, start, sweepMax * fraction, false, fg);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) =>
      old.fraction != fraction || old.color != color;
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

    const bg = Color(0xFFF6FBF6);
    const primary = Color(0xFF154B2E);
    const muted = Color(0xFF7A7A7A);

    final size = MediaQuery.of(context).size;
    final s = size.width / 375.0;

    if (_kitId == null) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Monitor',
            style: TextStyle(color: primary, fontWeight: FontWeight.w800),
          ),
          iconTheme: const IconThemeData(color: primary),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final state = ref.watch(monitorTelemetryProvider(_kitId));

    Telemetry? t = state.data;
    final last = state.lastUpdated;

    double safe(double? v) => v ?? 0;

    double frac(String key, double v) {
      switch (key) {
        case 'ph':
          return (v / 14).clamp(0, 1);
        case 'ppm':
          return (v / 3000).clamp(0, 1);
        case 'humidity':
          return (v / 100).clamp(0, 1);
        case 'temperature':
          return ((v + 10) / 60).clamp(0, 1);
      }
      return 0;
    }

    String format(DateTime? dt) {
      if (dt == null) return '--';
      final d = dt.toLocal();
      String two(int v) => v.toString().padLeft(2, '0');
      return '${d.year}-${two(d.month)}-${two(d.day)} '
          '${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Monitor',
          style: TextStyle(color: primary, fontWeight: FontWeight.w800),
        ),
        iconTheme: const IconThemeData(color: primary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16 * s, 10 * s, 16 * s, 16 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // GRID GAUGES
              GridView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: size.width >= 420 ? 3 : 2,
                  crossAxisSpacing: 14 * s,
                  mainAxisSpacing: 14 * s,
                  childAspectRatio: 0.75,
                ),
                children: [
                  _gaugeBox(
                    s,
                    'pH',
                    safe(t?.ph),
                    'pH',
                    frac('ph', safe(t?.ph)),
                  ),
                  _gaugeBox(
                    s,
                    'PPM',
                    safe(t?.ppm),
                    'ppm',
                    frac('ppm', safe(t?.ppm)),
                  ),
                  _gaugeBox(
                    s,
                    'Humidity',
                    safe(t?.humidity),
                    '%',
                    frac('humidity', safe(t?.humidity)),
                  ),
                  _gaugeBox(
                    s,
                    'Temperature',
                    safe(t?.tempC),
                    '°C',
                    frac('temperature', safe(t?.tempC)),
                  ),
                ],
              ),

              SizedBox(height: 22 * s),

              Text(
                'Your Kit',
                style: TextStyle(
                  fontSize: 18 * s,
                  fontWeight: FontWeight.w800,
                  color: primary,
                ),
              ),
              SizedBox(height: 10 * s),

              // YOUR KIT CARD + DROPDOWN INSIDE
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18 * s),
                  border: Border.all(
                    color: const Color(0xFF4DD4AC).withOpacity(0.35),
                    width: 1.4,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFE7FFF5).withOpacity(0.55),
                      const Color(0xFFDFFFFA).withOpacity(0.40),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4DD4AC).withOpacity(0.20),
                      blurRadius: 18,
                      offset: Offset(0, 6 * s),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18 * s),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14 * s,
                        vertical: 14 * s,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // STATUS DOT
                          Container(
                            width: 10 * s,
                            height: 10 * s,
                            margin: EdgeInsets.only(top: 6 * s),
                            decoration: BoxDecoration(
                              color: t == null
                                  ? Colors.grey
                                  : const Color(0xFF04D98B),
                              shape: BoxShape.circle,
                            ),
                          ),

                          SizedBox(width: 12 * s),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // DROPDOWN
                                _kitSelectorInsideCard(s),

                                SizedBox(height: 8 * s),

                                Text(
                                  'Last: ${format(last)}',
                                  style: TextStyle(
                                    fontSize: 12 * s,
                                    color: Colors.black.withOpacity(0.55),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 22 * s),

              _modeSection(context, s, _kitId),
            ],
          ),
        ),
      ),
    );
  }

  // DROPDOWN INSIDE YOUR KIT CARD
  Widget _kitSelectorInsideCard(double s) {
    final kitsAsync = ref.watch(apiKitsListProvider);

    return kitsAsync.when(
      loading: () => Container(
        height: 42 * s,
        alignment: Alignment.centerLeft,
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (e, _) => Text("Failed load kits: $e"),
      data: (kits) {
        if (kits.isEmpty) return const Text("No kits registered.");

        return Container(
          height: 42 * s,
          padding: EdgeInsets.symmetric(horizontal: 12 * s),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12 * s),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.70),
                Colors.white.withOpacity(0.55),
              ],
            ),
            border: Border.all(
              color: const Color(0xFF4DD4AC).withOpacity(0.40),
              width: 1.2,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: kitId,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF154B2E),
              ),
              items: kits.map<DropdownMenuItem<String>>((k) {
                final id = k["id"] as String;
                return DropdownMenuItem(
                  value: id,
                  child: Text(
                    id,
                    style: TextStyle(
                      fontSize: 14 * s,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF154B2E),
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
          ),
        );
      },
    );
  }

  Widget _gaugeBox(
    double s,
    String title,
    double value,
    String unit,
    double fraction,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: fraction),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, fr, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          padding: EdgeInsets.all(8 * s),
          decoration: BoxDecoration(
            color: const Color(0xFFF6FBF6).withOpacity(0.55),
            borderRadius: BorderRadius.circular(18 * s),
            border: Border.all(
              color: const Color.fromARGB(
                255,
                24,
                116,
                88,
              ).withOpacity(0.45), // tegas
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4DD4AC).withOpacity(0.18),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18 * s),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _iconFor(title),
                    size: 16 * s,
                    color: const Color(0xFF06B48A),
                  ),

                  SizedBox(height: 3 * s),

                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10 * s,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),

                  SizedBox(height: 4 * s),

                  SizedBox(
                    width: 45 * s,
                    height: 45 * s,
                    child: CustomPaint(
                      painter: _ArcPainter(
                        color: const Color(0xFF06B48A),
                        fraction: fr,
                      ),
                    ),
                  ),

                  SizedBox(height: 4 * s),

                  Text(
                    "$value $unit",
                    style: TextStyle(
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w800,
                      color: Colors.black.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // FUTURISTIC MODE SECTION
  Widget _modeSection(BuildContext context, double s, String currentKitId) {
    const primary = Color(0xFF154B2E);
    const muted = Color(0xFF7A7A7A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mode & Control',
          style: TextStyle(
            fontSize: 18 * s,
            fontWeight: FontWeight.w800,
            color: primary,
          ),
        ),
        SizedBox(height: 16 * s),

        // Futuristic Segmented Control
        AnimatedContainer(
          duration: Duration(milliseconds: 350),
          curve: Curves.easeOutQuint,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFFF6FBF6), const Color(0xFFEFF9EF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),

            borderRadius: BorderRadius.circular(18 * s),
            border: Border.all(color: Colors.white70, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: EdgeInsets.all(5 * s),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => isAuto = true);
                    ref
                        .read(monitorTelemetryProvider(currentKitId).notifier)
                        .setAuto();
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.symmetric(vertical: 14 * s),
                    decoration: BoxDecoration(
                      gradient: isAuto
                          ? LinearGradient(
                              colors: [Color(0xFF4DD4AC), Color(0xFF3AA6D0)],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(14 * s),
                      boxShadow: isAuto
                          ? [
                              BoxShadow(
                                color: Color(0xFF3AA6D0).withOpacity(0.4),
                                blurRadius: 12,
                                spreadRadius: 1,
                                offset: Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: AnimatedDefaultTextStyle(
                      duration: Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 14 * s,
                        fontWeight: FontWeight.w700,
                        color: isAuto ? Colors.white : muted,
                        letterSpacing: isAuto ? 0.6 : 0.3,
                      ),
                      child: Center(child: Text("AUTO")),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8 * s),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => isAuto = false);
                    ref
                        .read(monitorTelemetryProvider(currentKitId).notifier)
                        .setManual();
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.symmetric(vertical: 14 * s),
                    decoration: BoxDecoration(
                      gradient: !isAuto
                          ? LinearGradient(
                              colors: [Color(0xFF4DD4AC), Color(0xFF3AA6D0)],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(14 * s),
                      boxShadow: !isAuto
                          ? [
                              BoxShadow(
                                color: Color(0xFF4DD4AC).withOpacity(0.4),
                                blurRadius: 12,
                                spreadRadius: 1,
                                offset: Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: AnimatedDefaultTextStyle(
                      duration: Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 14 * s,
                        fontWeight: FontWeight.w700,
                        color: !isAuto ? Colors.white : muted,
                        letterSpacing: !isAuto ? 0.6 : 0.3,
                      ),
                      child: Center(child: Text("MANUAL")),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20 * s),

        if (!isAuto)
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _manualBtn(s, "PH UP", () {
                      ref
                          .read(monitorTelemetryProvider(currentKitId).notifier)
                          .phUp();
                    }),
                  ),
                  SizedBox(width: 12 * s),
                  Expanded(
                    child: _manualBtn(s, "PH DOWN", () {
                      ref
                          .read(monitorTelemetryProvider(currentKitId).notifier)
                          .phDown();
                    }),
                  ),
                ],
              ),
              SizedBox(height: 12 * s),
              Row(
                children: [
                  Expanded(
                    child: _manualBtn(s, "NUTRIENT", () {
                      ref
                          .read(monitorTelemetryProvider(currentKitId).notifier)
                          .nutrientAdd();
                    }),
                  ),
                  SizedBox(width: 12 * s),
                  Expanded(
                    child: _manualBtn(s, "REFILL", () {
                      ref
                          .read(monitorTelemetryProvider(currentKitId).notifier)
                          .refill();
                    }),
                  ),
                ],
              ),
              SizedBox(height: 22 * s),
            ],
          ),
      ],
    );
  }

  Widget _manualBtn(double s, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20 * s),
      splashColor: Color(0xFF4DD4AC).withOpacity(0.2),
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 16 * s),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF6FBF6), Color(0xFFE9F6EC)],
          ),
          borderRadius: BorderRadius.circular(20 * s),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10 * s,
              offset: Offset(0, 4 * s),
            ),
          ],
          border: Border.all(
            color: Color(0xFF4DD4AC).withOpacity(0.35),
            width: 1.2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15 * s,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A5E45),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
