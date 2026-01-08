import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/app/routes.dart';
import 'package:fountaine/utils/validators.dart';
import 'package:fountaine/providers/provider/auth_provider.dart';
import 'package:fountaine/utils/firebase_error_handler.dart';
import 'package:fountaine/l10n/app_localizations.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscure = true;

  Future<void> _doRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailCtrl.text.trim();
    final pw = _pwCtrl.text;

    setState(() => _loading = true);
    try {
      final auth = ref.read(authProvider.notifier);
      await auth.register(email: email, password: pw);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.verify);
    } catch (e) {
      if (!mounted) return;

      final (title, message) = FirebaseErrorHandler.handleAuthException(e);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(message),
            ],
          ),
          backgroundColor: FirebaseErrorHandler.isNetworkError(e)
              ? Colors.orange.shade700
              : Colors.red.shade700,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
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
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: CircleAvatar(
                    backgroundColor: colorScheme.surface,
                    radius: 20 * s,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: colorScheme.primary,
                        size: 20 * s,
                      ),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  ),
                ),

                SizedBox(height: 24 * s),

                // Title
                Text(
                  l10n.authRegisterTitle,
                  style: TextStyle(
                    fontSize: 32 * s,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 6 * s),
                Text(
                  l10n.authRegisterSubtitle,
                  style: TextStyle(fontSize: 14 * s, color: colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 28 * s),

                // Name
                Text(
                  l10n.authNameLabel,
                  style: TextStyle(
                    fontSize: 16 * s,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(height: 8 * s),
                _roundedField(
                  context: context,
                  controller: _nameCtrl,
                  hint: l10n.authNameHint,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.validationNameEmpty
                      : null,
                ),

                SizedBox(height: 18 * s),

                // Email
                Text(
                  l10n.authEmailLabel,
                  style: TextStyle(
                    fontSize: 16 * s,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(height: 8 * s),
                _roundedField(
                  context: context,
                  controller: _emailCtrl,
                  hint: l10n.authEmailHint,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => Validators.email(v),
                ),

                SizedBox(height: 18 * s),

                // Password
                Text(
                  l10n.authPasswordLabel,
                  style: TextStyle(
                    fontSize: 16 * s,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(height: 8 * s),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(28 * s),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _pwCtrl,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            hintText: l10n.authPasswordHint,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20 * s,
                              vertical: 18 * s,
                            ),
                          ),
                          validator: (v) => Validators.password(v),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 12 * s),
                        child: IconButton(
                          splashRadius: 22 * s,
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                            color: colorScheme.primary,
                            size: 22 * s,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 18 * s),

                // Location
                Text(
                  l10n.authLocationLabel,
                  style: TextStyle(
                    fontSize: 16 * s,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(height: 8 * s),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(28 * s),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _locationCtrl,
                          decoration: InputDecoration(
                            hintText: l10n.authLocationHint,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20 * s,
                              vertical: 18 * s,
                            ),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? l10n.validationLocationEmpty
                              : null,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 12 * s),
                        child: Icon(
                          Icons.location_on,
                          color: colorScheme.primary,
                          size: 22 * s,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 22 * s),

                // Sign Up button
                SizedBox(
                  height: 56 * s,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _doRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40 * s),
                      ),
                      elevation: 4,
                    ),
                    child: _loading
                        ? CircularProgressIndicator(color: colorScheme.onPrimary)
                        : Text(
                            l10n.authSignUp,
                            style: TextStyle(
                              fontSize: 18 * s,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: 16 * s),

                // Google Sign-in
                SizedBox(
                  height: 56 * s,
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.commonFeatureComingSoon)),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40 * s),
                      ),
                      side: const BorderSide(color: Colors.transparent),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/google_logo.png',
                          height: 20 * s,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.g_mobiledata,
                            size: 20 * s,
                            color: colorScheme.primary,
                          ),
                        ),
                        SizedBox(width: 10 * s),
                        Text(
                          l10n.authSignInGoogle,
                          style: TextStyle(
                            fontSize: 16 * s,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 28 * s),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roundedField({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
