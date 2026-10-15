import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/icons.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Enter your email and password.');
      return;
    }
    setState(() => _loading = true);
    final error = await ref
        .read(authControllerProvider.notifier)
        .signIn(email: _email.text, password: _password.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Sign in to your Welrent account',
      error: _error,
      legal: 'By signing in you agree to our ',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthField(
            label: 'Email address',
            controller: _email,
            hint: 'you@example.com',
          ),
          const SizedBox(height: 18),
          AuthField(
            label: 'Password',
            controller: _password,
            hint: '••••••••',
            obscure: true,
            trailing: GestureDetector(
              onTap: () => context.go('/forgot'),
              child: Text(
                'Forgot password?',
                style: AppText.outfit(
                  size: 12.8,
                  weight: FontWeight.w600,
                  color: AppColors.accentBlue,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          AuthButton(label: 'Sign in', loading: _loading, onPressed: _submit),
          const AuthDivider(),
          AuthSwitch(
            text: "Don't have an account? ",
            action: 'Create one free',
            onTap: () => context.go('/register'),
          ),
        ],
      ),
    );
  }
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (_name.text.trim().isEmpty || _email.text.trim().isEmpty) {
      setState(() => _error = 'Enter your name and email.');
      return;
    }
    setState(() => _loading = true);
    final error = await ref
        .read(authControllerProvider.notifier)
        .register(
          name: _name.text,
          email: _email.text,
          password: _password.text,
          confirm: _confirm.text,
        );
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Create your account',
      subtitle: 'Join thousands of drivers across the Netherlands and Belgium',
      error: _error,
      legal: 'By creating an account you agree to our ',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthField(
            label: 'Full name',
            controller: _name,
            hint: 'Jan de Vries',
          ),
          const SizedBox(height: 18),
          AuthField(
            label: 'Email address',
            controller: _email,
            hint: 'you@example.com',
          ),
          const SizedBox(height: 18),
          AuthField(
            label: 'Password',
            controller: _password,
            hint: 'Min. 8 characters',
            obscure: true,
          ),
          const SizedBox(height: 18),
          AuthField(
            label: 'Confirm password',
            controller: _confirm,
            hint: 'Repeat password',
            obscure: true,
          ),
          const SizedBox(height: 20),
          AuthButton(
            label: 'Create account',
            loading: _loading,
            onPressed: _submit,
          ),
          const AuthDivider(),
          AuthSwitch(
            text: 'Already have an account? ',
            action: 'Sign in',
            onTap: () => context.go('/login'),
          ),
        ],
      ),
    );
  }
}

class ForgotScreen extends ConsumerStatefulWidget {
  const ForgotScreen({super.key});

  @override
  ConsumerState<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends ConsumerState<ForgotScreen> {
  final _email = TextEditingController();
  String? _error;
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (_email.text.trim().isEmpty) {
      setState(() => _error = 'Enter your email address.');
      return;
    }
    setState(() => _loading = true);
    final error = await ref
        .read(authControllerProvider.notifier)
        .sendReset(_email.text);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _sent = error == null;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: _sent ? 'Check your email' : 'Forgot password?',
      subtitle: _sent
          ? "We've sent a password reset link to ${_email.text.trim()}. Check your inbox and spam folder."
          : "Enter your email and we'll send you a reset link.",
      error: _sent ? null : _error,
      showLegal: false,
      child: _sent
          ? Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: AppColors.activeBg,
                    shape: BoxShape.circle,
                  ),
                  child: const AppIcon(
                    'mail',
                    size: 28,
                    color: AppColors.accentBlue,
                  ),
                ),
                const SizedBox(height: 28),
                AuthButton(
                  label: 'Back to sign in',
                  onPressed: () => context.go('/login'),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuthField(
                  label: 'Email address',
                  controller: _email,
                  hint: 'you@example.com',
                ),
                const SizedBox(height: 20),
                AuthButton(
                  label: 'Send reset link',
                  loading: _loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 24),
                AuthSwitch(
                  text: 'Remember your password? ',
                  action: 'Sign in',
                  onTap: () => context.go('/login'),
                ),
              ],
            ),
    );
  }
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.error,
    this.legal,
    this.showLegal = true,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final String? error;
  final String? legal;
  final bool showLegal;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: MediaQuery.sizeOf(context).height - 200,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0F4FF), Color(0xFFF8F9FB), Color(0xFFFFF0F6)],
        ),
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40, 60, 40, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandLogo(height: 32),
                const SizedBox(height: 28),
                Text(
                  title,
                  style: AppText.outfit(size: 25.6, weight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: AppText.outfit(
                    size: 14.4,
                    color: AppColors.textMuted,
                    height: 1.5,
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.errorBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.errorBorder),
                    ),
                    child: Text(
                      error!,
                      style: AppText.outfit(size: 13.6, color: AppColors.error),
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                child,
                if (showLegal) ...[
                  const SizedBox(height: 20),
                  Text.rich(
                    TextSpan(
                      style: AppText.outfit(
                        size: 12.5,
                        color: AppColors.fieldText,
                        height: 1.6,
                      ),
                      children: [
                        TextSpan(text: legal ?? ''),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () => context.go('/terms'),
                            child: Text(
                              'Terms of Service',
                              style: AppText.outfit(
                                size: 12.5,
                                weight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () => context.go('/privacy'),
                            child: Text(
                              'Privacy Policy',
                              style: AppText.outfit(
                                size: 12.5,
                                weight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.trailing,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppText.outfit(size: 13.1, weight: FontWeight.w700),
            ),
            const Spacer(),
            ?trailing,
          ],
        ),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: AppText.outfit(size: 17.6),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppText.outfit(size: 17.6, color: AppColors.placeholder),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0x1A1C263A), width: 2),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0x1A1C263A), width: 2),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.accentBlue, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return HoverButton(
      onPressed: loading ? null : onPressed,
      enabled: !loading,
      background: AppColors.textPrimary,
      hoverBackground: const Color(0xFF2D3A54),
      radius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 14),
      shadow: const [
        BoxShadow(
          color: Color(0x331C263A),
          blurRadius: 15,
          offset: Offset(0, 4),
        ),
      ],
      child: loading
          ? const AppSpinner(size: 18)
          : Text(
              label,
              style: AppText.outfit(
                size: 16,
                weight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
    );
  }
}

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          Container(width: 40, height: 1, color: const Color(0x1A1C263A)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'or',
              style: AppText.outfit(size: 12.8, color: AppColors.textMuted),
            ),
          ),
          Container(width: 40, height: 1, color: const Color(0x1A1C263A)),
        ],
      ),
    );
  }
}

class AuthSwitch extends StatelessWidget {
  const AuthSwitch({
    super.key,
    required this.text,
    required this.action,
    required this.onTap,
  });

  final String text;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text.rich(
        TextSpan(
          style: AppText.outfit(size: 14, color: AppColors.textMuted),
          children: [
            TextSpan(text: text),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: onTap,
                child: Text(
                  action,
                  style: AppText.outfit(
                    size: 14,
                    weight: FontWeight.w700,
                    color: AppColors.accentBlue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
