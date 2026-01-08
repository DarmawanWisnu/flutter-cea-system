import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/app/routes.dart';
import 'package:fountaine/providers/provider/auth_provider.dart';
import 'package:fountaine/utils/validators.dart';
import 'package:fountaine/utils/firebase_error_handler.dart';
import 'package:fountaine/l10n/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  bool _obscure = true;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final email = _emailCtrl.text.trim();
    final pass = _pwCtrl.text;

    try {
      final auth = ref.read(authProvider.notifier);
      await auth.signIn(email: email, password: pass);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.home);
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
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: CircleAvatar(
                    backgroundColor: colorScheme.surface,
                    radius: 20,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: colorScheme.primary),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  l10n.authLoginTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.authLoginSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                ),

                const SizedBox(height: 36),

                // Email Label
                Text(
                  l10n.authEmailLabel,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),

                // Email Field
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: l10n.authEmailHint,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                    ),
                    validator: (v) => Validators.email(v),
                    onFieldSubmitted: (_) => _loading ? null : _submit(),
                  ),
                ),

                const SizedBox(height: 20),

                // Password Label
                Text(
                  l10n.authPasswordLabel,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),

                // Password Field
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(30),
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                          ),
                          validator: (v) => Validators.password(v),
                          onFieldSubmitted: (_) => _loading ? null : _submit(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          splashRadius: 22,
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Recovery Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, Routes.forgotPassword),
                    child: Text(
                      l10n.authRecoveryPassword,
                      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Sign In Button
                _HoverScaleButton(
                  height: 56,
                  radius: 40,
                  backgroundColor: colorScheme.primary,
                  shadowColor: colorScheme.primary.withValues(alpha: 0.2),
                  pressedScale: 0.985,
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          l10n.authSignIn,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                ),

                const SizedBox(height: 16),

                // Google Button
                _HoverScaleButton(
                  height: 56,
                  radius: 40,
                  backgroundColor: colorScheme.surface,
                  borderColor: Colors.transparent,
                  shadowColor: Colors.black.withValues(alpha: 0.1),
                  pressedScale: 0.985,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/google_logo.png',
                        height: 20,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.g_mobiledata,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        l10n.authSignInGoogle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.commonFeatureComingSoon)),
                    );
                  },
                ),

                const SizedBox(height: 28),

                // Footer
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: l10n.authNoAccount,
                      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                      children: [
                        TextSpan(
                          text: l10n.authSignUpFree,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(context, Routes.register);
                            },
                        ),
                      ],
                    ),
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

class _HoverScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double height;
  final double radius;
  final Color backgroundColor;
  final Color? borderColor;
  final Color shadowColor;
  final double pressedScale;

  const _HoverScaleButton({
    required this.child,
    required this.onPressed,
    required this.height,
    required this.radius,
    required this.backgroundColor,
    required this.shadowColor,
    this.borderColor,
    this.pressedScale = 0.98,
  });

  @override
  State<_HoverScaleButton> createState() => _HoverScaleButtonState();
}

class _HoverScaleButtonState extends State<_HoverScaleButton> {
  bool _hovered = false;
  bool _pressed = false;

  double get _scale => _pressed ? widget.pressedScale : (_hovered ? 1.01 : 1.0);
  double get _elevation => _pressed ? 2 : (_hovered ? 8 : 4);

  @override
  Widget build(BuildContext context) {
    final border = widget.borderColor ?? Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.onPressed == null
                  ? widget.backgroundColor.withValues(alpha: 0.6)
                  : widget.backgroundColor,
              borderRadius: BorderRadius.circular(widget.radius),
              border: Border.all(color: border),
              boxShadow: [
                BoxShadow(
                  color: widget.shadowColor,
                  blurRadius: _elevation + 6,
                  spreadRadius: 0,
                  offset: Offset(0, _elevation),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: widget.onPressed == null ? Colors.white70 : null,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
