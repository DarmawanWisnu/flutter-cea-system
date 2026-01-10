import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/app/routes.dart';
import 'package:fountaine/providers/provider/auth_provider.dart';
import 'package:fountaine/providers/provider/url_settings_provider.dart';
import 'package:fountaine/providers/provider/api_provider.dart';
import 'package:fountaine/providers/provider/locale_provider.dart';
import 'package:fountaine/providers/provider/theme_provider.dart';
import 'package:fountaine/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                await ref.read(authProvider.notifier).signOut();

                // Reset kit state to prevent data leak between accounts
                ref.read(currentKitIdProvider.notifier).state = null;
                ref.invalidate(apiKitsListProvider);
              } catch (_) {}

              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.login,
                  (route) => false,
                );
              }
            },
            child: Text(l10n.settingsLogout),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentTheme = ref.read(themeProvider);
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(l10n.themeSelectTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              context,
              ref,
              ThemeMode.light,
              l10n.themeLight,
              currentTheme,
              Icons.light_mode_outlined,
            ),
            _buildThemeOption(
              context,
              ref,
              ThemeMode.dark,
              l10n.themeDark,
              currentTheme,
              Icons.dark_mode_outlined,
            ),
            _buildThemeOption(
              context,
              ref,
              ThemeMode.system,
              l10n.themeSystem,
              currentTheme,
              Icons.settings_suggest_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    ThemeMode mode,
    String label,
    ThemeMode currentTheme,
    IconData icon,
  ) {
    final isSelected = currentTheme == mode;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: colorScheme.primary)
          : null,
      onTap: () {
        ref.read(themeProvider.notifier).setTheme(mode);
        Navigator.pop(context);
      },
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.read(localeProvider);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(l10n.languageSelectTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              context,
              ref,
              const Locale('en'),
              l10n.languageEnglish,
              currentLocale,
              '🇺🇸',
            ),
            _buildLanguageOption(
              context,
              ref,
              const Locale('id'),
              l10n.languageIndonesia,
              currentLocale,
              '🇮🇩',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    WidgetRef ref,
    Locale locale,
    String label,
    Locale currentLocale,
    String flag,
  ) {
    final isSelected = currentLocale.languageCode == locale.languageCode;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: colorScheme.primary)
          : null,
      onTap: () {
        ref.read(localeProvider.notifier).setLocale(locale);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.primary,
                ),
              ),
            ),
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.primary,
                ),
              ),
            ),
            Icon(
              Icons.open_in_new_rounded,
              size: 18,
              color: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final s = MediaQuery.of(context).size.width / 375.0;
    final user = ref.watch(authProvider);

    final email = user?.email ?? '—';
    final name =
        (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
        ? user.displayName!.trim()
        : (email != '—' ? email.split('@').first : 'User');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20 * s, vertical: 14 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.surface,
                    radius: 20 * s,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.arrow_back,
                        color: colorScheme.primary,
                        size: 20 * s,
                      ),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        l10n.settingsTitle,
                        style: TextStyle(
                          fontSize: 20 * s,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 40 * s),
                ],
              ),

              SizedBox(height: 20 * s),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Account Header
                      Container(
                        padding: EdgeInsets.all(16 * s),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(14 * s),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24 * s,
                              backgroundColor: colorScheme.primary,
                              child: Icon(
                                Icons.person,
                                color: colorScheme.onPrimary,
                                size: 24 * s,
                              ),
                            ),
                            SizedBox(width: 12 * s),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 16 * s,
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  SizedBox(height: 2 * s),
                                  Text(
                                    email,
                                    style: TextStyle(
                                      fontSize: 13 * s,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, Routes.profile),
                              child: Text(l10n.commonView),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24 * s),

                      // Account
                      Text(
                        l10n.settingsAccountSetting,
                        style: TextStyle(
                          fontSize: 16 * s,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 12 * s),

                      _buildTile(
                        context: context,
                        icon: Icons.person_outline,
                        label: l10n.settingsProfile,
                        onTap: () =>
                            Navigator.pushNamed(context, Routes.profile),
                      ),
                      _buildTile(
                        context: context,
                        icon: Icons.dark_mode_outlined,
                        label: l10n.settingsTheme,
                        onTap: () => _showThemeDialog(context, ref),
                      ),
                      _buildTile(
                        context: context,
                        icon: Icons.language,
                        label: l10n.settingsChangeLanguage,
                        onTap: () => _showLanguageDialog(context, ref),
                      ),
                      _buildTile(
                        context: context,
                        icon: Icons.eco_outlined,
                        label: l10n.settingsPlantConfiguration,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.commonFeatureComingSoon),
                            ),
                          );
                        },
                      ),
                      _buildTile(
                        context: context,
                        icon: Icons.privacy_tip_outlined,
                        label: l10n.settingsPrivacy,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.commonFeatureComingSoon),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 24 * s),

                      // Legal
                      Text(
                        l10n.settingsLegal,
                        style: TextStyle(
                          fontSize: 16 * s,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 12 * s),

                      _buildLinkTile(
                        context: context,
                        icon: Icons.article_outlined,
                        label: l10n.settingsTerms,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.commonLinkNotSet)),
                          );
                        },
                      ),
                      _buildLinkTile(
                        context: context,
                        icon: Icons.security_outlined,
                        label: l10n.settingsPrivacyPolicy,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.commonLinkNotSet)),
                          );
                        },
                      ),
                      _buildLinkTile(
                        context: context,
                        icon: Icons.info_outline,
                        label: l10n.settingsHelp,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.commonLinkNotSet)),
                          );
                        },
                      ),

                      SizedBox(height: 24 * s),

                      // Logout
                      Center(
                        child: OutlinedButton(
                          onPressed: () => _confirmLogout(context, ref),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: colorScheme.surface,
                            side: BorderSide(
                              color: colorScheme.primary.withValues(alpha: 0.2),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 60 * s,
                              vertical: 14 * s,
                            ),
                          ),
                          child: Text(
                            l10n.settingsLogout,
                            style: TextStyle(
                              fontSize: 16 * s,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 12 * s),
                      Center(
                        child: Text(
                          l10n.settingsVersion('1.0.0'),
                          style: TextStyle(
                            fontSize: 13 * s,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      SizedBox(height: 12 * s),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
