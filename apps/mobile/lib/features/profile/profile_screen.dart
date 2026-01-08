import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/app/routes.dart';
import 'package:fountaine/providers/provider/auth_provider.dart';
import 'package:fountaine/providers/provider/api_provider.dart';
import 'package:fountaine/l10n/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // FETCH kits dari backend
    final kitsAsync = ref.watch(apiKitsListProvider);

    final email = user?.email ?? '-';
    final uid = user?.uid ?? '-';

    final inferredName =
        (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
        ? user.displayName!.trim()
        : (email != '-' ? email.split('@').first : l10n.profileTitle);

    final name = inferredName;

    final s = MediaQuery.of(context).size.width / 375.0;

    // KIT dari backend
    String kitName = l10n.profileDefaultKitName;
    String kitId = l10n.profileDefaultKitId;

    // Get currently selected kit from monitor screen
    final currentKitId = ref.watch(currentKitIdProvider);

    kitsAsync.whenData((data) {
      if (data.isNotEmpty) {
        // Find kit matching currentKitIdProvider, fallback to first kit
        final selectedKit = data.firstWhere(
          (k) => k["id"] == currentKitId,
          orElse: () => data.first,
        );
        kitName = selectedKit["name"] as String? ?? l10n.profileDefaultKitName;
        kitId = selectedKit["id"] as String? ?? l10n.profileDefaultKitId;
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20 * s, vertical: 14 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  _pillIconButton(
                    context: context,
                    s: s,
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.maybePop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        l10n.profileTitle,
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

              SizedBox(height: 24 * s),

              // AVATAR + NAME
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(3 * s),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.primary.withValues(alpha: 0.8),
                            colorScheme.primary,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 16 * s,
                            offset: Offset(0, 8 * s),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 46 * s,
                        backgroundColor: colorScheme.surface,
                        child: CircleAvatar(
                          radius: 42 * s,
                          backgroundColor: colorScheme.primary,
                          child: Icon(
                            Icons.person,
                            size: 46 * s,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10 * s),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18 * s,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (email != '-')
                      Padding(
                        padding: EdgeInsets.only(top: 4 * s),
                        child: Text(
                          email,
                          style: TextStyle(
                            fontSize: 13 * s,
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 22 * s),

              // KIT BADGE
              _kitBadge(context, kitName, s, l10n),

              SizedBox(height: 14 * s),

              // INFO CARD
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(18 * s),
                  border: Border.all(color: colorScheme.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12 * s,
                      offset: Offset(0, 6 * s),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _infoTile(
                      context: context,
                      s: s,
                      icon: Icons.badge_outlined,
                      label: l10n.profileUserId,
                      value: uid,
                    ),
                    _divider(context, s),
                    _infoTile(
                      context: context,
                      s: s,
                      icon: Icons.email_outlined,
                      label: l10n.profileEmail,
                      value: email,
                    ),
                    _divider(context, s),
                    _infoTile(
                      context: context,
                      s: s,
                      icon: Icons.view_in_ar_outlined,
                      label: l10n.profileKitName,
                      value: kitName,
                    ),
                    _divider(context, s),
                    _infoTile(
                      context: context,
                      s: s,
                      icon: Icons.qr_code_2_outlined,
                      label: l10n.profileKitId,
                      value: kitId,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24 * s),

              // EDIT & LOGOUT
              _primaryButton(
                context: context,
                s: s,
                label: l10n.profileEditProfile,
                onTap: () => Navigator.pushNamed(context, Routes.settings),
              ),
              SizedBox(height: 12 * s),
              _ghostButton(
                context: context,
                s: s,
                label: l10n.settingsLogout,
                onTap: () async {
                  await ref.read(authProvider.notifier).signOut();
                  
                  // Reset kit state to prevent data leak between accounts
                  ref.read(currentKitIdProvider.notifier).state = null;
                  ref.invalidate(apiKitsListProvider);
                  
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      Routes.login,
                      (r) => false,
                    );
                  }
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // SMALL WIDGETS

  Widget _divider(BuildContext context, double s) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * s),
      child: Divider(height: 1, color: colorScheme.outlineVariant),
    );
  }

  Widget _pillIconButton({
    required BuildContext context,
    required double s,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(22 * s),
      child: InkWell(
        borderRadius: BorderRadius.circular(22 * s),
        onTap: onTap,
        child: Container(
          height: 40 * s,
          width: 40 * s,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22 * s),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10 * s,
                offset: Offset(0, 6 * s),
              ),
            ],
          ),
          child: Icon(icon, color: colorScheme.primary, size: 20 * s),
        ),
      ),
    );
  }

  Widget _kitBadge(BuildContext context, String kitName, double s, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 10 * s),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14 * s),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            height: 10 * s,
            width: 10 * s,
            decoration: BoxDecoration(
              color: Colors.greenAccent.shade400,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 10 * s),
          Expanded(
            child: Text(
              kitName,
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 14 * s,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 6 * s),
            decoration: BoxDecoration(
              color: const Color(0xFFE8FFF3),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF00C853)),
            ),
            child: Text(
              l10n.commonActive,
              style: TextStyle(
                color: const Color(0xFF00A84A),
                fontSize: 11 * s,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile({
    required BuildContext context,
    required double s,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 14 * s),
      child: Row(
        children: [
          Container(
            height: 40 * s,
            width: 40 * s,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12 * s),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 22 * s),
          ),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12 * s, color: colorScheme.onSurfaceVariant),
                ),
                SizedBox(height: 4 * s),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15 * s,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryButton({
    required BuildContext context,
    required double s,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 56 * s,
      child: InkWell(
        borderRadius: BorderRadius.circular(16 * s),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary.withValues(alpha: 0.85),
                colorScheme.primary,
              ],
            ),
            borderRadius: BorderRadius.circular(16 * s),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 16 * s,
                offset: Offset(0, 6 * s),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit_rounded, color: colorScheme.onPrimary),
                SizedBox(width: 10 * s),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16 * s,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _ghostButton({
    required BuildContext context,
    required double s,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 50 * s,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: colorScheme.surface,
          side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.18)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14 * s),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16 * s,
            fontWeight: FontWeight.w800,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
