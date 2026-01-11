import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends ConsumerWidget {
  LoginScreen({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                // 🔹 LOGO
                Image.asset('assets/images/app_logo.png', height: 360),

                const SizedBox(height: 28),

                // 🔹 TITLE
                Text(
                  'SIGN IN',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 40),

                // 🔹 EMAIL
                _UnderlineInput(
                  controller: emailController,
                  hint: 'Email',
                  icon: Icons.person_outline,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 20),

                // 🔹 PASSWORD
                _UnderlineInput(
                  controller: passwordController,
                  hint: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),

                const SizedBox(height: 8),

                // 🔹 FORGOT PASSWORD (CUSTOM ANIMATION)
                Align(
                  alignment: Alignment.centerRight,
                  child: OpacityTap(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot password?',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 🔹 ERROR
                if (authState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      authState.error!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),

                // 🔹 LOGIN BUTTON (COLOR ANIMATION, NO BORDER)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ColorAnimatedButton(
                    loading: authState.isLoading,
                    onTap: () {
                      ref
                          .read(authProvider.notifier)
                          .login(
                            emailController.text.trim(),
                            passwordController.text.trim(),
                          );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // 🔹 CREATE ACCOUNT (CUSTOM ANIMATION)
                OpacityTap(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SignupScreen()),
                    );
                  },
                  child: Text(
                    'Create account',
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

/// 🔹 UNDERLINE INPUT
class _UnderlineInput extends StatelessWidget {
  const _UnderlineInput({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
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

/// 🔹 LOGIN BUTTON (COLOR-ONLY ANIMATION)
class ColorAnimatedButton extends StatefulWidget {
  const ColorAnimatedButton({
    super.key,
    required this.onTap,
    required this.loading,
  });

  final VoidCallback onTap;
  final bool loading;

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
                'LOGIN',
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

/// 🔹 OPACITY TAP (FOR TEXT LINKS)
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
