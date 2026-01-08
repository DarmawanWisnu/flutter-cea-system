import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fountaine/app/routes.dart';
import 'package:fountaine/providers/provider/auth_provider.dart';
import 'package:fountaine/l10n/app_localizations.dart';

class VerifyScreen extends ConsumerStatefulWidget {
  const VerifyScreen({super.key});

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  bool _isWorking = false;
  bool _showTips = false;

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openMailApp() async {
    final uri = Uri.parse('https://mail.google.com/');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) _showSnack('Failed to open email. Try opening manually.');
    } catch (e) {
      _showSnack('Failed to open email. Error: $e');
    }
  }

  Future<void> _copyEmail(String email) async {
    await Clipboard.setData(ClipboardData(text: email));
    _showSnack('Email copied to clipboard');
  }

  Future<void> _resend() async {
    setState(() => _isWorking = true);
    try {
      await ref.read(authProvider.notifier).sendEmailVerification();
      _showSnack('Verification email sent. Check your inbox/spam.');
    } catch (e) {
      _showSnack('Failed to send verification: $e');
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _refresh() async {
    setState(() => _isWorking = true);
    try {
      await ref.read(authProvider.notifier).reloadUser();
      final user = ref.read(authProvider);
      if (user != null && user.emailVerified) {
        if (!mounted) return;
        _showSnack('Verification detected. Welcome!');
        Navigator.pushReplacementNamed(context, Routes.home);
        return;
      }
      _showSnack('Not verified yet. Try again in a few seconds.');
    } catch (e) {
      _showSnack('Failed to load status: $e');
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _logout() async {
    setState(() => _isWorking = true);
    try {
      await ref.read(authProvider.notifier).signOut();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.login);
    } catch (e) {
      _showSnack('Failed to logout: $e');
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 375.0;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authProvider);
    final email = user?.email ?? '—';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * s, vertical: 16 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: back & logout
              Row(
                children: [
                  Material(
                    color: colorScheme.surface,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.maybePop(context),
                      child: Padding(
                        padding: EdgeInsets.all(8 * s),
                        child: Icon(
                          Icons.arrow_back,
                          color: colorScheme.primary,
                          size: 20 * s,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _isWorking ? null : _logout,
                    icon: const Icon(Icons.logout),
                    label: Text(l10n.authLogout),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Banner
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 22 * s,
                  horizontal: 16 * s,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10 * s),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.asset(
                        'assets/images/app_name.png',
                        height: 36 * s,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(width: 12 * s),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fountaine',
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.authVerifyBanner,
                            style: TextStyle(
                              color: colorScheme.onPrimary.withValues(alpha: 0.7),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Title
              Center(
                child: Text(
                  l10n.authVerifyTitle,
                  style: TextStyle(
                    fontSize: 20 * s,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Description + user email
              Center(
                child: Text(
                  l10n.authVerifyDesc(email),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14 * s,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Action chips
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.copy, size: 18),
                    label: Text(l10n.authCopyEmail),
                    onPressed: email == '—' ? null : () => _copyEmail(email),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.mail_outline, size: 18),
                    label: Text(l10n.authOpenEmail),
                    onPressed: _isWorking ? null : _openMailApp,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Resend button
              SizedBox(
                height: 52 * s,
                child: ElevatedButton.icon(
                  onPressed: _isWorking ? null : _resend,
                  icon: const Icon(Icons.send_outlined, size: 18),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14 * s),
                    ),
                    elevation: 6,
                  ),
                  label: _isWorking
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          l10n.authResendEmail,
                          style: TextStyle(
                            fontSize: 16 * s,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: _isWorking ? null : _refresh,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.authRefreshStatus),
              ),

              const SizedBox(height: 16),

              // Tips expandable
              Card(
                elevation: 2,
                color: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14 * s,
                    vertical: 12 * s,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        onTap: () => setState(() => _showTips = !_showTips),
                        child: Row(
                          children: [
                            Icon(
                              _showTips ? Icons.expand_less : Icons.expand_more,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.authNeedHelp,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      if (_showTips) ...[
                        const SizedBox(height: 8),
                        Text(
                          l10n.authHelpTips,
                          style: TextStyle(
                            fontSize: 13 * s,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Back to Login
              Center(
                child: TextButton(
                  onPressed: _isWorking
                      ? null
                      : () => Navigator.pushReplacementNamed(
                            context,
                            Routes.login,
                          ),
                  child: Text(
                    l10n.authBackToLogin,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
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
