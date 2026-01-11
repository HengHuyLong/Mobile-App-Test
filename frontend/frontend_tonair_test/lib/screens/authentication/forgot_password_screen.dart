// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_tonair_test/providers/auth_provider.dart';
import 'package:frontend_tonair_test/screens/authentication/reset_password_screen.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Email is required')));
      return;
    }

    await ref.read(authProvider.notifier).forgotPassword(email);

    final authState = ref.read(authProvider);

    if (authState.error == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResetPasswordScreen(email: email)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'FORGOT PASSWORD',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Enter your email to receive a reset code.',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                _UnderlineInput(
                  controller: emailController,
                  hint: 'Email',
                  icon: Icons.person_outline,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 24),

                if (authState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      authState.error!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ColorAnimatedButton(
                    loading: authState.isLoading,
                    text: 'SEND OTP',
                    onTap: _submit,
                  ),
                ),

                const SizedBox(height: 24),

                OpacityTap(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    'Back to Sign In',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
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

class _UnderlineInput extends StatelessWidget {
  const _UnderlineInput({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: theme.textTheme.bodySmall,
        prefixIcon: Icon(
          icon,
          size: 20,
          color: theme.textTheme.bodySmall?.color,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }
}

class ColorAnimatedButton extends StatefulWidget {
  const ColorAnimatedButton({
    super.key,
    required this.onTap,
    required this.loading,
    required this.text,
  });

  final VoidCallback onTap;
  final bool loading;
  final String text;

  @override
  State<ColorAnimatedButton> createState() => _ColorAnimatedButtonState();
}

class _ColorAnimatedButtonState extends State<ColorAnimatedButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.loading ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.loading ? null : (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.loading ? null : widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        alignment: Alignment.center,
        color: _pressed ? Colors.white : Colors.black,
        child: widget.loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                widget.text,
                style: TextStyle(
                  color: _pressed ? Colors.black : Colors.white,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}

class OpacityTap extends StatefulWidget {
  const OpacityTap({super.key, required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<OpacityTap> createState() => _OpacityTapState();
}

class _OpacityTapState extends State<OpacityTap> {
  double _opacity = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _opacity = 0.5),
      onTapUp: (_) => setState(() => _opacity = 1.0),
      onTapCancel: () => setState(() => _opacity = 1.0),
      onTap: widget.onTap,
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 120),
        child: widget.child,
      ),
    );
  }
}
