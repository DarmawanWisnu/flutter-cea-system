import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/app/routes.dart';
import 'package:fountaine/providers/provider/api_provider.dart';
import 'package:fountaine/providers/provider/auth_provider.dart';
import 'package:fountaine/l10n/app_localizations.dart';

class AddKitScreen extends ConsumerStatefulWidget {
  const AddKitScreen({super.key});

  @override
  ConsumerState<AddKitScreen> createState() => _AddKitScreenState();
}

class _AddKitScreenState extends ConsumerState<AddKitScreen> {
  final _idCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() {
    _idCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (!_formKey.currentState!.validate()) return;

    final id = _idCtrl.text.trim();
    final name = _nameCtrl.text.trim();

    setState(() => _loading = true);

    try {
      final user = ref.read(authProvider);
      if (user == null) {
        throw Exception(l10n.authMustBeLoggedIn);
      }
      
      await ref.read(apiKitsProvider).addKit(
        id: id,
        name: name,
        userId: user.uid,
      );
      
      ref.invalidate(apiKitsListProvider);

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(l10n.commonSuccess),
          content: Text(l10n.addKitSuccess),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.commonOk),
            ),
          ],
        ),
      );

      Navigator.pushReplacementNamed(context, Routes.home);
    } catch (e) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(l10n.commonFailed),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.commonOk),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 375.0;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24 * s, vertical: 28 * s),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: Material(
                    color: colorScheme.surface,
                    shape: const CircleBorder(),
                    elevation: 3,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.maybePop(context),
                      child: Padding(
                        padding: EdgeInsets.all(10 * s),
                        child: Icon(
                          Icons.arrow_back,
                          color: colorScheme.primary,
                          size: 20 * s,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 30 * s),

                // Title
                Text(
                  l10n.addKitTitle,
                  style: TextStyle(
                    fontSize: 32 * s,
                    fontWeight: FontWeight.w900,
                    color: colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 6 * s),
                Text(
                  l10n.addKitSubtitle,
                  style: TextStyle(fontSize: 14 * s, color: colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 36 * s),

                // Input
                _modernField(
                  context: context,
                  s: s,
                  label: l10n.addKitNameLabel,
                  hint: l10n.addKitNameHint,
                  controller: _nameCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.addKitNameRequired
                      : null,
                ),
                SizedBox(height: 20 * s),
                _modernField(
                  context: context,
                  s: s,
                  label: l10n.addKitIdLabel,
                  hint: l10n.addKitIdHint,
                  controller: _idCtrl,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return l10n.addKitIdRequired;
                    }
                    if (v.trim().length < 5) return l10n.addKitIdTooShort;
                    return null;
                  },
                ),

                SizedBox(height: 36 * s),

                // Save button
                _modernSaveButton(
                  context: context,
                  s: s,
                  label: l10n.addKitSaveButton,
                  loadingLabel: l10n.commonSaving,
                  loading: _loading,
                  onTap: _loading ? null : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modernField({
    required BuildContext context,
    required double s,
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15 * s,
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
          ),
        ),
        SizedBox(height: 8 * s),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16 * s),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10 * s,
                offset: Offset(0, 4 * s),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            validator: validator,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 18 * s,
                vertical: 16 * s,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _modernSaveButton({
    required BuildContext context,
    required double s,
    required String label,
    required String loadingLabel,
    required bool loading,
    required VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return SizedBox(
      height: 56 * s,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16 * s),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary.withValues(alpha: 0.9),
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
            child: loading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: colorScheme.onPrimary,
                          strokeWidth: 2.5,
                        ),
                      ),
                      SizedBox(width: 10 * s),
                      Text(
                        loadingLabel,
                        style: TextStyle(
                          fontSize: 16 * s,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_rounded, color: colorScheme.onPrimary),
                      SizedBox(width: 8 * s),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 16 * s,
                          fontWeight: FontWeight.w800,
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
}
