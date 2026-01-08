import 'package:flutter/widgets.dart';
import 'package:fountaine/l10n/app_localizations.dart';

/// Extension for easy access to localization strings
/// Usage: context.l10n.settingsTitle
extension L10nExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
