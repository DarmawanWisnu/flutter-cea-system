import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/providers/provider/monitor_provider.dart';
import 'package:fountaine/providers/provider/api_provider.dart';
import '../../domain/telemetry.dart';

final kitsProvider = FutureProvider.autoDispose((ref) async {
  final api = ref.watch(apiServiceProvider);
  final result = await api.getJson("/kits");

  return (result as List)
      .map((e) => Kit(id: e['id'], name: e['name']))
      .toList();
});

class Kit {
  final String id;
  final String name;

  Kit({required this.id, required this.name});
}

class MonitorScreen extends ConsumerStatefulWidget {
  final String? selectedKit;

  const MonitorScreen({super.key, this.selectedKit});

  @override
  ConsumerState<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends ConsumerState<MonitorScreen> {
  late String kitId;
  bool isAuto = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final kits = await ref.read(apiKitsListProvider.future);

      if (kits.isEmpty) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, "/addkit");
        }
        return;
      }

      kitId = widget.selectedKit ?? kits.first["id"];
      setState(() {});
    });

    kitId = widget.selectedKit ?? "devkit-01";
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(monitorTelemetryProvider(kitId));

    const bg = Color(0xFFF6FBF6);
    const primary = Color(0xFF154B2E);
    const muted = Color(0xFF7A7A7A);

    final size = MediaQuery.of(context).size;
    final s = size.width / 375.0;

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
                            kitId,
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

              _modeSection(context, s),
            ],
          ),
        ),
      ),
    );
  }

  // KIT SELECTOR
  Widget _kitSelector(double s) {
    return Consumer(
      builder: (context, ref, _) {
        final kitsAsync = ref.watch(kitsProvider);

        return kitsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
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
                items: kits
                    .map(
                      (k) => DropdownMenuItem(value: k.id, child: Text(k.name)),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      kitId = v;
                    });
                  }
                },
              ),
            );
          },
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
  Widget _modeSection(BuildContext context, double s) {
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
                onTap: () => setState(() => isAuto = true),
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
                onTap: () => setState(() => isAuto = false),
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
                  Expanded(child: _manualBtn(s, "PH UP")),
                  SizedBox(width: 12 * s),
                  Expanded(child: _manualBtn(s, "PH DOWN")),
                ],
              ),
              SizedBox(height: 12 * s),
              Row(
                children: [
                  Expanded(child: _manualBtn(s, "NUTRIENT")),
                  SizedBox(width: 12 * s),
                  Expanded(child: _manualBtn(s, "REFILL")),
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

  Widget _manualBtn(double s, String label) {
    return Container(
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
    );
  }
}

// GAUGE ARC
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
