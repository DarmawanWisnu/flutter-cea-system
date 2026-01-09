import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/app/routes.dart';
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
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16 * s),
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
                style: TextStyle(fontSize: 13 * s, color: colorScheme.onSurfaceVariant),
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
                      child: Icon(Icons.image, size: 32 * s, color: colorScheme.primary),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
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
                            colors: _getWeatherGradient(weather.weatherCode),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // top controls
                  Positioned(
                    top: 12 * s,
                    left: 18 * s,
                    right: 18 * s,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white70,
                          radius: 20 * s,
                          child: IconButton(
                            icon: Icon(
                              Icons.grid_view_rounded,
                              color: colorScheme.primary,
                              size: 18 * s,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ],
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
                  onTap: () => ref.read(weatherProvider.notifier).refresh(),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18 * s,
                      vertical: 18 * s,
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            weather.isLoading
                                ? SizedBox(
                                    width: 24 * s,
                                    height: 24 * s,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colorScheme.primary,
                                    ),
                                  )
                                : Text(
                                    '${weather.temperature.round()}°C',
                                    style: TextStyle(
                                      fontSize: 28 * s,
                                      fontWeight: FontWeight.w800,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                            SizedBox(height: 6 * s),
                            Row(
                              children: [
                                Text(
                                  location.cityName,
                                  style: TextStyle(fontSize: 14 * s, color: colorScheme.primary),
                                ),
                                SizedBox(width: 6 * s),
                                Icon(
                                  Icons.refresh,
                                  size: 12 * s,
                                  color: colorScheme.primary.withValues(alpha: 0.5),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Icon(
                          _getWeatherIcon(weather.weatherCode),
                          size: 72 * s,
                          color: colorScheme.primary.withValues(alpha: 0.8),
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
                          Icons.people_outline,
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
                          Icons.park_outlined,
                          color: colorScheme.onSurfaceVariant,
                          size: 26 * s,
                        ),
                      ),

                      // Profile -> settings
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, Routes.settings),
                        child: Icon(
                          Icons.person_outline,
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

  /// Get gradient colors based on weather and time of day
  List<Color> _getWeatherGradient(int weatherCode) {
    final hour = DateTime.now().hour;
    
    // Thunderstorm (95-99) - dark stormy colors
    if (weatherCode >= 95) {
      return const [Color(0xFF2D3436), Color(0xFF636E72)];
    }
    
    // Rain/Drizzle (51-82) - gray rainy colors
    if (weatherCode >= 51 && weatherCode <= 82) {
      return const [Color(0xFF4B6584), Color(0xFF778CA3)];
    }
    
    // Fog (45-48) - misty colors  
    if (weatherCode >= 45 && weatherCode <= 48) {
      return const [Color(0xFF8395A7), Color(0xFFC8D6E5)];
    }
    
    // Cloudy (1-3) - slightly muted colors based on time
    if (weatherCode >= 1 && weatherCode <= 3) {
      if (hour >= 17 || hour < 7) {
        return const [Color(0xFF4B6584), Color(0xFF576574)];
      }
      return const [Color(0xFF74B9FF), Color(0xFFA29BFE)];
    }
    
    // Clear (0) - bright colors based on time
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

  /// Get weather icon based on WMO weather code
  IconData _getWeatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny;
    if (code <= 3) return Icons.cloud;
    if (code <= 48) return Icons.foggy;
    if (code <= 55) return Icons.grain;
    if (code <= 65) return Icons.water_drop;
    if (code <= 75) return Icons.ac_unit;
    if (code <= 82) return Icons.water_drop;
    if (code >= 95) return Icons.flash_on;
    return Icons.cloud;
  }
}
