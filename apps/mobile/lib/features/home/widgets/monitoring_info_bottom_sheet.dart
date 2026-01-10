import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fountaine/app/routes.dart';
import 'package:fountaine/core/constants.dart';
import 'package:fountaine/l10n/app_localizations.dart';

/// A modal bottom sheet widget that displays contextual information
/// about the active plant and ideal parameter ranges.
/// 
/// This widget is shown when the user long-presses on the Monitoring card
/// in the home screen. It displays IDEAL values from constants, not realtime data.
class MonitoringInfoBottomSheet extends StatelessWidget {
  /// Whether there's an active kit configured.
  final bool hasActiveKit;

  const MonitoringInfoBottomSheet({
    super.key,
    this.hasActiveKit = true,
  });

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 375.0;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22 * s)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20 * s, 12 * s, 20 * s, 24 * s),
        child: hasActiveKit
            ? _buildContent(context, s, colorScheme, l10n)
            : _buildEmptyState(context, s, colorScheme, l10n),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    double s,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Handle bar
        Center(
          child: Container(
            width: 40 * s,
            height: 4 * s,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2 * s),
            ),
          ),
        ),
        SizedBox(height: 16 * s),

        // Header with plant icon and title
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8 * s),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10 * s),
              ),
              child: Icon(
                Icons.eco_rounded,
                color: colorScheme.primary,
                size: 22 * s,
              ),
            ),
            SizedBox(width: 12 * s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.bottomSheetActivePlant,
                    style: TextStyle(
                      fontSize: 12 * s,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 2 * s),
                  Text(
                    l10n.plantNameLettuce,
                    style: TextStyle(
                      fontSize: 18 * s,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 20 * s),

        // Ideal Parameters Section Title
        Text(
          l10n.bottomSheetIdealParams,
          style: TextStyle(
            fontSize: 14 * s,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        SizedBox(height: 12 * s),

        // Parameter Grid
        Container(
          padding: EdgeInsets.all(14 * s),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12 * s),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _parameterTile(
                      context,
                      s,
                      colorScheme,
                      icon: Icons.science_outlined,
                      label: l10n.bottomSheetPhIdeal,
                      value: '${ThresholdConst.phMin} – ${ThresholdConst.phMax}',
                    ),
                  ),
                  SizedBox(width: 12 * s),
                  Expanded(
                    child: _parameterTile(
                      context,
                      s,
                      colorScheme,
                      icon: Icons.water_drop_outlined,
                      label: l10n.bottomSheetNutrientIdeal,
                      value: '${ThresholdConst.ppmMin.toInt()} – ${ThresholdConst.ppmMax.toInt()}',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12 * s),
              Row(
                children: [
                  Expanded(
                    child: _parameterTile(
                      context,
                      s,
                      colorScheme,
                      icon: Icons.thermostat_outlined,
                      label: l10n.bottomSheetWaterTempIdeal,
                      value: '${ThresholdConst.tempMin.toInt()} – ${ThresholdConst.tempMax.toInt()} °C',
                    ),
                  ),
                  SizedBox(width: 12 * s),
                  Expanded(
                    child: _parameterTileWithInfo(
                      context,
                      s,
                      colorScheme,
                      icon: Icons.waves_outlined,
                      label: l10n.bottomSheetWaterLevelIdeal,
                      value: '${ThresholdConst.wlMin} – ${ThresholdConst.wlMax}',
                      infoTooltip: l10n.bottomSheetWaterLevelInfo,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 20 * s),

        // View Details Button
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, Routes.monitor);
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14 * s),
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12 * s),
              ),
            ),
            child: Text(
              l10n.bottomSheetViewDetails,
              style: TextStyle(
                fontSize: 14 * s,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _parameterTile(
    BuildContext context,
    double s,
    ColorScheme colorScheme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14 * s,
              color: colorScheme.primary.withValues(alpha: 0.7),
            ),
            SizedBox(width: 4 * s),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11 * s,
                  color: colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 4 * s),
        Text(
          value,
          style: TextStyle(
            fontSize: 15 * s,
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _parameterTileWithInfo(
    BuildContext context,
    double s,
    ColorScheme colorScheme, {
    required IconData icon,
    required String label,
    required String value,
    required String infoTooltip,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14 * s,
              color: colorScheme.primary.withValues(alpha: 0.7),
            ),
            SizedBox(width: 4 * s),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11 * s,
                  color: colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 4 * s),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 15 * s,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(width: 4 * s),
            Tooltip(
              message: infoTooltip,
              triggerMode: TooltipTriggerMode.tap,
              showDuration: const Duration(seconds: 2),
              child: Icon(
                Icons.info_outline,
                size: 14 * s,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    double s,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle bar
        Center(
          child: Container(
            width: 40 * s,
            height: 4 * s,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2 * s),
            ),
          ),
        ),
        SizedBox(height: 32 * s),

        Icon(
          Icons.eco_outlined,
          size: 48 * s,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
        SizedBox(height: 16 * s),
        Text(
          l10n.bottomSheetNoActivePlant,
          style: TextStyle(
            fontSize: 16 * s,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        SizedBox(height: 8 * s),
        Text(
          l10n.bottomSheetAddKitFirst,
          style: TextStyle(
            fontSize: 13 * s,
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24 * s),

        // Add Kit Button
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, Routes.addKit);
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14 * s),
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12 * s),
              ),
            ),
            child: Text(
              l10n.homeAddKit,
              style: TextStyle(
                fontSize: 14 * s,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Shows the monitoring info bottom sheet with optional haptic feedback.
  static void show(BuildContext context, {bool hasActiveKit = true}) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) => MonitoringInfoBottomSheet(hasActiveKit: hasActiveKit),
    );
  }
}
