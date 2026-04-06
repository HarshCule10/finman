import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/services/secure_storage_service.dart';
import '../../data/services/storage_service.dart';
import '../../screens/shell/app_shell.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/pin_input.dart';

/// Lock screen shown on app launch when security is enabled.
/// Adapts between PIN keypad and password field based on stored preference.
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _passwordController = TextEditingController();
  final _pinKey = GlobalKey<PinInputState>();
  bool _isValidating = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _validateCredential(String input) async {
    if (_isValidating) return;
    setState(() {
      _isValidating = true;
      _errorMessage = null;
    });

    final secureStorage = context.read<SecureStorageService>();
    final isValid = await secureStorage.validateCredential(input);

    if (!mounted) return;

    if (isValid) {
      // Navigate to main app, replacing lock screen on the stack
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AppShell()),
      );
    } else {
      setState(() {
        _isValidating = false;
        _errorMessage = 'Incorrect. Please try again.';
      });

      // Shake the PIN dots if in PIN mode
      final storage = context.read<StorageService>();
      if (storage.securityType == 'pin') {
        _pinKey.currentState?.shakeAndClear();
      } else {
        _passwordController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.read<StorageService>();
    final isPinMode = storage.securityType == 'pin';
    final displayName = storage.displayName;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Lock icon
              Icon(
                Icons.lock_rounded,
                size: 48,
                color: AppColors.accent,
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(
                    begin: const Offset(0.7, 0.7),
                    curve: Curves.easeOutBack,
                  ),

              const SizedBox(height: 20),

              // Greeting
              Text(
                displayName.isNotEmpty
                    ? 'Welcome back, $displayName'
                    : 'Welcome back',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.15),

              const SizedBox(height: 8),

              Text(
                isPinMode ? 'Enter your PIN to continue' : 'Enter your password to continue',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textGrey,
                    ),
              )
                  .animate()
                  .fadeIn(delay: 350.ms, duration: 400.ms),

              const Spacer(flex: 1),

              // Input area
              if (isPinMode)
                PinInput(
                  key: _pinKey,
                  onCompleted: _validateCredential,
                )
              else
                _buildPasswordInput(),

              // Error message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: AppColors.expense, fontSize: 13),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.2),
                ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordInput() {
    return Column(
      children: [
        AppTextField(
          label: 'Password',
          hint: 'Enter your password',
          controller: _passwordController,
          obscureText: true,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (v) => _validateCredential(v.trim()),
        ),
        const SizedBox(height: 20),
        AppButton(
          label: 'Unlock',
          isLoading: _isValidating,
          onPressed: () =>
              _validateCredential(_passwordController.text.trim()),
        ),
      ],
    );
  }
}
