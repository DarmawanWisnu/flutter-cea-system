import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/providers/provider/monitor_provider.dart';
import 'package:fountaine/providers/provider/api_provider.dart';
import '../../domain/telemetry.dart';

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

    Future.microtask(() async {
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
        }
      } catch (e) {}
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
              _kitSelector(s),
              SizedBox(height: 14 * s),

              // Grid gauges
              GridView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: size.width >= 420 ? 3 : 2,
                  crossAxisSpacing: 14 * s,
                  mainAxisSpacing: 14 * s,
                  childAspectRatio: 1.02,
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

              SizedBox(height: 18 * s),

              Text(
                'Your Kit',
                style: TextStyle(
                  fontSize: 18 * s,
                  fontWeight: FontWeight.w800,
                  color: primary,
                ),
              ),
              SizedBox(height: 10 * s),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18 * s),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8 * s,
                      offset: Offset(0, 4 * s),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 14 * s,
                  vertical: 12 * s,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10 * s,
                      height: 10 * s,
                      decoration: BoxDecoration(
                        color: t == null
                            ? Colors.grey
                            : Colors.greenAccent.shade400,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 10 * s),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _kitId,
                            style: TextStyle(
                              fontSize: 15 * s,
                              fontWeight: FontWeight.w700,
                              color: primary,
                            ),
                          ),
                          SizedBox(height: 2 * s),
                          Text(
                            'Last: ${format(last)}',
                            style: TextStyle(fontSize: 12 * s, color: muted),
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

  // KIT SELECTOR
  Widget _kitSelector(double s) {
    final kitsAsync = ref.watch(apiKitsListProvider);

    return kitsAsync.when(
      loading: () => Container(
        height: 48 * s,
        padding: EdgeInsets.symmetric(horizontal: 12 * s),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14 * s),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text("Failed load kits: $e"),
      data: (kits) {
        if (kits.isEmpty) return const Text("No kits registered.");

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12 * s),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14 * s),
          ),
          child: DropdownButton<String>(
            value: kitId,
            underline: const SizedBox(),
            isExpanded: true,
            items: kits.map<DropdownMenuItem<String>>((k) {
              final id = k["id"] as String;
              final name = k["name"] as String? ?? id;
              return DropdownMenuItem(value: id, child: Text(name));
            }).toList(),
            onChanged: (v) async {
              if (v != null && v != kitId) {
                setState(() => kitId = v);
                await ref
                    .read(monitorTelemetryProvider(v).notifier)
                    .switchKit(v);
              }
            },
          ),
        );
      },
    );
  }

  // GAUGE BOX
  Widget _gaugeBox(
    double s,
    String label,
    double value,
    String unit,
    double fraction,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * s),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8 * s,
            offset: Offset(0, 4 * s),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(12 * s, 12 * s, 12 * s, 10 * s),
      child: Column(
        children: [
          SizedBox(
            width: 75 * s,
            height: 75 * s,
            child: CustomPaint(
              painter: _ArcPainter(
                color: const Color(0xFF154B2E),
                fraction: fraction,
                strokeFactor: 0.12,
              ),
            ),
          ),
          SizedBox(height: 6 * s),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value.toStringAsFixed(label == 'pH' ? 2 : 1),
                style: TextStyle(
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF154B2E),
                ),
              ),
              if (unit.isNotEmpty) const SizedBox(width: 4),
              if (unit.isNotEmpty)
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 12 * s,
                    color: const Color(0xFF7A7A7A),
                  ),
                ),
            ],
          ),
          SizedBox(height: 6 * s),
          Text(
            label,
            style: TextStyle(
              fontSize: 13 * s,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF154B2E),
            ),
          ),
        ],
      ),
    );
  }

  // MODE & CONTROL
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
        SizedBox(height: 14 * s),

        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => isAuto = true);
                  ref
                      .read(monitorTelemetryProvider(currentKitId).notifier)
                      .setAuto();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14 * s),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14 * s),
                    border: Border.all(
                      color: isAuto ? primary : Colors.grey.shade300,
                      width: isAuto ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "AUTO",
                      style: TextStyle(
                        fontSize: 15 * s,
                        fontWeight: FontWeight.w700,
                        color: isAuto ? primary : muted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12 * s),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => isAuto = false);
                  ref
                      .read(monitorTelemetryProvider(currentKitId).notifier)
                      .setManual();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14 * s),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14 * s),
                    border: Border.all(
                      color: !isAuto ? primary : Colors.grey.shade300,
                      width: !isAuto ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "MANUAL",
                      style: TextStyle(
                        fontSize: 15 * s,
                        fontWeight: FontWeight.w700,
                        color: !isAuto ? primary : muted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 18 * s),

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

        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 16 * s),
          child: Text(
            "SOON",
            style: TextStyle(
              fontSize: 18 * s,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _manualBtn(double s, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16 * s),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16 * s),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16 * s),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8 * s,
              offset: Offset(0, 4 * s),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15 * s,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF154B2E),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final Color color;
  final double fraction;
  final double strokeFactor;

  _ArcPainter({
    required this.color,
    required this.fraction,
    this.strokeFactor = 0.12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * strokeFactor;

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = const Color(0xFFF0F0F0);

    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawArc(rect, 0, 6.28, false, bg);

    final start = 3.14 * 0.75;
    final sweepMax = 3.14 * 0.9;

    canvas.drawArc(rect, start, sweepMax * fraction, false, fg);
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.fraction != fraction || old.color != color;
}
