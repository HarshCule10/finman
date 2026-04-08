import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/services/secure_storage_service.dart';
import '../../widgets/pin_input.dart';
import 'set_pin_screen.dart';

/// Screen for verifying the current PIN before allowing changes.
/// Displays a PIN input and validates against SecureStorageService.
class VerifyPINScreen extends StatefulWidget {
  final VoidCallback? onSuccess;
  const VerifyPINScreen({super.key, this.onSuccess});

  @override
  State<VerifyPINScreen> createState() => _VerifyPINScreenState();
}

class _VerifyPINScreenState extends State<VerifyPINScreen> {
  String _pinValue = '';
  String? _errorMessage;
  final _pinInputKey = GlobalKey<PinInputState>();

  Future<void> _verifyPIN() async {
    final secureStorage = context.read<SecureStorageService>();
    final isValid = await secureStorage.validateCredential(_pinValue);

    if (!mounted) return;

    if (isValid) {
      if (widget.onSuccess != null) {
        widget.onSuccess!();
      } else {
        // Navigate to SetPINScreen on success
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const SetPINScreen(isChanging: true),
          ),
        );
      }
    } else {
      // Show error message and shake animation on failure
      setState(() => _errorMessage = 'Incorrect PIN. Please try again.');
      _pinInputKey.currentState?.shakeAndClear();
      
      // Clear error message after a delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _errorMessage = null);
        }
      });
    }
  }

  void _onPINComplete(String pin) {
    setState(() {
      _pinValue = pin;
      _errorMessage = null;
    });
    
    // Automatically verify when PIN is complete
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _verifyPIN();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Current PIN'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              Text(
                'Verify Current PIN',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.2, end: 0),
              
              const SizedBox(height: 12),
              
              // Subtitle
              Text(
                'Enter your current PIN to continue',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textGrey,
                    ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: -0.2, end: 0),
              
              const SizedBox(height: 48),
              
              // PIN Input
              PinInput(
                key: _pinInputKey,
                onCompleted: _onPINComplete,
                onChanged: (v) => setState(() {
                  _pinValue = v;
                  _errorMessage = null;
                }),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 24),
              
              // Error message
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: AppColors.expense,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .shake(hz: 4, curve: Curves.easeInOut),
            ],
          ),
        ),
      ),
    );
  }
}
