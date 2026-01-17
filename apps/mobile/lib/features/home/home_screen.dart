import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/app/routes.dart';
import 'package:fountaine/features/home/widgets/monitoring_info_bottom_sheet.dart';
import 'package:fountaine/l10n/app_localizations.dart';
import 'package:fountaine/providers/provider/location_provider.dart';
import 'package:fountaine/providers/provider/weather_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = MediaQuery.of(context).size.width / 375.0;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Watch location and weather providers
    final location = ref.watch(locationProvider);
    final weather = ref.watch(weatherProvider);

    Widget featureCard({
      required String title,
      required String subtitle,
      required String assetImage,
      required VoidCallback onTap,
      VoidCallback? onLongPress,
    }) {
      return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16 * s),
          ),
          padding: EdgeInsets.all(12 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18 * s,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(height: 6 * s),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13 * s,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12 * s),
                  child: Image.asset(
                    assetImage,
                    width: 110 * s,
                    height: 90 * s,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 110 * s,
                      height: 90 * s,
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.image,
                        size: 32 * s,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    void showMonitoringInfoSheet() {
      MonitoringInfoBottomSheet.show(context);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER HERO
            SizedBox(
              height: 180 * s,
              child: Stack(
                children: [
                  // hero background - dynamic gradient based on time
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(28 * s),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _getWeatherGradient(weather.effectiveWeather),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // location block
                  Positioned(
                    top: 60 * s,
                    left: 0,
                    right: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.homeYourLocation,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12 * s,
                          ),
                        ),
                        SizedBox(height: 6 * s),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.redAccent,
                              size: 16 * s,
                            ),
                            SizedBox(width: 6 * s),
                            Text(
                              location.cityName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16 * s,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Weather card overlapping - tap to refresh
            Transform.translate(
              offset: Offset(0, -28 * s),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18 * s),
                child: GestureDetector(
                  onTap: () => ref.read(weatherProvider.notifier).refreshAll(),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18 * s,
                      vertical: 16 * s,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16 * s),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Left side: Time and Date
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatTime(),
                              style: TextStyle(
                                fontSize: 24 * s,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                                height: 1.1,
                              ),
                            ),
                            SizedBox(height: 2 * s),
                            Text(
                              _formatDate(l10n),
                              style: TextStyle(
                                fontSize: 13 * s,
                                color: colorScheme.primary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Right side: Weather icon, description, temp
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(
                              _getWeatherIcon(weather.effectiveWeather),
                              size: 36 * s,
                              color: colorScheme.primary,
                            ),
                            SizedBox(height: 4 * s),
                            weather.isLoading
                                ? SizedBox(
                                    width: 16 * s,
                                    height: 16 * s,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colorScheme.primary,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _getWeatherDescription(
                                          weather.effectiveWeather,
                                          l10n,
                                        ),
                                        style: TextStyle(
                                          fontSize: 13 * s,
                                          color: colorScheme.primary.withValues(
                                            alpha: 0.7,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8 * s),
                                      Text(
                                        '${weather.temperature.round()}°C',
                                        style: TextStyle(
                                          fontSize: 16 * s,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 8 * s),

            // Section title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 22 * s),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.homeAllFeatures,
                  style: TextStyle(
                    fontSize: 18 * s,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),

            SizedBox(height: 12 * s),

            // Grid 2x2
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 18 * s,
                ).copyWith(bottom: 18 * s),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14 * s,
                  crossAxisSpacing: 12 * s,
                  childAspectRatio: 0.82,
                  children: [
                    featureCard(
                      title: l10n.homeMonitoring,
                      subtitle: l10n.homeMonitoringDesc,
                      assetImage: 'assets/images/feature_monitor.png',
                      onTap: () => Navigator.pushNamed(context, Routes.monitor),
                      onLongPress: showMonitoringInfoSheet,
                    ),
                    featureCard(
                      title: l10n.homeNotification,
                      subtitle: l10n.homeNotificationDesc,
                      assetImage: 'assets/images/feature_notification.png',
                      onTap: () => Navigator.pushNamed(context, Routes.history),
                    ),
                    featureCard(
                      title: l10n.homeAddKit,
                      subtitle: l10n.homeAddKitDesc,
                      assetImage: 'assets/images/feature_addkit.png',
                      onTap: () => Navigator.pushNamed(context, Routes.addKit),
                    ),
                    featureCard(
                      title: l10n.homeSetting,
                      subtitle: l10n.homeSettingDesc,
                      assetImage: 'assets/images/feature_setting.png',
                      onTap: () =>
                          Navigator.pushNamed(context, Routes.settings),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom navigation with center QR button
      bottomNavigationBar: SizedBox(
        height: 84 * s,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // background rounded bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 64 * s,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(22 * s),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28 * s),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Home icon
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(
                          context,
                          Routes.home,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home_outlined,
                              color: colorScheme.primary,
                              size: 26 * s,
                            ),
                            SizedBox(height: 6 * s),
                            Container(
                              width: 6 * s,
                              height: 6 * s,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // People -> monitor
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, Routes.monitor),
                        child: Icon(
                          Icons.dashboard_outlined,
                          color: colorScheme.onSurfaceVariant,
                          size: 26 * s,
                        ),
                      ),

                      // spacer for center button
                      SizedBox(width: 56 * s),

                      // Tree -> notification/history
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, Routes.history),
                        child: Icon(
                          Icons.history_outlined,
                          color: colorScheme.onSurfaceVariant,
                          size: 26 * s,
                        ),
                      ),

                      // Profile -> settings
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, Routes.settings),
                        child: Icon(
                          Icons.settings_outlined,
                          color: colorScheme.onSurfaceVariant,
                          size: 26 * s,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // center floating QR button
            Positioned(
              top: 0,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, Routes.addKit),
                child: Container(
                  width: 72 * s,
                  height: 72 * s,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.18),
                        blurRadius: 18 * s,
                        offset: Offset(0, 8 * s),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.qr_code_2,
                      color: colorScheme.onPrimary,
                      size: 30 * s,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get gradient colors based on effective weather and time of day
  List<Color> _getWeatherGradient(EffectiveWeatherType weather) {
    final hour = DateTime.now().hour;

    // Weather-based gradients (priority over time)
    switch (weather) {
      case EffectiveWeatherType.thunderstorm:
        // Dark stormy colors
        return const [Color(0xFF2D3436), Color(0xFF636E72)];

      case EffectiveWeatherType.heavyRain:
        // Dark gray rainy colors
        return const [Color(0xFF3D5A73), Color(0xFF5D768E)];

      case EffectiveWeatherType.rain:
        // Gray rainy colors
        return const [Color(0xFF4B6584), Color(0xFF778CA3)];

      case EffectiveWeatherType.drizzle:
        // Light gray colors
        return const [Color(0xFF6D8299), Color(0xFF8FA4B8)];

      case EffectiveWeatherType.snow:
        // Cool white/blue
        return const [Color(0xFFB8C6DB), Color(0xFFF5F7FA)];

      case EffectiveWeatherType.foggy:
        // Misty colors
        return const [Color(0xFF8395A7), Color(0xFFC8D6E5)];

      case EffectiveWeatherType.partlyCloudy:
        // Slightly muted colors based on time
        if (hour >= 17 || hour < 7) {
          return const [Color(0xFF4B6584), Color(0xFF576574)];
        }
        return const [Color(0xFF74B9FF), Color(0xFFA29BFE)];

      case EffectiveWeatherType.clear:
        // Bright colors based on time of day
        if (hour >= 5 && hour < 7) {
          // Dawn - soft orange to pink
          return const [Color(0xFFFF9A8B), Color(0xFFFF6A88)];
        } else if (hour >= 7 && hour < 12) {
          // Morning - light blue to cyan
          return const [Color(0xFF74EBD5), Color(0xFFACB6E5)];
        } else if (hour >= 12 && hour < 17) {
          // Afternoon - sky blue to deeper blue
          return const [Color(0xFF56CCF2), Color(0xFF2F80ED)];
        } else if (hour >= 17 && hour < 20) {
          // Evening - orange to purple sunset
          return const [Color(0xFFFFA751), Color(0xFFFFE259)];
        } else {
          // Night - dark blue to purple
          return const [Color(0xFF2C3E50), Color(0xFF4CA1AF)];
        }
    }
  }

  /// Get weather icon based on effective weather type
  IconData _getWeatherIcon(EffectiveWeatherType weather) {
    switch (weather) {
      case EffectiveWeatherType.clear:
        return Icons.wb_sunny;
      case EffectiveWeatherType.partlyCloudy:
        return Icons.cloud;
      case EffectiveWeatherType.foggy:
        return Icons.foggy;
      case EffectiveWeatherType.drizzle:
        return Icons.grain;
      case EffectiveWeatherType.rain:
      case EffectiveWeatherType.heavyRain:
        return Icons.water_drop;
      case EffectiveWeatherType.snow:
        return Icons.ac_unit;
      case EffectiveWeatherType.thunderstorm:
        return Icons.flash_on;
    }
  }

  /// Format current time hour:minute with timezone (WIB/WITA/WIT)
  String _formatTime() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');

    String timezone = '';
    final offset = now.timeZoneOffset.inHours;
    if (offset == 7) {
      timezone = 'WIB';
    } else if (offset == 8) {
      timezone = 'WITA';
    } else if (offset == 9) {
      timezone = 'WIT';
    }

    return '$hour:$minute $timezone';
  }

  /// Format date like "Jum, 09 Januari"
  String _formatDate(AppLocalizations l10n) {
    final now = DateTime.now();

    String dayName;
    switch (now.weekday) {
      case DateTime.monday:
        dayName = l10n.dayMon;
        break;
      case DateTime.tuesday:
        dayName = l10n.dayTue;
        break;
      case DateTime.wednesday:
        dayName = l10n.dayWed;
        break;
      case DateTime.thursday:
        dayName = l10n.dayThu;
        break;
      case DateTime.friday:
        dayName = l10n.dayFri;
        break;
      case DateTime.saturday:
        dayName = l10n.daySat;
        break;
      case DateTime.sunday:
        dayName = l10n.daySun;
        break;
      default:
        dayName = '';
    }

    String monthName;
    switch (now.month) {
      case DateTime.january:
        monthName = l10n.monthJan;
        break;
      case DateTime.february:
        monthName = l10n.monthFeb;
        break;
      case DateTime.march:
        monthName = l10n.monthMar;
        break;
      case DateTime.april:
        monthName = l10n.monthApr;
        break;
      case DateTime.may:
        monthName = l10n.monthMay;
        break;
      case DateTime.june:
        monthName = l10n.monthJun;
        break;
      case DateTime.july:
        monthName = l10n.monthJul;
        break;
      case DateTime.august:
        monthName = l10n.monthAug;
        break;
      case DateTime.september:
        monthName = l10n.monthSep;
        break;
      case DateTime.october:
        monthName = l10n.monthOct;
        break;
      case DateTime.november:
        monthName = l10n.monthNov;
        break;
      case DateTime.december:
        monthName = l10n.monthDec;
        break;
      default:
        monthName = '';
    }

    return '$dayName, ${now.day.toString().padLeft(2, '0')} $monthName';
  }

  /// Get localized weather description based on effective weather type
  String _getWeatherDescription(
    EffectiveWeatherType weather,
    AppLocalizations l10n,
  ) {
    switch (weather) {
      case EffectiveWeatherType.clear:
        return l10n.weatherClear;
      case EffectiveWeatherType.partlyCloudy:
        return l10n.weatherPartlyCloudy;
      case EffectiveWeatherType.foggy:
        return l10n.weatherFoggy;
      case EffectiveWeatherType.drizzle:
        return l10n.weatherDrizzle;
      case EffectiveWeatherType.rain:
        return l10n.weatherRain;
      case EffectiveWeatherType.heavyRain:
        return l10n.weatherHeavyRain;
      case EffectiveWeatherType.snow:
        return l10n.weatherSnow;
      case EffectiveWeatherType.thunderstorm:
        return l10n.weatherThunderstorm;
    }
  }
}
